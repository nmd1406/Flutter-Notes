import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:notes/providers/notes_provider.dart';
import 'package:notes/widgets/files_grid_view.dart';

class NewNoteScreen extends ConsumerStatefulWidget {
  const NewNoteScreen({super.key});

  @override
  ConsumerState<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends ConsumerState<NewNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<PlatformFile> _pickedFiles = [];
  late double _latitude;
  late double _longitude;
  String? _address;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNewNote() {
    String enteredTitle = _titleController.text.trim().isEmpty
        ? 'Tiêu đề'
        : _titleController.text.trim();
    String enteredContent =
        _contentController.text.trim().isEmpty ? '' : _contentController.text;
    DateTime date = DateTime.now();

    ref.watch(notesProvider.notifier).addNewNote(
        enteredTitle, enteredContent, date, _pickedFiles.toList(), _address);

    setState(() {
      _pickedFiles.clear();
      _address = null;
    });

    Navigator.of(context).pop();
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
        actions: [
          IconButton(
            tooltip: 'Lưu',
            onPressed: _saveNewNote,
            icon: const Icon(Icons.save_outlined),
          ),
          IconButton(
            tooltip: 'Đính kèm tệp',
            onPressed: _pickFiles,
            icon: const Icon(Icons.attach_file_rounded),
          ),
          IconButton(
            tooltip: 'Vị trí của tôi',
            onPressed: () {
              _getCurrentPosition().then((location) {
                setState(() {
                  _latitude = location.latitude;
                  _longitude = location.longitude;
                });
                _liveLocation();
              });
            },
            icon: const Icon(Icons.location_on_outlined),
          )
        ],
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Tiêu đề',
            border: InputBorder.none,
          ),
        ),
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
            FileGridView(files: _pickedFiles.toList()),
            const SizedBox(height: 50),
            if (_address != null)
              Text(
                ('Vị trí hiện tại: $_address'),
                style: Theme.of(context).textTheme.labelSmall,
              )
          ],
        ),
      ),
    );
  }
}
