class MoodEntry {
  final String id;
  final String userId;
  final int moodRating;
  final List<String> moodTags;
  final String? journalText;
  final String? audioUrl;
  final String? transcription;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodRating,
    required this.moodTags,
    this.journalText,
    this.audioUrl,
    this.transcription,
    required this.createdAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    T? _firstOfKeys<T>(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) {
          return json[k] as T?;
        }
      }
      return null;
    }

    int _parseInt(dynamic v, {int fallback = 3}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final p = int.tryParse(v);
        if (p != null) return p;
      }
      return fallback;
    }

    List<String> _parseStringList(dynamic v) {
      if (v == null) return <String>[];
      if (v is List) {
        return v.map((e) => e.toString()).toList();
      }
      if (v is String) {
        // support comma-separated tags
        return v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return <String>[];
    }

    final id = _firstOfKeys<String>(['id']) ?? '';
    final userId = _firstOfKeys<String>(['user_id', 'userId']) ?? '';
    final ratingRaw = _firstOfKeys<dynamic>(['mood_rating', 'rating', 'score']);
    final moodRating = _parseInt(ratingRaw, fallback: 3);
    final tagsRaw = _firstOfKeys<dynamic>(['mood_tags', 'tags', 'labels']);
    final moodTags = _parseStringList(tagsRaw);
    final journalText = _firstOfKeys<String>([
      'journal_text',
      'journal',
      'note',
      'notes',
      'description',
    ]);
    final audioUrl = _firstOfKeys<String>(['audio_url', 'audioUrl']);
    final transcription = _firstOfKeys<String>(['transcription']);
    final createdAtRaw = _firstOfKeys<dynamic>(['created_at', 'createdAt', 'created']);
    final createdAt = (createdAtRaw is DateTime
            ? createdAtRaw
            : (createdAtRaw is String
                ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
                : DateTime.now()))
        .toLocal();

    return MoodEntry(
      id: id,
      userId: userId,
      moodRating: moodRating,
      moodTags: moodTags,
      journalText: journalText,
      audioUrl: audioUrl,
      transcription: transcription,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'mood_rating': moodRating,
    'mood_tags': moodTags,
    'journal_text': journalText,
    'audio_url': audioUrl,
    'transcription': transcription,
    'created_at': createdAt.toIso8601String(),
  };

  MoodEntry copyWith({
    String? id,
    String? userId,
    int? moodRating,
    List<String>? moodTags,
    String? journalText,
    String? audioUrl,
    String? transcription,
    DateTime? createdAt,
  }) => MoodEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    moodRating: moodRating ?? this.moodRating,
    moodTags: moodTags ?? this.moodTags,
    journalText: journalText ?? this.journalText,
    audioUrl: audioUrl ?? this.audioUrl,
    transcription: transcription ?? this.transcription,
    createdAt: createdAt ?? this.createdAt,
  );
}
