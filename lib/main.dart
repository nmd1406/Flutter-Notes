import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes/screens/main_content.dart';
import 'package:notes/services/database_service.dart';
import 'package:workmanager/workmanager.dart';

final _databaseService = DatabaseService.instance;

void callbackDispatcher() {
  Workmanager().executeTask(
    (taskName, inputData) async {
      _databaseService.monthlyCleanUpNotes();
      return Future.value(true);
    },
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1",
    "Monthly Clean Up Notes",
    frequency: const Duration(days: 30),
  );

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
