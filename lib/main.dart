import 'package:flutter/material.dart';
import 'package:e_tontine_app/screens/welcome_screen.dart';
import 'package:e_tontine_app/screens/login_screen.dart';
import 'package:e_tontine_app/screens/signup_screen.dart';
import 'package:e_tontine_app/screens/dashboard_screen.dart';
import 'package:e_tontine_app/screens/create_tontine_screen.dart';
import 'package:e_tontine_app/screens/tontine_detail_screen.dart';
import 'package:e_tontine_app/screens/contribute_screen.dart';
import 'package:e_tontine_app/screens/settings_screen.dart';
import 'package:e_tontine_app/screens/join_tontine_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-tontine App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.green),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green,
            side: const BorderSide(color: Colors.green),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/create_tontine': (context) => const CreateTontineScreen(),
        '/dashboard': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          final nom = args['nom'] as String;
          final isNewUser = args['isNewUser'] as bool;
          return DashboardScreen(nomUtilisateur: nom, isNewUser: isNewUser);
        },
        '/tontine_detail': (context) {
          final tontineId = ModalRoute.of(context)!.settings.arguments as int;
          return TontineDetailScreen(tontineId: tontineId);
        },
        // Mise à jour de la route /contribute pour accepter un Map d'arguments
        '/contribute': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ContributeScreen(args: args);
        },
        '/settings': (context) => const SettingsScreen(),
        '/join_tontine': (context) => const JoinTontineScreen(),
      },
    );
  }
}
