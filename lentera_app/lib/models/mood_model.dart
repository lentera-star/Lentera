/// Mood entry model matching mood_entries table
class MoodEntry {
  final String id;
  final String userId;
  final int moodScore; // 1-5
  final String? journalText;
  final String? audioPath; // Supabase Storage path
  final String? transcription;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodScore,
    this.journalText,
    this.audioPath,
    this.transcription,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      moodScore: json['mood_score'] as int,
      journalText: json['journal_text'] as String?,
      audioPath: json['audio_path'] as String?,
      transcription: json['transcription'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood_score': moodScore,
      'journal_text': journalText,
      'audio_path': audioPath,
      'transcription': transcription,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with for immutability
  MoodEntry copyWith({
    String? id,
    String? userId,
    int? moodScore,
    String? journalText,
    String? audioPath,
    String? transcription,
    DateTime? createdAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodScore: moodScore ?? this.moodScore,
      journalText: journalText ?? this.journalText,
      audioPath: audioPath ?? this.audioPath,
      transcription: transcription ?? this.transcription,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MoodEntry(id: $id, userId: $userId, moodScore: $moodScore, createdAt: $createdAt)';
  }
}
