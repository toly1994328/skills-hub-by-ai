-- Skills Share — 数据库建表
-- 技能以压缩包为单位，解压存储到文件系统

DROP TABLE IF EXISTS skill_files;
DROP TABLE IF EXISTS skills;

-- 技能主表
CREATE TABLE skills (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(200)    NOT NULL COMMENT '技能名称（从 SKILL.md front-matter 提取）',
    description   TEXT            NOT NULL COMMENT '技能描述',
    author        VARCHAR(100)    NOT NULL DEFAULT '' COMMENT '作者',
    tags          VARCHAR(500)    NOT NULL DEFAULT '' COMMENT '标签，逗号分隔',
    icon_url      VARCHAR(500)    NOT NULL DEFAULT '' COMMENT '图标URL',
    source_url    VARCHAR(500)    NOT NULL DEFAULT '' COMMENT '来源网站URL',
    version       VARCHAR(50)     NOT NULL DEFAULT '1.0.0' COMMENT '语义化版本号',
    download_url  VARCHAR(500)    NOT NULL DEFAULT '' COMMENT '下载链接',
    file_count    INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '文件数量',
    total_size    BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '解压后总大小（字节）',
    entry_file    VARCHAR(500)    NOT NULL DEFAULT 'SKILL.md' COMMENT '入口文件路径',
    storage_path  VARCHAR(500)    NOT NULL DEFAULT '' COMMENT '磁盘存储根路径（相对 storage/skills/）',
    status        VARCHAR(20)     NOT NULL DEFAULT 'published' COMMENT '状态: draft/published/archived',
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_status (status),
    INDEX idx_updated_at (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='技能表';

-- 技能文件表（只存路径元信息，内容在文件系统）
CREATE TABLE skill_files (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    skill_id      BIGINT UNSIGNED NOT NULL COMMENT '所属技能ID',
    file_path     VARCHAR(500)    NOT NULL COMMENT '文件相对路径（如 references/animation.md）',
    file_name     VARCHAR(200)    NOT NULL COMMENT '文件名',
    file_size     BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件大小（字节）',
    is_dir        TINYINT(1)      NOT NULL DEFAULT 0 COMMENT '是否为目录',
    mime_type     VARCHAR(100)    NOT NULL DEFAULT 'text/plain' COMMENT 'MIME 类型',
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_skill_id (skill_id),
    INDEX idx_skill_path (skill_id, file_path),
    CONSTRAINT fk_skill_files_skill FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='技能文件表';
