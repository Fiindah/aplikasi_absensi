// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io'; // Import for File

import 'package:aplikasi_absensi/api/endpoint.dart';
import 'package:aplikasi_absensi/helper/share_pref.dart';
import 'package:aplikasi_absensi/models/attendance_model.dart'; // New import for Attendance models
import 'package:aplikasi_absensi/models/attendance_response.dart';
import 'package:aplikasi_absensi/models/attendance_stats_model.dart'; // New import for AttendanceStats models
import 'package:aplikasi_absensi/models/login_model.dart';
import 'package:aplikasi_absensi/models/profil_photo_model.dart';
import 'package:aplikasi_absensi/models/profile_model.dart';
import 'package:aplikasi_absensi/models/register_model.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:http/http.dart' as http;

class AuthService {
  // Metode untuk login pengguna
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    final body = jsonEncode({'email': email, 'password': password});
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    debugPrint('--- Login Request ---');
    debugPrint('URL: $url');
    debugPrint('Headers: $headers');
    debugPrint('Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      debugPrint('--- Login Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('Is Redirect: ${response.isRedirect}');
      debugPrint('Location Header: ${response.headers['location']}');

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        if (loginResponse.data != null) {
          await SharedPreferencesUtil.saveAuthToken(loginResponse.data!.token);
          await SharedPreferencesUtil.saveUserData(loginResponse.data!.user);
        }
        return loginResponse;
      } else if (response.statusCode == 302) {
        return LoginResponse(
          message:
              'Login gagal. Server mengalihkan permintaan ke: ${response.headers['location'] ?? 'URL tidak diketahui'}. Ini mungkin masalah konfigurasi API di sisi server.',
          data: null,
        );
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          return LoginResponse(
            message:
                errorJson['message'] ?? 'Login gagal. Respon tidak dikenal.',
            errors: errorJson['errors'],
            data: null,
          );
        } on FormatException catch (e) {
          debugPrint(
            'Error parsing login error response (FormatException): $e',
          );
          return LoginResponse(
            message:
                'Login gagal. Respon server tidak valid (bukan JSON): ${response.body}',
            data: null,
          );
        } catch (e) {
          debugPrint('Error parsing login error response: $e');
          return LoginResponse(
            message:
                'Login gagal. Terjadi kesalahan saat memproses respon server: ${response.body}',
            data: null,
          );
        }
      }
    } catch (e) {
      debugPrint('Exception during login: $e');
      return LoginResponse(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda atau URL API: $e',
        data: null,
      );
    }
  }

  // Metode untuk register pengguna
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse(Endpoint.register);
    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'jenis_kelamin': jenisKelamin,
      'batch_id': batchId,
      'training_id': trainingId,
    });
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    debugPrint('--- Register Request ---');
    debugPrint('URL: $url');
    debugPrint('Headers: $headers');
    debugPrint('Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      debugPrint('--- Register Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('Is Redirect: ${response.isRedirect}');
      debugPrint('Location Header: ${response.headers['location']}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final registerResponse = RegisterResponse.fromJson(
          jsonDecode(response.body),
        );
        if (registerResponse.data != null) {
          await SharedPreferencesUtil.saveAuthToken(
            registerResponse.data!.token,
          );
          await SharedPreferencesUtil.saveUserData(registerResponse.data!.user);
        }
        return registerResponse;
      } else if (response.statusCode == 302) {
        return RegisterResponse(
          message:
              'Pendaftaran gagal. Server mengalihkan permintaan ke: ${response.headers['location'] ?? 'URL tidak diketahui'}. Ini mungkin masalah konfigurasi API di sisi server.',
          data: null,
        );
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          return RegisterResponse(
            message:
                errorJson['message'] ??
                'Pendaftaran gagal. Respon tidak dikenal.',
            errors: errorJson['errors'],
            data: null,
          );
        } on FormatException catch (e) {
          debugPrint(
            'Error parsing register error response (FormatException): $e',
          );
          return RegisterResponse(
            message:
                'Pendaftaran gagal. Respon server tidak valid (bukan JSON): ${response.body}',
            data: null,
          );
        } catch (e) {
          debugPrint('Error parsing register error response: $e');
          return RegisterResponse(
            message:
                'Pendaftaran gagal. Terjadi kesalahan saat memproses respon server: ${response.body}',
            data: null,
          );
        }
      }
    } catch (e) {
      debugPrint('Exception during registration: $e');
      return RegisterResponse(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda atau URL API: $e',
        data: null,
      );
    }
  }

  // Metode untuk mengambil daftar batch
  Future<List<Batch>> fetchBatches() async {
    final url = Uri.parse(Endpoint.batches);
    debugPrint('--- Fetch Batches Request ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url);
      debugPrint('--- Fetch Batches Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'];
        return dataList.map((json) => Batch.fromJson(json)).toList();
      } else {
        debugPrint(
          'Failed to load batches: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('Exception fetching batches: $e');
      return [];
    }
  }

  // Metode untuk mengambil daftar training (parsing mirip fetchBatches)
  Future<List<Training>> fetchTrainings() async {
    final url = Uri.parse(Endpoint.trainings);
    debugPrint('--- Fetch Trainings Request ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url);
      debugPrint('--- Fetch Trainings Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'];
        return dataList.map((json) => Training.fromJson(json)).toList();
      } else {
        debugPrint(
          'Failed to load trainings: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('Exception fetching trainings: $e');
      return [];
    }
  }

  // Metode untuk mengambil detail training berdasarkan ID (parsing mirip fetchBatches)
  Future<Training?> fetchTrainingDetail(int id) async {
    final url = Uri.parse('${Endpoint.trainingDetail}/$id');
    debugPrint('--- Fetch Training Detail Request ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url);
      debugPrint('--- Fetch Training Detail Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'];
        return dataList.isNotEmpty ? Training.fromJson(dataList.first) : null;
      } else {
        debugPrint(
          'Failed to load training detail: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Exception fetching training detail: $e');
      return null;
    }
  }

  // Metode untuk mengambil profil pengguna
  Future<ProfileResponse> fetchUserProfile() async {
    final url = Uri.parse(Endpoint.profile);
    final token = await SharedPreferencesUtil.getAuthToken();

    if (token == null) {
      return ProfileResponse(
        message: 'Token autentikasi tidak ditemukan.',
        data: null,
      );
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('--- Fetch User Profile Request ---');
    debugPrint('URL: $url');
    debugPrint('Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      debugPrint('--- Fetch User Profile Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return ProfileResponse.fromJson(jsonDecode(response.body));
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          return ProfileResponse(
            message: errorJson['message'] ?? 'Gagal mengambil data profil.',
            data: null,
          );
        } on FormatException catch (e) {
          debugPrint(
            'Error parsing profile error response (FormatException): $e',
          );
          return ProfileResponse(
            message:
                'Gagal mengambil data profil. Respon server tidak valid (bukan JSON): ${response.body}',
            data: null,
          );
        } catch (e) {
          debugPrint('Error parsing profile error response: $e');
          return ProfileResponse(
            message:
                'Gagal mengambil data profil. Terjadi kesalahan saat memproses respon server: ${response.body}',
            data: null,
          );
        }
      }
    } catch (e) {
      debugPrint('Exception fetching user profile: $e');
      return ProfileResponse(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        data: null,
      );
    }
  }

  // Metode untuk memperbarui profil pengguna (data teks)
  Future<ProfileResponse> updateUserProfile({
    required String name,
    required String email,
    String? jenisKelamin,
    dynamic batchId,
    dynamic trainingId,
    String? onesignalPlayerId,
  }) async {
    final url = Uri.parse(Endpoint.updateProfile);
    final token = await SharedPreferencesUtil.getAuthToken();

    if (token == null) {
      return ProfileResponse(
        message: 'Token autentikasi tidak ditemukan.',
        data: null,
      );
    }

    final body = jsonEncode({
      'name': name,
      'email': email,
      'jenis_kelamin': jenisKelamin,
      'batch_id': batchId,
      'training_id': trainingId,
      'onesignal_player_id': onesignalPlayerId,
    });
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('--- Update User Profile Request (PUT) ---'); // Log method
    debugPrint('URL: $url');
    debugPrint('Headers: $headers');
    debugPrint('Body: $body');

    try {
      final response = await http.put(
        // Changed to http.put
        url,
        headers: headers,
        body: body,
      );

      debugPrint('--- Update User Profile Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final profileResponse = ProfileResponse.fromJson(
          jsonDecode(response.body),
        );
        if (profileResponse.data != null) {
          await SharedPreferencesUtil.saveUserData(profileResponse.data!);
        }
        return profileResponse;
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          return ProfileResponse(
            message: errorJson['message'] ?? 'Gagal memperbarui profil.',
            errors: errorJson['errors'],
            data: null,
          );
        } on FormatException catch (e) {
          debugPrint(
            'Error parsing update profile error response (FormatException): $e',
          );
          return ProfileResponse(
            message:
                'Gagal memperbarui profil. Respon server tidak valid (bukan JSON): ${response.body}',
            data: null,
          );
        } catch (e) {
          debugPrint('Error parsing update profile error response: $e');
          return ProfileResponse(
            message:
                'Gagal memperbarui profil. Terjadi kesalahan saat memproses respon server: ${response.body}',
            data: null,
          );
        }
      }
    } catch (e) {
      debugPrint('Exception during update user profile: $e');
      return ProfileResponse(
        message:
            'Tidak dapat terhubung ke server untuk memperbarui profil. Periksa koneksi internet Anda.',
        data: null,
      );
    }
  }

  // Metode untuk memperbarui foto profil
  Future<ProfilePhotoUpdateResponse> updateProfilePhoto({
    required File imageFile,
  }) async {
    final url = Uri.parse(Endpoint.updateProfilePhoto);
    final token = await SharedPreferencesUtil.getAuthToken();

    if (token == null) {
      return ProfilePhotoUpdateResponse(
        message: 'Token autentikasi tidak ditemukan.',
        data: null,
      );
    }

    // Menggunakan MultipartRequest untuk upload file, ini tetap POST/PATCH
    // http.MultipartRequest tidak mendukung PUT secara langsung untuk file upload
    // Jika backend Anda mengharapkan PUT untuk file, Anda mungkin perlu menyesuaikan backend
    // atau menggunakan metode PATCH jika didukung.
    // Untuk kasus ini, kita akan tetap menggunakan POST untuk MultipartRequest
    // atau jika backend mendukung PUT dengan body, Anda bisa menggunakan http.put
    // dengan body bytes dari file. Namun, umum untuk file upload menggunakan POST/PATCH.
    // Asumsi: Backend menerima PUT untuk data JSON, tetapi POST untuk Multipart/form-data.
    // Jika API Anda benar-benar mengharapkan PUT untuk file, Anda perlu cara lain.
    // Namun, jika Anda ingin mengirim file dengan PUT, Anda bisa menggunakan http.Request
    // dan mengatur method secara manual.

    // Untuk mengunggah file dengan PUT, Anda perlu membaca file sebagai bytes
    // dan mengirimkannya sebagai body. Ini berbeda dengan MultipartRequest.
    // Contoh:
    // var request = http.Request('PUT', url);
    // request.headers['Authorization'] = 'Bearer $token';
    // request.headers['Content-Type'] = 'image/jpeg'; // Atau mimeType file Anda
    // request.bodyBytes = await imageFile.readAsBytes();
    // final streamedResponse = await request.send();
    // final response = await http.Response.fromStream(streamedResponse);

    // Jika backend Anda mengharapkan PUT dengan multipart/form-data,
    // maka Anda perlu library HTTP yang lebih canggih yang mendukungnya,
    // atau mengubah backend untuk menerima POST/PATCH.
    // Untuk saat ini, saya akan tetap menggunakan POST untuk MultipartRequest
    // karena ini adalah praktik umum untuk upload file.
    // Jika Anda bersikeras PUT untuk file, mohon konfirmasi bagaimana backend Anda mengharapkannya.

    // Jika backend Anda mengharapkan PUT untuk profile photo dan itu bukan multipart,
    // melainkan base64 encoded string atau URL, maka implementasi ini perlu diubah drastis.
    // Berdasarkan respons yang Anda berikan sebelumnya, 'profile_photo' adalah string URL,
    // yang menyiratkan upload file terpisah.
    // Saya akan mempertahankan ini sebagai POST karena MultipartRequest secara default adalah POST.
    // Jika Anda ingin PUT untuk file, kita perlu diskusi lebih lanjut tentang bagaimana API Anda bekerja.

    // Menggunakan MultipartRequest, yang secara default adalah POST.
    // Jika backend Anda benar-benar mengharapkan PUT untuk file upload,
    // Anda perlu mengklarifikasi bagaimana payloadnya (misalnya, base64, atau multipart dengan method override).
    var request = http.MultipartRequest(
      'POST',
      url,
    ); // Tetap POST untuk MultipartRequest
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_photo', // Nama field yang diharapkan oleh backend untuk file foto
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    );

    debugPrint(
      '--- Update Profile Photo Request (Multipart - assumed POST) ---',
    ); // Log method
    debugPrint('URL: $url');
    debugPrint('Headers: ${request.headers}');
    debugPrint('File: ${imageFile.path}');

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('--- Update Profile Photo Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final photoResponse = ProfilePhotoUpdateResponse.fromJson(
          jsonDecode(response.body),
        );
        if (photoResponse.data != null) {
          final currentUser = await SharedPreferencesUtil.getUserData();
          if (currentUser != null) {
            // Perbarui hanya field profilePhoto
            final updatedUser = ProfileData(
              id: currentUser.id,
              name: currentUser.name,
              email: currentUser.email,
              profilePhoto: photoResponse.data!.profilePhotoUrl.replaceFirst(
                '${Endpoint.baseUrl}/public/',
                '',
              ),
              emailVerifiedAt: currentUser.emailVerifiedAt,
              createdAt: currentUser.createdAt,
              updatedAt: currentUser.updatedAt,
              batchId: currentUser.batchId,
              trainingId: currentUser.trainingId,
              jenisKelamin: currentUser.jenisKelamin,
              batchKe: currentUser.batchKe,
              trainingTitle: currentUser.trainingTitle,
              batch: currentUser.batch,
              training: currentUser.training,
              token: currentUser.token,
              onesignalPlayerId: currentUser.onesignalPlayerId,
            );
            await SharedPreferencesUtil.saveUserData(updatedUser);
          }
        }
        return photoResponse;
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          return ProfilePhotoUpdateResponse(
            message: errorJson['message'] ?? 'Gagal memperbarui foto profil.',
            data: null,
          );
        } on FormatException catch (e) {
          debugPrint(
            'Error parsing photo update error response (FormatException): $e',
          );
          return ProfilePhotoUpdateResponse(
            message:
                'Gagal memperbarui foto profil. Respon server tidak valid (bukan JSON): ${response.body}',
            data: null,
          );
        } catch (e) {
          debugPrint('Error parsing photo update error response: $e');
          return ProfilePhotoUpdateResponse(
            message:
                'Gagal memperbarui foto profil. Terjadi kesalahan saat memproses respon server: ${response.body}',
            data: null,
          );
        }
      }
    } catch (e) {
      debugPrint('Exception during update profile photo: $e');
      return ProfilePhotoUpdateResponse(
        message:
            'Tidak dapat terhubung ke server untuk memperbarui foto. Periksa koneksi internet Anda.',
        data: null,
      );
    }
  }

  // Metode untuk absensi masuk
  Future<AttendanceResponse> checkInAttendance({
    required double latitude,
    required double longitude,
    required String address,
    required String attendanceDate,
    required String checkIn,
  }) async {
    final url = Uri.parse(Endpoint.absenCheckIn);
    final token = await SharedPreferencesUtil.getAuthToken();

    if (token == null) {
      return AttendanceResponse(
        message: 'Token autentikasi tidak ditemukan.',
        data: null,
      );
    }

    final body = jsonEncode({
      "check_in_lat": latitude,
      "check_in_lng": longitude,
      "check_in_location": "$latitude,$longitude",
      "check_in_address": address,
      "attendance_date": attendanceDate,
      "check_in": checkIn,
    });

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // ✅ Tambahkan debug log
    debugPrint('--- Check-in Request ---');
    debugPrint('URL: $url');
    debugPrint('Headers: $headers');
    debugPrint('Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      debugPrint('--- Check-in Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AttendanceResponse.fromJson(jsonDecode(response.body));
      } else {
        return AttendanceResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Exception during check-in: $e'); // ❗ log error juga
      return AttendanceResponse(
        message: 'Terjadi kesalahan saat mengirim absen: $e',
        data: null,
      );
    }
  }

  // Metode untuk absensi pulang
  Future<AttendanceResponse> checkOutAttendance({
    required double latitude,
    required double longitude,
    required String address,
    required String attendanceDate,
    required String checkOut,
  }) async {
    final url = Uri.parse(Endpoint.absenCheckOut);
    final token = await SharedPreferencesUtil.getAuthToken();

    if (token == null) {
      return AttendanceResponse(
        message: 'Token autentikasi tidak ditemukan.',
        data: null,
      );
    }

    final body = jsonEncode({
      'check_out_lat': latitude,
      'check_out_lng': longitude,
      'check_out_location': '$latitude,$longitude',
      'check_out_address': address,
      'attendance_date': attendanceDate,
      'check_out': checkOut,
    });

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 🔍 Tambahkan log debug lengkap
    debugPrint('--- Check-out Request ---');
    debugPrint('URL: $url');
    debugPrint('Headers: $headers');
    debugPrint('Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      debugPrint('--- Check-out Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return AttendanceResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorJson = jsonDecode(response.body);
        return AttendanceResponse(
          message: errorJson['message'] ?? 'Gagal melakukan absen pulang.',
          errors: errorJson['errors'],
          data: null,
        );
      }
    } catch (e) {
      debugPrint('Exception during check-out: $e');
      return AttendanceResponse(message: 'Gagal koneksi: $e', data: null);
    }
  }

  // Metode untuk mengajukan izin
  Future<AttendanceResponse> submitPermission({required String reason}) async {
    final url = Uri.parse(Endpoint.absenIzin);
    final token = await SharedPreferencesUtil.getAuthToken();

    if (token == null) {
      return AttendanceResponse(
        message: 'Token autentikasi tidak ditemukan.',
        data: null,
      );
    }

    final body = jsonEncode({'alasan_izin': reason});
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('--- Submit Permission Request ---');
    debugPrint('URL: $url');
    debugPrint('Headers: $headers');
    debugPrint('Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      debugPrint('--- Submit Permission Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return AttendanceResponse.fromJson(jsonDecode(response.body));
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          return AttendanceResponse(
            message: errorJson['message'] ?? 'Gagal mengajukan izin.',
            errors: errorJson['errors'],
            data: null,
          );
        } on FormatException catch (e) {
          debugPrint(
            'Error parsing permission error response (FormatException): $e',
          );
          return AttendanceResponse(
            message:
                'Gagal mengajukan izin. Respon server tidak valid (bukan JSON): ${response.body}',
            data: null,
          );
        } catch (e) {
          debugPrint('Error parsing permission error response: $e');
          return AttendanceResponse(
            message:
                'Gagal mengajukan izin. Terjadi kesalahan saat memproses respon server: ${response.body}',
            data: null,
          );
        }
      }
    } catch (e) {
      debugPrint('Exception during submit permission: $e');
      return AttendanceResponse(
        message:
            'Tidak dapat terhubung ke server untuk mengajukan izin. Periksa koneksi internet Anda.',
        data: null,
      );
    }
  }

  // Metode untuk mengambil status absensi hari ini
  Future<AttendanceResponse> fetchTodayAttendance() async {
    final url = Uri.parse(Endpoint.absenToday);
    final token = await SharedPreferencesUtil.getAuthToken();

    if (token == null) {
      return AttendanceResponse(
        message: 'Token autentikasi tidak ditemukan.',
        data: null,
      );
    }

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('--- Fetch Today Attendance Request ---');
    debugPrint('URL: $url');
    debugPrint('Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      debugPrint('--- Fetch Today Attendance Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return AttendanceResponse.fromJson(jsonDecode(response.body));
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          return AttendanceResponse(
            message:
                errorJson['message'] ??
                'Gagal mengambil status absensi hari ini.',
            errors: errorJson['errors'],
            data: null,
          );
        } on FormatException catch (e) {
          debugPrint(
            'Error parsing today attendance error response (FormatException): $e',
          );
          return AttendanceResponse(
            message:
                'Gagal mengambil status absensi. Respon server tidak valid (bukan JSON): ${response.body}',
            data: null,
          );
        } catch (e) {
          debugPrint('Error parsing today attendance error response: $e');
          return AttendanceResponse(
            message:
                'Gagal mengambil status absensi. Terjadi kesalahan saat memproses respon server: ${response.body}',
            data: null,
          );
        }
      }
    } catch (e) {
      debugPrint('Exception during fetch today attendance: $e');
      return AttendanceResponse(
        message:
            'Tidak dapat terhubung ke server untuk mengambil status absensi. Periksa koneksi internet Anda.',
        data: null,
      );
    }
  }

  // Metode untuk mengambil statistik absensi
  Future<AttendanceStatsResponse> fetchAttendanceStats() async {
    final url = Uri.parse(Endpoint.absenStats);
    final token = await SharedPreferencesUtil.getAuthToken();

    if (token == null) {
      return AttendanceStatsResponse(
        message: 'Token autentikasi tidak ditemukan.',
        data: null,
      );
    }

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('--- Fetch Attendance Stats Request ---');
    debugPrint('URL: $url');
    debugPrint('Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      debugPrint('--- Fetch Attendance Stats Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return AttendanceStatsResponse.fromJson(jsonDecode(response.body));
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          return AttendanceStatsResponse(
            message:
                errorJson['message'] ?? 'Gagal mengambil statistik absensi.',
            errors: errorJson['errors'],
            data: null,
          );
        } on FormatException catch (e) {
          debugPrint(
            'Error parsing attendance stats error response (FormatException): $e',
          );
          return AttendanceStatsResponse(
            message:
                'Gagal mengambil statistik absensi. Respon server tidak valid (bukan JSON): ${response.body}',
            data: null,
          );
        } catch (e) {
          debugPrint('Error parsing attendance stats error response: $e');
          return AttendanceStatsResponse(
            message:
                'Gagal mengambil statistik absensi. Terjadi kesalahan saat memproses respon server: ${response.body}',
            data: null,
          );
        }
      }
    } catch (e) {
      debugPrint('Exception during fetch attendance stats: $e');
      return AttendanceStatsResponse(
        message:
            'Tidak dapat terhubung ke server untuk mengambil statistik absensi. Periksa koneksi internet Anda.',
        data: null,
      );
    }
  }

  // Metode untuk logout pengguna
  Future<bool> logout() async {
    return await SharedPreferencesUtil.clearAllData();
  }
}
