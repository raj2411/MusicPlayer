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
  late List<CameraDescription> cameras;
  String? capturedImagePath; // Variable to store image path

  @override
  void initState() {
    super.initState();
    requestCameraPermission();
    requestPermissions();
  }

  void requestPermissions() async {
    await [
      Permission.camera,
      Permission.storage, // This is for both read and write storage permissions
    ].request();
    initializeCamera();
  }

  void requestCameraPermission() async {
    var permissionStatus = await Permission.camera.request();

    if (permissionStatus.isGranted) {
      initializeCamera();
    } else {
      print('Camera permission denied');
    }
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    CameraDescription frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
  }

  Future<XFile?> takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }

    if (_cameraController!.value.isTakingPicture) {
      return null;
    }

    try {
      XFile picture = await _cameraController!.takePicture();

      // Get the external documents directory
      final Directory? extDir = await getExternalStorageDirectory();
      final String dirPath = '${extDir?.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);

      // Copy the file to the new path
      final String filePath = '$dirPath/${path.basename(picture.path)}';
      await File(picture.path).copy(filePath);

      setState(() {
        capturedImagePath = filePath; // Update the path after copying
      });

      return XFile(filePath); // Return the new file
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
      Reference storageReference = FirebaseStorage.instance.ref().child("images/$userId/$fileName");
      UploadTask uploadTask = storageReference.putFile(File(capturedImagePath!));
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.2.13:5000/submit-rating'),
      );
      request.fields['userId'] = userId;
      request.fields['trackId'] = widget.currentSong.id;
      request.fields['rating'] = _rating.toString();
      request.fields['imageUrl'] = imageUrl;

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Rating submitted successfully');
      } else {
        print('Failed to submit rating');
      }
      Navigator.pop(context);
    } else {
      print("Error taking picture or file not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate ${widget.currentSong.title}')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rate this song:', style: TextStyle(fontSize: 20)),
            if (capturedImagePath != null) // Display the captured image
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
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
