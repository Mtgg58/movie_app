import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/details_screen.dart';
import 'screens/info_screen.dart';

void main() {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'movie app',
      theme: AppTheme.themeData,
      initialRoute: 'welcome',
      routes: {
        'welcome': (context) => const WelcomeScreen(),
        'home': (context) => const HomeScreen(),
        'details': (context) => const DetailsScreen(),
        'info': (context) => const InfoScreen(),
      },
    );
  }
}