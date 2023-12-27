import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';
import 'rating_screen.dart';

class MusicPlayerScreen extends StatefulWidget {
  final Song currentSong;

  MusicPlayerScreen({required this.currentSong});

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer _audioPlayer;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0; // Added for volume control
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(_volume); // Initialize the volume

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    _playMusic(widget.currentSong.audioPreviewUrl);
  }

  Future<void> _playMusic(String url) async {
    await _audioPlayer.play(UrlSource(url));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Now Playing'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.star_rate), // Using a star icon for the rating button
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RatingScreen(currentSong: widget.currentSong),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(widget.currentSong.albumCover, height: 250, width: 250, fit: BoxFit.cover),
            SizedBox(height: 20),
            Text(widget.currentSong.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(widget.currentSong.artists.toString(), style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatDuration(_position)),
                Text(formatDuration(_duration)),
              ],
            ),
            Slider(
              value: _position.inSeconds.toDouble(),
              min: 0.0,
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) async {
                await _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: () {
                  },
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (_isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.resume();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volume_mute),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (newVolume) {
                      setState(() {
                        _volume = newVolume;
                        _audioPlayer.setVolume(_volume);
                      });
                    },
                  ),
                ),
                Icon(Icons.volume_up),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
