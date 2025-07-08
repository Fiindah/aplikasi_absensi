import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:flutter/material.dart';
// import 'package:aplikasi_absensi/constant/app_color.dart'; // Komentar ini karena AppColor tidak didefinisikan di sini

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


// import 'package:aplikasi_absensi/constant/app_color.dart';
// import 'package:flutter/material.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   // Function to show a message using SnackBar
//   void _showMessage(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),

//         // child: Container(
//         //   decoration: BoxDecoration(
//         //     color: AppColor.myblue2,
//         //     borderRadius: BorderRadius.horizontal(
              
//         //     ),
//         //     ),
//             // gradient: LinearGradient(

//             //   colors: [
//             //     Colors.blue.shade700,
//             //     Colors.blue.shade400,
//             //   ], // Warna gradien
//             //   begin: Alignment.topLeft,
//             //   end: Alignment.bottomRight,
//             // ),
//           // ),
//           child: Column(
//             // Menggunakan Column untuk menumpuk bagian profil dan konten utama
//             children: <Widget>[
//               // Padding untuk menghindari AppBar
//               SizedBox(
//                 height:
//                     MediaQuery.of(context).padding.top +
//                     AppBar().preferredSize.height +
//                     20,
//               ), // Tambah sedikit spasi di bawah app bar
//               // Bagian Informasi Profil Singkat (tetap di atas gradien)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundImage: NetworkImage(
//                           'https://placehold.co/60x60/007bff/ffffff?text=User',
//                         ),
//                       ),
//                       const SizedBox(width: 15),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           SizedBox(height: 13),
//                           Text(
//                             'Nama',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Text(
//                             'Nomor ID',
//                             style: TextStyle(fontSize: 15, color: Colors.white),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Kontainer untuk bagian Opsi Profil
//               Expanded(
//                 // Menggunakan Expanded agar konten ini mengisi sisa ruang
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     // borderRadius: BorderRadius.vertical(
//                     //   top: Radius.circular(30),
//                     // ), // Border radius melingkar di bagian atas
//                   ),
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       children: [
//                         SizedBox(height: 16),
//                         Column(
//                           children: [
//                             ListTile(
//                               leading: const Icon(
//                                 Icons.edit,
//                                 color: Colors.blue,
//                               ),
//                               title: const Text('Ubah Profil'),
//                               trailing: const Icon(
//                                 Icons.arrow_forward_ios,
//                                 size: 18,
//                               ),
//                               onTap: () {
//                                 _showMessage(
//                                   context,
//                                   'Navigasi ke halaman Ubah Profil',
//                                 );
//                                 // TODO: Implement navigation to Edit Profile page
//                               },
//                             ),
//                             const Divider(
//                               indent: 16,
//                               endIndent: 16,
//                             ), // Garis pemisah
//                             ListTile(
//                               leading: const Icon(
//                                 Icons.lock,
//                                 color: Colors.green,
//                               ),
//                               title: const Text('Ubah Kata Sandi'),
//                               trailing: const Icon(
//                                 Icons.arrow_forward_ios,
//                                 size: 18,
//                               ),
//                               onTap: () {
//                                 _showMessage(
//                                   context,
//                                   'Navigasi ke halaman Ubah Kata Sandi',
//                                 );
//                                 // TODO: Implement navigation to Change Password page
//                               },
//                             ),
//                             const Divider(
//                               indent: 16,
//                               endIndent: 16,
//                             ), // Garis pemisah
//                             ListTile(
//                               leading: const Icon(
//                                 Icons.logout,
//                                 color: Colors.red,
//                               ),
//                               title: const Text('Keluar'),
//                               trailing: const Icon(
//                                 Icons.arrow_forward_ios,
//                                 size: 18,
//                               ),
//                               onTap: () {
//                                 _showMessage(context, 'Anda telah keluar.');
//                                 // TODO: Implement actual logout logic (clear session, navigate to login)
//                                 Navigator.pop(
//                                   context,
//                                 ); // Kembali ke halaman sebelumnya (HomePage)
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     )
//   }
// }

// import 'package:flutter/material.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Stack(children: [buildBackground(), buildProfile()]),
//       ),
//     );
//   }

//   Container buildBackground() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.blue,
//         borderRadius: BorderRadius.vertical(
//           bottom: Radius.circular(30),
//         ), // Warna gradien
//         // begin: Alignment.topLeft,
//         // end: Alignment.bottomRight,
//       ),
//       // height: double.infinity,
//       // width: double.infinity,
//       // decoration: const BoxDecoration(
//       //   image: DecorationImage(
//       //     image: AssetImage("assets/images/background.png"),
//       //     fit: BoxFit.cover,
//       //   ),
//     );
//   }

//   SafeArea buildProfile() {
//     return SafeArea(
//       child: Center(
//         child: Column(
//           children: [
//             SizedBox(height: 100),
//             CircleAvatar(radius: 50, backgroundColor: Colors.blue),
//             SizedBox(height: 10),
//             Text(
//               "Nama Peserta",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               "Nomer Peserta Pelatihan",
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//             SizedBox(height: 100),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.person, color: Colors.blue),
//                     title: const Text('Ubah Profil'),
//                     trailing: const Icon(Icons.arrow_forward_ios, size: 12),
//                     onTap: () {},
//                   ),

//                   const Divider(indent: 16, endIndent: 16), // Garis pemisah
//                   ListTile(
//                     leading: const Icon(Icons.lock, color: Colors.orange),
//                     title: const Text('Ubah Kata Sandi'),
//                     trailing: const Icon(Icons.arrow_forward_ios, size: 12),
//                     onTap: () {},
//                   ),
//                   const Divider(indent: 16, endIndent: 16), // Garis pemisah
//                   ListTile(
//                     leading: const Icon(Icons.logout, color: Colors.red),
//                     title: const Text('Keluar'),
//                     trailing: const Icon(Icons.arrow_forward_ios, size: 12),
//                     onTap: () {},
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'package:belajar_flutter/constant/app_color.dart';
// // import 'package:belajar_flutter/helper/preference.dart';
// // import 'package:belajar_flutter/meet_25/tugas_15/api/user_api.dart';
// // import 'package:belajar_flutter/meet_25/tugas_15/profile_screen.dart';
// // import 'package:belajar_flutter/meet_25/tugas_15/register_screen.dart';
// // import 'package:flutter/material.dart';

// // class LoginScreenApi extends StatefulWidget {
// //   const LoginScreenApi({super.key});
// //   static const String id = "/login_screen_api";
// //   @override
// //   State<LoginScreenApi> createState() => _LoginScreenApiState();
// // }

// // class _LoginScreenApiState extends State<LoginScreenApi> {
// //   final UserService userService = UserService();
// //   bool isVisibility = false;
// //   bool isLoading = false;

// //   final TextEditingController emailController = TextEditingController();
// //   final TextEditingController passwordController = TextEditingController();
// //   final _formKey = GlobalKey<FormState>();

// //   void login() async {
// //     setState(() {
// //       isLoading = true;
// //     });
// //     final res = await userService.loginUser(
// //       email: emailController.text,
// //       password: passwordController.text,
// //     );
// //     if (res["data"] != null) {
// //       PreferenceHandler.saveToken(res["data"]["token"]);
// //       print("Token: ${res["data"]["token"]}");
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text("Login successful!"),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //       Navigator.pushNamedAndRemoveUntil(
// //         context,
// //         ProfileUserScreen.id,
// //         (route) => false,
// //       );
// //     } else if (res["errors"] != null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text("${res["message"]}"),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //     setState(() {
// //       isLoading = false;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Form(
// //         key: _formKey,
// //         child: Stack(children: [buildBackground(), buildLayer()]),
// //       ),
// //     );
// //   }

// //   SafeArea buildLayer() {
// //     return SafeArea(
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             // crossAxisAlignment: CrossAxisAlignment.center,
// //             children: [
// //               Text(
// //                 "Logo Brand",
// //                 style: TextStyle(
// //                   fontSize: 24,
// //                   fontWeight: FontWeight.bold,
// //                   color: AppColor.myblue1,
// //                 ),
// //               ),
// //               height(12),
// //               Text(
// //                 "Login to your account",
// //                 style: TextStyle(fontSize: 16, color: AppColor.black22),
// //               ),
// //               height(24),
// //               buildTitle("Email"),
// //               height(12),
// //               buildTextField(
// //                 hintText: "Enter your email",
// //                 controller: emailController,
// //               ),
// //               height(16),
// //               buildTitle("Password"),
// //               height(12),
// //               buildTextField(
// //                 hintText: "Enter your password",
// //                 isPassword: true,
// //                 controller: passwordController,
// //               ),
// //               height(12),
// //               Align(
// //                 alignment: Alignment.centerRight,
// //                 child: TextButton(
// //                   onPressed: () {
// //                     // Navigator.push(
// //                     //   context,
// //                     //   MaterialPageRoute(builder: (context) => MeetSebelas()),
// //                     // );
// //                   },
// //                   child: Text(
// //                     "Forgot Password?",
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       color: AppColor.orange,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               height(24),
// //               SizedBox(
// //                 width: double.infinity,
// //                 height: 56,
// //                 child: ElevatedButton(
// //                   onPressed: () {
// //                     if (_formKey.currentState!.validate()) {
// //                       print("Email: ${emailController.text}");
// //                       print("Password: ${passwordController.text}");
// //                       login();
// //                     }
// //                   },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: AppColor.blueButton,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(6),
// //                     ),
// //                   ),
// //                   child:
// //                       isLoading
// //                           ? CircularProgressIndicator(color: Colors.white)
// //                           : Text(
// //                             "Login",
// //                             style: TextStyle(
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.white,
// //                             ),
// //                           ),
// //                 ),
// //               ),
// //               height(16),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Expanded(
// //                     child: Container(
// //                       margin: EdgeInsets.only(right: 8),
// //                       height: 1,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                   Text(
// //                     "Or Sign In With",
// //                     style: TextStyle(fontSize: 12, color: AppColor.gray88),
// //                   ),
// //                   Expanded(
// //                     child: Container(
// //                       margin: EdgeInsets.only(left: 8),

// //                       height: 1,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 ],
// //               ),

// //               height(16),
// //               SizedBox(
// //                 height: 48,
// //                 child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.white,
// //                   ),
// //                   onPressed: () {
// //                     // Navigate to MeetLima screen menggunakan pushnamed
// //                     Navigator.pushNamed(context, "/meet_2");
// //                   },
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Image.asset(
// //                         "assets/images/icon_google.png",
// //                         height: 16,
// //                         width: 16,
// //                       ),
// //                       width(4),
// //                       Text("Google"),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               height(16),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Text(
// //                     "Don't have an account?",
// //                     style: TextStyle(fontSize: 12, color: AppColor.gray88),
// //                   ),
// //                   TextButton(
// //                     onPressed: () {
// //                       Navigator.pushNamed(context, RegisterScreenAPI.id);
// //                     },
// //                     child: Text(
// //                       "Sign Up",
// //                       style: TextStyle(
// //                         color: AppColor.blueButton,

// //                         fontSize: 12,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Container buildBackground() {
// //     return Container(
// //       height: double.infinity,
// //       width: double.infinity,
// //       decoration: const BoxDecoration(
// //         color: AppColor.neutral,
// //         // image: DecorationImage(
// //         //   image: AssetImage("assets/images/background.png"),
// //         //   fit: BoxFit.cover,
// //         // ),
// //       ),
// //     );
// //   }

// //   Widget buildTextField({
// //     String? hintText,
// //     bool isPassword = false,
// //     required TextEditingController controller,
// //   }) {
// //     return TextFormField(
// //       controller: controller,
// //       validator: (value) {
// //         if (value == null || value.isEmpty) {
// //           return 'Please enter some text';
// //         }
// //         return null;
// //       },
// //       obscureText: isPassword ? isVisibility : false,
// //       decoration: InputDecoration(
// //         hintText: hintText,
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(6),
// //           borderSide: BorderSide(
// //             color: Colors.black.withOpacity(0.2),
// //             width: 1.0,
// //           ),
// //         ),
// //         focusedBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(6),
// //           borderSide: BorderSide(color: Colors.black, width: 1.0),
// //         ),
// //         enabledBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(6),
// //           borderSide: BorderSide(
// //             color: Colors.black.withOpacity(0.2),
// //             width: 1.0,
// //           ),
// //         ),
// //         suffixIcon:
// //             isPassword
// //                 ? IconButton(
// //                   onPressed: () {
// //                     setState(() {
// //                       isVisibility = !isVisibility;
// //                     });
// //                   },
// //                   icon: Icon(
// //                     isVisibility ? Icons.visibility_off : Icons.visibility,
// //                     color: AppColor.gray88,
// //                   ),
// //                 )
// //                 : null,
// //       ),
// //     );
// //   }

// //   SizedBox height(double height) => SizedBox(height: height);
// //   SizedBox width(double width) => SizedBox(width: width);

// //   Widget buildTitle(String text) {
// //     return Row(
// //       children: [
// //         Text(text, style: TextStyle(fontSize: 16, color: AppColor.myblue1)),
// //       ],
// //     );
// //   }
// // }
