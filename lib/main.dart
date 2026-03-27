import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haupokemon/services/auth_provider.dart';
import 'package:haupokemon/screens/auth/login_screen.dart';
import 'package:haupokemon/screens/home/home_screen.dart';
import 'package:haupokemon/screens/monsters/detect_screen.dart';
import 'package:haupokemon/screens/ec2/ec2_screen.dart';
import 'package:haupokemon/screens/monsters/manage_monsters_screen.dart';
import 'package:haupokemon/screens/leaderboard/view_top_monster_hunters.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HAUPokemon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      // THIS IS THE ROUTE TABLE - IT FIXES YOUR ERROR
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/detect': (context) => const DetectScreen(),
        '/ec2': (context) => const Ec2Screen(),
        '/manage': (context) => const ManageMonstersScreen(),
        '/leaderboard': (context) => const ViewTopMonsterHuntersScreen(),
      },
    );
  }
}