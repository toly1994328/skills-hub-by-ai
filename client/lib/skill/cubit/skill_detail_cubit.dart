import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/skill_repository.dart';
import 'skill_detail_state.dart';

class SkillDetailCubit extends Cubit<SkillDetailState> {
  final SkillRepository _repo = SkillRepository();

  SkillDetailCubit() : super(const SkillDetailState());

  Future<void> loadDetail(int id) async {
    emit(state.copyWith(status: SkillDetailStatus.loading));

    final ret = await _repo.detail(id);

    if (ret.success) {
      emit(state.copyWith(
        status: SkillDetailStatus.loaded,
        skill: ret.data,
      ));
    } else {
      emit(state.copyWith(
        status: SkillDetailStatus.error,
        errorMsg: ret.msg,
      ));
    }
  }
}
