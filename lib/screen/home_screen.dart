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
  Map<String, List<Song>> genreBasedSongs = {};
  List<String> userPreferences = [];
  List<Song> historySongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
  }

  Future<void> fetchUserPreferences() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    var userPrefsResponse = await http.get(Uri.parse('http://192.168.2.31:5000/user-preferences?userId=$userId'));
    if (userPrefsResponse.statusCode == 200) {
      var decodedResponse = json.decode(userPrefsResponse.body);
      if (decodedResponse is List) {
        userPreferences = List<String>.from(decodedResponse);
      } else if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey('preferences')) {
        userPreferences = List<String>.from(decodedResponse['preferences']);
      }
      if (mounted) {
        fetchSongsForGenres();
        fetchHistory();
      }
    }
  }

  Future<void> fetchSongsForGenres() async {
    for (String genre in userPreferences) {
      var response = await http.get(Uri.parse('http://192.168.2.31:5000/recommendedsongs?userId=${FirebaseAuth.instance.currentUser?.uid}&genre=$genre'));
      if (response.statusCode == 200) {
        List<Song> songs = (json.decode(response.body) as List).map((songData) => Song.fromJson(songData)).toList();
        if (mounted) {
          setState(() {
            genreBasedSongs[genre.trim()] = songs;
          });
        }
      }
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchHistory() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    var response = await http.get(Uri.parse('http://192.168.2.31:5000/history?userId=$userId'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as List;
      if (mounted) {
        setState(() {
          historySongs = data.map((songData) => Song.fromJson(songData)).toList();
        });
      }
    }
  }

  Future<void> _addSongToHistoryAndNavigate(Song song) async {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final String songId = song.id;
    final response = await http.post(
      Uri.parse('http://192.168.2.31:5000/update-history'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'songId': songId}),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MusicPlayerScreen(currentSong: song),
        ),
      );
    } else {
      print('Failed to update history');
      // Handle the error here
    }
  }

  Widget buildSongList(List<Song> songs, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              var song = songs[index];
              return GestureDetector(
                onTap: () => _addSongToHistoryAndNavigate(song),
                child: Container(
                  width: 160,
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(song.albumCover, fit: BoxFit.cover),
                      ),
                      SizedBox(height: 8),
                      Text(song.title, style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
                      Text(song.artists.join(", "), style: TextStyle(fontSize: 14, color: Colors.grey), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
        actions: [
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
          : SingleChildScrollView(
        child: Column(
          children: [
            ...userPreferences.map((genre) => buildSongList(genreBasedSongs[genre] ?? [], genre)).toList(),
            buildSongList(historySongs, "Your History"),
          ],
        ),
      ),
    );
  }
}
