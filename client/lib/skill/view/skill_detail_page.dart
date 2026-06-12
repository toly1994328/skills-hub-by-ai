import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../cubit/skill_detail_cubit.dart';
import '../cubit/skill_detail_state.dart';
import '../model/skill_detail.dart';

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
          appBar: AppBar(
            title: Text(
              state.skill?.name ?? '',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF181818)),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFFEDEDED),
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF181818)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: _buildHeader(skill),
          ),
          const SizedBox(height: 8),
          if (skill.tagList.isNotEmpty || skill.sourceUrl.isNotEmpty || skill.downloadUrl.isNotEmpty)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: _buildMetaSection(skill),
            ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: _buildMarkdown(skill.content),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeader(SkillDetail skill) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (skill.iconUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              skill.iconUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.extension, size: 20, color: Color(0xFF999999)),
              ),
            ),
          ),
        if (skill.iconUrl.isNotEmpty) const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(skill.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF181818))),
              const SizedBox(height: 4),
              Text('v${skill.version}  ·  ${skill.author}', style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
              if (skill.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(skill.description, style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaSection(SkillDetail skill) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (skill.tagList.isNotEmpty)
          Wrap(
            spacing: 6, runSpacing: 6,
            children: skill.tagList.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(3)),
              child: Text(tag, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
            )).toList(),
          ),
        if ((skill.sourceUrl.isNotEmpty || skill.downloadUrl.isNotEmpty) && skill.tagList.isNotEmpty)
          const SizedBox(height: 12),
        if (skill.sourceUrl.isNotEmpty) _buildLinkItem(Icons.open_in_new, '来源', skill.sourceUrl),
        if (skill.sourceUrl.isNotEmpty && skill.downloadUrl.isNotEmpty)
          const Padding(padding: EdgeInsets.only(left: 32), child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE5E5E5))),
        if (skill.downloadUrl.isNotEmpty) _buildLinkItem(Icons.download_outlined, '下载', skill.downloadUrl),
      ],
    );
  }

  Widget _buildLinkItem(IconData icon, String label, String url) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF576B95)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF576B95))),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdown(String content) {
    if (content.isEmpty) {
      return const Text('暂无说明文档', style: TextStyle(fontSize: 15, color: Color(0xFF999999)));
    }
    return MarkdownBody(
      data: content,
      builders: {'code': _CodeBlockBuilder()},
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF181818), height: 1.5),
        h2: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF181818), height: 1.5),
        h3: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF181818), height: 1.5),
        p: const TextStyle(fontSize: 15, color: Color(0xFF181818), height: 1.6),
        listBullet: const TextStyle(fontSize: 15, color: Color(0xFF181818), height: 1.6),
        code: TextStyle(fontSize: 13, color: const Color(0xFF181818), backgroundColor: const Color(0xFFF5F5F5), fontFamily: 'monospace'),
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
