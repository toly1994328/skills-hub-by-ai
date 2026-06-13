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
  bool _showMore = false;

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
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, size: 22, color: Color(0xFF181818)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            _buildPublishAction(),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // 基本信息（必填）
              _buildSection([
                _buildField(_nameController, '技能名称', required: true, icon: Icons.title),
                _buildField(_descController, '一句话描述', icon: Icons.short_text),
                _buildField(_authorController, '作者', icon: Icons.person_outline),
              ]),
              const SizedBox(height: 8),
              // 版本与标签
              _buildSection([
                _buildField(_versionController, '版本号', icon: Icons.tag),
                _buildField(_tagsController, '标签', hint: '逗号分隔，如 Flutter,工具', icon: Icons.label_outline),
              ]),
              const SizedBox(height: 8),
              // 更多（折叠）
              _buildExpandableSection(),
              const SizedBox(height: 8),
              // 内容输入
              _buildContentSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPublishAction() {
    return BlocBuilder<SkillPublishCubit, SkillPublishState>(
      builder: (context, state) {
        final isLoading = state.status == SkillPublishStatus.submitting;
        return GestureDetector(
          onTap: isLoading ? null : _submit,
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: isLoading ? const Color(0xFFFF6D00).withValues(alpha: 0.5) : const Color(0xFFFF6D00),
              borderRadius: BorderRadius.circular(16),
            ),
            child: isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('发布', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 52),
                child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFF0F0F0)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool required = false, String? hint, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: const Color(0xFF999999)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 15, color: Color(0xFF181818)),
              decoration: InputDecoration(
                hintText: hint ?? label,
                hintStyle: const TextStyle(fontSize: 15, color: Color(0xFFBBBBBB)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (required)
            const Text('*', style: TextStyle(fontSize: 16, color: Color(0xFFFF6D00))),
        ],
      ),
    );
  }

  Widget _buildExpandableSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showMore = !_showMore),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.more_horiz, size: 18, color: Color(0xFF999999)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('更多信息', style: TextStyle(fontSize: 15, color: Color(0xFF666666))),
                  ),
                  Icon(
                    _showMore ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20, color: const Color(0xFF999999),
                  ),
                ],
              ),
            ),
          ),
          if (_showMore) ...[
            const Padding(
              padding: EdgeInsets.only(left: 52),
              child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFF0F0F0)),
            ),
            _buildField(_sourceUrlController, '来源 URL', icon: Icons.link),
            const Padding(
              padding: EdgeInsets.only(left: 52),
              child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFF0F0F0)),
            ),
            _buildField(_downloadUrlController, '下载链接', icon: Icons.download_outlined),
            const Padding(
              padding: EdgeInsets.only(left: 52),
              child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFF0F0F0)),
            ),
            _buildField(_iconUrlController, '图标 URL', icon: Icons.image_outlined),
          ],
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 14, bottom: 4),
            child: Text('技能内容 *', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
          ),
          // Tab 栏
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(3),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF181818),
              unselectedLabelColor: const Color(0xFF999999),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
              ),
              dividerHeight: 0,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: const [Tab(text: '选择文件'), Tab(text: '手动输入'), Tab(text: '预览')],
            ),
          ),
          // 内容区
          SizedBox(
            height: 360,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFAFAFA),
              ),
              child: Column(
                children: [
                  Icon(
                    _fileName.isEmpty ? Icons.upload_file_outlined : Icons.description_outlined,
                    size: 40,
                    color: _fileName.isEmpty ? const Color(0xFFBBBBBB) : const Color(0xFFFF6D00),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _fileName.isEmpty ? '点击选择 .md 文件' : _fileName,
                    style: TextStyle(
                      fontSize: 14,
                      color: _fileName.isEmpty ? const Color(0xFF999999) : const Color(0xFF181818),
                      fontWeight: _fileName.isEmpty ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  if (_fileContent.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${_fileContent.length} 字符  ·  点击重新选择',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _contentController,
          maxLines: null,
          expands: true,
          style: const TextStyle(fontSize: 14, color: Color(0xFF181818), height: 1.6, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            hintText: '# 技能名称\n\n## 简介\n\n在这里输入 Markdown 内容...',
            hintStyle: TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewTab() {
    final content = _currentContent;
    if (content.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.preview_outlined, size: 40, color: Color(0xFFDDDDDD)),
            SizedBox(height: 8),
            Text('输入内容后可在此预览', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
          ],
        ),
      );
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
          code: TextStyle(fontSize: 12, color: const Color(0xFFFF6D00), backgroundColor: const Color(0xFFFF6D00).withValues(alpha: 0.1), fontFamily: 'monospace'),
          codeblockDecoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(6)),
          codeblockPadding: const EdgeInsets.all(10),
        ),
      ),
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
