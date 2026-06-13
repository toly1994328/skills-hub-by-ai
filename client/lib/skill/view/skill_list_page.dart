import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/skill_list_cubit.dart';
import '../cubit/skill_list_state.dart';
import 'skill_card.dart';
import 'skill_detail_page.dart';
import 'skill_publish_page.dart';

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
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: const Text(
          '技能广场',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181818),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF181818)),
            onPressed: () => _navigateToPublish(context),
          ),
        ],
      ),
      body: BlocBuilder<SkillListCubit, SkillListState>(
        builder: (context, state) {
          switch (state.status) {
            case SkillListStatus.initial:
            case SkillListStatus.loading:
              if (state.skills.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6D00),
                    strokeWidth: 2,
                  ),
                );
              }
              return _buildList(context, state);
            case SkillListStatus.loaded:
              if (state.skills.isEmpty) {
                return const Center(
                  child: Text(
                    '暂无技能',
                    style: TextStyle(fontSize: 15, color: Color(0xFF999999)),
                  ),
                );
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
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          context.read<SkillListCubit>().loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: state.skills.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.skills.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6D00),
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }
          final skill = state.skills[index];
          return Column(
            children: [
              SkillCard(
                skill: skill,
                onTap: () => _navigateToDetail(context, skill.id),
              ),
              if (index < state.skills.length - 1)
                Container(height: 6, color: const Color(0xFFF5F5F5)),
            ],
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
          Text(
            msg,
            style: const TextStyle(fontSize: 15, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.read<SkillListCubit>().loadSkills(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6D00),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '重试',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
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

  void _navigateToPublish(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SkillPublishPage()),
    );
    if (result == true && context.mounted) {
      context.read<SkillListCubit>().loadSkills();
    }
  }
}
