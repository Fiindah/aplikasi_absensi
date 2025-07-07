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
      appBar: AppBar(
        // title: const Text('Absensi Karyawan'),
        // centerTitle: true,
        // elevation: 0, // Remove shadow for a cleaner look
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Bagian Circle Avatar dan Informasi Pengguna
            _buildProfileSection(),
            const SizedBox(height: 30),

            // Bagian Check-in dan Check-out
            _buildAttendanceStatusCard(),
            const SizedBox(height: 30),

            // Bagian Riwayat Kehadiran
            _buildAttendanceHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(
            'https://placehold.co/80x80/007bff/ffffff?text=User',
          ),
          backgroundColor: Colors.blue.shade100, // Background color for avatar
        ),
        const SizedBox(width: 15), // Spasi antara avatar dan teks
        Expanded(
          // Menggunakan Expanded agar teks mengambil sisa ruang
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Teks rata kiri
            children: [
              const Text(
                'Nama Karyawan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Nomer Induk',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget to build the attendance status card (Check-in/Check-out buttons)
  Widget _buildAttendanceStatusCard() {
    return Card(
      elevation: 8, // Increased elevation for a more prominent card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kehadiran Hari Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Check-in',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _checkInTime,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _handleCheckIn,

                        label: const Text(
                          'Check-in',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // Warna tombol check-in
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Check-out',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _checkOutTime,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _handleCheckOut,

                        label: const Text(
                          'Check-out',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Warna tombol check-out
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the attendance history section
  Widget _buildAttendanceHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Kehadiran',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _riwayatKehadiran.length,
          itemBuilder: (context, index) {
            final entry = _riwayatKehadiran[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // Changed to Column to stack date and times vertically
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      entry["date"]!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      entry["day"]!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Check-in:',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  '${entry["checkIn"]}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            // Vertical line separator
                            height: 70, // Height of the line
                            width: 1, // Thickness of the line
                            color: Colors.grey.shade400, // Color of the line
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ), // Space around the line
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Check-out:',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  '${entry["checkOut"]}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
// import 'package:intl/intl.dart'; // Import for date and time formatting

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // State variables for check-in/check-out times and attendance history
//   String _checkInTime = "Belum Check-in";
//   String _checkOutTime = "Belum Check-out";
//   final List<Map<String, String>> _riwayatKehadiran = [
//     {"date": "09 Juni 2025", "checkIn": "07:30", "checkOut": "15:00"},
//     {"date": "10 Juni 2025", "checkIn": "07:45", "checkOut": "16:55"},
//     {"date": "11 Juni 2025", "checkIn": "07:58", "checkOut": "17:02"},
//     {"date": "12 Juni 2025", "checkIn": "07:58", "checkOut": "17:02"},
//     {"date": "13 Juni 2025", "checkIn": "07:36", "checkOut": "17:02"},
//     {"date": "14 Juni 2025", "checkIn": "07:58", "checkOut": "17:02"},
//   ]; // Contoh data riwayat kehadiran

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
//       appBar: AppBar(
//         // title: const Text('Absensi Karyawan'),
//         // centerTitle: true,
//         // elevation: 0, // Remove shadow for a cleaner look
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             // Bagian Circle Avatar dan Informasi Pengguna
//             _buildProfileSection(),
//             const SizedBox(height: 30),

//             // Bagian Check-in dan Check-out
//             _buildAttendanceStatusCard(),
//             const SizedBox(height: 30),

//             // Bagian Riwayat Kehadiran
//             _buildAttendanceHistorySection(),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget to build the profile section (Circle Avatar, Name, Position)
//   Widget _buildProfileSection() {
//     return Row(
//       // Menggunakan Row untuk menempatkan avatar di kiri
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         CircleAvatar(
//           radius: 40, // Mengurangi ukuran radius avatar
//           // Placeholder image, replace with actual user image URL or asset
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
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueGrey,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               const Text(
//                 'Jabatan',
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
//       elevation: 8, // Increased elevation for a more prominent card
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Status Kehadiran Hari Ini',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.deepPurple,
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
//                         style: TextStyle(fontSize: 18, color: Colors.grey),
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
//                         icon: const Icon(Icons.login, size: 20),
//                         label: const Text(
//                           'Check-in Sekarang',
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
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 20), // Spacer between buttons
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
//                         icon: const Icon(Icons.logout, size: 20),
//                         label: const Text(
//                           'Check-out Sekarang',
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
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.blueGrey,
//           ),
//         ),
//         const SizedBox(height: 15),
//         Card(
//           elevation: 8,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: ListView.builder(
//             shrinkWrap:
//                 true, // Penting agar ListView bisa di dalam SingleChildScrollView
//             physics:
//                 const NeverScrollableScrollPhysics(), // Menonaktifkan scroll ListView
//             itemCount: _riwayatKehadiran.length,
//             itemBuilder: (context, index) {
//               final entry = _riwayatKehadiran[index];
//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 8.0,
//                   horizontal: 16.0,
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.calendar_today,
//                       color: Colors.blue.shade700,
//                       size: 24,
//                     ),
//                     const SizedBox(width: 15),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             entry["date"]!,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Check-in: ${entry["checkIn"]}, Check-out: ${entry["checkOut"]}',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
