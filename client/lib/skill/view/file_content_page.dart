import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:fx_dio/fx_dio.dart';
import 'package:markdown/markdown.dart' as md;

import '../model/file_content.dart';
import '../repository/skill_repository.dart';

class FileContentPage extends StatefulWidget {
  final int skillId;
  final String filePath;
  final String fileName;

  const FileContentPage({
    super.key,
    required this.skillId,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<FileContentPage> createState() => _FileContentPageState();
}

class _FileContentPageState extends State<FileContentPage> {
  final SkillRepository _repo = SkillRepository();
  bool _loading = true;
  String _content = '';
  String _mimeType = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final ApiRet<FileContent> ret = await _repo.fileContent(widget.skillId, widget.filePath);
    if (ret.success) {
      setState(() {
        _loading = false;
        _content = ret.data.content;
        _mimeType = ret.data.mimeType;
      });
    } else {
      setState(() {
        _loading = false;
        _error = ret.msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.fileName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF181818))),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF181818)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6D00), strokeWidth: 2));
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error, style: const TextStyle(fontSize: 14, color: Color(0xFF999999))));
    }

    // Markdown 文件用 MarkdownBody 渲染
    if (_mimeType.contains('markdown')) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownBody(
          data: _stripFrontMatter(_content),
          builders: {'code': _CodeBlockBuilder()},
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF181818), height: 1.5),
            h2: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF181818), height: 1.5),
            h3: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF181818), height: 1.5),
            p: const TextStyle(fontSize: 15, color: Color(0xFF181818), height: 1.6),
            code: TextStyle(fontSize: 13, color: const Color(0xFFFF6D00), backgroundColor: const Color(0xFFFF6D00).withValues(alpha: 0.1), fontFamily: 'monospace'),
            codeblockDecoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(6)),
            codeblockPadding: const EdgeInsets.all(12),
          ),
        ),
      );
    }

    // 代码文件用语法高亮
    final String language = _guessLanguage(_mimeType, widget.fileName);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: HighlightView(
        _content,
        language: language,
        theme: githubTheme,
        textStyle: const TextStyle(fontSize: 13, fontFamily: 'monospace', height: 1.5),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  String _stripFrontMatter(String content) {
    final String trimmed = content.trimLeft();
    if (!trimmed.startsWith('---')) return content;
    final int endIndex = trimmed.indexOf('---', 3);
    if (endIndex == -1) return content;
    final String frontMatter = trimmed.substring(3, endIndex).trim();
    final String body = trimmed.substring(endIndex + 3).trimLeft();
    return '```yaml\n$frontMatter\n```\n\n$body';
  }

  String _guessLanguage(String mimeType, String fileName) {
    if (mimeType.contains('dart')) return 'dart';
    if (mimeType.contains('python')) return 'python';
    if (mimeType.contains('rust')) return 'rust';
    if (mimeType.contains('javascript')) return 'javascript';
    if (mimeType.contains('typescript')) return 'typescript';
    if (mimeType.contains('json')) return 'json';
    if (mimeType.contains('yaml')) return 'yaml';
    if (mimeType.contains('shell')) return 'bash';
    if (mimeType.contains('html')) return 'html';
    if (mimeType.contains('css')) return 'css';
    if (mimeType.contains('sql')) return 'sql';
    if (mimeType.contains('kotlin')) return 'kotlin';
    if (mimeType.contains('java')) return 'java';
    if (mimeType.contains('swift')) return 'swift';
    if (mimeType.contains('go')) return 'go';
    if (mimeType.contains('xml')) return 'xml';
    final String ext = fileName.split('.').last.toLowerCase();
    return ext.isNotEmpty ? ext : 'plaintext';
  }
}

class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.attributes['class'] == null && !element.textContent.contains('\n')) {
      return null;
    }
    final String code = element.textContent;
    final String language = element.attributes['class']?.replaceFirst('language-', '') ?? '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: HighlightView(
            code,
            language: language.isNotEmpty ? language : 'plaintext',
            theme: githubTheme,
            textStyle: const TextStyle(fontSize: 13, fontFamily: 'monospace', height: 1.5),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
