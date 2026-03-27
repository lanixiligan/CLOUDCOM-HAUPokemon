import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; 

class ApiService {
  static const String baseUrl = 'http://100.73.206.81/api';

  // LEADERBOARD: Get top players
  Future<List<dynamic>> getTopHunters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hunters/top'), // Check if this matches your backend!
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming your backend returns { "data": [...] }
        return data['data'] as List;
      }
    } catch (e) {
      debugPrint("Leaderboard Error: $e");
    }
    return [];
  }
    
  // --- HELPER METHODS ---
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- MONSTER MANAGEMENT (ADD, UPDATE, DELETE) ---

  Future<bool> addMonster(String name, double lat, double lng) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/monsters'),
      headers: await _headers(),
      body: jsonEncode({
        'monster_name': name,
        'monster_type': 'Normal',
        'spawn_latitude': lat,
        'spawn_longitude': lng,
        'spawn_radius_meters': 100.0,
      }),
    );

    // ADD THESE TWO LINES TO SEE THE TRUTH:
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Server Response: ${response.body}"); 

    return response.statusCode == 201 || response.statusCode == 200;
  } catch (e) {
    debugPrint("Network Error: $e");
    return false;
  }
}

  Future<bool> updateMonster(int id, String name, double lat, double lng) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/monsters/$id'),
        headers: await _headers(),
        body: jsonEncode({
          'monster_name': name,
          'spawn_latitude': lat,    // Changed to match SQL
          'spawn_longitude': lng,   // Changed to match SQL
          // Add monster_type here too if your backend needs it for updates
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    }
  }

  Future<bool> deleteMonster(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/monsters/$id'),
        headers: await _headers(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Delete Error: $e");
      return false;
    }
  }

  // --- EXISTING METHODS (LOGIN, DETECT, EC2) ---

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        body: jsonEncode({'username': username, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<dynamic>> detectMonsters(double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/monsters/detect'),
        headers: await _headers(),
        body: jsonEncode({'latitude': lat, 'longitude': lng}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as List;
      }
    } catch (e) {
      debugPrint("Radar Error: $e");
    }
    return [];
  }

  Future<String> getEc2Status(String instanceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ec2/status'),
        headers: await _headers(),
        body: jsonEncode({'instance_id': instanceId}),
      );
      final data = jsonDecode(response.body);
      return data['data']['status'] ?? 'unknown';
    } catch (e) {
      return 'error';
    }
  }

  Future<void> controlEc2(String instanceId, String action) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/ec2/$action'),
        headers: await _headers(),
        body: jsonEncode({'instance_id': instanceId}),
      );
    } catch (e) {
      debugPrint("EC2 Control Error: $e");
    }
  }
}