// lib/services/auth_service.dart
import 'dart:convert';

import 'package:aplikasi_absensi/api/endpoint.dart';
import 'package:aplikasi_absensi/helper/share_pref.dart';
import 'package:aplikasi_absensi/models/login_model.dart';
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
      // Tangani semua jenis exception, termasuk SocketException (masalah jaringan)
      debugPrint('Exception during login: $e');
      return LoginResponse(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda atau URL API: $e', // Tambahkan detail exception
        data: null,
      );
    }
  }

  // Metode untuk register pengguna (tetap konsisten dengan penanganan 302)
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

  // Metode untuk logout pengguna
  Future<bool> logout() async {
    return await SharedPreferencesUtil.clearAllData();
  }
}


// // lib/services/auth_service.dart
// import 'dart:convert';

// import 'package:aplikasi_absensi/api/endpoint.dart';
// import 'package:aplikasi_absensi/helper/share_pref.dart';
// import 'package:aplikasi_absensi/models/login_model.dart';
// import 'package:aplikasi_absensi/models/profile_model.dart';
// import 'package:aplikasi_absensi/models/register_model.dart';
// import 'package:flutter/foundation.dart'; 
// import 'package:http/http.dart' as http;

// class AuthService {
//   Future<LoginResponse> login({
//     required String email,
//     required String password,
//   }) async {
//     final url = Uri.parse(Endpoint.login);
//     final body = jsonEncode({'email': email, 'password': password});
//     final headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };

//     debugPrint('--- Login Request ---');
//     debugPrint('URL: $url');
//     debugPrint('Headers: $headers');
//     debugPrint('Body: $body');

//     try {
//       final response = await http.post(url, headers: headers, body: body);

//       debugPrint('--- Login Response ---');
//       debugPrint('Status Code: ${response.statusCode}');
//       debugPrint('Response Body: ${response.body}');
//       debugPrint('Is Redirect: ${response.isRedirect}');
//       debugPrint('Location Header: ${response.headers['location']}');

//       if (response.statusCode == 200) {
//         final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
//         if (loginResponse.data != null) {
//           await SharedPreferencesUtil.saveAuthToken(loginResponse.data!.token);
//           await SharedPreferencesUtil.saveUserData(loginResponse.data!.user);
//         }
//         return loginResponse;
//       } else if (response.statusCode == 302) {
//         return LoginResponse(
//           message:
//               'Login gagal. Server mengalihkan permintaan ke: ${response.headers['location'] ?? 'URL tidak diketahui'}. Ini mungkin masalah konfigurasi API di sisi server.',
//           data: null,
//         );
//       } else {
//         try {
//           final errorJson = jsonDecode(response.body);
//           return LoginResponse(
//             message:
//                 errorJson['message'] ?? 'Login gagal. Respon tidak dikenal.',
//             errors: errorJson['errors'],
//             data: null,
//           );
//         } on FormatException catch (e) {
//           debugPrint(
//             'Error parsing login error response (FormatException): $e',
//           );
//           return LoginResponse(
//             message:
//                 'Login gagal. Respon server tidak valid (bukan JSON): ${response.body}',
//             data: null,
//           );
//         } catch (e) {
//           debugPrint('Error parsing login error response: $e');
//           return LoginResponse(
//             message:
//                 'Login gagal. Terjadi kesalahan saat memproses respon server: ${response.body}',
//             data: null,
//           );
//         }
//       }
//     } catch (e) {
//       // Tangani semua jenis exception, termasuk SocketException (masalah jaringan)
//       debugPrint('Exception during login: $e');
//       return LoginResponse(
//         message:
//             'Tidak dapat terhubung ke server. Periksa koneksi internet Anda atau URL API: $e', // Tambahkan detail exception
//         data: null,
//       );
//     }
//   }

//   // Metode untuk register pengguna (tetap konsisten dengan penanganan 302)
//   Future<RegisterResponse> register({
//     required String name,
//     required String email,
//     required String password,
//     required String jenisKelamin,
//     required int batchId,
//     required int trainingId,
//   }) async {
//     final url = Uri.parse(Endpoint.register);
//     final body = jsonEncode({
//       'name': name,
//       'email': email,
//       'password': password,
//       'jenis_kelamin': jenisKelamin,
//       'batch_id': batchId,
//       'training_id': trainingId,
//     });
//     final headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };

//     debugPrint('--- Register Request ---');
//     debugPrint('URL: $url');
//     debugPrint('Headers: $headers');
//     debugPrint('Body: $body');

//     try {
//       final response = await http.post(url, headers: headers, body: body);

//       debugPrint('--- Register Response ---');
//       debugPrint('Status Code: ${response.statusCode}');
//       debugPrint('Response Body: ${response.body}');
//       debugPrint('Is Redirect: ${response.isRedirect}');
//       debugPrint('Location Header: ${response.headers['location']}');

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         final registerResponse = RegisterResponse.fromJson(
//           jsonDecode(response.body),
//         );
//         if (registerResponse.data != null) {
//           await SharedPreferencesUtil.saveAuthToken(
//             registerResponse.data!.token,
//           );
//           await SharedPreferencesUtil.saveUserData(registerResponse.data!.user);
//         }
//         return registerResponse;
//       } else if (response.statusCode == 302) {
//         return RegisterResponse(
//           message:
//               'Pendaftaran gagal. Server mengalihkan permintaan ke: ${response.headers['location'] ?? 'URL tidak diketahui'}. Ini mungkin masalah konfigurasi API di sisi server.',
//           data: null,
//         );
//       } else {
//         try {
//           final errorJson = jsonDecode(response.body);
//           return RegisterResponse(
//             message:
//                 errorJson['message'] ??
//                 'Pendaftaran gagal. Respon tidak dikenal.',
//             errors: errorJson['errors'],
//             data: null,
//           );
//         } on FormatException catch (e) {
//           debugPrint(
//             'Error parsing register error response (FormatException): $e',
//           );
//           return RegisterResponse(
//             message:
//                 'Pendaftaran gagal. Respon server tidak valid (bukan JSON): ${response.body}',
//             data: null,
//           );
//         } catch (e) {
//           debugPrint('Error parsing register error response: $e');
//           return RegisterResponse(
//             message:
//                 'Pendaftaran gagal. Terjadi kesalahan saat memproses respon server: ${response.body}',
//             data: null,
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Exception during registration: $e');
//       return RegisterResponse(
//         message:
//             'Tidak dapat terhubung ke server. Periksa koneksi internet Anda atau URL API: $e',
//         data: null,
//       );
//     }
//   }

//   // Metode untuk mengambil daftar batch
//   Future<List<Batch>> fetchBatches() async {
//     final url = Uri.parse(Endpoint.batches);
//     debugPrint('--- Fetch Batches Request ---');
//     debugPrint('URL: $url');

//     try {
//       final response = await http.get(url);
//       debugPrint('--- Fetch Batches Response ---');
//       debugPrint('Status Code: ${response.statusCode}');
//       debugPrint('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
//         final List<dynamic> dataList = jsonResponse['data'];
//         return dataList.map((json) => Batch.fromJson(json)).toList();
//       } else {
//         debugPrint(
//           'Failed to load batches: ${response.statusCode} - ${response.body}',
//         );
//         return [];
//       }
//     } catch (e) {
//       debugPrint('Exception fetching batches: $e');
//       return [];
//     }
//   }

//   // Metode untuk mengambil daftar training (parsing mirip fetchBatches)
//   Future<List<Training>> fetchTrainings() async {
//     final url = Uri.parse(Endpoint.trainings);
//     debugPrint('--- Fetch Trainings Request ---');
//     debugPrint('URL: $url');

//     try {
//       final response = await http.get(url);
//       debugPrint('--- Fetch Trainings Response ---');
//       debugPrint('Status Code: ${response.statusCode}');
//       debugPrint('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
//         final List<dynamic> dataList = jsonResponse['data'];
//         return dataList.map((json) => Training.fromJson(json)).toList();
//       } else {
//         debugPrint(
//           'Failed to load trainings: ${response.statusCode} - ${response.body}',
//         );
//         return [];
//       }
//     } catch (e) {
//       debugPrint('Exception fetching trainings: $e');
//       return [];
//     }
//   }

//   // Metode untuk mengambil detail training berdasarkan ID (parsing mirip fetchBatches)
//   Future<Training?> fetchTrainingDetail(int id) async {
//     final url = Uri.parse('${Endpoint.trainingDetail}/$id');
//     debugPrint('--- Fetch Training Detail Request ---');
//     debugPrint('URL: $url');

//     try {
//       final response = await http.get(url);
//       debugPrint('--- Fetch Training Detail Response ---');
//       debugPrint('Status Code: ${response.statusCode}');
//       debugPrint('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
//         final List<dynamic> dataList = jsonResponse['data'];
//         return dataList.isNotEmpty ? Training.fromJson(dataList.first) : null;
//       } else {
//         debugPrint(
//           'Failed to load training detail: ${response.statusCode} - ${response.body}',
//         );
//         return null;
//       }
//     } catch (e) {
//       debugPrint('Exception fetching training detail: $e');
//       return null;
//     }
//   }

//   // Metode untuk mengambil profil pengguna
//   Future<ProfileResponse> fetchUserProfile() async {
//     final url = Uri.parse(Endpoint.profile);
//     final token = await SharedPreferencesUtil.getAuthToken();

//     if (token == null) {
//       return ProfileResponse(
//         message: 'Token autentikasi tidak ditemukan.',
//         data: null,
//       );
//     }

//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };

//     debugPrint('--- Fetch User Profile Request ---');
//     debugPrint('URL: $url');
//     debugPrint('Headers: $headers');

//     try {
//       final response = await http.get(url, headers: headers);

//       debugPrint('--- Fetch User Profile Response ---');
//       debugPrint('Status Code: ${response.statusCode}');
//       debugPrint('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         return ProfileResponse.fromJson(jsonDecode(response.body));
//       } else {
//         try {
//           final errorJson = jsonDecode(response.body);
//           return ProfileResponse(
//             message: errorJson['message'] ?? 'Gagal mengambil data profil.',
//             data: null,
//           );
//         } on FormatException catch (e) {
//           debugPrint(
//             'Error parsing profile error response (FormatException): $e',
//           );
//           return ProfileResponse(
//             message:
//                 'Gagal mengambil data profil. Respon server tidak valid (bukan JSON): ${response.body}',
//             data: null,
//           );
//         } catch (e) {
//           debugPrint('Error parsing profile error response: $e');
//           return ProfileResponse(
//             message:
//                 'Gagal mengambil data profil. Terjadi kesalahan saat memproses respon server: ${response.body}',
//             data: null,
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Exception fetching user profile: $e');
//       return ProfileResponse(
//         message:
//             'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
//         data: null,
//       );
//     }
//   }

//   // Metode untuk logout pengguna
//   Future<bool> logout() async {
//     return await SharedPreferencesUtil.clearAllData();
//   }
// }
