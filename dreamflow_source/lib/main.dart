import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'nav.dart';
import 'package:lentera/supabase/supabase_config.dart';
import 'package:lentera/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Main entry point for the application
///
/// This sets up:
/// - Supabase initialization
/// - Provider state management (ThemeProvider, CounterProvider)
/// - go_router navigation
/// - Material 3 theming with light/dark modes
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  // Initialize intl locale data used by DateFormat('MMMM yyyy', 'id_ID')
  try {
    await initializeDateFormatting('id_ID');
  } catch (e) {
    // Safe to continue; will fallback to default locale if this fails
    debugPrint('Intl init error: $e');
  }
  
  // Initialize the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider()..load(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'LENTERA',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.mode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
