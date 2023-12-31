import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import './app_utils.dart';
import 'login_screen.dart';
import 'player_screen.dart';
import 'history_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorites_screen.dart';




class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> favoriteSongs = [];
  int _selectedIndex = 0; // New variable for tracking the selected index
  Map<String, List<Song>> genreBasedSongs = {};
  List<String> userPreferences = [];
  List<Song> historySongs = [];
  bool isLoading = true;

  // Define userFavorites as a list of strings
  List<String> userFavorites = [];

  Future<void> fetchUserFavorites() async {
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
  void initState() {
    super.initState();
    fetchUserPreferences();
    fetchUserFavorites();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchUserPreferences() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    var userPrefsResponse = await http.get(Uri.parse('${backendUrl}/user-preferences?userId=$userId'));
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
      var response = await http.get(Uri.parse('${backendUrl}/recommendedsongs?userId=${FirebaseAuth.instance.currentUser?.uid}&genre=$genre'));
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
    var response = await http.get(Uri.parse('${backendUrl}/history?userId=$userId'));
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
      Uri.parse('${backendUrl}/update-history'),
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

  List<Widget> _widgetOptions() {
    return [
      // Replace with your actual home screen widget
      SingleChildScrollView(
        child: Column(
          children: [
            ...userPreferences.map((genre) => buildSongList(genreBasedSongs[genre] ?? [], genre)).toList(),
            buildSongList(historySongs, "Your History"),
          ],
        ),
      ),
      // Replace with your actual favorites widget
      FavoritesScreen(favoriteSongs: favoriteSongs),
      // Replace with your actual profile management widget
      HistoryScreen(), // Add this

      // ProfileScreen(), // Uncomment and implement the ProfileScreen widget
      Text('Profile Management Placeholder'),
    ];
  }

  Widget buildFavoritesList(List<Song> favoriteSongs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text("Your Favorites", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: favoriteSongs.length,
            itemBuilder: (context, index) {
              var song = favoriteSongs[index];
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
      body: isLoading ? Center(child: CircularProgressIndicator()) : _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), // This is new
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorPrimary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
