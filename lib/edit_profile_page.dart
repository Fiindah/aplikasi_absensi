import 'dart:io'; // For File

import 'package:aplikasi_absensi/api/endpoint.dart';
import 'package:aplikasi_absensi/api/user_api.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  Batch? _selectedBatch;
  List<Batch> _batches = [];

  Training? _selectedTraining;
  List<Training> _trainings = [];

  String _profileImageUrl =
      'https://placehold.co/100x100/007bff/ffffff?text=User';
  ProfileData? _currentUserProfile;
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isSaving = false;

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final profileResponse = await _authService.fetchUserProfile();
      if (profileResponse.data != null) {
        _currentUserProfile = profileResponse.data;
        _nameController.text = _currentUserProfile!.name;
        _emailController.text = _currentUserProfile!.email;

        _selectedGender = _formatGenderForDropdown(
          _currentUserProfile!.jenisKelamin,
        );
        debugPrint(
          'Initial gender: ${_currentUserProfile!.jenisKelamin} -> _selectedGender: $_selectedGender',
        );

        if (_currentUserProfile!.profilePhoto != null &&
            _currentUserProfile!.profilePhoto!.isNotEmpty) {
          _profileImageUrl =
              _currentUserProfile!.profilePhoto!.startsWith('http')
                  ? _currentUserProfile!.profilePhoto!
                  : '${Endpoint.baseUrl}/public/${_currentUserProfile!.profilePhoto!}';
        }
      } else {
        _showMessage(context, profileResponse.message, color: Colors.red);
      }

      final fetchedBatches = await _authService.fetchBatches();
      final fetchedTrainings = await _authService.fetchTrainings();

      setState(() {
        _batches = fetchedBatches;
        _trainings = fetchedTrainings;

        if (_currentUserProfile != null) {
          final int? currentBatchId =
              _currentUserProfile!.batchId is int
                  ? _currentUserProfile!.batchId
                  : int.tryParse(_currentUserProfile!.batchId.toString());

          final int? currentTrainingId =
              _currentUserProfile!.trainingId is int
                  ? _currentUserProfile!.trainingId
                  : int.tryParse(_currentUserProfile!.trainingId.toString());

          _selectedBatch = _batches.firstWhereOrNull(
            (batch) => batch.id == currentBatchId,
          );
          _selectedTraining = _trainings.firstWhereOrNull(
            (training) => training.id == currentTrainingId,
          );

          // Fallback jika tidak ditemukan, dan daftar tidak kosong
          if (_selectedBatch == null && _batches.isNotEmpty) {
            _selectedBatch = _batches.first;
            debugPrint(
              'Fallback: _selectedBatch set to first available batch.',
            );
          }
          if (_selectedTraining == null && _trainings.isNotEmpty) {
            _selectedTraining = _trainings.first;
            debugPrint(
              'Fallback: _selectedTraining set to first available training.',
            );
          }
          debugPrint(
            'Initial batch ID: $currentBatchId -> _selectedBatch: ${_selectedBatch?.batchKe}',
          );
          debugPrint(
            'Initial training ID: $currentTrainingId -> _selectedTraining: ${_selectedTraining?.title}',
          );
        }
      });
    } catch (e) {
      debugPrint('Error loading all data: $e');
      _showMessage(context, 'Gagal memuat data: $e', color: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
        debugPrint('Loading complete. _isLoading set to false.');
      });
    }
  }

  String? _formatGenderForDropdown(String? genderCode) {
    if (genderCode == null) return null;
    switch (genderCode.toUpperCase()) {
      case 'L':
        return 'Laki-laki';
      case 'P':
        return 'Perempuan';
      default:
        return null;
    }
  }

  String? _formatGenderForApi(String? genderText) {
    if (genderText == null) return null;
    switch (genderText) {
      case 'Laki-laki':
        return 'L';
      case 'Perempuan':
        return 'P';
      default:
        return null;
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    Color color = Colors.black,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        backgroundColor: color,
      ), // Durasi lebih lama
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        _profileImageUrl = pickedFile.path;
      });
      await _uploadProfilePhoto();
    } else {
      _showMessage(context, 'Pemilihan gambar dibatalkan.');
    }
  }

  Future<void> _uploadProfilePhoto() async {
    if (_pickedImage == null) {
      _showMessage(
        context,
        'Tidak ada gambar yang dipilih untuk diunggah.',
        color: Colors.orange,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await _authService.updateProfilePhoto(
        imageFile: _pickedImage!,
      );

      if (response.data != null) {
        _showMessage(context, response.message, color: Colors.green);
        setState(() {
          _profileImageUrl = response.data!.profilePhotoUrl;
        });
        await _loadAllData();
      } else {
        _showMessage(context, response.message, color: Colors.red);
      }
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      _showMessage(
        context,
        'Gagal mengunggah foto profil: $e',
        color: Colors.red,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _saveChanges() async {
    debugPrint('Save Changes button pressed. Current _isSaving: $_isSaving');

    if (_isSaving) {
      debugPrint('Save process already in progress. Ignoring button press.');
      return;
    }

    if (_currentUserProfile == null) {
      debugPrint('Validation: _currentUserProfile is null.');
      _showMessage(
        context,
        'Data pengguna tidak ditemukan. Harap muat ulang halaman.',
        color: Colors.red,
      );
      return;
    }

    // Menggunakan GlobalKey<FormState> untuk validasi
    // Asumsi Anda akan membungkus TextFormField dan DropdownButtonFormField dengan Form widget
    // Jika belum, ini akan selalu melewati validasi ini.
    // if (!_formKey.currentState!.validate()) { // Jika Anda menggunakan Form widget dengan _formKey
    //   debugPrint('Validation: Form fields are invalid.');
    //   _showMessage(context, 'Harap isi semua kolom dengan benar.', color: Colors.red);
    //   return;
    // }

    // Validasi manual untuk dropdown
    if (_selectedGender == null) {
      debugPrint('Validation: _selectedGender is null.');
      _showMessage(
        context,
        'Jenis kelamin tidak boleh kosong. Harap pilih jenis kelamin.',
        color: Colors.red,
      );
      return;
    }
    if (_selectedBatch == null) {
      debugPrint('Validation: _selectedBatch is null.');
      _showMessage(
        context,
        'Batch tidak boleh kosong. Harap pilih batch.',
        color: Colors.red,
      );
      return;
    }
    if (_selectedTraining == null) {
      debugPrint('Validation: _selectedTraining is null.');
      _showMessage(
        context,
        'Training tidak boleh kosong. Harap pilih training.',
        color: Colors.red,
      );
      return;
    }

    setState(() {
      _isSaving = true;
      debugPrint('Save Changes: Setting _isSaving to true.');
    });

    try {
      debugPrint(
        'Save Changes: Attempting to call AuthService.updateUserProfile().',
      );
      final response = await _authService.updateUserProfile(
        name: _nameController.text,
        email: _emailController.text,
        jenisKelamin: _formatGenderForApi(_selectedGender!),
        batchId: _selectedBatch!.id,
        trainingId: _selectedTraining!.id,
        onesignalPlayerId: _currentUserProfile!.onesignalPlayerId,
      );
      debugPrint(
        'Save Changes: AuthService.updateUserProfile() call completed.',
      );

      if (response.data != null) {
        debugPrint('Save Changes: API response indicates success.');
        _showMessage(context, response.message, color: Colors.green);
        Navigator.pop(context, true);
      } else {
        debugPrint(
          'Save Changes: API response indicates failure. Message: ${response.message}',
        );
        String errorMessage = response.message;
        if (response.errors != null) {
          response.errors!.forEach((key, value) {
            errorMessage +=
                '\n${key.toUpperCase()}: ${(value as List).join(', ')}';
          });
        }
        _showMessage(context, errorMessage, color: Colors.red);
      }
    } catch (e) {
      debugPrint('Save Changes Error: Exception caught: $e');
      _showMessage(
        context,
        'Terjadi kesalahan tak terduga saat menyimpan: $e',
        color: Colors.red,
      );
    } finally {
      setState(() {
        _isSaving = false;
        debugPrint(
          'Save Changes: Setting _isSaving to false in finally block.',
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        title: const Text(
          'Ubah Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.myblue2,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                _pickedImage != null
                                    ? FileImage(_pickedImage!)
                                        as ImageProvider<Object>
                                    : NetworkImage(_profileImageUrl),
                            backgroundColor: AppColor.myblue,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
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
                            _buildTitle("Nama Lengkap"),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _nameController,
                              hintText: 'Masukkan nama lengkap Anda',
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 20),

                            _buildTitle("Email"),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Masukkan email Anda',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),

                            _buildTitle("Jenis Kelamin"),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: _buildDropdownDecoration(
                                'Pilih jenis kelamin Anda',
                                Icons.wc,
                              ),
                              items:
                                  _genders.map((String gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                  debugPrint(
                                    'Selected Gender: $newValue',
                                  ); // Debugging dropdown change
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Jenis kelamin tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildTitle("Batch"),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Batch>(
                              value: _selectedBatch,
                              decoration: _buildDropdownDecoration(
                                'Pilih Batch Anda',
                                Icons.group,
                              ),
                              items:
                                  _batches.map((Batch batch) {
                                    return DropdownMenuItem<Batch>(
                                      value: batch,
                                      child: Text(
                                        'Batch ${batch.batchKe} (${batch.startDate} - ${batch.endDate})',
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (Batch? newValue) {
                                setState(() {
                                  _selectedBatch = newValue;
                                  debugPrint(
                                    'Selected Batch: ${newValue?.batchKe}',
                                  ); // Debugging dropdown change
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Batch tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildTitle("Training"),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Training>(
                              value: _selectedTraining,
                              decoration: _buildDropdownDecoration(
                                'Pilih Training Anda',
                                Icons.school,
                              ),
                              items:
                                  _trainings.map((Training training) {
                                    return DropdownMenuItem<Training>(
                                      value: training,
                                      child: Text(training.title),
                                    );
                                  }).toList(),
                              onChanged: (Training? newValue) {
                                setState(() {
                                  _selectedTraining = newValue;
                                  debugPrint(
                                    'Selected Training: ${newValue?.title}',
                                  ); // Debugging dropdown change
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Training tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            ElevatedButton(
                              onPressed: _isSaving ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child:
                                  _isSaving
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
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

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
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
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColor.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColor.primary, width: 2.0),
        ),
        fillColor: Colors.grey.shade50,
        filled: true,
      ),
    );
  }

  InputDecoration _buildDropdownDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: AppColor.primary),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColor.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildTitle(String text) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.myblue,
          ),
        ),
      ],
    );
  }
}

// Extension untuk FirstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

// import 'dart:io'; // For File

// import 'package:aplikasi_absensi/api/endpoint.dart';
// import 'package:aplikasi_absensi/api/user_api.dart';
// import 'package:aplikasi_absensi/constant/app_color.dart';
// import 'package:aplikasi_absensi/models/profile_model.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Import image_picker

// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});

//   @override
//   _EditProfilePageState createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _jenisKelaminController =
//       TextEditingController(); // Untuk display jenis kelamin
//   final TextEditingController _batchKeController =
//       TextEditingController(); // Untuk display batch
//   final TextEditingController _trainingTitleController =
//       TextEditingController(); // Untuk display training

//   String _profileImageUrl =
//       'https://placehold.co/100x100/007bff/ffffff?text=User';
//   ProfileData? _currentUserProfile;
//   final AuthService _authService = AuthService();
//   bool _isLoading = false;
//   bool _isSaving = false;

//   File? _pickedImage; // Untuk menyimpan gambar yang dipilih

//   @override
//   void initState() {
//     super.initState();
//     _loadUserDataAndPopulateFields();
//   }

//   Future<void> _loadUserDataAndPopulateFields() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await _authService.fetchUserProfile();
//       if (response.data != null) {
//         _currentUserProfile = response.data;
//         _nameController.text = _currentUserProfile!.name;
//         _emailController.text = _currentUserProfile!.email;
//         _jenisKelaminController.text = _currentUserProfile!.jenisKelamin ?? '-';
//         _batchKeController.text = _currentUserProfile!.batchKe ?? '-';
//         _trainingTitleController.text =
//             _currentUserProfile!.trainingTitle ?? '-';

//         if (_currentUserProfile!.profilePhoto != null &&
//             _currentUserProfile!.profilePhoto!.isNotEmpty) {
//           // Pastikan URL foto profil lengkap dengan base URL
//           _profileImageUrl =
//               _currentUserProfile!.profilePhoto!.startsWith('http')
//                   ? _currentUserProfile!.profilePhoto!
//                   : '${Endpoint.baseUrl}/public/${_currentUserProfile!.profilePhoto!}';
//         }
//       } else {
//         _showMessage(context, response.message, color: Colors.red);
//       }
//     } catch (e) {
//       _showMessage(context, 'Gagal memuat profil: $e', color: Colors.red);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showMessage(
//     BuildContext context,
//     String message, {
//     Color color = Colors.black,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 3),
//         backgroundColor: color,
//       ),
//     );
//   }

//   // Fungsi untuk memilih gambar dari galeri/kamera
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//     ); // Atau .camera

//     if (pickedFile != null) {
//       setState(() {
//         _pickedImage = File(pickedFile.path);
//         _profileImageUrl =
//             pickedFile.path; // Tampilkan gambar yang baru dipilih secara lokal
//       });
//       _uploadProfilePhoto(); // Langsung unggah setelah memilih
//     } else {
//       _showMessage(context, 'Pemilihan gambar dibatalkan.');
//     }
//   }

//   // Fungsi untuk mengunggah foto profil
//   Future<void> _uploadProfilePhoto() async {
//     if (_pickedImage == null) {
//       _showMessage(
//         context,
//         'Tidak ada gambar yang dipilih untuk diunggah.',
//         color: Colors.orange,
//       );
//       return;
//     }

//     setState(() {
//       _isSaving = true; // Gunakan _isSaving untuk proses upload juga
//     });

//     try {
//       final response = await _authService.updateProfilePhoto(
//         imageFile: _pickedImage!,
//       );

//       if (response.data != null) {
//         _showMessage(context, response.message, color: Colors.green);
//         // Perbarui URL gambar profil setelah berhasil diunggah
//         setState(() {
//           _profileImageUrl = response.data!.profilePhotoUrl;
//         });
//         // Muat ulang data profil dari server untuk memastikan konsistensi
//         await _loadUserDataAndPopulateFields();
//       } else {
//         _showMessage(context, response.message, color: Colors.red);
//       }
//     } catch (e) {
//       _showMessage(
//         context,
//         'Gagal mengunggah foto profil: $e',
//         color: Colors.red,
//       );
//     } finally {
//       setState(() {
//         _isSaving = false;
//       });
//     }
//   }

//   void _saveChanges() async {
//     if (_currentUserProfile == null) {
//       _showMessage(
//         context,
//         'Data pengguna tidak ditemukan.',
//         color: Colors.red,
//       );
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       // Mengambil batchId dan trainingId dari _currentUserProfile
//       // Jika Anda ingin mengizinkan pengguna mengubah batch/training,
//       // Anda perlu menambahkan dropdown di EditProfilePage dan mengambil ID dari sana.
//       // Untuk saat ini, kita akan menggunakan nilai yang ada atau null.
//       final int? currentBatchId =
//           _currentUserProfile!.batchId is int
//               ? _currentUserProfile!.batchId
//               : int.tryParse(_currentUserProfile!.batchId.toString());

//       final int? currentTrainingId =
//           _currentUserProfile!.trainingId is int
//               ? _currentUserProfile!.trainingId
//               : int.tryParse(_currentUserProfile!.trainingId.toString());

//       final response = await _authService.updateUserProfile(
//         name: _nameController.text,
//         email: _emailController.text,
//         jenisKelamin:
//             _jenisKelaminController.text == '-'
//                 ? null
//                 : _jenisKelaminController
//                     .text, // Kirim null jika tidak ada perubahan
//         batchId: currentBatchId, // Menggunakan ID yang ada
//         trainingId: currentTrainingId, // Menggunakan ID yang ada
//         onesignalPlayerId:
//             _currentUserProfile!
//                 .onesignalPlayerId, // Pertahankan nilai yang ada
//       );

//       if (response.data != null) {
//         _showMessage(context, response.message, color: Colors.green);
//         // Data di SharedPreferences sudah diperbarui oleh AuthService
//         Navigator.pop(
//           context,
//           true,
//         ); // Kembali ke halaman profil dan beri tahu untuk refresh
//       } else {
//         String errorMessage = response.message;
//         if (response.errors != null) {
//           response.errors!.forEach((key, value) {
//             errorMessage +=
//                 '\n${key.toUpperCase()}: ${(value as List).join(', ')}';
//           });
//         }
//         _showMessage(context, errorMessage, color: Colors.red);
//       }
//     } catch (e) {
//       _showMessage(
//         context,
//         'Terjadi kesalahan tak terduga saat menyimpan: $e',
//         color: Colors.red,
//       );
//     } finally {
//       setState(() {
//         _isSaving = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _jenisKelaminController.dispose();
//     _batchKeController.dispose();
//     _trainingTitleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.neutral,
//       appBar: AppBar(
//         title: const Text(
//           'Ubah Profil',
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: AppColor.myblue2,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: <Widget>[
//                     Center(
//                       child: Stack(
//                         children: [
//                           CircleAvatar(
//                             radius: 60,
//                             backgroundImage:
//                                 _pickedImage != null
//                                     ? FileImage(_pickedImage!)
//                                         as ImageProvider<Object>
//                                     : NetworkImage(_profileImageUrl),
//                             backgroundColor: AppColor.myblue,
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: GestureDetector(
//                               onTap: _pickImage, // Panggil fungsi pilih gambar
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: AppColor.primary,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: 2,
//                                   ),
//                                 ),
//                                 child: const Icon(
//                                   Icons.camera_alt,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 30),

//                     Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       color: Colors.white,
//                       child: Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildTextField(
//                               controller: _nameController,
//                               labelText: 'Nama Lengkap',
//                               icon: Icons.person,
//                             ),
//                             const SizedBox(height: 20),
//                             _buildTextField(
//                               controller: _emailController,
//                               labelText: 'Email',
//                               icon: Icons.email,
//                               keyboardType: TextInputType.emailAddress,
//                               readOnly:
//                                   true, // Email biasanya tidak bisa diubah
//                             ),
//                             const SizedBox(height: 20),
//                             _buildTextField(
//                               controller: _jenisKelaminController,
//                               labelText: 'Jenis Kelamin',
//                               icon: Icons.wc,
//                               // Jika Anda ingin mengizinkan edit, ganti dengan DropdownButtonFormField
//                               // atau buat pop-up pilihan. Untuk saat ini, hanya display.
//                             ),
//                             const SizedBox(height: 20),
//                             _buildTextField(
//                               controller: _batchKeController,
//                               labelText: 'Batch',
//                               icon: Icons.group,
//                               readOnly:
//                                   true, // Asumsi batch tidak bisa diubah lewat sini
//                             ),
//                             const SizedBox(height: 20),
//                             _buildTextField(
//                               controller: _trainingTitleController,
//                               labelText: 'Training',
//                               icon: Icons.school,
//                               readOnly:
//                                   true, // Asumsi training tidak bisa diubah lewat sini
//                             ),
//                             const SizedBox(height: 30),
//                             ElevatedButton(
//                               onPressed:
//                                   _isSaving
//                                       ? null
//                                       : _saveChanges, // Dinonaktifkan saat menyimpan
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColor.primary,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 15,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 elevation: 5,
//                                 minimumSize: const Size(double.infinity, 50),
//                               ),
//                               child:
//                                   _isSaving
//                                       ? const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       )
//                                       : const Text(
//                                         'Simpan Perubahan',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String labelText,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     bool readOnly = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       readOnly: readOnly,
//       keyboardType: keyboardType,
//       style: const TextStyle(color: Colors.black87),
//       decoration: InputDecoration(
//         labelText: labelText,
//         labelStyle: TextStyle(color: Colors.grey.shade700),
//         prefixIcon: Icon(icon, color: AppColor.primary),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade400),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: AppColor.primary, width: 2.0),
//         ),
//         fillColor: Colors.grey.shade50,
//         filled: true,
//       ),
//     );
//   }
// }
