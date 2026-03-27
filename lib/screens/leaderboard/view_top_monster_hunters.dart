import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ViewTopMonsterHuntersScreen extends StatefulWidget {
  const ViewTopMonsterHuntersScreen({super.key});

  @override
  State<ViewTopMonsterHuntersScreen> createState() => _ViewTopMonsterHuntersScreenState();
}

class _ViewTopMonsterHuntersScreenState extends State<ViewTopMonsterHuntersScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _hunters = [];
  bool _isLoading = true;

  final Color monsterRed = const Color(0xFFC62828);
  final Color darkSlate = const Color(0xFF263238);

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    final results = await _api.getTopHunters();
    setState(() {
      _hunters = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text("ELITE HUNTERS", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: darkSlate,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Summary
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: darkSlate,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: const Column(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 50),
                SizedBox(height: 10),
                Text("GLOBAL RANKINGS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Top performers in the field", style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: monsterRed))
                : _hunters.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _hunters.length,
                        itemBuilder: (context, index) => _buildHunterTile(index, _hunters[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHunterTile(int index, dynamic hunter) {
    bool isTopThree = index < 3;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isTopThree ? monsterRed : darkSlate.withOpacity(0.1),
          child: Text("${index + 1}", style: TextStyle(color: isTopThree ? Colors.white : darkSlate, fontWeight: FontWeight.bold)),
        ),
        title: Text(
          hunter['username'] ?? 'Anonymous Hunter',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Level ${hunter['level'] ?? 1}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${hunter['capture_count'] ?? 0}",
              style: TextStyle(color: monsterRed, fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const Text("CAPTURES", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          const Text("No data found in the archive."),
          TextButton(onPressed: _loadLeaderboard, child: const Text("RETRY CONNECTION"))
        ],
      ),
    );
  }
}