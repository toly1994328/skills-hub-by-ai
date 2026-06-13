import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../cubit/skill_publish_cubit.dart';
import '../cubit/skill_publish_state.dart';
import '../model/create_skill_request.dart';

class SkillPublishPage extends StatelessWidget {
  const SkillPublishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SkillPublishCubit(),
      child: const _PublishView(),
    );
  }
}

class _PublishView extends StatefulWidget {
  const _PublishView();

  @override
  State<_PublishView> createState() => _PublishViewState();
}

class _PublishViewState extends State<_PublishView> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _authorController = TextEditingController();
  final _tagsController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0.0');
  final _downloadUrlController = TextEditingController();
  final _iconUrlController = TextEditingController();
  final _contentController = TextEditingController();

  late TabController _tabController;
  String _fileContent = '';
  String _fileName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    _sourceUrlController.dispose();
    _versionController.dispose();
    _downloadUrlController.dispose();
    _iconUrlController.dispose();
    _contentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String get _currentContent {
    if (_fileContent.isNotEmpty) return _fileContent;
    return _contentController.text;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      setState(() {
        _fileContent = content;
        _fileName = result.files.single.name;
      });
    }
  }

  void _submit() {
    final request = CreateSkillRequest(
      name: _nameController.text,
      description: _descController.text,
      author: _authorController.text,
      tags: _tagsController.text,
      iconUrl: _iconUrlController.text,
      sourceUrl: _sourceUrlController.text,
      version: _versionController.text,
      downloadUrl: _downloadUrlController.text,
      content: _currentContent,
    );
    context.read<SkillPublishCubit>().publish(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SkillPublishCubit, SkillPublishState>(
      listener: (context, state) {
        if (state.status == SkillPublishStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.status == SkillPublishStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMsg), backgroundColor: const Color(0xFFFA5151)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEDEDED),
        appBar: AppBar(
          title: const Text('发布技能', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF181818))),
          centerTitle: true,
          backgroundColor: const Color(0xFFEDEDED),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF181818)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildFormSection(),
              const SizedBox(height: 8),
              _buildContentSection(),
              const SizedBox(height: 8),
              _buildSubmitButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildTextField(_nameController, '名称', required: true),
          _divider(),
          _buildTextField(_descController, '描述'),
          _divider(),
          _buildTextField(_authorController, '作者'),
          _divider(),
          _buildTextField(_tagsController, '标签', hint: '逗号分隔'),
          _divider(),
          _buildTextField(_sourceUrlController, '来源 URL'),
          _divider(),
          _buildTextField(_versionController, '版本号'),
          _divider(),
          _buildTextField(_downloadUrlController, '下载链接'),
          _divider(),
          _buildTextField(_iconUrlController, '图标 URL'),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool required = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              required ? '$label *' : label,
              style: TextStyle(fontSize: 15, color: required ? const Color(0xFF181818) : const Color(0xFF666666)),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 15, color: Color(0xFF181818)),
              decoration: InputDecoration(
                hintText: hint ?? '请输入$label',
                hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF999999)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFFF6D00),
            unselectedLabelColor: const Color(0xFF666666),
            indicatorColor: const Color(0xFFFF6D00),
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            tabs: const [Tab(text: '选择文件'), Tab(text: '手动输入'), Tab(text: '预览')],
          ),
          const Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE5E5E5)),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [_buildFileTab(), _buildManualTab(), _buildPreviewTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(6)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.file_open_outlined, size: 18, color: Color(0xFF576B95)),
                  const SizedBox(width: 8),
                  Text(
                    _fileName.isEmpty ? '选择 .md 文件' : _fileName,
                    style: TextStyle(fontSize: 14, color: _fileName.isEmpty ? const Color(0xFF576B95) : const Color(0xFF181818)),
                  ),
                ],
              ),
            ),
          ),
          if (_fileContent.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('已读取 ${_fileContent.length} 字符', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
          ],
        ],
      ),
    );
  }

  Widget _buildManualTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        expands: true,
        style: const TextStyle(fontSize: 14, color: Color(0xFF181818), height: 1.5),
        decoration: const InputDecoration(
          hintText: '在这里输入 Markdown 内容...',
          hintStyle: TextStyle(fontSize: 14, color: Color(0xFF999999)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildPreviewTab() {
    final content = _currentContent;
    if (content.isEmpty) {
      return const Center(child: Text('暂无内容', style: TextStyle(fontSize: 14, color: Color(0xFF999999))));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MarkdownBody(
        data: content,
        builders: {'code': _CodeBlockBuilder()},
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF181818)),
          h2: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF181818)),
          p: const TextStyle(fontSize: 14, color: Color(0xFF181818), height: 1.5),
          code: TextStyle(fontSize: 12, backgroundColor: const Color(0xFFF5F5F5), fontFamily: 'monospace'),
          codeblockDecoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(6)),
          codeblockPadding: const EdgeInsets.all(10),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<SkillPublishCubit, SkillPublishState>(
      builder: (context, state) {
        final isLoading = state.status == SkillPublishStatus.submitting;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: isLoading ? null : _submit,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: isLoading ? const Color(0xFFFF6D00).withValues(alpha: 0.5) : const Color(0xFFFF6D00),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('发布', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 96),
      child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE5E5E5)),
    );
  }
}

class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.attributes['class'] == null && !element.textContent.contains('\n')) {
      return null;
    }
    final code = element.textContent;
    final language = element.attributes['class']?.replaceFirst('language-', '') ?? '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(6)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(10),
          child: HighlightView(
            code,
            language: language.isNotEmpty ? language : 'plaintext',
            theme: githubTheme,
            textStyle: const TextStyle(fontSize: 12, fontFamily: 'monospace', height: 1.4),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
