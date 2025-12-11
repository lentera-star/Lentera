// TEMPORARY STUB: Audio service disabled for web compatibility
// For Android/iOS, uncomment flutter_sound in pubspec.yaml and use full implementation

class AudioService {
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;

  // Initialize recorder (stub)
  Future<void> initRecorder() async {
    print('⚠️ Audio recording not available on web platform');
    _isRecorderInitialized = true;
  }

  // Initialize player (stub)
  Future<void> initPlayer() async {
    print('⚠️ Audio playback not available on web platform');
    _isPlayerInitialized = true;
  }

  // Start recording (stub)
  Future<void> startRecording(String path) async {
    print('⚠️ Recording not supported on web');
  }

  // Stop recording (stub)
  Future<String?> stopRecording() async {
    print('⚠️ Recording not supported on web');
    return null;
  }

  // Play audio (stub)
  Future<void> playAudio(String path) async {
    print('⚠️ Audio playback not supported on web');
  }

  // Dispose (stub)
  void dispose() {
    print('AudioService disposed');
  }
}
