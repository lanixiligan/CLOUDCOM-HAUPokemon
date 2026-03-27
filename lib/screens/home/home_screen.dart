import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../monsters/detect_screen.dart'; 
import 'package:haupokemon/screens/ec2/ec2_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    const Color monsterRed = Color(0xFFC62828);
    const Color darkSlate = Color(0xFF263238);
    const Color oceanBlue = Color(0xFF0277BD); 
    const Color trophyGold = Color(0xFFFFA000); // Color for Leaderboard

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HAUPokemon Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: monsterRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [monsterRed.withOpacity(0.15), Colors.white],
            stops: const [0.0, 0.4],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Profile Section
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: monsterRed,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Welcome, ${auth.playerName ?? 'Trainer'}",
                style: const TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold,
                  color: darkSlate,
                ),
              ),
              const Text(
                "Elite Monster Hunter",
                style: TextStyle(color: Colors.black54, letterSpacing: 1.1),
              ),
              const SizedBox(height: 30),
              
              // ACTION CARD 1: MONSTER RADAR
              _buildMenuCard(
                context,
                title: "Monster Radar",
                subtitle: "Scan for wild monsters",
                icon: Icons.radar,
                color: monsterRed,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DetectScreen()),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              // ACTION CARD 2: INFRASTRUCTURE
              _buildMenuCard(
                context,
                title: "AWS Console",
                subtitle: "Manage Infrastructure",
                icon: Icons.cloud_sync,
                color: darkSlate,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Ec2Screen()),
                  );                 
                },
              ),

              const SizedBox(height: 12),

              // ACTION CARD 3: MONSTER MANAGEMENT
              _buildMenuCard(
                context,
                title: "Monster Registry",
                subtitle: "Add, Edit, or Remove Entities",
                icon: Icons.settings_suggest_outlined,
                color: oceanBlue,
                onTap: () => Navigator.pushNamed(context, '/manage'),
              ),

              const SizedBox(height: 12),

              // NEW ACTION CARD 4: LEADERBOARD
              _buildMenuCard(
                context,
                title: "Hunter Rankings",
                subtitle: "View Global Leaderboard",
                icon: Icons.emoji_events_outlined,
                color: trophyGold,
                onTap: () => Navigator.pushNamed(context, '/leaderboard'),
              ),
              
              const Spacer(),
              
              // Sign Out
              TextButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context, 
                        '/login', 
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.black45),
                  label: const Text(
                    "SIGN OUT", 
                    style: TextStyle(
                      color: Colors.black45, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color,
    required VoidCallback onTap
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          title: Text(
            title, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
          ),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
          onTap: onTap,
        ),
      ),
    );
  }
}