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
  List<Song> historySongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSongs();
    fetchHistory();
  }

  Future<void> fetchSongs() async {
    try {
      String email = FirebaseAuth.instance.currentUser?.email ?? "";
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      var url = Uri.parse('http://192.168.2.31:5000/recommended-songs?userId=$userId');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
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

  Future<void> fetchHistory() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      var response = await http.get(Uri.parse('http://192.168.2.31:5000/history?userId=$userId'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        setState(() {
          historySongs = data.map((songData) => Song.fromJson(songData)).toList();
        });
      } else {
        print("Failed to fetch history. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching history: ${e.toString()}");
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
            buildSongList(recommendedSongs, "Recommended Songs"),
            buildSongList(historySongs, "Your History"),
          ],
        ),
      ),
    );
  }
}
