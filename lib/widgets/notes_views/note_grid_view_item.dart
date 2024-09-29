import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/note_details.dart';

class NoteGridViewItem extends StatelessWidget {
  final Note note;

  const NoteGridViewItem({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 7,
                        offset: ui.Offset(-10, 5),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(19),
                    child: Card(
                      color: Colors.yellow,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          note.content,
                          maxLines: 7,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NoteDetailsScreen(note: note),
                        ),
                      );
                    },
                  ),
                ),
                if (note.isLocked)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ),
                      child: Container(
                        color: Colors.transparent,
                        child: const Icon(Icons.lock),
                      ),
                    ),
                  ),
                if (note.isPinned)
                  Container(
                    alignment: Alignment.topRight,
                    child: const Icon(Icons.push_pin),
                  )
              ],
            ),
          ),
        ),
        Text(
          note.isLocked ? 'Ghi chú bị khoá' : note.title,
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
        ),
        if (note.dateEdited != null)
          Text(note.getSimpleDate(note.dateEdited!))
        else
          Text(note.getSimpleDate(note.dateCreated))
      ],
    );
  }
}
