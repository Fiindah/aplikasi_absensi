import 'package:aplikasi_absensi/api/user_api.dart';
import 'package:aplikasi_absensi/attendance_detail_page.dart';
import 'package:aplikasi_absensi/check_in_page.dart';
import 'package:aplikasi_absensi/check_out_page.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/helper/share_pref.dart';
import 'package:aplikasi_absensi/models/attendance_model.dart';
import 'package:aplikasi_absensi/models/attendance_stats_model.dart'; // New import
import 'package:aplikasi_absensi/models/profile_model.dart';
import 'package:fl_chart/fl_chart.dart'; // New import for charts
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static const String id = "/dashboard_page";

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ProfileData? _currentUser;
  String _currentDate = '';
  AttendanceData? _todayAttendance;
  AttendanceStatsData? _attendanceStats; // New state for attendance stats
  bool _isLoadingAttendance = true;
  bool _isLoadingStats = true; // New loading state for stats
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    debugPrint('DashboardPage: initState called.');
    _loadUserDataAndDate();
    _fetchTodayAttendanceStatus();
    _fetchAttendanceStats();
  }

  Future<void> _loadUserDataAndDate() async {
    debugPrint('DashboardPage: _loadUserDataAndDate started.');
    final user = await SharedPreferencesUtil.getUserData();
    debugPrint(
      'DashboardPage: User data fetched from SharedPreferences: ${user?.name}',
    );

    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');

    setState(() {
      _currentUser = user;
      _currentDate = formatter.format(now);
      debugPrint('DashboardPage: _currentUser set to: ${_currentUser?.name}');
      debugPrint('DashboardPage: _currentDate set to: $_currentDate');
    });
  }

  Future<void> _fetchTodayAttendanceStatus() async {
    setState(() {
      _isLoadingAttendance = true;
    });
    try {
      final response = await _authService.fetchTodayAttendance();
      if (response.data != null) {
        setState(() {
          _todayAttendance = response.data;
        });
        debugPrint(
          'DashboardPage: Today attendance status fetched: ${_todayAttendance?.status}',
        );
      } else {
        setState(() {
          _todayAttendance = AttendanceData(
            id: 0,
            attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            status: 'belum_absen',
            alasanIzin: response.message, // Use message for default status
          );
        });
        debugPrint(
          'DashboardPage: No attendance data for today. Status set to belum_absen.',
        );
      }
    } catch (e) {
      debugPrint('DashboardPage: Error fetching today attendance: $e');
      setState(() {
        _todayAttendance = AttendanceData(
          id: 0,
          attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          status: 'error_loading',
          alasanIzin: 'Gagal memuat status absensi: $e',
        );
      });
    } finally {
      setState(() {
        _isLoadingAttendance = false;
      });
    }
  }

  // New method to fetch attendance statistics
  Future<void> _fetchAttendanceStats() async {
    setState(() {
      _isLoadingStats = true;
    });
    try {
      final response = await _authService.fetchAttendanceStats();
      if (response.data != null) {
        setState(() {
          _attendanceStats = response.data;
        });
        debugPrint(
          'DashboardPage: Attendance stats fetched: Total Absen: ${_attendanceStats?.totalAbsen}, Masuk: ${_attendanceStats?.totalMasuk}, Izin: ${_attendanceStats?.totalIzin}',
        );
      } else {
        _showMessage(context, response.message, color: Colors.red);
        debugPrint(
          'DashboardPage: Failed to fetch attendance stats: ${response.message}',
        );
      }
    } catch (e) {
      debugPrint('DashboardPage: Error fetching attendance stats: $e');
      _showMessage(
        context,
        'Gagal memuat statistik absensi: $e',
        color: Colors.red,
      );
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 18) {
      return 'Selamat Siang';
    } else {
      return 'Selamat Malam';
    }
  }

  Future<void> _showPermissionDialog() async {
    final TextEditingController reasonController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajukan Izin/Cuti'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan alasan izin/cuti Anda',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Kirim Izin'),
              onPressed: () async {
                if (reasonController.text.isEmpty) {
                  _showMessage(
                    context,
                    'Alasan tidak boleh kosong.',
                    color: Colors.red,
                  );
                  return;
                }
                Navigator.of(context).pop();
                await _submitPermission(reasonController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPermission(String reason) async {
    setState(() {
      _isLoadingAttendance = true;
    });
    try {
      final response = await _authService.submitPermission(reason: reason);
      if (response.data != null) {
        _showMessage(context, response.message, color: Colors.green);
        await _fetchTodayAttendanceStatus();
        await _fetchAttendanceStats(); // Refresh stats after permission
      } else {
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
      _showMessage(context, 'Gagal mengajukan izin: $e', color: Colors.red);
    } finally {
      setState(() {
        _isLoadingAttendance = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'DashboardPage: build method called. Displaying name: ${_currentUser?.name}',
    );

    String attendanceStatusText = 'Memuat status...';
    Color attendanceStatusColor = Colors.grey;
    bool canCheckIn = false;
    bool canCheckOut = false;
    bool canSubmitPermission = false;
    bool canViewDetail = false;

    if (!_isLoadingAttendance && _todayAttendance != null) {
      if (_todayAttendance!.status == 'masuk') {
        attendanceStatusText =
            'Anda sudah Absen Masuk hari ini pada pukul ${_todayAttendance!.checkInTime}';
        attendanceStatusColor = Colors.green;
        canCheckIn = false;
        canCheckOut = true;
        canSubmitPermission = false;
        canViewDetail = true;
      } else if (_todayAttendance!.status == 'pulang') {
        attendanceStatusText =
            'Anda sudah Absen Pulang hari ini pada pukul ${_todayAttendance!.checkOutTime}';
        attendanceStatusColor = AppColor.orange;
        canCheckIn = false;
        canCheckOut = false;
        canSubmitPermission = false;
        canViewDetail = true;
      } else if (_todayAttendance!.status == 'izin') {
        attendanceStatusText =
            'Anda sudah mengajukan Izin hari ini: "${_todayAttendance!.alasanIzin}"';
        attendanceStatusColor = Colors.blueGrey;
        canCheckIn = false;
        canCheckOut = false;
        canSubmitPermission = false;
        canViewDetail = true;
      } else if (_todayAttendance!.status == 'belum_absen') {
        attendanceStatusText = 'Anda belum Absen Masuk hari ini.';
        attendanceStatusColor = Colors.red;
        canCheckIn = true;
        canCheckOut = false;
        canSubmitPermission = true;
        canViewDetail = false;
      } else if (_todayAttendance!.status == 'error_loading') {
        attendanceStatusText =
            _todayAttendance!.alasanIzin ?? 'Gagal memuat status absensi.';
        attendanceStatusColor = Colors.red;
        canCheckIn = true;
        canCheckOut = false;
        canSubmitPermission = true;
        canViewDetail = false;
      }
    }

    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.myblue2,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting and User Name
            Text(
              '${_getGreeting()},',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColor.myblue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentUser?.name ?? 'Pengguna',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Today's Date
            Text(
              'Hari ini:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColor.gray88,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentDate,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),

            // Attendance Status Card
            GestureDetector(
              onTap:
                  canViewDetail && _todayAttendance != null
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AttendanceDetailPage(
                                  attendanceData: _todayAttendance!,
                                ),
                          ),
                        );
                      }
                      : null,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Absensi Hari Ini',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.myblue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _isLoadingAttendance
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: attendanceStatusColor,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  attendanceStatusText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: attendanceStatusColor,
                                  ),
                                ),
                              ),
                              if (canViewDetail)
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColor.gray88,
                                ),
                            ],
                          ),
                      const SizedBox(height: 20),
                      // Tombol Absen Masuk dan Absen Pulang
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  canCheckIn
                                      ? () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const CheckInPage(),
                                          ),
                                        );
                                        if (result == true) {
                                          await _fetchTodayAttendanceStatus();
                                          await _fetchAttendanceStats(); // Refresh stats after check-in
                                        }
                                      }
                                      : null,
                              icon: const Icon(
                                Icons.login,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Absen Masuk',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  canCheckOut
                                      ? () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const CheckOutPage(),
                                          ),
                                        );
                                        if (result == true) {
                                          await _fetchTodayAttendanceStatus();
                                          await _fetchAttendanceStats(); // Refresh stats after check-out
                                        }
                                      }
                                      : null,
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Absen Pulang',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Tombol Izin
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              canSubmitPermission
                                  ? _showPermissionDialog
                                  : null,
                          icon: const Icon(
                            Icons.edit_calendar,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Ajukan Izin/Cuti',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.myblue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Attendance Statistics Card with Pie Chart
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Absensi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.myblue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _isLoadingStats
                        ? const Center(child: CircularProgressIndicator())
                        : _attendanceStats != null &&
                            _attendanceStats!.totalAbsen > 0
                        ? SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: _getPieChartSections(_attendanceStats!),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              pieTouchData: PieTouchData(
                                enabled: false,
                              ), // Disable touch for simplicity
                            ),
                          ),
                        )
                        : Center(
                          child: Text(
                            _attendanceStats != null &&
                                    _attendanceStats!.totalAbsen == 0
                                ? 'Belum ada data absensi.'
                                : 'Gagal memuat statistik.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.gray88,
                            ),
                          ),
                        ),
                    if (!_isLoadingStats && _attendanceStats != null) ...[
                      const SizedBox(height: 10),
                      _buildStatLegend(
                        color: Colors.green,
                        title: 'Masuk',
                        value: _attendanceStats!.totalMasuk,
                      ),
                      _buildStatLegend(
                        color: Colors.blueGrey,
                        title: 'Izin',
                        value: _attendanceStats!.totalIzin,
                      ),
                      _buildStatLegend(
                        color: Colors.grey,
                        title: 'Total Absen',
                        value: _attendanceStats!.totalAbsen,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Info Card (Existing)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Cepat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.myblue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Jadwal Berikutnya',
                      'Rapat Tim, 14:00',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.school,
                      'Training Aktif',
                      _currentUser?.trainingTitle ?? 'Belum ada',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Action Button (Existing)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tombol Aksi Cepat ditekan!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Icons.touch_app),
                label: const Text(
                  'Aksi Cepat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build info rows
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColor.gray88, size: 24),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showMessage(
    BuildContext context,
    String message, {
    Color color = Colors.black,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: color,
      ),
    );
  }

  // Helper function to create PieChartSections
  List<PieChartSectionData> _getPieChartSections(AttendanceStatsData stats) {
    final double total = stats.totalMasuk + stats.totalIzin.toDouble();
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '0%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: Colors.green,
        value: (stats.totalMasuk / total) * 100,
        title: '${stats.totalMasuk} Masuk',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.blueGrey,
        value: (stats.totalIzin / total) * 100,
        title: '${stats.totalIzin} Izin',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  // Helper widget for chart legend
  Widget _buildStatLegend({
    required Color color,
    required String title,
    required int value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            '$title: $value',
            style: TextStyle(fontSize: 16, color: AppColor.gray88),
          ),
        ],
      ),
    );
  }
}
