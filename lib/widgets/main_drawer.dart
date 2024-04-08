import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      width: MediaQuery.of(context).size.width * 0.82,
      child: Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              const SizedBox(
                height: 60,
                width: double.infinity,
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: const Text('Tất cả ghi chú'),
                trailing: const Text('0'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {},
              ),
              const SizedBox(
                height: 6,
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Ghi chú bị khoá'),
                trailing: const Text('0'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {},
              ),
              const SizedBox(
                height: 6,
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Thùng rác'),
                trailing: const Text('0'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
