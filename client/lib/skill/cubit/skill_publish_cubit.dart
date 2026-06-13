import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/create_skill_request.dart';
import '../repository/skill_repository.dart';
import 'skill_publish_state.dart';

class SkillPublishCubit extends Cubit<SkillPublishState> {
  final SkillRepository _repo = SkillRepository();

  SkillPublishCubit() : super(const SkillPublishState());

  Future<void> publish(CreateSkillRequest request) async {
    if (request.name.trim().isEmpty) {
      emit(state.copyWith(
        status: SkillPublishStatus.error,
        errorMsg: '名称不能为空',
      ));
      return;
    }
    if (request.content.trim().isEmpty) {
      emit(state.copyWith(
        status: SkillPublishStatus.error,
        errorMsg: '内容不能为空',
      ));
      return;
    }

    emit(state.copyWith(status: SkillPublishStatus.submitting));

    final ret = await _repo.create(request);

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
