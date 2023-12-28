import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';

class RatingScreen extends StatefulWidget {
  final Song currentSong;

  RatingScreen({required this.currentSong});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  String? capturedImagePath;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    bool isCameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    bool isStorageGranted = statuses[Permission.storage]?.isGranted ?? false;

    if (!isCameraGranted || !isStorageGranted) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Permissions error'),
            content: Text(
                'Camera and Storage permissions are needed to take and save pictures.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ));
      print('Camera or Storage permission denied');
    } else {
      initializeCamera();
    }
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    CameraDescription camera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first);

    _cameraController = CameraController(camera, ResolutionPreset.high);
    try {
      await _cameraController!.initialize();
    } on CameraException catch (e) {
      // Handle exception
      print('Error initializing camera: $e');
    }
  }

  Future<XFile?> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }

    if (_cameraController!.value.isTakingPicture) {
      // Handle this case as needed
      return null;
    }

    try {
      XFile picture = await _cameraController!.takePicture();
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${appDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);

      final String filePath = '$dirPath/${path.basename(picture.path)}';
      File savedImage = await File(picture.path).copy(filePath);

      setState(() {
        capturedImagePath = savedImage.path;
      });

      return XFile(savedImage.path);
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _submitRating() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    XFile? pictureFile = await takePicture();
    if (pictureFile != null) {
      print("Captured Image Path: ${pictureFile.path}");
      String fileName = path.basename(capturedImagePath!);
      Reference storageReference =
      FirebaseStorage.instance.ref().child("images/$userId/$fileName");
      UploadTask uploadTask = storageReference.putFile(File(capturedImagePath!));

      try {
        TaskSnapshot taskSnapshot = await uploadTask;
        if (taskSnapshot.state == TaskState.success) {
          String imageUrl = await taskSnapshot.ref.getDownloadURL();

          var request = http.MultipartRequest(
            'POST',
            Uri.parse('http://192.168.2.31:5000/submit-rating'),
          );
          request.fields['userId'] = userId;
          request.fields['trackId'] = widget.currentSong.id;
          request.fields['rating'] = _rating.toString();
          request.fields['imageUrl'] = imageUrl;

          var response = await request.send();
          if (response.statusCode == 200) {
            print('Rating submitted successfully');
          } else {
            print('Failed to submit rating: ${response.statusCode}');
          }
        } else {
          print('Upload task did not complete successfully.');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print("Error taking picture or file not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate ${widget.currentSong.title}')),
      body: SingleChildScrollView( // Make the column scrollable
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rate this song:', style: TextStyle(fontSize: 20)),
              if (capturedImagePath != null)
                Image.file(File(capturedImagePath!)),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _submitRating,
                child: Text('Submit Rating'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
