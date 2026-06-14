use std::io::{Cursor, Read};
use std::path::{Path, PathBuf};

use sqlx::MySqlPool;

use crate::app_error::AppError;

use super::skill_model::{
    FileContent, PagedList, Skill, SkillFile, SkillMeta, SkillSummary, UploadResult,
};
use super::skill_repository;

/// 上传 zip 并创建技能
pub async fn upload_skill(
    db: &MySqlPool,
    storage_root: &str,
    zip_bytes: Vec<u8>,
) -> Result<UploadResult, AppError> {
    // 1. 同步部分：解压 zip，提取所有数据
    let (meta, files) = extract_zip_contents(zip_bytes)?;

    // 2. 插入 skills 表
    let tags_str: String = meta.tags.unwrap_or_default().join(",");
    let skill_id: u64 = skill_repository::insert_skill(
        db,
        &meta.name,
        meta.description.as_deref().unwrap_or(""),
        meta.author.as_deref().unwrap_or(""),
        &tags_str,
        meta.icon_url.as_deref().unwrap_or(""),
        meta.source_url.as_deref().unwrap_or(""),
        meta.version.as_deref().unwrap_or("1.0.0"),
        meta.download_url.as_deref().unwrap_or(""),
        "",
    )
    .await?;

    // 3. 创建存储目录
    let storage_path: String = format!("{}", skill_id);
    let skill_dir: PathBuf = Path::new(storage_root).join("skills").join(&storage_path);
    std::fs::create_dir_all(&skill_dir)
        .map_err(|e| AppError::internal(e, "create storage dir"))?;

    // 更新 storage_path
    sqlx::query("UPDATE skills SET storage_path = ? WHERE id = ?")
        .bind(&storage_path)
        .bind(skill_id)
        .execute(db)
        .await?;

    // 4. 写入文件到磁盘 + 数据库
    let mut file_count: u32 = 0;
    let mut total_size: u64 = 0;

    for file_entry in &files {
        let dest_path: PathBuf = skill_dir.join(&file_entry.path);

        if file_entry.is_dir {
            std::fs::create_dir_all(&dest_path)
                .map_err(|e| AppError::internal(e, "create dir"))?;
            skill_repository::insert_file(
                db, skill_id, &file_entry.path, &file_entry.name, 0, true, "",
            )
            .await?;
        } else {
            if let Some(parent) = dest_path.parent() {
                std::fs::create_dir_all(parent)
                    .map_err(|e| AppError::internal(e, "create parent dir"))?;
            }
            std::fs::write(&dest_path, &file_entry.content)
                .map_err(|e| AppError::internal(e, "write file"))?;

            let file_size: u64 = file_entry.content.len() as u64;
            let mime_type: &str = guess_mime_type(&file_entry.name);

            skill_repository::insert_file(
                db, skill_id, &file_entry.path, &file_entry.name, file_size, false, mime_type,
            )
            .await?;

            file_count += 1;
            total_size += file_size;
        }
    }

    // 5. 更新统计
    skill_repository::update_skill_stats(db, skill_id, file_count, total_size).await?;

    Ok(UploadResult {
        id: skill_id,
        name: meta.name,
        file_count,
        total_size,
    })
}

/// 解压文件条目（同步，不跨 await）
struct ZipFileEntry {
    path: String,
    name: String,
    is_dir: bool,
    content: Vec<u8>,
}

/// 同步提取 zip 内容
fn extract_zip_contents(zip_bytes: Vec<u8>) -> Result<(SkillMeta, Vec<ZipFileEntry>), AppError> {
    let cursor = Cursor::new(zip_bytes);
    let mut archive = zip::ZipArchive::new(cursor)
        .map_err(|e| AppError::bad_request(format!("无效的 zip 文件: {}", e)))?;

    // 找 SKILL.md
    let meta: SkillMeta = extract_skill_meta(&mut archive)?;

    // 提取所有文件
    let mut files: Vec<ZipFileEntry> = Vec::new();
    for i in 0..archive.len() {
        let mut entry = archive.by_index(i)
            .map_err(|e| AppError::internal(e, "read zip entry"))?;

        let entry_path: String = entry.name().to_string();
        if entry_path.starts_with("__MACOSX") || entry_path.starts_with("._") {
            continue;
        }

        let file_name: String = Path::new(&entry_path)
            .file_name()
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_default();

        if entry.is_dir() {
            files.push(ZipFileEntry {
                path: entry_path,
                name: file_name,
                is_dir: true,
                content: Vec::new(),
            });
        } else {
            let mut content: Vec<u8> = Vec::new();
            entry.read_to_end(&mut content)
                .map_err(|e| AppError::internal(e, "read zip file"))?;
            files.push(ZipFileEntry {
                path: entry_path,
                name: file_name,
                is_dir: false,
                content,
            });
        }
    }

    Ok((meta, files))
}

/// 从 zip 中提取 SKILL.md 的 front-matter
fn extract_skill_meta(archive: &mut zip::ZipArchive<Cursor<Vec<u8>>>) -> Result<SkillMeta, AppError> {
    // 查找 SKILL.md（可能在根目录或一层子目录下）
    let mut skill_md_content: Option<String> = None;

    for i in 0..archive.len() {
        let mut entry = archive.by_index(i).map_err(|e| AppError::internal(e, "read zip"))?;
        let name: String = entry.name().to_string();

        if name.ends_with("SKILL.md") && !name.contains("__MACOSX") {
            let mut content: String = String::new();
            entry.read_to_string(&mut content)
                .map_err(|e| AppError::internal(e, "read SKILL.md"))?;
            skill_md_content = Some(content);
            break;
        }
    }

    let content: String = skill_md_content
        .ok_or_else(|| AppError::bad_request("zip 中未找到 SKILL.md 文件"))?;

    let meta: SkillMeta = parse_front_matter(&content)
        .ok_or_else(|| AppError::bad_request("SKILL.md 缺少有效的 YAML front-matter"))?;

    if meta.name.trim().is_empty() {
        return Err(AppError::bad_request("SKILL.md front-matter 中 name 不能为空"));
    }

    Ok(meta)
}

/// 解析 YAML front-matter
fn parse_front_matter(content: &str) -> Option<SkillMeta> {
    let trimmed: &str = content.trim_start();
    if !trimmed.starts_with("---") {
        return None;
    }
    let after_first: &str = &trimmed[3..];
    let end_idx: usize = after_first.find("---")?;
    let yaml_str: &str = &after_first[..end_idx];
    serde_yaml::from_str(yaml_str).ok()
}

/// 推断 MIME 类型
fn guess_mime_type(file_name: &str) -> &'static str {
    let ext: &str = file_name.rsplit('.').next().unwrap_or("");
    match ext.to_lowercase().as_str() {
        "md" => "text/markdown",
        "dart" => "text/x-dart",
        "rs" => "text/x-rust",
        "py" => "text/x-python",
        "js" => "text/javascript",
        "ts" => "text/typescript",
        "json" => "application/json",
        "yaml" | "yml" => "text/yaml",
        "toml" => "text/toml",
        "sh" | "bash" => "text/x-shellscript",
        "html" | "htm" => "text/html",
        "css" => "text/css",
        "txt" => "text/plain",
        "xml" | "xsd" => "text/xml",
        "sql" => "text/x-sql",
        "swift" => "text/x-swift",
        "kt" | "kts" => "text/x-kotlin",
        "java" => "text/x-java",
        "go" => "text/x-go",
        "c" | "h" => "text/x-c",
        "cpp" | "cc" | "cxx" => "text/x-cpp",
        _ => "application/octet-stream",
    }
}

/// 列表查询
pub async fn list_skills(
    db: &MySqlPool,
    page: u32,
    page_size: u32,
) -> Result<PagedList<SkillSummary>, AppError> {
    let page: u32 = page.max(1);
    let page_size: u32 = page_size.clamp(1, 100);
    let offset: u32 = (page - 1) * page_size;

    let list: Vec<SkillSummary> = skill_repository::find_published(db, offset, page_size).await?;
    let total: i64 = skill_repository::count_published(db).await?;

    Ok(PagedList {
        list,
        total,
        page,
        page_size,
    })
}

/// 详情查询
pub async fn get_skill(
    db: &MySqlPool,
    storage_root: &str,
    id: u64,
) -> Result<(Skill, String), AppError> {
    let skill: Skill = skill_repository::find_by_id(db, id)
        .await?
        .ok_or_else(|| AppError::not_found("技能不存在"))?;

    // 读取 entry_file 内容
    let file_path: PathBuf = Path::new(storage_root)
        .join("skills")
        .join(&skill.storage_path)
        .join(&skill.entry_file);

    let entry_content: String = std::fs::read_to_string(&file_path).unwrap_or_default();

    Ok((skill, entry_content))
}

/// 文件目录查询
pub async fn get_files(db: &MySqlPool, skill_id: u64) -> Result<Vec<SkillFile>, AppError> {
    // 先确认技能存在
    skill_repository::find_by_id(db, skill_id)
        .await?
        .ok_or_else(|| AppError::not_found("技能不存在"))?;

    let files: Vec<SkillFile> = skill_repository::find_files_by_skill_id(db, skill_id).await?;
    Ok(files)
}

/// 单文件内容查询
pub async fn get_file_content(
    db: &MySqlPool,
    storage_root: &str,
    skill_id: u64,
    file_path: &str,
) -> Result<FileContent, AppError> {
    let skill: Skill = skill_repository::find_by_id(db, skill_id)
        .await?
        .ok_or_else(|| AppError::not_found("技能不存在"))?;

    let full_path: PathBuf = Path::new(storage_root)
        .join("skills")
        .join(&skill.storage_path)
        .join(file_path);

    if !full_path.exists() {
        return Err(AppError::not_found("文件不存在"));
    }

    let mime_type: &str = guess_mime_type(
        full_path.file_name().unwrap_or_default().to_str().unwrap_or(""),
    );

    // 二进制文件不可预览
    if mime_type == "application/octet-stream" {
        return Err(AppError::bad_request("二进制文件不可预览"));
    }

    let content: String = std::fs::read_to_string(&full_path)
        .map_err(|e| AppError::internal(e, "read file content"))?;

    Ok(FileContent {
        file_path: file_path.to_string(),
        mime_type: mime_type.to_string(),
        content,
    })
}

/// 删除技能
pub async fn delete_skill(db: &MySqlPool, storage_root: &str, id: u64) -> Result<(), AppError> {
    let skill: Skill = skill_repository::find_by_id(db, id)
        .await?
        .ok_or_else(|| AppError::not_found("技能不存在"))?;

    // 删除磁盘文件
    let skill_dir: PathBuf = Path::new(storage_root)
        .join("skills")
        .join(&skill.storage_path);
    if skill_dir.exists() {
        std::fs::remove_dir_all(&skill_dir)
            .map_err(|e| AppError::internal(e, "remove storage dir"))?;
    }

    // 删除数据库记录（CASCADE 会删 skill_files）
    skill_repository::delete_skill(db, id).await?;

    Ok(())
}
