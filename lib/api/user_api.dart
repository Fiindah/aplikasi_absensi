// lib/services/auth_service.dart
import 'dart:convert';

import 'package:aplikasi_absensi/api/endpoint.dart';
import 'package:aplikasi_absensi/models/login_model.dart';
import 'package:aplikasi_absensi/models/register_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Metode untuk login pengguna
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login); // Gunakan Endpoint.login

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Debugging: Print response status and body
      print('Login API Response Status: ${response.statusCode}');
      print('Login API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Jika respons 200 OK, parse data
        return LoginResponse.fromJson(jsonDecode(response.body));
      } else {
        // Jika status code bukan 200, coba parse error message
        final errorJson = jsonDecode(response.body);
        return LoginResponse(
          message: errorJson['message'] ?? 'Terjadi kesalahan saat login.',
          data: null, // Data null jika login gagal
        );
      }
    } catch (e) {
      // Tangani error jaringan atau parsing
      print('Error during login: $e');
      return LoginResponse(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        data: null,
      );
    }
  }

  // Metode untuk register pengguna
  Future<RegisterResponse> register({
    // Mengubah tipe return menjadi RegisterResponse
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
  }) async {
    final url = Uri.parse(Endpoint.register); // Gunakan Endpoint.register

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'jenis_kelamin': jenisKelamin, // Tambahkan field jenis_kelamin
        }),
      );

      print('Register API Response Status: ${response.statusCode}');
      print('Register API Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Jika registrasi berhasil (biasanya 201 Created atau 200 OK)
        return RegisterResponse.fromJson(jsonDecode(response.body));
      } else {
        // Jika ada error dari server (misalnya validasi)
        final errorJson = jsonDecode(response.body);
        return RegisterResponse(
          message: errorJson['message'] ?? 'Pendaftaran gagal.',
          errors: errorJson['errors'], // Mengambil detail error jika ada
          data: null,
        );
      }
    } catch (e) {
      // Tangani error jaringan atau parsing
      print('Error during registration: $e');
      return RegisterResponse(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        data: null,
      );
    }
  }

  // TODO: Tambahkan metode lain seperti reset password, update profile, dll.
}
