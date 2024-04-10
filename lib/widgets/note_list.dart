import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes/models/note.dart';
import 'package:notes/providers/multiple_selection_function.dart';
import 'package:notes/widgets/note_grid_view_item.dart';
import 'package:notes/widgets/note_item.dart';

class NoteList extends ConsumerStatefulWidget {
  final List<Note> noteList;

  const NoteList({
    super.key,
    required this.noteList,
  });

  @override
  ConsumerState<NoteList> createState() => _NoteListState();
}

class _NoteListState extends ConsumerState<NoteList> {
  bool _isAscendingOrder = true;
  bool _isMultiPleSelectorVisible = false;
  String _selectingViewStyle = 'list';
  final Set<Note> _selectedNote = HashSet();

  void _sortNotes(String sortType) {
    if (sortType == 'Tiêu đề') {
      if (_isAscendingOrder) {
        widget.noteList.sort(
          (a, b) => a.title.compareTo(b.title),
        );
      } else {
        widget.noteList.sort(
          (a, b) => b.title.compareTo(a.title),
        );
      }
    } else if (sortType == 'Ngày tạo') {
      if (_isAscendingOrder) {
        widget.noteList.sort(
          (a, b) => a.dateCreated.compareTo(b.dateCreated),
        );
      } else {
        widget.noteList.sort(
          (a, b) => b.dateCreated.compareTo(a.dateCreated),
        );
      }
    } else {
      if (_isAscendingOrder) {
        widget.noteList.sort(
          (a, b) {
            if (a.dateEdited == null || b.dateEdited == null) {
              return 0;
            }
            return a.dateEdited!.compareTo(b.dateEdited!);
          },
        );
      } else {
        widget.noteList.sort(
          (a, b) {
            if (a.dateEdited == null || b.dateEdited == null) {
              return 0;
            }
            return b.dateEdited!.compareTo(a.dateEdited!);
          },
        );
      }
    }
  }

  void doMultipleSelection(Note note) {
    if (_isMultiPleSelectorVisible) {
      if (_selectedNote.contains(note)) {
        _selectedNote.remove(note);
      } else {
        _selectedNote.add(note);
      }
    }

    ref.watch(selectedNoteProvider.notifier).updateSelectedNotes(_selectedNote);
    ref.watch(selectedNotesCountProvider.notifier).update(_selectedNote.length);
  }

  @override
  Widget build(BuildContext context) {
    String selectingValue = 'Tiêu đề';

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  backgroundColor: _selectingViewStyle == 'grid'
                      ? Colors.black12
                      : Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _selectingViewStyle = 'grid';
                      });
                    },
                    icon: const Icon(Icons.grid_view_outlined),
                  ),
                ),
              ),
              const VerticalDivider(
                width: 3,
                thickness: 1,
                indent: 20,
                endIndent: 16,
                color: Colors.grey,
              ),
              CircleAvatar(
                backgroundColor: _selectingViewStyle == 'list'
                    ? Colors.black12
                    : Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _selectingViewStyle = 'list';
                    });
                  },
                  icon: const Icon(Icons.view_list_outlined),
                ),
              ),
              const Spacer(),
              DropdownMenu(
                initialSelection: selectingValue,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(
                    value: 'Tiêu đề',
                    label: 'Tiêu đề',
                  ),
                  DropdownMenuEntry(
                    value: 'Ngày tạo',
                    label: 'Ngày tạo',
                  ),
                  DropdownMenuEntry(
                    value: 'Ngày sửa đổi',
                    label: 'Ngày sửa đổi',
                  ),
                ],
                onSelected: (value) {
                  setState(() {
                    selectingValue = value!;
                    _sortNotes(value);
                  });
                },
              ),
              IconButton(
                tooltip: _isAscendingOrder ? 'Giảm dần' : 'Tăng dần',
                onPressed: () {
                  setState(() {
                    _isAscendingOrder = !_isAscendingOrder;
                    _sortNotes(selectingValue);
                  });
                },
                icon: Icon(
                  _isAscendingOrder
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_selectingViewStyle == 'list')
          Expanded(
            child: ListView.builder(
              itemCount: widget.noteList.length,
              padding: const EdgeInsets.all(13),
              itemBuilder: (context, index) => InkWell(
                onLongPress: () {
                  setState(() {
                    _isMultiPleSelectorVisible = !_isMultiPleSelectorVisible;
                    _selectedNote.clear();
                    ref
                        .read(multipleSelectionFunctionProvider.notifier)
                        .showScreen(_isMultiPleSelectorVisible);
                  });
                },
                child: Stack(
                  children: [
                    AbsorbPointer(
                      absorbing: _isMultiPleSelectorVisible,
                      child: NoteItem(
                        key: ValueKey(widget.noteList[index].id),
                        note: widget.noteList[index],
                      ),
                    ),
                    Visibility(
                      visible: _isMultiPleSelectorVisible,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              doMultipleSelection(widget.noteList[index]);
                            });
                          },
                          icon: !_selectedNote.contains(widget.noteList[index])
                              ? const Icon(Icons.circle_outlined)
                              : const Icon(
                                  Icons.check_circle,
                                  color: Colors.red,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: widget.noteList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) => InkWell(
                onLongPress: () {
                  setState(() {
                    _isMultiPleSelectorVisible = !_isMultiPleSelectorVisible;
                    _selectedNote.clear();
                    ref
                        .read(multipleSelectionFunctionProvider.notifier)
                        .showScreen(_isMultiPleSelectorVisible);
                  });
                },
                child: Stack(
                  children: [
                    AbsorbPointer(
                      absorbing: _isMultiPleSelectorVisible,
                      child: NoteGridViewItem(
                        key: ValueKey(widget.noteList[index].id),
                        note: widget.noteList[index],
                      ),
                    ),
                    Visibility(
                      visible: _isMultiPleSelectorVisible,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              doMultipleSelection(widget.noteList[index]);
                            });
                          },
                          icon: !_selectedNote.contains(widget.noteList[index])
                              ? const Icon(Icons.circle_outlined)
                              : const Icon(
                                  Icons.check_circle,
                                  color: Colors.red,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }
}
