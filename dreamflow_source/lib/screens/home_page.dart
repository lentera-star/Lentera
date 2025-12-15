import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lentera/auth/supabase_auth_manager.dart';
import 'package:lentera/services/preferences_service.dart';
import 'package:lentera/services/user_service.dart';
import 'package:lentera/theme_provider.dart';
import 'package:lentera/components/calendar_month.dart';
import 'package:lentera/components/pill_tag.dart';
import 'package:lentera/screens/ai_chat_screen.dart';
import 'package:lentera/models/mood_entry.dart';
import 'package:lentera/services/mood_service.dart';
import 'package:lentera/services/gamification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<_MoodScreenState> _moodKey = GlobalKey<_MoodScreenState>();

  late final List<Widget> _pages = [
    const HomeScreen(),
    MoodScreen(key: _moodKey),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
            if (index == 1) {
              // Ensure Mood screen refreshes when user switches to it
              _moodKey.currentState?.refresh();
            }
          },
          backgroundColor: theme.colorScheme.surface,
          indicatorColor: theme.colorScheme.primaryContainer,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.home, color: theme.colorScheme.primary),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Builder(builder: (context) {
                final appColors = Theme.of(context).extension<AppColors>();
                return Icon(Icons.favorite, color: appColors?.amber ?? theme.colorScheme.primary);
              }),
              label: 'Mood',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.chat_bubble, color: theme.colorScheme.primary),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.person, color: theme.colorScheme.primary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Selamat Pagi'
        : now.hour < 18
            ? 'Selamat Siang'
            : 'Selamat Malam';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGamificationHeaderSection(context),
              const SizedBox(height: AppSpacing.lg),
              Text(
                greeting,
                style: context.textStyles.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bagaimana perasaan Anda hari ini?',
                style: context.textStyles.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildQuickActions(context),
              
              const SizedBox(height: AppSpacing.xl),
              
              Text(
                'Fitur Utama',
                style: context.textStyles.titleLarge?.semiBold,
              ),
              const SizedBox(height: AppSpacing.md),
              
              _buildFeatureCard(
                context,
                icon: Icons.mic,
                title: 'Voice Call AI',
                description: 'Bicara langsung dengan AI Counselor melalui panggilan suara',
                color: theme.colorScheme.primary,
                onTap: () => context.push('/voice-call'),
              ),
              
              _buildFeatureCard(
                context,
                icon: Icons.psychology,
                title: 'Konsultasi Psikolog',
                description: 'Booking sesi dengan psikolog profesional',
                color: theme.colorScheme.secondary,
                onTap: () => context.push('/psychologists'),
              ),
              
              _buildFeatureCard(
                context,
                icon: Icons.auto_awesome,
                title: 'Daily Trivia',
                description: 'Pelajari tips kesehatan mental setiap hari',
                color: theme.colorScheme.tertiary,
                onTap: () => context.push('/trivia'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamificationHeaderSection(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? kAppColorsLight;

    final gf = GamificationService();
    return ValueListenableBuilder<int>(
      valueListenable: gf.tick,
      builder: (context, _, __) {
        return FutureBuilder<(
          GamificationSummary, String?)>(
          future: () async {
            final gs = await GamificationService().getSummary();
            String? name;
            try {
              name = (await SupabaseAuthManager().getCurrentUser())?.fullName;
            } catch (e) {
              debugPrint('Home header get user error: $e');
            }
            return (gs, name);
          }(),
          builder: (context, snapshot) {
            final gs = snapshot.hasData ? snapshot.data!.$1 : null;
            final name = snapshot.hasData ? snapshot.data!.$2 : null;
            return Column(
              children: [
                // Header card with avatar, level, koin, streak
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 72,
                              height: 72,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: (gs?.xpProgress ?? 0)),
                                duration: const Duration(milliseconds: 650),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) {
                                  return CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 6,
                                    color: theme.colorScheme.primary,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    appColors.sage.withValues(alpha: 0.35),
                                    appColors.slateBlue.withValues(alpha: 0.25),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(Icons.sentiment_satisfied_rounded, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.military_tech, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 6),
                                      Text('Lvl ${gs?.level ?? 1}', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: appColors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.monetization_on, size: 16, color: appColors.amber),
                                      const SizedBox(width: 6),
                                      Text('${gs?.koin ?? 0} koin', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: appColors.slateBlue)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              name?.isNotEmpty == true ? name! : 'Pengguna',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Tetap konsisten — streak ${gs?.streak ?? 0}🔥',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Daily target compact card
                _buildDailyTargetCard(context, gs),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDailyTargetCard(BuildContext context, GamificationSummary? gs) {
    final theme = Theme.of(context);
    final target = gs?.dailyTarget ?? 1;
    final progress = gs?.todayProgress ?? 0;
    final pct = (progress / target).clamp(0, 1).toDouble();

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_circle, color: theme.colorScheme.tertiary),
              const SizedBox(width: 8),
              Text('Target Harian', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('$progress/$target', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.tertiary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: pct,
              color: theme.colorScheme.tertiary,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Text('Check-in mood 1x/hari untuk mendapat koin', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.mood,
            label: 'My Day',
            color: theme.colorScheme.tertiary,
            onTap: () => context.push('/mood-entry'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.chat,
            label: 'Chat AI',
            color: theme.colorScheme.primary,
            onTap: () => context.push('/chat'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textStyles.titleMedium?.semiBold,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  late DateTime _visibleMonth;
  DateTime _selectedDate = DateTime.now();

  // Mood indicators pulled from Supabase (fallback to empty)
  Map<DateTime, MoodLevel> _moodIndicators = {};
  bool _loadingMonth = false;

  // Swipe/animation helpers
  double _dragAccumX = 0.0;
  int _monthAnimDir = 0; // -1 prev, 1 next, 0 none

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadMonthIndicators();
  }

  // Allow parent (HomePage) to trigger a refresh when tab is opened
  void refresh() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _visibleMonth = DateTime(now.year, now.month, 1);
    });
    _loadMonthIndicators();
  }

  Future<void> _loadMonthIndicators() async {
    setState(() => _loadingMonth = true);
    try {
      final auth = SupabaseAuthManager();
      final userId = auth.currentUserId;
      if (userId == null) {
        // Not logged in; leave empty mapping
        setState(() => _moodIndicators = {});
        return;
      }
      final start = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
      final end = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
      final entries = await MoodService().getMoodEntriesBetween(
        userId,
        start: start,
        end: end,
      );
      final map = <DateTime, MoodLevel>{};
      for (final e in entries) {
        final key = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
        if (!map.containsKey(key)) {
          // translate rating 1..5 to low/ok/good
          final level = e.moodRating >= 4
              ? MoodLevel.good
              : (e.moodRating >= 2 ? MoodLevel.ok : MoodLevel.low);
          map[key] = level;
        }
      }
      if (mounted) {
        debugPrint('MoodScreen: loaded ${map.length} day indicators for ${_visibleMonth.month}/${_visibleMonth.year}');
        setState(() => _moodIndicators = map);
      }
    } catch (e) {
      debugPrint('MoodScreen: load month indicators error: $e');
    } finally {
      if (mounted) setState(() => _loadingMonth = false);
    }
  }

  void _goPrevMonth() {
    setState(() {
      _monthAnimDir = -1;
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    });
    _loadMonthIndicators();
  }

  void _goNextMonth() {
    setState(() {
      _monthAnimDir = 1;
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
    _loadMonthIndicators();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppColors>();
    final appColors = ext ?? kAppColorsLight;
    final textTheme = context.textStyles;
    final dayOfYear = int.parse(DateFormat('D').format(DateTime.now()));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lentera',
                      style: textTheme.headlineSmall?.semiBold.withColor(theme.colorScheme.onSurface),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil – segera hadir')),
                      );
                    },
                    icon: Icon(Icons.person_outline, color: theme.colorScheme.onSurface),
                    tooltip: 'Profil',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Progress title
              Text(
                'Perjalanan Hari ke-$dayOfYear',
                style: textTheme.headlineMedium?.semiBold.withColor(appColors.slateGrey),
              ),
              const SizedBox(height: AppSpacing.md),

              // Calendar
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) {
                  _dragAccumX = 0.0;
                },
                onHorizontalDragUpdate: (details) {
                  _dragAccumX += details.delta.dx;
                },
                onHorizontalDragEnd: (_) {
                  const threshold = 60; // px
                  if (_dragAccumX <= -threshold) {
                    _goNextMonth();
                  } else if (_dragAccumX >= threshold) {
                    _goPrevMonth();
                  }
                  _dragAccumX = 0.0;
                },
                child: Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _goPrevMonth,
                            icon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
                          ),
                          Expanded(
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) {
                                  final beginOffset = Offset(
                                    _monthAnimDir == 1
                                        ? 0.2
                                        : _monthAnimDir == -1
                                            ? -0.2
                                            : 0.0,
                                    0,
                                  );
                                  return FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
                                        CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  DateFormat('MMMM yyyy', 'id_ID').format(_visibleMonth),
                                  key: ValueKey('${_visibleMonth.year}-${_visibleMonth.month}'),
                                  style: textTheme.titleMedium?.semiBold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _goNextMonth,
                            icon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) {
                          final beginOffset = Offset(
                            _monthAnimDir == 1
                                ? 0.15
                                : _monthAnimDir == -1
                                    ? -0.15
                                    : 0.0,
                            0,
                          );
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
                                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: CalendarMonth(
                          key: ValueKey('${_visibleMonth.year}-${_visibleMonth.month}'),
                          month: _visibleMonth,
                          selectedDate: _selectedDate,
                          onSelect: (d) => setState(() => _selectedDate = d),
                          indicators: _moodIndicators,
                        ),
                      ),
                      if (_loadingMonth)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            color: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Insight Card reacts to selected date
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _InsightCard(
                    key: ValueKey(_selectedDate.toIso8601String()),
                    selectedDate: _selectedDate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatefulWidget {
  final DateTime selectedDate;
  const _InsightCard({super.key, required this.selectedDate});

  @override
  State<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<_InsightCard> {
  MoodEntry? _entry;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _InsightCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      _load();
    }
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _entry = null;
    });
    try {
      final auth = SupabaseAuthManager();
      final userId = auth.currentUserId;
      if (userId != null) {
        final m = await MoodService().getMoodEntryForDate(userId, widget.selectedDate);
        if (mounted) setState(() => _entry = m);
      }
    } catch (e) {
      debugPrint('InsightCard: load entry error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? kAppColorsLight;
    final textTheme = context.textStyles;

    final dateLabel = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(widget.selectedDate);
    final weekday = DateFormat('EEEE', 'id_ID').format(widget.selectedDate);
    final emoji = _pickEmoji(widget.selectedDate);
    final tags = _entry?.moodTags.isNotEmpty == true ? _entry!.moodTags : _pickTags(widget.selectedDate);
    final journal = _entry?.journalText;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Make the card content scrollable within the available height to avoid
      // bottom overflow when the calendar above consumes more space on small screens.
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      appColors.amber.withValues(alpha: 0.25),
                      appColors.amber.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ringkasan $weekday', style: textTheme.titleLarge?.semiBold),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in tags)
                          PillTag(
                            label: t,
                            color: {
                                  0: appColors.sage,
                                  1: appColors.slateBlue,
                                  2: appColors.amber,
                                }[tags.indexOf(t) % 3] ?? appColors.sage,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Catatan Jurnal:', style: textTheme.titleMedium?.semiBold.withColor(theme.colorScheme.onSurface)),
          const SizedBox(height: 6),
          if (_loading)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              journal?.isNotEmpty == true
                  ? journal!
                  : 'Belum ada catatan untuk tanggal ini.',
              style: textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_loading && (journal?.isNotEmpty ?? false))
                  InkWell(
                    onTap: () {
                      context.push('/mood-insight', extra: {
                        'date': widget.selectedDate,
                        'entry': _entry,
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Baca selengkapnya',
                          style: textTheme.labelLarge?.semiBold.withColor(appColors.slateBlue),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.north_east, size: 16, color: appColors.slateBlue),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _pickEmoji(DateTime d) {
    const emojis = ['😊', '🌤️', '🌿', '💪', '🎯', '💡', '🧘'];
    final idx = (d.day + d.month * 2 + d.weekday) % emojis.length;
    return emojis[idx];
  }

  List<String> _pickTags(DateTime d) {
    final pool = [
      'Produktif',
      'Fokus',
      'Mindfulness',
      'Olahraga',
      'Syukur',
      'Hidrasi',
      'Tidur Nyenyak',
      'Sosial',
      'Pola Makan',
      'Self‑care',
    ];
    final base = d.day + d.month + d.weekday;
    // deterministically pick 3 distinct tags
    final first = pool[base % pool.length];
    final second = pool[(base + 3) % pool.length];
    final third = pool[(base + 6) % pool.length];
    return {first, second, third}.toList();
  }

  String _generateSummary(DateTime d, String weekday) {
    final templates = [
      'Awal $weekday yang tenang. Luangkan 5 menit untuk napas 4‑7‑8 dan susun prioritas harianmu. Kemajuan kecil tetap berarti.',
      '$weekday ini terlihat seimbang. Jika sempat cemas, coba grounding 5‑4‑3‑2‑1. Kamu sudah di jalur yang tepat.',
      'Energi di $weekday terasa stabil. Rayakan capaian kecil dan beri jeda mikro tiap 50 menit kerja.',
      'Catatan $weekday: hidrasi cukup dan peregangan ringan bisa membantu fokus. Jangan lupa istirahat mata 20‑20‑20.',
      '$weekday yang hangat. Tulis tiga hal yang kamu syukuri hari ini—ini ampuh menurunkan stres.',
      'Mood $weekday condong positif. Amankan tidur 7‑8 jam malam ini agar ritme tetap prima.',
      'Jika $weekday terasa berat, itu wajar. Cobalah jalan 10 menit dan tarik napas perlahan. Kamu tidak sendiri.',
    ];
    final idx = (d.year + d.month * 3 + d.day) % templates.length;
    return templates[idx];
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Render the high-fidelity AI Chat screen inside the Chat tab.
    // Back button is hidden in tab context.
    return const AiChatScreen(showBack: false);
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifEnabled = true;
  bool _biometricEnabled = false;

  String? _fullName;
  String? _email;
  String? _avatarUrl;

  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    // Load profile and preferences
    try {
      final auth = SupabaseAuthManager();
      final user = await auth.getCurrentUser();
      if (mounted && user != null) {
        setState(() {
          _fullName = user.fullName;
          _email = user.email;
          _avatarUrl = user.avatarUrl;
        });
      }
    } catch (e) {
      debugPrint('ProfileScreen: load user error: $e');
    } finally {
      try {
        final prefs = PreferencesService();
        final notif = await prefs.getNotificationsEnabled();
        final bio = await prefs.getBiometricEnabled();
        if (mounted) {
          setState(() {
            _notifEnabled = notif;
            _biometricEnabled = bio;
            _loadingProfile = false;
          });
        }
      } catch (e) {
        debugPrint('ProfileScreen: load prefs error: $e');
        if (mounted) setState(() => _loadingProfile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = context.textStyles;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Profil', style: textTheme.titleLarge?.semiBold),
        actions: [
          IconButton(
            onPressed: _onEditProfile,
            icon: Icon(Icons.edit, color: theme.colorScheme.primary),
            tooltip: 'Edit Profil',
          )
        ],
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: AppSpacing.xl),

                    Text('Fitur Utama', style: textTheme.titleLarge?.semiBold),
                    const SizedBox(height: AppSpacing.md),
                    _buildMenuTile(
                      context,
                      icon: Icons.event_note,
                      color: theme.colorScheme.primary,
                      title: 'Riwayat Konsultasi',
                      subtitle: 'Lihat booking yang akan datang dan yang sudah selesai',
                      onTap: () => context.push('/bookings'),
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.mood,
                      color: theme.colorScheme.tertiary,
                      title: 'Jurnal Mood',
                      subtitle: 'Ringkasan bulanan/tahunan dan catatan mood Anda',
                      onTap: () => context.push('/mood-entry'),
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.credit_card,
                      color: theme.colorScheme.secondary,
                      title: 'Metode Pembayaran',
                      subtitle: 'Kelola kartu dan lihat riwayat pembayaran',
                      onTap: () => context.push('/payment-methods'),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    Text('Pengaturan', style: textTheme.titleLarge?.semiBold),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSwitchTile(
                      context,
                      icon: Icons.notifications_active,
                      color: theme.colorScheme.primary,
                      title: 'Notifikasi',
                      value: _notifEnabled,
                      onChanged: (v) async {
                        setState(() => _notifEnabled = v);
                        await PreferencesService().setNotificationsEnabled(v);
                      },
                    ),
                    _buildThemeTile(context),

                    const SizedBox(height: AppSpacing.md),
                    Text('Keamanan', style: textTheme.titleLarge?.semiBold),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMenuTile(
                      context,
                      icon: Icons.lock_reset,
                      color: theme.colorScheme.primary,
                      title: 'Ubah Password',
                      subtitle: 'Kirim tautan reset ke email',
                      onTap: _onChangePassword,
                    ),
                    _buildSwitchTile(
                      context,
                      icon: Icons.fingerprint,
                      color: theme.colorScheme.tertiary,
                      title: 'Login Biometrik',
                      value: _biometricEnabled,
                      onChanged: (v) async {
                        setState(() => _biometricEnabled = v);
                        await PreferencesService().setBiometricEnabled(v);
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),
                    Text('Bantuan & Tentang', style: textTheme.titleLarge?.semiBold),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMenuTile(
                      context,
                      icon: Icons.help_outline,
                      color: theme.colorScheme.primary,
                      title: 'Bantuan',
                      subtitle: 'FAQ atau hubungi tim dukungan',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.info_outline,
                      color: theme.colorScheme.tertiary,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Versi v1.0.0',
                      onTap: () => _showAbout(context),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final initials = (_fullName ?? 'U').trim().split(RegExp(r"\s+")).map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
              ? (_avatarUrl!.startsWith('http')
                  ? NetworkImage(_avatarUrl!)
                  : AssetImage(_avatarUrl!) as ImageProvider)
              : null,
          child: (_avatarUrl == null || _avatarUrl!.isEmpty)
              ? Text(initials, style: context.textStyles.titleLarge?.semiBold.withColor(theme.colorScheme.primary))
              : null,
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_fullName ?? '-', style: context.textStyles.titleLarge?.semiBold),
              const SizedBox(height: 4),
              Text(
                _email ?? '-',
                style: context.textStyles.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textStyles.titleMedium?.semiBold),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.textStyles.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant),
                    ),
                  ]
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(title, style: context.textStyles.titleMedium?.semiBold),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<ThemeProvider>();
    final mode = context.watch<ThemeProvider>().mode;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.dark_mode, color: theme.colorScheme.tertiary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text('Tampilan', style: context.textStyles.titleMedium?.semiBold),
          ),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.wb_sunny_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.nights_stay_outlined)),
            ],
            selected: {mode == ThemeMode.light ? ThemeMode.light : mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light},
            onSelectionChanged: (set) {
              final selected = set.first;
              provider.setMode(selected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(theme.colorScheme.errorContainer),
        foregroundColor: WidgetStatePropertyAll(theme.colorScheme.onErrorContainer),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
      ),
      onPressed: _onLogout,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout),
          const SizedBox(width: 8),
          Text('Logout', style: context.textStyles.labelLarge?.semiBold),
        ],
      ),
    );
  }

  Future<void> _onEditProfile() async {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: _fullName ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profil', style: this.context.textStyles.titleLarge?.semiBold),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.push('/avatar-shop');
                    // Reload avatar from server after selection
                    try {
                      final user = await SupabaseAuthManager().getCurrentUser();
                      if (mounted && user != null) {
                        setState(() => _avatarUrl = user.avatarUrl);
                      }
                    } catch (e) {
                      debugPrint('Reload avatar after shop error: $e');
                    }
                  },
                  icon: const Icon(Icons.storefront),
                  label: const Text('Pilih Avatar'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () async {
                  try {
                    final auth = SupabaseAuthManager();
                    final user = await auth.getCurrentUser();
                    if (user != null) {
                       final updated = user.copyWith(
                         fullName: nameController.text.trim().isEmpty ? user.fullName : nameController.text.trim(),
                       );
                      final saved = await UserService().updateUser(updated);
                      if (saved != null && mounted) {
                        setState(() {
                          _fullName = saved.fullName;
                          _avatarUrl = saved.avatarUrl;
                        });
                        Navigator.of(context).pop();
                      }
                    }
                  } catch (e) {
                    debugPrint('Edit profile error: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan profil: $e')),
                      );
                    }
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onChangePassword() async {
    final email = _email;
    if (email == null || email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email tidak ditemukan untuk akun ini')),
        );
      }
      return;
    }
    try {
      await SupabaseAuthManager().resetPassword(email: email, context: context);
    } catch (e) {
      debugPrint('Reset password error: $e');
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Segera hadir')),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tentang Aplikasi'),
        content: const Text('LENTERA\nVersi v1.0.0'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Future<void> _onLogout() async {
    try {
      await SupabaseAuthManager().signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      if (mounted) context.go('/login');
    }
  }
}
