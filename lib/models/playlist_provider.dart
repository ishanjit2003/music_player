import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:music_player/models/song.dart';

class PlaylistProvider extends ChangeNotifier {
  // Playlist of songs
  final List<Song> _playlist = [
    Song(
        songName: "Tum se hi",
        artistName: "Diya",
        albumArtImagepath: "assets/images/album1.jpg",
        audioPath: "audio/tum_se_hi.mp3"),
    Song(
        songName: "Tum se hi",
        artistName: "Minna",
        albumArtImagepath: "assets/images/album2.jpg",
        audioPath: "audio/tum_se_hi.mp3"),
    Song(
        songName: "Tum se hi",
        artistName: "Nora",
        albumArtImagepath: "assets/images/album3.jpg",
        audioPath: "audio/tum_se_hi.mp3"),
  ];

  // Current song playing index
  int? _currentSongIndex;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Durations
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Constructor
  PlaylistProvider() {
    listenToDuration();
  }

  // Initially not playing
  bool _isPlaying = false;

  // Play the song
  void play() async {
    if (_currentSongIndex == null) return;
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop(); // Stop current song
    await _audioPlayer.play(AssetSource(path)); // Play the new song
    _isPlaying = true;
    notifyListeners();
  }

  // Pause current song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // Resume playing
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // Pause or resume
  void pauseOrResume() async {
    if (_isPlaying) {
       pause();
    } else {
       resume();
    }
    notifyListeners();
  }

  // Seek to a specific position in the current song
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Play next song
  void playNextSong() {
    if (_currentSongIndex != null) {
      if (_currentSongIndex! < _playlist.length - 1) {
        // Go to the next song if it's not the last song
        currentSongIndex = _currentSongIndex! + 1;
      } else {
        // If it is the last song, loop back to the first song
        currentSongIndex = 0;
      }
    }
  }

  // Play previous song
  void playPreviousSong() async {
    if (_currentDuration.inSeconds > 2) {
      // If it's within the first 2 seconds of the song, go to the previous song
      seek(Duration.zero);
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        // If it's the first song, loop back to the last song
        currentSongIndex = _playlist.length - 1;
      }
    }
  }

  // Listen to durations
  void listenToDuration() {
    // Listen for total duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    // Listen for current duration
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    // Listen for song completion
    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }

  // Dispose audio player
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Getters
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  // Setters
  set currentSongIndex(int? newIndex) {
    // Update current song index
    _currentSongIndex = newIndex;

    if (newIndex != null) {
      play(); // Play the song at the new index
    }

    // Update UI
    notifyListeners();
  }
}
