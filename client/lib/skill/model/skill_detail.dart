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
  final String content;
  final String status;
  final String createdAt;
  final String updatedAt;

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
    this.content = '',
    this.status = '',
    this.createdAt = '',
    this.updatedAt = '',
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
    content: map['content'] ?? '',
    status: map['status'] ?? '',
    createdAt: map['created_at'] ?? '',
    updatedAt: map['updated_at'] ?? '',
  );

  List<String> get tagList => tags.isEmpty ? [] : tags.split(',');
}
