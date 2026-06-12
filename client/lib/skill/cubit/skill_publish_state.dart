enum SkillPublishStatus { initial, submitting, success, error }

class SkillPublishState {
  final SkillPublishStatus status;
  final String errorMsg;

  const SkillPublishState({
    this.status = SkillPublishStatus.initial,
    this.errorMsg = '',
  });

  SkillPublishState copyWith({
    SkillPublishStatus? status,
    String? errorMsg,
  }) {
    return SkillPublishState(
      status: status ?? this.status,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}
