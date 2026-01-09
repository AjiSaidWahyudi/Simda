import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simda_mobile/models/user.dart';
import 'package:simda_mobile/services/api_services.dart';

class AuthProvider extends ChangeNotifier {
  String _token = '';
  String get token => _token;
  bool get isAuthenticated => _token.isNotEmpty;

  User? _user;
  User? get user => _user;

  String get name => _user?.name ?? '';
  String get username => _user?.username ?? '';
  String get email => _user?.email ?? '';

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final sp = await SharedPreferences.getInstance();

    _token = sp.getString('token') ?? '';

    final userJson = sp.getString('user');
    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson));
    }

    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final resp = await ApiService.login(username, password);
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      if (body['token'] != null && body['user'] != null) {
        _token = body['token'];
        _user = User.fromJson(body['user']);

        final sp = await SharedPreferences.getInstance();
        await sp.setString('token', _token);
        await sp.setString('user', jsonEncode(body['user']));

        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> register(Map<String, String> body) async {
    final resp = await ApiService.register(body);
    return resp.statusCode == 201 || resp.statusCode == 200;
  }

  Future<void> logout() async {
    _token = '';
    _user = null;

    final sp = await SharedPreferences.getInstance();
    await sp.remove('token');
    await sp.remove('user');

    notifyListeners();
  }
}
