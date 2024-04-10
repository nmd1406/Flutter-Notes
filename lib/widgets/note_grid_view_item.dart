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
          child: SizedBox(
            width: double.infinity,
            child: InkWell(
              borderRadius: BorderRadius.circular(19),
              child: Card(
                elevation: 4,
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
        ),
        Text(
          note.title,
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
