import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class Ec2Screen extends StatefulWidget {
  const Ec2Screen({super.key});

  @override
  State<Ec2Screen> createState() => _Ec2ScreenState();
}

class _Ec2ScreenState extends State<Ec2Screen> {
  final ApiService _api = ApiService();
  
  // Hardcoded constants
  final String webServerId = 'i-05ce381fccaf8c19e';
  final String dbServerId = 'i-05eed06c8a863333f';
  final Color monsterRed = const Color(0xFFC62828);
  final Color darkSlate = const Color(0xFF263238);

  String _webStatus = "Unknown";
  String _dbStatus = "Unknown";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllStatuses();
  }

  Future<void> _fetchAllStatuses() async {
    setState(() => _isLoading = true);
    final web = await _api.getEc2Status(webServerId);
    final db = await _api.getEc2Status(dbServerId);
    if (mounted) {
      setState(() {
        _webStatus = web;
        _dbStatus = db;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleControl(String instanceId, String action) async {
    setState(() => _isLoading = true);
    await _api.controlEc2(instanceId, action);
    await Future.delayed(const Duration(seconds: 1));
    await _fetchAllStatuses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), 
      appBar: AppBar(
        title: const Text(
          "AWS CONSOLE",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: darkSlate,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _fetchAllStatuses,
          )
        ],
      ),
      body: Stack(
        children: [
          // FIXED HEADER BORDER: Clean curve at the top
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
          ),
          
          Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildServerCard("Web Server", "Paris (eu-west-3)", webServerId, _webStatus, Icons.cloud_queue),
                    const SizedBox(height: 16),
                    _buildServerCard("Database", "Virginia (us-east-1)", dbServerId, _dbStatus, Icons.dns_rounded),
                  ],
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text("SYSTEM ONLINE", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: CircularProgressIndicator(color: monsterRed),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServerCard(String name, String region, String id, String status, IconData icon) {
    bool isRunning = status.toLowerCase() == 'running';
    bool isStopped = status.toLowerCase() == 'stopped';
    Color statusColor = isRunning ? Colors.green : (isStopped ? monsterRed : Colors.orange);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: darkSlate, size: 24),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(region, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusChip(status, statusColor),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Text("ID: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                    Text(id, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: isRunning ? null : () => _handleControl(id, 'start'),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("START"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: monsterRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: isStopped ? null : () => _handleControl(id, 'stop'),
                      icon: const Icon(Icons.stop),
                      label: const Text("STOP"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}