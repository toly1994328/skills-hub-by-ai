import '../model/skill_file_item.dart';

enum SkillFilesStatus { initial, loading, loaded, error }

class SkillFilesState {
  final SkillFilesStatus status;
  final List<SkillFileItem> files;
  final String errorMsg;

  const SkillFilesState({
    this.status = SkillFilesStatus.initial,
    this.files = const [],
    this.errorMsg = '',
  });

  SkillFilesState copyWith({
    SkillFilesStatus? status,
    List<SkillFileItem>? files,
    String? errorMsg,
  }) {
    return SkillFilesState(
      status: status ?? this.status,
      files: files ?? this.files,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}
