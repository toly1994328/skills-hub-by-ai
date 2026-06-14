import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/skill_repository.dart';
import 'skill_publish_state.dart';

class SkillPublishCubit extends Cubit<SkillPublishState> {
  final SkillRepository _repo = SkillRepository();

  SkillPublishCubit() : super(const SkillPublishState());

  Future<void> upload(List<int> zipBytes) async {
    if (zipBytes.isEmpty) {
      emit(state.copyWith(
        status: SkillPublishStatus.error,
        errorMsg: '请选择 zip 文件',
      ));
      return;
    }

    emit(state.copyWith(status: SkillPublishStatus.submitting));

    final ret = await _repo.upload(Uint8List.fromList(zipBytes));

    if (ret.success) {
      emit(state.copyWith(status: SkillPublishStatus.success));
    } else {
      emit(state.copyWith(
        status: SkillPublishStatus.error,
        errorMsg: ret.msg,
      ));
    }
  }
}
