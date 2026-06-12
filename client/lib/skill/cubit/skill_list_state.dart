import '../model/skill_summary.dart';

enum SkillListStatus { initial, loading, loaded, error }

class SkillListState {
  final SkillListStatus status;
  final List<SkillSummary> skills;
  final int page;
  final int total;
  final bool hasMore;
  final String errorMsg;

  const SkillListState({
    this.status = SkillListStatus.initial,
    this.skills = const [],
    this.page = 1,
    this.total = 0,
    this.hasMore = true,
    this.errorMsg = '',
  });

  SkillListState copyWith({
    SkillListStatus? status,
    List<SkillSummary>? skills,
    int? page,
    int? total,
    bool? hasMore,
    String? errorMsg,
  }) {
    return SkillListState(
      status: status ?? this.status,
      skills: skills ?? this.skills,
      page: page ?? this.page,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}
