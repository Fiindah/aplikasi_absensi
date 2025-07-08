import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _checkInTime = "Belum Check-in";
  String _checkOutTime = "Belum Check-out";
  final List<Map<String, String>> _riwayatKehadiran = [
    {
      "day": "Senin",
      "date": "09 Juni",
      "checkIn": "07:30",
      "checkOut": "15:00",
    },
    {
      "day": "Selasa",
      "date": "10 Juni",
      "checkIn": "07:45",
      "checkOut": "16:55",
    },
    {"day": "Rabu", "date": "11 Juni", "checkIn": "07:58", "checkOut": "17:02"},
    {
      "day": "Kamis",
      "date": "12 Juni",
      "checkIn": "07:58",
      "checkOut": "17:02",
    },
    {
      "day": "Jum'at",
      "date": "13 Juni",
      "checkIn": "07:36",
      "checkOut": "17:02",
    },
    {
      "day": "Sabtu",
      "date": "14 Juni",
      "checkIn": "07:58",
      "checkOut": "17:02",
    },
  ];

  // Function to get the current formatted time
  String _getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  // Function to handle check-in
  void _handleCheckIn() {
    setState(() {
      _checkInTime = _getCurrentTime();
    });
    // TODO: Add logic to save check-in time to database
    _showMessage('Check-in berhasil pada $_checkInTime');
  }

  // Function to handle check-out
  void _handleCheckOut() {
    if (_checkInTime == "Belum Check-in") {
      _showMessage('Anda harus Check-in terlebih dahulu!');
      return;
    }
    setState(() {
      _checkOutTime = _getCurrentTime();
    });
    // TODO: Add logic to save check-out time to database
    _showMessage('Check-out berhasil pada $_checkOutTime');
  }

  // Function to show a message using SnackBar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildProfileSection(),
            const SizedBox(height: 30),
            _buildAttendanceStatusCard(),
            const SizedBox(height: 30),
            _buildAttendanceHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white, // Latar belakang putih bersih
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Bayangan lebih halus
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: const NetworkImage(
              'https://placehold.co/80x80/007bff/ffffff?text=User',
            ),
            backgroundColor: Colors.blue.shade100,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nama Peserta Pelatihan',
                  style: TextStyle(
                    fontSize: 18, // Ukuran font sedikit disesuaikan
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Warna teks lebih gelap
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'ID Peserta: 123456789',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatusCard() {
    return Card(
      elevation: 3, // Elevasi disesuaikan
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Sudut sedikit kurang melengkung
      color: Colors.white, // Latar belakang putih bersih
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kehadiran Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700, // Warna judul yang lebih formal
              ),
            ),
            const Divider(
              height: 25,
              thickness: 1,
              color: Colors.grey,
            ), // Garis pemisah lebih formal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCheckButton(
                  title: 'Check-in',
                  time: _checkInTime,
                  onPressed: _handleCheckIn,
                  color: Colors.green.shade600, // Warna hijau yang lebih kalem
                  icon: Icons.login,
                ),
                const SizedBox(width: 20),
                _buildCheckButton(
                  title: 'Check-out',
                  time: _checkOutTime,
                  onPressed: _handleCheckOut,
                  color: Colors.red.shade600, // Warna merah yang lebih kalem
                  icon: Icons.logout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckButton({
    required String title,
    required String time,
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          Text(
            time,
            style: TextStyle(
              fontSize: 24, // Ukuran font waktu sedikit disesuaikan
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20), // Ukuran ikon disesuaikan
            label: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
              ), // Ukuran font label disesuaikan
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ), // Padding disesuaikan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ), // Sudut tombol lebih sederhana
              ),
              elevation: 3, // Elevasi tombol disesuaikan
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Kehadiran',
          style: TextStyle(
            fontSize: 18, // Ukuran font judul riwayat disesuaikan
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Warna teks judul riwayat agar kontras
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _riwayatKehadiran.length,
          itemBuilder: (context, index) {
            final entry = _riwayatKehadiran[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10.0),
              elevation: 2, // Elevasi kartu riwayat lebih rendah
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10,
                ), // Sudut kartu riwayat lebih sederhana
              ),
              color: Colors.white, // Latar belakang putih bersih
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry["day"]!,
                          style: const TextStyle(
                            fontSize: 16, // Ukuran font hari disesuaikan
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          entry["date"]!,
                          style: TextStyle(
                            fontSize: 14, // Ukuran font tanggal disesuaikan
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Check-in: ${entry["checkIn"]}',
                          style: TextStyle(
                            fontSize:
                                14, // Ukuran font check-in/out disesuaikan
                            color:
                                Colors
                                    .green
                                    .shade700, // Warna hijau yang lebih gelap
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Check-out: ${entry["checkOut"]}',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Colors
                                    .red
                                    .shade700, // Warna merah yang lebih gelap
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String _checkInTime = "Belum Check-in";
//   String _checkOutTime = "Belum Check-out";
//   final List<Map<String, String>> _riwayatKehadiran = [
//     {
//       "day": "Senin",
//       "date": "09 Juni",
//       "checkIn": "07:30",
//       "checkOut": "15:00",
//     },
//     {
//       "day": "Selasa",
//       "date": "10 Juni",
//       "checkIn": "07:45",
//       "checkOut": "16:55",
//     },
//     {"day": "Rabu", "date": "11 Juni", "checkIn": "07:58", "checkOut": "17:02"},
//     {
//       "day": "Kamis",
//       "date": "12 Juni",
//       "checkIn": "07:58",
//       "checkOut": "17:02",
//     },
//     {
//       "day": "Jum'at",
//       "date": "13 Juni",
//       "checkIn": "07:36",
//       "checkOut": "17:02",
//     },
//     {
//       "day": "Sabtu",
//       "date": "14 Juni",
//       "checkIn": "07:58",
//       "checkOut": "17:02",
//     },
//   ];

//   // Function to get the current formatted time
//   String _getCurrentTime() {
//     return DateFormat('HH:mm:ss').format(DateTime.now());
//   }

//   // Function to handle check-in
//   void _handleCheckIn() {
//     setState(() {
//       _checkInTime = _getCurrentTime();
//     });
//     // TODO: Add logic to save check-in time to database
//     _showMessage('Check-in berhasil pada $_checkInTime');
//   }

//   // Function to handle check-out
//   void _handleCheckOut() {
//     if (_checkInTime == "Belum Check-in") {
//       _showMessage('Anda harus Check-in terlebih dahulu!');
//       return;
//     }
//     setState(() {
//       _checkOutTime = _getCurrentTime();
//     });
//     // TODO: Add logic to save check-out time to database
//     _showMessage('Check-out berhasil pada $_checkOutTime');
//   }

//   // Function to show a message using SnackBar
//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             const SizedBox(height: 30),
//             _buildProfileSection(),
//             const SizedBox(height: 30),

//             _buildAttendanceStatusCard(),
//             const SizedBox(height: 30),

//             _buildAttendanceHistorySection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileSection() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         CircleAvatar(
//           radius: 25,
//           backgroundImage: NetworkImage(
//             'https://placehold.co/80x80/007bff/ffffff?text=User',
//           ),
//           backgroundColor: Colors.blue.shade100, // Background color for avatar
//         ),
//         const SizedBox(width: 15), // Spasi antara avatar dan teks
//         Expanded(
//           // Menggunakan Expanded agar teks mengambil sisa ruang
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start, // Teks rata kiri
//             children: [
//               const Text(
//                 'Nama Karyawan',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueGrey,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               const Text(
//                 'Nomer Peserta',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget to build the attendance status card (Check-in/Check-out buttons)
//   Widget _buildAttendanceStatusCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Kehadiran Hari Ini',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       const Text(
//                         'Check-in',
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         _checkInTime,
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green.shade700,
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       ElevatedButton.icon(
//                         onPressed: _handleCheckIn,

//                         label: const Text(
//                           'Check-in',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               Colors.green, // Warna tombol check-in
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           elevation: 5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       const Text(
//                         'Check-out',
//                         style: TextStyle(fontSize: 18, color: Colors.grey),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         _checkOutTime,
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.red.shade700,
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       ElevatedButton.icon(
//                         onPressed: _handleCheckOut,

//                         label: const Text(
//                           'Check-out',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red, // Warna tombol check-out
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget to build the attendance history section
//   Widget _buildAttendanceHistorySection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Riwayat Kehadiran',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.blueGrey,
//           ),
//         ),
//         const SizedBox(height: 15),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: _riwayatKehadiran.length,
//           itemBuilder: (context, index) {
//             final entry = _riwayatKehadiran[index];
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 10.0),
//               child: Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     // Changed to Column to stack date and times vertically
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               children: [
//                                 Column(
//                                   children: [
//                                     Text(
//                                       entry["date"]!,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       entry["day"]!,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Expanded(
//                             child: Column(
//                               children: [
//                                 Text(
//                                   'Check-in:',
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${entry["checkIn"]}',
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             height: 70,
//                             width: 1,
//                             color: Colors.grey.shade400,
//                             margin: const EdgeInsets.symmetric(horizontal: 10),
//                           ),
//                           Expanded(
//                             child: Column(
//                               children: [
//                                 Text(
//                                   'Check-out:',
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${entry["checkOut"]}',
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
