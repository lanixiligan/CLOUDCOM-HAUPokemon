import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';



class AuthProvider extends ChangeNotifier {

  final ApiService _apiService = ApiService();

  String? _token;

  String? _playerName;

  bool _isLoading = false;



  bool get isAuthenticated => _token != null;

  bool get isLoading => _isLoading;

  String? get playerName => _playerName;



  AuthProvider() {

    _loadToken();

  }



  Future<void> _loadToken() async {

    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('token');

    _playerName = prefs.getString('player_name');

    notifyListeners();

  }



  Future<bool> login(String username, String password) async {

    _isLoading = true;

    notifyListeners();



    try {

      final response = await _apiService.login(username, password);

      if (response['status'] == 200) {

        _token = response['data']['token'];

        _playerName = response['data']['player_name'];

       

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', _token!);

        await prefs.setString('player_name', _playerName!);

       

        _isLoading = false;

        notifyListeners();

        return true;

      }

    } catch (e) {

      debugPrint("Login error: $e");

    }



    _isLoading = false;

    notifyListeners();

    return false;

  }



  Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    _token = null;

    _playerName = null;

    notifyListeners();

  }

}