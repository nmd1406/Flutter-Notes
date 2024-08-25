import 'package:flutter/material.dart';

import 'package:notes/models/note.dart';
import 'package:notes/widgets/notes_views/note_list_item.dart';

class SearchScreen extends SearchDelegate {
  final List<Note> noteList;

  SearchScreen(this.noteList);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Note> matchQuery = [];
    for (var note in noteList) {
      if (note.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(note);
      }
    }

    return matchQuery.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 62,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'Không có ghi chú phù hợp',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: matchQuery.length,
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 12,
            ),
            itemBuilder: (context, index) {
              var result = matchQuery[index];
              return NoteListItem(note: result);
            },
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_rounded,
              size: 62,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              'Bắt đầu tìm kiếm',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    List<Note> matchQuery = [];
    for (var note in noteList) {
      if (note.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(note);
      }
    }

    return matchQuery.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 62,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'Không có ghi chú phù hợp',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: matchQuery.length,
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 12,
            ),
            itemBuilder: (context, index) {
              var result = matchQuery[index];
              return NoteListItem(note: result);
            },
          );
  }

  @override
  String? get searchFieldLabel => 'Tiêu đề ghi chú';
}
