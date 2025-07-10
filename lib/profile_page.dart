import 'package:aplikasi_absensi/api/endpoint.dart';
import 'package:aplikasi_absensi/api/user_api.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/models/profile_model.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const String id = "/profile_page";

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileData? _userProfile;
  bool _isLoadingProfile = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fungsi untuk memuat data profil dari API
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });
    try {
      final response = await _authService.fetchUserProfile();
      if (response.data != null) {
        setState(() {
          _userProfile = response.data;
        });
      } else {
        _showMessage(context, response.message);
      }
    } catch (e) {
      _showMessage(context, 'Gagal memuat profil: $e');
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  // Function to show a message using SnackBar
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // Fungsi untuk menangani logout
  void _logout() async {
    await _authService.logout(); // Panggil metode logout dari AuthService
    _showMessage(context, 'Anda telah keluar.');
    // Navigasi kembali ke halaman login atau welcome page
    // Pastikan LoginPage diimpor jika Anda ingin navigasi ke sana
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => const LoginPage()),
    //   (Route<dynamic> route) => false, // Hapus semua rute sebelumnya
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral, // Consistent background color
      appBar: AppBar(
        title: const Text(
          'Profil Pengguna',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.myblue2, // Consistent app bar color
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _isLoadingProfile
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Tampilkan loading indicator
              : _userProfile == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Gagal memuat data profil.'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _fetchUserProfile, // Coba lagi
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
                    decoration: BoxDecoration(
                      color: AppColor.myblue2, // Consistent color
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _userProfile?.profilePhoto != null
                                  ? NetworkImage(
                                    '${Endpoint.baseUrl}/${_userProfile!.profilePhoto!}',
                                  ) // Gunakan base URL untuk foto
                                  : const NetworkImage(
                                    'https://placehold.co/100x100/007bff/ffffff?text=User',
                                  ),
                          backgroundColor: AppColor.myblue, // Consistent color
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _userProfile?.name ?? 'Nama Peserta Pelatihan',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _userProfile?.id != null
                              ? 'ID Peserta: ${_userProfile!.id}'
                              : 'ID Peserta: Tidak Diketahui',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start, // Align content to the start (left)
                          children: [
                            _buildInfoRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: _userProfile?.email ?? '-',
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.group,
                              label: 'Batch',
                              value: _userProfile?.batchKe ?? '-',
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.school,
                              label: 'Training',
                              value: _userProfile?.trainingTitle ?? '-',
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.wc,
                              label: 'Jenis Kelamin',
                              value: _userProfile?.jenisKelamin ?? '-',
                            ),
                            _buildDivider(),
                            // Tambahkan informasi lain yang ingin Anda tampilkan dari profil
                            const SizedBox(height: 20),
                            _buildOptionTile(
                              context,
                              icon: Icons.edit,
                              iconColor: AppColor.myblue, // Consistent color
                              title: 'Ubah Profil',
                              message: 'Navigasi ke halaman Ubah Profil',
                              onTap: () {},
                              // onTap: () async {
                              //   final result = await Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder:
                              //           (context) => const EditProfilePage(),
                              //     ),
                              //   );
                              //   if (result == true) {
                              //     _fetchUserProfile(); // Muat ulang data setelah kembali dari EditProfilePage
                              //   }
                              // },
                            ),
                            _buildDivider(),
                            _buildOptionTile(
                              context,
                              icon: Icons.lock,
                              iconColor: AppColor.orange, // Consistent color
                              title: 'Ubah Kata Sandi',
                              message: 'Navigasi ke halaman Ubah Kata Sandi',
                              onTap: () {
                                // TODO: Implement navigation to Change Password page
                                _showMessage(
                                  context,
                                  'Fitur Ubah Kata Sandi belum tersedia.',
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildOptionTile(
                              context,
                              icon: Icons.logout,
                              iconColor: Colors.red,
                              title: 'Keluar',
                              message: 'Anda telah keluar.',
                              onTap: _logout,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColor.myblue, size: 24),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.gray88,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey,
      ),
      onTap: onTap, // Langsung panggil onTap, pesan sudah di dalam onTap
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      indent: 0,
      endIndent: 0,
      thickness: 0.8,
      color: Colors.black12,
    );
  }
}
