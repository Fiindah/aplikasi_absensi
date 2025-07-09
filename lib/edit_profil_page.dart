import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // TextEditingController untuk setiap field input
  final TextEditingController _nameController = TextEditingController(
    text: 'Nama Peserta Pelatihan',
  );
  final TextEditingController _idController = TextEditingController(
    text: '123456789',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'peserta.pelatihan@example.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '081234567890',
  );

  // URL gambar profil (bisa diubah nanti jika ada fitur upload gambar)
  final String _profileImageUrl =
      'https://placehold.co/100x100/007bff/ffffff?text=User';

  // Function to show a message using SnackBar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // Fungsi untuk menyimpan perubahan (placeholder)
  void _saveChanges() {
    // Di sini Anda akan mengimplementasikan logika untuk menyimpan data ke database
    // Contoh:
    // String newName = _nameController.text;
    // String newId = _idController.text;
    // String newEmail = _emailController.text;
    // String newPhone = _phoneController.text;

    _showMessage('Perubahan profil berhasil disimpan!');
    // Setelah menyimpan, Anda mungkin ingin kembali ke halaman profil
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Pastikan untuk membuang controller saat widget dihapus
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral, // Latar belakang abu-abu muda
      appBar: AppBar(
        title: const Text(
          'Ubah Profil', // Judul AppBar
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.myblue2, // Warna AppBar yang solid dan formal
        elevation: 0, // Tanpa bayangan
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Bagian Foto Profil
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60, // Ukuran avatar lebih besar
                    backgroundImage: NetworkImage(_profileImageUrl),
                    backgroundColor: Colors.blue.shade100,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        _showMessage('Fitur ubah foto profil akan datang!');
                        // TODO: Implementasi fitur pilih gambar dari galeri/kamera
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.myblue, // Warna ikon ubah foto
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Bagian Form Ubah Profil
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'Nama Lengkap',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _idController,
                      labelText: 'Nomor ID Peserta',
                      icon: Icons.badge,
                      readOnly: true, // Nomor ID biasanya tidak bisa diubah
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _phoneController,
                      labelText: 'Nomor Telepon',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.myblue, // Warna tombol simpan
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Sudut tombol
                        ),
                        elevation: 5,
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ), // Lebar penuh
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk membuat TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        prefixIcon: Icon(
          icon,
          color: AppColor.myblue,
        ), // Ikon dengan warna primary
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Sudut input field
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColor.myblue, width: 2.0),
        ),
        fillColor: Colors.grey.shade50, // Latar belakang input field
        filled: true,
      ),
    );
  }
}
