import 'package:flutter/material.dart';
import '../models/song.dart';
import 'player_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import './app_utils.dart';


class FavoritesScreen extends StatefulWidget {
  final List<Song> favoriteSongs;

  FavoritesScreen({required this.favoriteSongs});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Song> favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    fetchFavoriteSongs(); // Call the function to fetch favorite songs
  }

  Future<void> fetchFavoriteSongs() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final response = await http.get(
      Uri.parse('${backendUrl}/favorite-songs?userId=$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> decodedResponse = json.decode(response.body);
      final List<Song> songs = decodedResponse.map((songData) => Song.fromJson(songData)).toList();

      setState(() {
        favoriteSongs = songs;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Favorites'),
      ),
      body: ListView.builder(
        itemCount: widget.favoriteSongs.length,
        itemBuilder: (context, index) {
          var song = widget.favoriteSongs[index];
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
