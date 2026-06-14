import 'dart:typed_data';

import 'package:fx_dio/fx_dio.dart';

import '../env/skill_host.dart';
import '../model/file_content.dart';
import '../model/skill_detail.dart';
import '../model/skill_file_item.dart';
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
      convertor: (dynamic data) {
        final List<dynamic> list = data['data']['list'] as List<dynamic>;
        return list.map<SkillSummary>(SkillSummary.fromApi).toList();
      },
    );
  }

  /// 查询技能详情
  Future<ApiRet<SkillDetail>> detail(int id) {
    return host.get<SkillDetail>(
      '/skills/$id',
      convertor: (dynamic data) => SkillDetail.fromApi(data['data']),
    );
  }

  /// 上传 zip 创建技能
  Future<ApiRet<int>> upload(Uint8List zipBytes) {
    return host.post<int>(
      '/skills/upload',
      data: zipBytes,
      convertor: (dynamic data) => data['data']['id'] as int,
    );
  }

  /// 查询文件目录
  Future<ApiRet<List<SkillFileItem>>> files(int skillId) {
    return host.get<List<SkillFileItem>>(
      '/skills/$skillId/files',
      convertor: (dynamic data) {
        final List<dynamic> list = data['data'] as List<dynamic>;
        return list.map<SkillFileItem>(SkillFileItem.fromApi).toList();
      },
    );
  }

  /// 查询单文件内容
  Future<ApiRet<FileContent>> fileContent(int skillId, String filePath) {
    return host.get<FileContent>(
      '/skills/$skillId/files/$filePath',
      convertor: (dynamic data) => FileContent.fromApi(data['data']),
    );
  }
}
