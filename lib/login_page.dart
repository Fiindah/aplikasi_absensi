import 'package:aplikasi_absensi/api/user_api.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/helper/preference.dart';
import 'package:aplikasi_absensi/register_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String id = "/login_page";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {Color color = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: color,
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (response.data != null) {
          // Login berhasil
          _showMessage(
            'Login berhasil! Selamat datang, ${response.data!.user.name}',
            color: Colors.green,
          );
          await SharedPreferencesUtil.saveAuthToken(response.data!.token);
          await SharedPreferencesUtil.saveUserData(response.data!.user);
          // TODO: Simpan token dan data pengguna (misalnya ke SharedPreferences)
          // Contoh navigasi ke HomePage setelah login berhasil
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        } else {
          // Login gagal, tampilkan pesan error dari API
          _showMessage(response.message, color: Colors.red);
        }
      } catch (e) {
        // Tangani error lain (misalnya parsing error)
        _showMessage('Terjadi kesalahan tak terduga: $e', color: Colors.red);
      } finally {
        setState(() {
          _isLoading = false; // Sembunyikan loading
        });
      }
    }
  }

  // void _login() async {

  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final res = await userService.loginUser(
  //       email: _emailController.text,
  //       password: _passwordController.text,
  //     );

  //     if (res["data"] != null) {
  //       SharePref.saveToken(res["data"]["token"]);
  //       debugPrint("Token: ${res["data"]["token"]}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("Login berhasil!"),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //       Navigator.pushReplacementNamed(context, MainWrapperPage.id);
  //     } else if (res["errors"] != null) {
  //       // More specific error handling for API validation messages
  //       String errorMessage = "Login gagal.";
  //       if (res["errors"]["email"] != null) {
  //         errorMessage += "\nEmail: ${res["errors"]["email"].join(', ')}";
  //       }
  //       if (res["errors"]["password"] != null) {
  //         errorMessage += "\nPassword: ${res["errors"]["password"].join(', ')}";
  //       } else if (res["message"] != null) {
  //         // General message from API if no specific field errors
  //         errorMessage = res["message"];
  //       }

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("Login gagal: Respon tidak terduga."),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint("Login Error: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Terjadi kesalahan saat login: $e"),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral, // Consistent background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   AppImage.logo,
              //   height: 120, // Adjusted size
              //   width: 120,
              // ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Masuk Akun Anda",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColor.myblue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTitle("Email"),
                      const SizedBox(height: 12),
                      _buildTextField(
                        hintText: "Masukkan email Anda",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTitle("Kata Sandi"),
                      const SizedBox(height: 12),
                      _buildTextField(
                        hintText: "Masukkan kata sandi Anda",
                        controller: _passwordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement Forgot Password logic
                          },
                          child: Text(
                            "Lupa Kata Sandi?",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          // onPressed: () {},
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.myblue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4, // Button shadow
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Belum punya akun?",
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColor.gray88,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, RegisterPage.id);
                            },

                            child: Text(
                              "Daftar Sekarang", // Changed text
                              style: TextStyle(
                                color: AppColor.myblue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    String? hintText,
    bool isPassword = false,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText:
          isPassword
              ? !_isPasswordVisible
              : false, // Use ! instead of direct isVisibility
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // More rounded corners
          borderSide: BorderSide.none, // No border needed if filled
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColor.myblue,
            width: 2.0,
          ), // Highlight focus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ), // Error highlight
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ), // Error highlight on focus
        ),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon:
            isPassword
                ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColor.gray88,
                  ),
                )
                : null,
      ),
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

// import 'package:aplikasi_absensi/constant/app_color.dart';
// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   final _formKey = GlobalKey<FormState>();

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
//     );
//   }

//   // Fungsi untuk menangani proses login
//   void _login() {
//     if (_formKey.currentState!.validate()) {
//       String email = _emailController.text;
//       String password = _passwordController.text;

//       if (email == 'test@example.com' && password == 'password123') {
//         _showMessage('Login berhasil! Selamat datang, $email');
//         // Contoh: Navigasi ke HomePage setelah login berhasil
//         // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
//       } else {
//         _showMessage('Email atau kata sandi salah.');
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.neutral,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               const SizedBox(height: 50),

//               // Icon(Icons.fingerprint, size: 100, color: AppColor.myblue1),
//               const SizedBox(height: 20),
//               // const Text(
//               //   'Selamat Datang Kembali!',
//               //   textAlign: TextAlign.center,
//               //   style: TextStyle(
//               //     fontSize: 24,
//               //     fontWeight: FontWeight.bold,
//               //     color: Colors.black87,
//               //   ),
//               // ),
//               const SizedBox(height: 10),
//               Text(
//                 'Silakan login untuk melanjutkan',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//               ),
//               const SizedBox(height: 40),

//               TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   hintText: 'Masukkan email',
//                   prefixIcon: const Icon(
//                     Icons.person_outline,
//                     color: Colors.blueGrey,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none, // Menghilangkan border default
//                   ),
//                   filled: true,
//                   fillColor:
//                       Colors.white, // Latar belakang putih untuk input field
//                   contentPadding: const EdgeInsets.symmetric(
//                     vertical: 16,
//                     horizontal: 16,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: Colors.grey.shade300,
//                       width: 1.0,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AppColor.myblue1, width: 2.0),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Email tidak boleh kosong';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),

//               // Input Password
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Kata Sandi',
//                   hintText: 'Masukkan kata sandi',
//                   prefixIcon: const Icon(
//                     Icons.lock_outline,
//                     color: Colors.blueGrey,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                   contentPadding: const EdgeInsets.symmetric(
//                     vertical: 16,
//                     horizontal: 16,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: Colors.grey.shade300,
//                       width: 1.0,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AppColor.myblue1, width: 2.0),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Kata sandi tidak boleh kosong';
//                   }
//                   if (value.length < 6) {
//                     return 'Kata sandi minimal 6 karakter';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),

//               // Tombol Lupa Kata Sandi
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     _showMessage('Fitur Lupa Kata Sandi belum tersedia.');
//                   },
//                   child: Text(
//                     'Lupa Kata Sandi?',
//                     style: TextStyle(
//                       color: AppColor.myblue1,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),

//               // Tombol Login
//               ElevatedButton(
//                 onPressed: _login,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColor.myblue1, // Warna tombol login
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30), // Sudut tombol
//                   ),
//                   elevation: 5,
//                   minimumSize: const Size(double.infinity, 50), // Lebar penuh
//                 ),
//                 child: const Text(
//                   'Login',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Belum punya akun?',
//                     style: TextStyle(color: Colors.grey.shade700),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       _showMessage('Fitur Daftar belum tersedia.');
//                     },
//                     child: Text(
//                       'Daftar Sekarang',
//                       style: TextStyle(
//                         color: AppColor.myblue1,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
