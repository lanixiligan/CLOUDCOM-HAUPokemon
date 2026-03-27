import 'package:flutter/material.dart';
import 'package:haupokemon/utils/design.dart';
import '../../services/api_service.dart';
// REMOVED: provider.dart (Unused)
// REMOVED: auth_provider.dart (Unused)

class DetectScreen extends StatefulWidget {
  const DetectScreen({super.key});

  @override
  State<DetectScreen> createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late AnimationController _pulseController;
  List<dynamic> _monsters = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    
    try {
      // Hardcoded coords for testing (Paris)
      final results = await _api.detectMonsters(48.8566, 2.3522);
      
      // Artificial delay for the "scanning" animation feel
      await Future.delayed(const Duration(seconds: 1)); 
      
      if (mounted) {
        setState(() {
          _monsters = results;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Scan failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.darkSlate,
      appBar: AppBar(
        title: const Text("MONSTER RADAR"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 280 * _pulseController.value,
                      height: 280 * _pulseController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppDesign.monsterRed.withOpacity(1 - _pulseController.value),
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                    color: Colors.black38,
                  ),
                  child: const Icon(Icons.my_location, color: Colors.white54, size: 40),
                ),
                // Monster blips
                ..._monsters.map((m) => Positioned(
                  left: 150 + (double.tryParse(m['distance_meters'].toString()) ?? 50) % 100,
                  top: 150 + (double.tryParse(m['distance_meters'].toString()) ?? 50) % 80,
                  child: const Icon(Icons.location_on, color: AppDesign.monsterRed, size: 30),
                )),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isScanning ? Colors.grey : AppDesign.monsterRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _isScanning ? null : _startScan,
              icon: const Icon(Icons.radar),
              label: Text(_isScanning ? "SCANNING..." : "SCAN AREA"),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), 
                  topRight: Radius.circular(30)
                ),
              ),
              child: _monsters.isEmpty 
                ? const Center(child: Text("No monsters nearby. Try scanning!"))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _monsters.length,
                    separatorBuilder: (c, i) => const Divider(),
                    itemBuilder: (context, i) {
                      final m = _monsters[i];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppDesign.backgroundGrey,
                          child: Icon(Icons.catching_pokemon, color: AppDesign.monsterRed),
                        ),
                        title: Text(
                          m['monster_name'] ?? "Unknown", 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Text("${m['distance_meters']} meters away"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Implement catch logic
                        },
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}