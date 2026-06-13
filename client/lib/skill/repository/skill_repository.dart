import 'package:fx_dio/fx_dio.dart';

import '../env/skill_host.dart';
import '../model/create_skill_request.dart';
import '../model/skill_detail.dart';
import '../model/skill_summary.dart';

class SkillRepository with SkillHostMixin {
  /// 分页查询技能列表
  Future<ApiRet<List<SkillSummary>>> list({
    int page = 1,
    int pageSize = 20,
  }) {
    return host.get<List<SkillSummary>>(
      '/skills',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
      convertor: (data) {
        List list = data['data']['list'] as List;
        return list.map<SkillSummary>(SkillSummary.fromApi).toList();
      },
    );
  }

  /// 查询技能详情
  Future<ApiRet<SkillDetail>> detail(int id) {
    return host.get<SkillDetail>(
      '/skills/$id',
      convertor: (data) => SkillDetail.fromApi(data['data']),
    );
  }

  /// 创建技能
  Future<ApiRet<int>> create(CreateSkillRequest request) {
    return host.post<int>(
      '/skills',
      data: request.toJson(),
      convertor: (data) => data['data']['id'] as int,
    );
  }
}
