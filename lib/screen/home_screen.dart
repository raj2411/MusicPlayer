import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import 'login_screen.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> recommendedSongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    try {
      String email = FirebaseAuth.instance.currentUser?.email ?? "";
      print("Fetching songs for email: $email");
      var url = Uri.parse('http://127.0.0.1:5000/recommended-songs?email=$email');
      var response = await http.get(url);
      print("Received response: ${response.statusCode}");
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        print("Data received: $data");
        setState(() {
          recommendedSongs = data.map((songData) => Song.fromJson(songData)).toList();
          isLoading = false;
        });
      } else {
        print("Failed to load songs. Status code: ${response.statusCode}");
        throw Exception('Failed to load songs');
      }
    } catch (e) {
      print("Error fetching songs: ${e.toString()}");
      setState(() => isLoading = false);
    }
  }

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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: recommendedSongs.length,
        itemBuilder: (context, index) {
          var song = recommendedSongs[index];
          return ListTile(
            leading: Image.network(song.albumCover),
            title: Text(song.title),
            subtitle: Text(song.artists.toString()),
            onTap: () {
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
