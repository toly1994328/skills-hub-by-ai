class FileContent {
  final String filePath;
  final String mimeType;
  final String content;

  FileContent({
    required this.filePath,
    required this.mimeType,
    required this.content,
  });

  factory FileContent.fromApi(dynamic map) => FileContent(
    filePath: map['file_path'] ?? '',
    mimeType: map['mime_type'] ?? '',
    content: map['content'] ?? '',
  );
}
