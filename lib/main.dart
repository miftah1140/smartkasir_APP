import 'package:flutter/material.dart';
import 'pages/splash_screen_page.dart';

// Titik awal aplikasi
void main() {
  runApp(const SmartKasirApp());
}

// Widget root aplikasi (StatelessWidget)
class SmartKasirApp extends StatelessWidget {
  const SmartKasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartKasir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal, // Live Tweak 1: tema teal
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreenPage(), // Mulai dari Splash Screen
    );
  }
}
