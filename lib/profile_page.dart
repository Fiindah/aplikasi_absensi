import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Function to show a message using SnackBar
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang Scaffold adalah warna abu-abu muda yang formal
      backgroundColor: AppColor.neutral,
      // appBar: AppBar(
      //   title: const Text(
      //     'Profil Pengguna', // Judul AppBar yang jelas
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor:
      //       Colors.blue.shade700, // Warna AppBar yang solid dan formal
      //   elevation: 0, // Tanpa bayangan untuk tampilan yang lebih bersih
      //   centerTitle: true,
      // ),
      body: Column(
        children: <Widget>[
          // Bagian atas: Informasi Profil Singkat
          Padding(
            padding: const EdgeInsets.only(left: 28.0, right: 28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 40.0,
                bottom: 50.0,
              ), // Padding disesuaikan
              decoration: BoxDecoration(
                color: AppColor.myblue2,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(99),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 28),
                  CircleAvatar(
                    radius: 50, // Ukuran avatar sedikit lebih besar
                    backgroundImage: const NetworkImage(
                      'https://placehold.co/100x100/007bff/ffffff?text=User', // Ganti dengan URL gambar profil nyata
                    ),
                    backgroundColor: Colors.blue.shade100,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Nama Peserta', // Ganti dengan nama aktual
                    style: TextStyle(
                      fontSize: 16, // Ukuran font lebih besar
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Warna teks putih agar kontras
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'ID Peserta: 123456789', // Ganti dengan nomor ID aktual
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ), // Warna teks sedikit transparan
                  ),
                ],
              ),
            ),
          ),

          // Bagian bawah: Opsi Profil
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 18.0,
              ),
              child: Column(
                children: [
                  _buildDivider(),
                  _buildOptionTile(
                    context,
                    icon: Icons.edit,
                    iconColor: Colors.blue.shade600,
                    title: 'Ubah Profil',
                    message: 'Navigasi ke halaman Ubah Profil',
                    onTap: () {
                      // TODO: Implement navigation to Edit Profile page
                    },
                  ),
                  _buildDivider(),
                  _buildOptionTile(
                    context,
                    icon: Icons.lock,
                    iconColor: Colors.green,
                    title: 'Ubah Kata Sandi',
                    message: 'Navigasi ke halaman Ubah Kata Sandi',
                    onTap: () {
                      // TODO: Implement navigation to Change Password page
                    },
                  ),
                  _buildDivider(),
                  _buildOptionTile(
                    context,
                    icon: Icons.logout,
                    iconColor: Colors.red.shade600,
                    title: 'Keluar',
                    message: 'Anda telah keluar.',
                    onTap: () {
                      // TODO: Implement actual logout logic (clear session, navigate to login)
                      Navigator.pop(
                        context,
                      ); // Contoh: Kembali ke halaman sebelumnya
                    },
                  ),
                  _buildDivider(),
                  // Tambahkan opsi lain di sini
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pembantu untuk membuat ListTile opsi
  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
        size: 24, // Ukuran ikon disesuaikan
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey,
      ),
      onTap: () {
        _showMessage(context, message);
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 2,
      ), // Padding konten disesuaikan
    );
  }

  // Widget pembantu untuk garis pemisah
  Widget _buildDivider() {
    return const Divider(
      indent: 0, // Mengisi lebar penuh
      endIndent: 0, // Mengisi lebar penuh
      thickness: 0.8, // Ketebalan garis
      color: Colors.black12, // Warna garis yang lembut
    );
  }
}
