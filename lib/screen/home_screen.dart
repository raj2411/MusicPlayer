import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/screen/player_screen.dart';
import '../models/song.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  // Dummy list of songs
  final List<Song> recommendedSongs = [
    Song(title: "Song 1", artist: "Artist 1", imageUrl: "https://dummyimage.com/300.png/09f/fff", audioUrl: "https://file-examples.com/storage/fee4e04377657b56c9a6785/2017/11/file_example_MP3_5MG.mp3"),
    Song(title: "Song 2", artist: "Artist 2", imageUrl: "https://dummyimage.com/300.png/09f/fff", audioUrl: "https://file-examples.com/storage/fee4e04377657b56c9a6785/2017/11/file_example_MP3_5MG.mp3"),

  ];

  @override
  Widget build(BuildContext context) {
    String userName = FirebaseAuth.instance.currentUser?.email ?? "No name available";
    print("Current logged-in user's name: $userName");

    return Scaffold(
      appBar: AppBar(
        title: Text('Recommended Songs'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: recommendedSongs.length,
        itemBuilder: (context, index) {
          var song = recommendedSongs[index];
          return ListTile(
            leading: Image.network(song.imageUrl),
            title: Text(song.title),
            subtitle: Text(song.artist),
            onTap: () {
              // Navigate to the music player screen with the selected song
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicPlayerScreen(currentSong: song),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
