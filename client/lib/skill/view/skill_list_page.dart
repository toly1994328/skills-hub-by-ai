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
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: const Text(
          'Skills',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181818),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<SkillListCubit, SkillListState>(
        builder: (context, state) {
          switch (state.status) {
            case SkillListStatus.initial:
            case SkillListStatus.loading:
              if (state.skills.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF07C160),
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
                    color: Color(0xFF07C160),
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }
          final skill = state.skills[index];
          return Column(
            children: [
              if (index == 0)
                Container(color: Colors.white, height: 0), // 白色块起始
              SkillCard(
                skill: skill,
                onTap: () => _navigateToDetail(context, skill.id),
              ),
              if (index < state.skills.length - 1)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 68),
                  child: const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Color(0xFFE5E5E5),
                  ),
                ),
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
                color: const Color(0xFF07C160),
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
}
