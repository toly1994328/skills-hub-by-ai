import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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
              state.skill?.name ?? '技能详情',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF181818),
              ),
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
          child: CircularProgressIndicator(
            color: Color(0xFF07C160),
            strokeWidth: 2,
          ),
        );
      case SkillDetailStatus.loaded:
        return _buildDetail(context, state.skill!);
      case SkillDetailStatus.error:
        return Center(
          child: Text(
            state.errorMsg,
            style: const TextStyle(fontSize: 15, color: Color(0xFF999999)),
          ),
        );
    }
  }

  Widget _buildDetail(BuildContext context, SkillDetail skill) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          // 头部信息区（白色块）
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: _buildHeader(skill),
          ),
          const SizedBox(height: 8),
          // 标签和链接区（白色块）
          if (skill.tagList.isNotEmpty || skill.sourceUrl.isNotEmpty || skill.downloadUrl.isNotEmpty)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: _buildMetaSection(skill),
            ),
          const SizedBox(height: 8),
          // Markdown 内容区（白色块）
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.extension, size: 20, color: Color(0xFF999999)),
              ),
            ),
          ),
        if (skill.iconUrl.isNotEmpty) const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                skill.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181818),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'v${skill.version}  ·  ${skill.author}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
              if (skill.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  skill.description,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                ),
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
        if (skill.tagList.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: skill.tagList.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                tag,
                style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
              ),
            )).toList(),
          ),
        ],
        if ((skill.sourceUrl.isNotEmpty || skill.downloadUrl.isNotEmpty) && skill.tagList.isNotEmpty)
          const SizedBox(height: 12),
        if (skill.sourceUrl.isNotEmpty)
          _buildLinkItem(Icons.open_in_new, '来源', skill.sourceUrl),
        if (skill.sourceUrl.isNotEmpty && skill.downloadUrl.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 32),
            child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE5E5E5)),
          ),
        if (skill.downloadUrl.isNotEmpty)
          _buildLinkItem(Icons.download_outlined, '下载', skill.downloadUrl),
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
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF576B95)),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdown(String content) {
    if (content.isEmpty) {
      return const Text(
        '暂无说明文档',
        style: TextStyle(fontSize: 15, color: Color(0xFF999999)),
      );
    }
    return MarkdownBody(data: content);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
