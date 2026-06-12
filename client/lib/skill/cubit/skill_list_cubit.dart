import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/skill_repository.dart';
import 'skill_list_state.dart';

class SkillListCubit extends Cubit<SkillListState> {
  final SkillRepository _repo = SkillRepository();
  static const int _pageSize = 20;

  SkillListCubit() : super(const SkillListState());

  /// 加载第一页
  Future<void> loadSkills() async {
    emit(state.copyWith(status: SkillListStatus.loading));

    final ret = await _repo.list(page: 1, pageSize: _pageSize);

    if (ret.success) {
      final list = ret.data;
      final total = ret.paginate?.total ?? list.length;
      emit(state.copyWith(
        status: SkillListStatus.loaded,
        skills: list,
        page: 1,
        total: total,
        hasMore: list.length >= _pageSize,
      ));
    } else {
      emit(state.copyWith(
        status: SkillListStatus.error,
        errorMsg: ret.msg,
      ));
    }
  }

  /// 加载更多（下一页）
  Future<void> loadMore() async {
    if (!state.hasMore || state.status == SkillListStatus.loading) return;

    final nextPage = state.page + 1;
    final ret = await _repo.list(page: nextPage, pageSize: _pageSize);

    if (ret.success) {
      final list = ret.data;
      final allSkills = [...state.skills, ...list];
      emit(state.copyWith(
        status: SkillListStatus.loaded,
        skills: allSkills,
        page: nextPage,
        hasMore: list.length >= _pageSize,
      ));
    } else {
      emit(state.copyWith(
        status: SkillListStatus.error,
        errorMsg: ret.msg,
      ));
    }
  }
}
