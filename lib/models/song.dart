class Song {
  String id;
  String title;
  List<String> artists;
  String albumName;
  String albumId;
  String albumCover;
  String audioPreviewUrl;

  Song({
    required this.id,
    required this.title,
    required this.artists,
    required this.albumName,
    required this.albumId,
    required this.albumCover,
    required this.audioPreviewUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['track_id'] as String,
      title: json['track_name'] as String,
      artists: List<String>.from(json['artist_names']),
      albumName: json['album_name'] as String,
      albumId: json['album_id'] as String,
      albumCover: json['album_cover'] as String,
      audioPreviewUrl: json['audio_preview_url'] as String,
    );
  }
}
