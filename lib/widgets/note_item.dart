import 'package:flutter/material.dart';

import 'package:notes/models/note.dart';
import 'package:notes/screens/note_details.dart';

class NoteItem extends StatelessWidget {
  final Note note;

  const NoteItem({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        color: Colors.yellow,
        elevation: 4,
        child: ListTile(
          title: Text(
            note.title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.content,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (note.dateEdited != null)
                Text(
                  'Lần sửa đổi cuối: ${note.getEditedDate()}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
            ],
          ),
          trailing: Text(note.getCreatedDate()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
    );
  }
}
