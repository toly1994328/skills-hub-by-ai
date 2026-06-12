import '../model/skill_detail.dart';

enum SkillDetailStatus { initial, loading, loaded, error }

class SkillDetailState {
  final SkillDetailStatus status;
  final SkillDetail? skill;
  final String errorMsg;

  const SkillDetailState({
    this.status = SkillDetailStatus.initial,
    this.skill,
    this.errorMsg = '',
  });

  SkillDetailState copyWith({
    SkillDetailStatus? status,
    SkillDetail? skill,
    String? errorMsg,
  }) {
    return SkillDetailState(
      status: status ?? this.status,
      skill: skill ?? this.skill,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}
