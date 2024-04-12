import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/providers/edit_state_provider.dart';

class ContentTextField extends ConsumerStatefulWidget {
  final TextEditingController textController;

  const ContentTextField({
    super.key,
    required this.textController,
  });

  @override
  ConsumerState<ContentTextField> createState() => _ContentTextFieldState();
}

class _ContentTextFieldState extends ConsumerState<ContentTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: false,
      controller: widget.textController,
      enabled: ref.watch(editStateNotifier),
      textCapitalization: TextCapitalization.sentences,
      maxLength: 1024,
      maxLines: null,
      cursorColor: Colors.red,
      buildCounter: (context,
              {int? currentLength, bool? isFocused, int? maxLength}) =>
          null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(15),
        hintText: 'Ghi chú ở đây...',
      ),
    );
  }
}
