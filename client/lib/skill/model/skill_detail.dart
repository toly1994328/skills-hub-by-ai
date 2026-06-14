class SkillDetail {
  final int id;
  final String name;
  final String description;
  final String author;
  final String tags;
  final String iconUrl;
  final String sourceUrl;
  final String version;
  final String downloadUrl;
  final int fileCount;
  final int totalSize;
  final String entryFile;
  final String storagePath;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String entryContent;

  SkillDetail({
    required this.id,
    required this.name,
    this.description = '',
    this.author = '',
    this.tags = '',
    this.iconUrl = '',
    this.sourceUrl = '',
    this.version = '',
    this.downloadUrl = '',
    this.fileCount = 0,
    this.totalSize = 0,
    this.entryFile = 'SKILL.md',
    this.storagePath = '',
    this.status = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.entryContent = '',
  });

  factory SkillDetail.fromApi(dynamic map) => SkillDetail(
    id: map['id'] ?? 0,
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    author: map['author'] ?? '',
    tags: map['tags'] ?? '',
    iconUrl: map['icon_url'] ?? '',
    sourceUrl: map['source_url'] ?? '',
    version: map['version'] ?? '',
    downloadUrl: map['download_url'] ?? '',
    fileCount: map['file_count'] ?? 0,
    totalSize: map['total_size'] ?? 0,
    entryFile: map['entry_file'] ?? 'SKILL.md',
    storagePath: map['storage_path'] ?? '',
    status: map['status'] ?? '',
    createdAt: map['created_at'] ?? '',
    updatedAt: map['updated_at'] ?? '',
    entryContent: map['entry_content'] ?? '',
  );

  List<String> get tagList => tags.isEmpty ? [] : tags.split(',');
}
