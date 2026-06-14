import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/skill_repository.dart';
import 'skill_files_state.dart';

class SkillFilesCubit extends Cubit<SkillFilesState> {
  final SkillRepository _repo = SkillRepository();

  SkillFilesCubit() : super(const SkillFilesState());

  Future<void> loadFiles(int skillId) async {
    emit(state.copyWith(status: SkillFilesStatus.loading));

    final ret = await _repo.files(skillId);

    if (ret.success) {
      emit(state.copyWith(
        status: SkillFilesStatus.loaded,
        files: ret.data,
      ));
    } else {
      emit(state.copyWith(
        status: SkillFilesStatus.error,
        errorMsg: ret.msg,
      ));
    }
  }
}
