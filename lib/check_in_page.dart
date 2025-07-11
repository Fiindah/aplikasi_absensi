import 'package:aplikasi_absensi/api/user_api.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});
  static const String id = "/check_in_page";

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _statusMessage = 'Mencoba mendapatkan lokasi...'; // Pesan awal diubah
  Color _messageColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _checkLocationAndCheckIn();
  }

  void _showMessage(String message, {Color color = Colors.black}) {
    setState(() {
      _statusMessage = message;
      _messageColor = color;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _checkLocationAndCheckIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mendapatkan lokasi saat ini...';
      _messageColor = Colors.black;
    });

    try {
      // Cek apakah layanan lokasi diaktifkan
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage(
          'Layanan lokasi dinonaktifkan. Harap aktifkan GPS Anda.',
          color: Colors.red,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Cek izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage(
            'Izin lokasi ditolak. Absen masuk dibatalkan.',
            color: Colors.red,
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Izin lokasi ditolak secara permanen. Harap aktifkan secara manual di pengaturan aplikasi.',
          color: Colors.red,
        );
        setState(() {
          _isLoading = false;
        });
        // Tidak ada openAppSettings() tanpa permission_handler
        return;
      }

      // Jika izin diberikan dan layanan aktif, lanjutkan mendapatkan posisi
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeout: const Duration(seconds: 10),
      );
      debugPrint('Lokasi didapat: ${position.latitude}, ${position.longitude}');

      setState(() {
        _statusMessage = 'Mendapatkan alamat dari lokasi...';
      });

      String address = 'Lokasi Tidak Diketahui';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
          localeIdentifier: 'id_ID',
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          address =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}';
        }
      } catch (e) {
        debugPrint('Error getting address from coordinates: $e');
        address = 'Gagal mendapatkan alamat ($e)';
      }

      setState(() {
        _statusMessage = 'Mengirim data absen masuk...';
      });

      final response = await _authService.checkInAttendance(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      if (response.data != null) {
        _showMessage(response.message, color: Colors.green);
        Navigator.pop(context, true);
      } else {
        String errorMessage = response.message;
        if (response.errors != null) {
          response.errors!.forEach((key, value) {
            errorMessage +=
                '\n${key.toUpperCase()}: ${(value as List).join(', ')}';
          });
        }
        _showMessage(errorMessage, color: Colors.red);
      }
    } on TimeoutException {
      _showMessage(
        'Gagal mendapatkan lokasi dalam waktu yang ditentukan. Coba lagi.',
        color: Colors.red,
      );
    } catch (e) {
      debugPrint('Error getting location or checking in: $e');
      _showMessage('Terjadi kesalahan: $e', color: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        title: const Text(
          'Absen Masuk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.myblue2,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isLoading
                  ? CircularProgressIndicator(color: AppColor.myblue)
                  : Icon(
                    Icons.location_on,
                    size: 100,
                    color:
                        _messageColor == Colors.green
                            ? Colors.green
                            : AppColor.myblue2,
                  ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _messageColor,
                ),
              ),
              const SizedBox(height: 40),
              if (!_isLoading)
                ElevatedButton.icon(
                  onPressed: () {
                    _checkLocationAndCheckIn();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Coba Lagi',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.myblue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
