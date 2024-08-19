import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import 'package:notes/models/note.dart';
import 'package:notes/providers/multiple_selection_function.dart';
import 'package:notes/widgets/notes_views/note_grid_view_item.dart';
import 'package:notes/widgets/notes_views/note_list_item.dart';

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
  final List<Note> _selectedNote = [];
  String _selectingValue = 'Tiêu đề';

  late final LocalAuthentication auth;

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
  }

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

    final pinnedNotes = widget.noteList.where((note) => note.isPinned).toList();
    widget.noteList.removeWhere((note) => pinnedNotes.contains(note));
    widget.noteList.insertAll(0, pinnedNotes);
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

  Future<void> _authenticate(Note note) async {
    try {
      bool authenticate = await auth.authenticate(
        localizedReason: 'Quét vân tay để mở khoá',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      if (authenticate) {
        setState(() {
          note.toggleNoteLocker();
        });
      }
    } on PlatformException {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
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
                indent: 12,
                endIndent: 12,
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
              DropdownButton(
                borderRadius: BorderRadius.circular(12),
                value: _selectingValue,
                items: const [
                  DropdownMenuItem(
                    value: 'Tiêu đề',
                    child: Text('Tiêu đề'),
                  ),
                  DropdownMenuItem(
                    value: 'Ngày tạo',
                    child: Text('Ngày tạo'),
                  ),
                  DropdownMenuItem(
                    value: 'Ngày sửa đổi',
                    child: Text('Ngày sửa đổi'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectingValue = value!;
                    _sortNotes(value);
                  });
                },
              ),
              IconButton(
                tooltip: _isAscendingOrder ? 'Giảm dần' : 'Tăng dần',
                onPressed: () {
                  setState(() {
                    _isAscendingOrder = !_isAscendingOrder;
                    _sortNotes(_selectingValue);
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
                onTap: () {
                  if (!widget.noteList[index].isLocked) {
                    return;
                  }
                  _authenticate(widget.noteList[index]);
                },
                child: Stack(
                  children: [
                    AbsorbPointer(
                      absorbing: _isMultiPleSelectorVisible,
                      child: NoteListItem(
                        key: ValueKey(widget.noteList[index].id),
                        note: widget.noteList[index],
                      ),
                    ),
                    Visibility(
                      visible: _isMultiPleSelectorVisible,
                      child: Align(
                        alignment: Alignment.topLeft,
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
                onTap: () {
                  if (!widget.noteList[index].isLocked) {
                    return;
                  }
                  _authenticate(widget.noteList[index]);
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
