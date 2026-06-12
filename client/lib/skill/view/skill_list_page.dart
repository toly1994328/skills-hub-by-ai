import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/skill_list_cubit.dart';
import '../cubit/skill_list_state.dart';
import 'skill_card.dart';
import 'skill_detail_page.dart';

class SkillListPage extends StatelessWidget {
  const SkillListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SkillListCubit()..loadSkills(),
      child: const _SkillListView(),
    );
  }
}

class _SkillListView extends StatelessWidget {
  const _SkillListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skills')),
      body: BlocBuilder<SkillListCubit, SkillListState>(
        builder: (context, state) {
          switch (state.status) {
            case SkillListStatus.initial:
            case SkillListStatus.loading:
              if (state.skills.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildList(context, state);
            case SkillListStatus.loaded:
              if (state.skills.isEmpty) {
                return const Center(child: Text('暂无技能'));
              }
              return _buildList(context, state);
            case SkillListStatus.error:
              if (state.skills.isEmpty) {
                return _buildError(context, state.errorMsg);
              }
              return _buildList(context, state);
          }
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, SkillListState state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          context.read<SkillListCubit>().loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.skills.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.skills.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final skill = state.skills[index];
          return SkillCard(
            skill: skill,
            onTap: () => _navigateToDetail(context, skill.id),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<SkillListCubit>().loadSkills(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, int skillId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SkillDetailPage(skillId: skillId),
      ),
    );
  }
}
