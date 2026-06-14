class SkillFileItem {
  final int id;
  final int skillId;
  final String filePath;
  final String fileName;
  final int fileSize;
  final bool isDir;
  final String mimeType;

  SkillFileItem({
    required this.id,
    required this.skillId,
    required this.filePath,
    required this.fileName,
    this.fileSize = 0,
    this.isDir = false,
    this.mimeType = '',
  });

  factory SkillFileItem.fromApi(dynamic map) => SkillFileItem(
    id: map['id'] ?? 0,
    skillId: map['skill_id'] ?? 0,
    filePath: map['file_path'] ?? '',
    fileName: map['file_name'] ?? '',
    fileSize: map['file_size'] ?? 0,
    isDir: map['is_dir'] == true || map['is_dir'] == 1,
    mimeType: map['mime_type'] ?? '',
  );
}
