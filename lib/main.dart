import 'package:flutter/material.dart';
import 'ui/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AtelierApp());
}

class AtelierApp extends StatelessWidget {
  const AtelierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATELIER - Carpintería & Melamina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488), // Teal / Taller moderno
          brightness: Brightness.light,
          primary: const Color(0xFF0F766E),
          secondary: const Color(0xFFB45309), // Warm amber/wood
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
