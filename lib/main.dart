import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes/screens/main_content.dart';

void main() {
  runApp(
    ProviderScope(
      child: Phoenix(
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghi chú',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        menuButtonTheme: MenuButtonThemeData(
          style: MenuItemButton.styleFrom(
            foregroundColor: Colors.black,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: const ButtonStyle().copyWith(
            foregroundColor: const WidgetStatePropertyAll<Color>(Colors.black),
          ),
        ),
      ),
      home: const MainContentScreen(),
    );
  }
}
