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
          appBar: AppBar(
            title: Text(state.skill?.name ?? '技能详情'),
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
        return const Center(child: CircularProgressIndicator());
      case SkillDetailStatus.loaded:
        return _buildDetail(context, state.skill!);
      case SkillDetailStatus.error:
        return Center(
          child: Text(state.errorMsg, style: TextStyle(color: Colors.grey[600])),
        );
    }
  }

  Widget _buildDetail(BuildContext context, SkillDetail skill) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(skill),
          const SizedBox(height: 12),
          _buildTags(skill),
          const SizedBox(height: 12),
          _buildLinks(skill),
          const Divider(height: 32),
          _buildMarkdown(skill.content),
        ],
      ),
    );
  }

  Widget _buildHeader(SkillDetail skill) {
    return Row(
      children: [
        if (skill.iconUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              skill.iconUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.extension, size: 32),
              ),
            ),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                skill.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'v${skill.version}  ·  ${skill.author}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              if (skill.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  skill.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTags(SkillDetail skill) {
    final tags = skill.tagList;
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) => Chip(
        label: Text(tag, style: const TextStyle(fontSize: 12)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      )).toList(),
    );
  }

  Widget _buildLinks(SkillDetail skill) {
    return Wrap(
      spacing: 8,
      children: [
        if (skill.sourceUrl.isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => _openUrl(skill.sourceUrl),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('来源'),
          ),
        if (skill.downloadUrl.isNotEmpty)
          FilledButton.icon(
            onPressed: () => _openUrl(skill.downloadUrl),
            icon: const Icon(Icons.download, size: 16),
            label: const Text('下载'),
          ),
      ],
    );
  }

  Widget _buildMarkdown(String content) {
    if (content.isEmpty) {
      return Text('暂无说明文档', style: TextStyle(color: Colors.grey[400]));
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
