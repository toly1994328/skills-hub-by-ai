import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dio/fx_dio.dart';
import 'package:skills/skill/env/skill_host.dart';
import 'package:skills/skill/repository/skill_repository.dart';

void main() {
  setUpAll(() {
    FxDio().register(const SkillHost());
  });

  final repo = SkillRepository();

  group('SkillRepository.list', () {
    test('获取技能列表成功', () async {
      final ret = await repo.list(page: 1, pageSize: 10);
      expect(ret.success, isTrue);
      expect(ret.data, isNotEmpty);
    });

    test('分页参数生效', () async {
      final ret = await repo.list(page: 1, pageSize: 1);
      expect(ret.success, isTrue);
      expect(ret.data.length, 1);
    });

    test('列表项字段完整', () async {
      final ret = await repo.list(page: 1, pageSize: 1);
      expect(ret.success, isTrue);
      final skill = ret.data.first;
      expect(skill.id, greaterThan(0));
      expect(skill.name, isNotEmpty);
    });
  });

  group('SkillRepository.detail', () {
    test('获取详情成功', () async {
      // 先获取列表拿到一个 ID
      final listRet = await repo.list(page: 1, pageSize: 1);
      expect(listRet.success, isTrue);
      final id = listRet.data.first.id;

      final ret = await repo.detail(id);
      expect(ret.success, isTrue);
      expect(ret.data.id, id);
      expect(ret.data.name, isNotEmpty);
      expect(ret.data.entryContent, isNotEmpty);
    });

    test('不存在的 ID 返回失败', () async {
      final ret = await repo.detail(99999);
      expect(ret.success, isFalse);
    });
  });
}
