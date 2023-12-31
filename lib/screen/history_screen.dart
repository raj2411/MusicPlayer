// history_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'player_screen.dart';
import 'favorites_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Song> historySongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    var response = await http.get(Uri.parse('http://192.168.2.31:5000/history?userId=$userId'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as List;
      setState(() {
        historySongs = data.map((songData) => Song.fromJson(songData)).toList();
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your History'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: historySongs.length,
        itemBuilder: (context, index) {
          var song = historySongs[index];
          return ListTile(
            leading: Image.network(song.albumCover, fit: BoxFit.cover),
            title: Text(song.title),
            subtitle: Text(song.artists.join(", ")),
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
