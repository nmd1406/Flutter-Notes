import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';

import 'package:notes/models/note.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/widgets/file_view/files_grid_view.dart';

class NoteDetailsScreen extends ConsumerStatefulWidget {
  final Note note;

  const NoteDetailsScreen({
    super.key,
    required this.note,
  });

  @override
  ConsumerState<NoteDetailsScreen> createState() {
    return _NoteDetailsScreenState();
  }
}

class _NoteDetailsScreenState extends ConsumerState<NoteDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _hasAddress = false;
  late final List<PlatformFile> _pickedFiles = [];
  late double _latitude;
  late double _longitude;
  String? _address;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEditedNote() {
    String editedTitle = _titleController.text.trim().isEmpty
        ? 'Tiêu đề'
        : _titleController.text.trim();
    String editedContent =
        _contentController.text.trim().isEmpty ? '' : _contentController.text;
    DateTime date = DateTime.now();

    ref.watch(notesProvider.notifier).saveEditedNote(
          widget.note,
          editedTitle,
          editedContent,
          date,
          _pickedFiles.toList(),
        );

    if (_address != null) {
      ref
          .watch(notesProvider.notifier)
          .updateUserLocation(widget.note, _address!);
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 3),
        content: Text('Đã lưu thay đổi'),
      ),
    );

    setState(() {
      _pickedFiles.clear();
      _address = null;
    });
  }

  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) {
      return;
    }

    setState(() {
      _pickedFiles.addAll(result.files);
    });
  }

  Future<File> _saveFile(PlatformFile file) {
    final appDir = getApplicationDocumentsDirectory();
    final newFile = File('$appDir/${file.name}');

    return File(file.path!).copy(newFile.path);
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _liveLocation() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((postion) {
      setState(() {
        _latitude = postion.latitude;
        _longitude = postion.longitude;
      });
    });
    final placemarks = await placemarkFromCoordinates(_latitude, _longitude);
    setState(() {
      _address =
          "${placemarks[0].street}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}, ${placemarks[0].country}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autocorrect: false,
          controller: _titleController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Tiêu đề',
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Lưu thay đổi',
            onPressed: _saveEditedNote,
            icon: const Icon(Icons.save_outlined),
          ),
          IconButton(
            tooltip: 'Tìm kiếm',
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          PopupMenuButton(
            tooltip: 'Tuỳ chọn khác',
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _pickFiles,
                child: const ListTile(
                  leading: Icon(Icons.attach_file_rounded),
                  title: Text('Đính kèm tệp'),
                ),
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.star_border),
                  title: Text('Thêm vào mục yêu thích'),
                ),
                onTap: () {},
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.lock_open),
                  title: Text('Mở khoá'),
                ),
                onTap: () {},
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Xoá'),
                ),
                onTap: () {},
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.location_on_outlined),
                  title: Text('Vị trí của tôi'),
                ),
                onTap: () {
                  _getCurrentPosition().then((location) {
                    setState(() {
                      _latitude = location.latitude;
                      _longitude = location.longitude;
                      _hasAddress = true;
                    });
                    _liveLocation();
                  });
                },
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              autocorrect: false,
              controller: _contentController,
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
            ),
            if (_pickedFiles.isNotEmpty)
              FileGridView(files: [...widget.note.files, ..._pickedFiles])
            else
              FileGridView(files: widget.note.files),
            const SizedBox(height: 30),
            if (_hasAddress || widget.note.address != null)
              Text(
                ('Vị trí hiện tại: ${_address ?? widget.note.address}'),
                style: Theme.of(context).textTheme.labelSmall,
              )
          ],
        ),
      ),
    );
  }
}
