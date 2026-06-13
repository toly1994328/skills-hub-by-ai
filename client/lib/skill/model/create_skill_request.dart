class CreateSkillRequest {
  final String name;
  final String description;
  final String author;
  final String tags;
  final String iconUrl;
  final String sourceUrl;
  final String version;
  final String downloadUrl;
  final String content;

  const CreateSkillRequest({
    required this.name,
    required this.content,
    this.description = '',
    this.author = '',
    this.tags = '',
    this.iconUrl = '',
    this.sourceUrl = '',
    this.version = '1.0.0',
    this.downloadUrl = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'author': author,
    'tags': tags,
    'icon_url': iconUrl,
    'source_url': sourceUrl,
    'version': version,
    'download_url': downloadUrl,
    'content': content,
  };
}
