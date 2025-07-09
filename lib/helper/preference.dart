// lib/utils/shared_preferences_util.dart
import 'dart:convert';

import 'package:aplikasi_absensi/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  // Metode untuk menyimpan token autentikasi
  static Future<bool> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_authTokenKey, token);
  }

  // Metode untuk mengambil token autentikasi
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Metode untuk menyimpan data pengguna (objek User)
  static Future<bool> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    // Konversi objek User menjadi string JSON
    final userDataJson = jsonEncode(user.toJson());
    return prefs.setString(_userDataKey, userDataJson);
  }

  // Metode untuk mengambil data pengguna (objek User)
  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userDataKey);
    if (userDataJson != null) {
      // Konversi string JSON kembali menjadi objek User
      return User.fromJson(jsonDecode(userDataJson));
    }
    return null;
  }

  // Metode untuk menghapus semua data yang tersimpan (saat logout)
  static Future<bool> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear(); // Menghapus semua data yang disimpan oleh aplikasi
  }
}
