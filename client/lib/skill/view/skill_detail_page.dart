import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../cubit/skill_detail_cubit.dart';
import '../cubit/skill_detail_state.dart';
import '../model/skill_detail.dart';
import 'skill_files_view.dart';

class SkillDetailPage extends StatelessWidget {
  final int skillId;

  const SkillDetailPage({super.key, required this.skillId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SkillDetailCubit()..loadDetail(skillId),
      child: const _SkillDetailView(),
    );
  }
}

class _SkillDetailView extends StatelessWidget {
  const _SkillDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SkillDetailCubit, SkillDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFEDEDED),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SkillDetailState state) {
    switch (state.status) {
      case SkillDetailStatus.initial:
      case SkillDetailStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6D00), strokeWidth: 2),
        );
      case SkillDetailStatus.loaded:
        return _buildDetail(context, state.skill!);
      case SkillDetailStatus.error:
        return Center(
          child: Text(state.errorMsg, style: const TextStyle(fontSize: 15, color: Color(0xFF999999))),
        );
    }
  }

  Widget _buildDetail(BuildContext context, SkillDetail skill) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF181818)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final top = constraints.biggest.height;
              final collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
              final expandRatio = ((top - collapsedHeight) / (220 - collapsedHeight)).clamp(0.0, 1.0);
              return FlexibleSpaceBar(
                centerTitle: true,
                title: expandRatio < 0.3
                    ? Text(
                        skill.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF181818)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 第一行：logo + 名称 + 版本作者
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: skill.iconUrl.isNotEmpty
                                  ? Image.network(
                                      skill.iconUrl,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => _iconPlaceholder(),
                                    )
                                  : _iconPlaceholder(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    skill.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF181818)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text('v${skill.version}', style: const TextStyle(fontSize: 11, color: Color(0xFFFF6D00))),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(skill.author, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // 标签
                        if (skill.tagList.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: skill.tagList.map((tag) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(3)),
                                  child: Text(tag, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                        // 来源链接
                        if (skill.sourceUrl.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _openUrl(skill.sourceUrl),
                            child: Row(
                              children: [
                                const Icon(Icons.link, size: 14, color: Color(0xFF576B95)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    skill.sourceUrl,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF576B95)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // 按钮
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (skill.downloadUrl.isNotEmpty) _openUrl(skill.downloadUrl);
                                },
                                child: Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFFF6D00)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Text('下载技能', style: TextStyle(fontSize: 14, color: Color(0xFFFF6D00))),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: skill.entryContent));
                                },
                                child: Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFFF6D00)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Text('复制全文', style: TextStyle(fontSize: 14, color: Color(0xFFFF6D00))),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // 描述
              if (skill.description.isNotEmpty)
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    skill.description,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5),
                  ),
                ),
              const SizedBox(height: 8),
              // Tab 面板
              DefaultTabController(
                length: 2,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5)),
                        ),
                        child: const TabBar(
                          labelColor: Color(0xFFFF6D00),
                          unselectedLabelColor: Color(0xFF666666),
                          indicatorColor: Color(0xFFFF6D00),
                          indicatorSize: TabBarIndicatorSize.label,
                          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          unselectedLabelStyle: TextStyle(fontSize: 14),
                          dividerHeight: 0,
                          tabs: [
                            Tab(text: 'SKILL.md'),
                            Tab(text: '文件列表'),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 500,
                        child: TabBarView(
                          children: [
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: _buildMarkdown(skill.entryContent),
                            ),
                            SkillFilesView(skillId: skill.id),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }


  Widget _iconPlaceholder() {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.extension, size: 20, color: Color(0xFF999999)),
    );
  }

  Widget _buildMarkdown(String content) {
    if (content.isEmpty) {
      return const Text('暂无说明文档', style: TextStyle(fontSize: 15, color: Color(0xFF999999)));
    }
    // 剥离 YAML front-matter
    final stripped = _stripFrontMatter(content);
    return MarkdownBody(
      data: stripped,
      builders: {'code': _CodeBlockBuilder()},
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF181818), height: 1.5),
        h2: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF181818), height: 1.5),
        h3: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF181818), height: 1.5),
        p: const TextStyle(fontSize: 15, color: Color(0xFF181818), height: 1.6),
        listBullet: const TextStyle(fontSize: 15, color: Color(0xFF181818), height: 1.6),
        code: TextStyle(fontSize: 13, color: const Color(0xFFFF6D00), backgroundColor: const Color(0xFFFF6D00).withValues(alpha: 0.1), fontFamily: 'monospace'),
        codeblockDecoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(6)),
        codeblockPadding: const EdgeInsets.all(12),
        blockquoteDecoration: BoxDecoration(border: Border(left: BorderSide(color: const Color(0xFFFF6D00), width: 3))),
        blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        blockquote: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5),
        tableHead: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF181818)),
        tableBody: const TextStyle(fontSize: 13, color: Color(0xFF181818)),
        tableBorder: TableBorder.all(color: const Color(0xFFE5E5E5), width: 0.5),
        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        horizontalRuleDecoration: BoxDecoration(border: Border(top: BorderSide(color: const Color(0xFFE5E5E5), width: 0.5))),
        h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
        h2Padding: const EdgeInsets.only(top: 14, bottom: 6),
        h3Padding: const EdgeInsets.only(top: 12, bottom: 4),
      ),
    );
  }

  String _stripFrontMatter(String content) {
    final trimmed = content.trimLeft();
    if (!trimmed.startsWith('---')) return content;
    final endIndex = trimmed.indexOf('---', 3);
    if (endIndex == -1) return content;
    // 提取 front-matter 内容，包装成 yaml 代码块
    final frontMatter = trimmed.substring(3, endIndex).trim();
    final body = trimmed.substring(endIndex + 3).trimLeft();
    return '```yaml\n$frontMatter\n```\n\n$body';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // 只处理代码块（父元素是 pre），行内代码交给默认样式
    if (element.attributes['class'] == null && !element.textContent.contains('\n')) {
      return null;
    }
    final code = element.textContent;
    final language = element.attributes['class']?.replaceFirst('language-', '') ?? '';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
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
