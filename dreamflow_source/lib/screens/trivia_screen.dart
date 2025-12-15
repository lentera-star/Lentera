import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/theme.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  bool _inIntro = true;
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  // Ensure users always see education even if state restores directly to quiz
  // We'll render a compact education card above the quiz as well.

  final List<Map<String, dynamic>> _trivias = [
    {
      'question': 'Berapa lama waktu tidur yang ideal untuk orang dewasa?',
      'options': ['5-6 jam', '7-9 jam', '10-12 jam', '4-5 jam'],
      'correctAnswer': '7-9 jam',
      'explanation': 'Orang dewasa membutuhkan 7-9 jam tidur per malam untuk kesehatan optimal.',
    },
    {
      'question': 'Apa yang dimaksud dengan mindfulness?',
      'options': [
        'Berpikir tentang masa lalu',
        'Fokus pada saat ini',
        'Merencanakan masa depan',
        'Multitasking'
      ],
      'correctAnswer': 'Fokus pada saat ini',
      'explanation': 'Mindfulness adalah praktik untuk fokus pada momen saat ini tanpa judgment.',
    },
    {
      'question': 'Aktivitas fisik yang disarankan per minggu adalah?',
      'options': ['30 menit', '75 menit', '150 menit', '300 menit'],
      'correctAnswer': '150 menit',
      'explanation': 'WHO merekomendasikan 150 menit aktivitas fisik intensitas sedang per minggu.',
    },
  ];

  Map<String, dynamic> get _currentTrivia => _trivias[_currentIndex];

  void _checkAnswer() {
    setState(() => _showResult = true);
  }

  void _nextTrivia() {
    if (_currentIndex < _trivias.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Selesai!',
              style: context.textStyles.headlineSmall?.semiBold,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Anda telah menyelesaikan trivia hari ini',
              style: context.textStyles.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text(
              'Kembali',
              style: context.textStyles.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect = _selectedAnswer == _currentTrivia['correctAnswer'];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Daily Trivia', style: context.textStyles.titleLarge?.semiBold),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: AppSpacing.paddingLg,
        child: _inIntro ? _buildIntro(context) : _buildQuiz(context, theme, isCorrect),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/mindfulness_education_minimal_illustration_turquoise_1765787407954.png',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Edukasi Hari Ini: Menjaga Kesehatan Mental', style: context.textStyles.titleLarge?.semiBold),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Sebelum kuis, baca ringkasan singkat ini. Praktik kecil sehari-hari bisa meningkatkan kesejahteraan emosional Anda.',
                      style: context.textStyles.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _bullet(context, Icons.nights_stay, 'Tidur 7–9 jam membantu regulasi emosi dan fokus.'),
                    _bullet(context, Icons.self_improvement, 'Latih mindfulness 5 menit untuk menurunkan stres.'),
                    _bullet(context, Icons.directions_walk, 'Aktif bergerak total 150 menit/minggu untuk mood lebih stabil.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _inIntro = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              elevation: 0,
            ),
            child: Text('Mulai Kuis', style: context.textStyles.labelLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
      ),
    );
  }

  Widget _bullet(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: context.textStyles.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(BuildContext context, ThemeData theme, bool isCorrect) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Education banner (always visible before questions)
        Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/mindfulness_education_minimal_illustration_turquoise_1765787407954.png',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edukasi Singkat Hari Ini',
                      style: context.textStyles.titleMedium?.semiBold,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Coba praktikkan kebiasaan kecil ini untuk menjaga keseimbangan mental sebelum menjawab kuis.',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _bullet(context, Icons.nights_stay, 'Tidur 7–9 jam membantu regulasi emosi dan fokus.'),
                    _bullet(context, Icons.self_improvement, 'Latih mindfulness 5 menit untuk menurunkan stres.'),
                    _bullet(context, Icons.directions_walk, 'Aktif bergerak total 150 menit/minggu untuk mood lebih stabil.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _trivias.length,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Pertanyaan ${_currentIndex + 1} dari ${_trivias.length}',
          style: context.textStyles.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _currentTrivia['question'],
          style: context.textStyles.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...(_currentTrivia['options'] as List<String>).map((option) {
          final isSelected = _selectedAnswer == option;
          final isCorrectOption = option == _currentTrivia['correctAnswer'];
          Color? backgroundColor;
          Color? borderColor;
          Color? textColor;
          if (_showResult) {
            if (isCorrectOption) {
              backgroundColor = theme.colorScheme.tertiary.withValues(alpha: 0.15);
              borderColor = theme.colorScheme.tertiary;
              textColor = theme.colorScheme.tertiary;
            } else if (isSelected) {
              backgroundColor = theme.colorScheme.error.withValues(alpha: 0.15);
              borderColor = theme.colorScheme.error;
              textColor = theme.colorScheme.error;
            }
          } else if (isSelected) {
            backgroundColor = theme.colorScheme.primaryContainer;
            borderColor = theme.colorScheme.primary;
            textColor = theme.colorScheme.onPrimaryContainer;
          }
          return GestureDetector(
            onTap: _showResult ? null : () => setState(() => _selectedAnswer = option),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.2), width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: textColor ?? theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (_showResult && isCorrectOption)
                    Icon(Icons.check_circle, color: theme.colorScheme.tertiary)
                  else if (_showResult && isSelected && !isCorrectOption)
                    Icon(Icons.cancel, color: theme.colorScheme.error),
                ],
              ),
            ),
          );
        }),
        if (_showResult) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: isCorrect ? theme.colorScheme.tertiary.withValues(alpha: 0.15) : theme.colorScheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(isCorrect ? Icons.check_circle : Icons.info, color: isCorrect ? theme.colorScheme.tertiary : theme.colorScheme.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCorrect ? 'Benar!' : 'Jawaban yang benar:',
                        style: context.textStyles.titleSmall?.copyWith(
                          color: isCorrect ? theme.colorScheme.tertiary : theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _currentTrivia['explanation'],
                        style: context.textStyles.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedAnswer == null
                ? null
                : _showResult
                    ? _nextTrivia
                    : _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              elevation: 0,
            ),
            child: Text(_showResult ? 'Lanjut' : 'Cek Jawaban', style: context.textStyles.labelLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
      ),
    );
  }
}
