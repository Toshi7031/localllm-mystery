import 'package:flutter/material.dart';
import '../features/title/title_page.dart';

class MysteryApp extends StatelessWidget {
  const MysteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mystery ADV',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      home: const TitlePage(),
    );
  }
}
