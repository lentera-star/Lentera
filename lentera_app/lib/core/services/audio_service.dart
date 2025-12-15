import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;

  /// Initialize recorder
  Future<void> initRecorder() async {
    _recorder = FlutterSoundRecorder();
    
// Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    await _recorder!.openRecorder();
    _isRecorderInitialized = true;
    debugPrint('Recorder initialized');
  }

  /// Initialize player
  Future<void> initPlayer() async {
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
    _isPlayerInitialized = true;
    debugPrint('Player initialized');
  }

  /// Start recording
  Future<String> startRecording() async {
    if (!_isRecorderInitialized) {
      await initRecorder();
    }

    // Get temp directory for recording
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/mood_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder!.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
      bitRate: 128000,
      sampleRate: 44100,
    );

    debugPrint('Recording started: $path');
    return path;
  }

  /// Stop recording and return file path
  Future<String?> stopRecording() async {
    if (!_isRecorderInitialized || _recorder == null) {
      return null;
    }

    final path = await _recorder!.stopRecorder();
    debugPrint('Recording stopped: $path');
    return path;
  }

  /// Check if currently recording
  bool get isRecording => _recorder?.isRecording ?? false;

  /// Play audio from file
  Future<void> playAudio(String path) async {
    if (!_isPlayerInitialized) {
      await initPlayer();
    }

    await _player!.startPlayer(
      fromURI: path,
      codec: Codec.aacADTS,
    );

    debugPrint('Playing audio: $path');
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    if (_isPlayerInitialized && _player != null) {
      await _player!.stopPlayer();
    }
  }

  /// Check if currently playing
  bool get isPlaying => _player?.isPlaying ?? false;

  /// Dispose resources
  Future<void> dispose() async {
    if (_recorder != null) {
      await _recorder!.closeRecorder();
      _recorder = null;
    }
    if (_player != null) {
      await _player!.closePlayer();
      _player = null;
    }
    _isRecorderInitialized = false;
    _isPlayerInitialized = false;
    debugPrint('AudioService disposed');
  }
}
