import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:notes/services/database_service.dart' as database;

final db = database.DatabaseService.instance;

class MainDrawer extends StatelessWidget {
  final int noteCount;
  final int lockedNoteCount;
  final int deletedNoteCount;

  final void Function(String changedTitle) onChangeTitle;

  const MainDrawer({
    super.key,
    required this.noteCount,
    required this.lockedNoteCount,
    required this.deletedNoteCount,
    required this.onChangeTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.82,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: DrawerHeader(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Image.asset("assets/images/unnamed.png"),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: const Text(
                  'Tất cả ghi chú',
                  style: TextStyle(fontSize: 20),
                ),
                trailing: Text(
                  '$noteCount',
                  style: const TextStyle(fontSize: 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {
                  onChangeTitle('Tất cả ghi chú');
                  if (Scaffold.of(context).isDrawerOpen) {
                    Scaffold.of(context).closeDrawer();
                  }
                },
              ),
              const SizedBox(
                height: 6,
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text(
                  'Ghi chú bị khoá',
                  style: TextStyle(fontSize: 20),
                ),
                trailing: Text(
                  '$lockedNoteCount',
                  style: const TextStyle(fontSize: 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {
                  onChangeTitle('Ghi chú bị khoá');
                  if (Scaffold.of(context).isDrawerOpen) {
                    Scaffold.of(context).closeDrawer();
                  }
                },
              ),
              const SizedBox(
                height: 6,
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text(
                  'Thùng rác',
                  style: TextStyle(fontSize: 20),
                ),
                trailing: Text(
                  '$deletedNoteCount',
                  style: const TextStyle(fontSize: 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {
                  onChangeTitle('Thùng rác');
                  if (Scaffold.of(context).isDrawerOpen) {
                    Scaffold.of(context).closeDrawer();
                  }
                },
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Xác nhận',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      content: Text(
                        'Toàn bộ dữ liệu sẽ bị xoá vĩnh viễn.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            db.emptyTable();
                            Phoenix.rebirth(context);
                          },
                          style: ElevatedButton.styleFrom().copyWith(
                            backgroundColor:
                                const WidgetStatePropertyAll<Color>(Colors.red),
                            foregroundColor:
                                const WidgetStatePropertyAll<Color>(
                                    Colors.white),
                            elevation: const WidgetStatePropertyAll<double>(10),
                          ),
                          child: const Text('Reset'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Huỷ'),
                        ),
                      ],
                    ),
                  );
                },
                style: TextButton.styleFrom().copyWith(
                  foregroundColor:
                      const WidgetStatePropertyAll<Color>(Colors.red),
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.all(20),
                  ),
                ),
                icon: const Icon(Icons.restart_alt),
                label: const Text(
                  "Reset",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
