import 'package:flutter/material.dart';
import 'package:fx_dio/fx_dio.dart';

import 'skill/env/skill_host.dart';
import 'skill/view/skill_list_page.dart';

void main() {
  FxDio().register(const SkillHost());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skills Share',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const SkillListPage(),
    );
  }
}
