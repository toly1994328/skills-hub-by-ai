import 'package:flutter/material.dart';
import 'package:fx_dio/fx_dio.dart';

import 'skill/env/skill_host.dart';
import 'skill/view/app_shell.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEDEDED),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEDEDED),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181818),
          ),
          iconTheme: IconThemeData(color: Color(0xFF181818)),
        ),
        listTileTheme: ListTileThemeData(
          tileColor: Colors.white
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const AppShell(),
    );
  }
}
