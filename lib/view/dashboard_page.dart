import 'package:aplikasi_absensi/api/user_api.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/models/attendance_model.dart';
import 'package:aplikasi_absensi/models/attendance_stats_model.dart';
import 'package:aplikasi_absensi/view/check_in_page.dart';
import 'package:aplikasi_absensi/view/check_out_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static const String id = "/dashboard_page";

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _currentDate = '';
  AttendanceData? _todayAttendance;
  AttendanceStatsData? _attendanceStats;
  bool _isLoadingAttendance = true;
  bool _isLoadingStats = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeLocaleAndLoadData();
    _fetchTodayAttendanceStatus();
    _fetchAttendanceStats();
  }

  Future<void> _initializeLocaleAndLoadData() async {
    await initializeDateFormatting('id_ID', null);
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    setState(() {
      _currentDate = formatter.format(now);
    });
  }

  Future<void> _fetchTodayAttendanceStatus() async {
    setState(() => _isLoadingAttendance = true);
    try {
      final response = await _authService.fetchTodayAttendance();
      setState(() {
        _todayAttendance =
            response.data ??
            AttendanceData(
              id: 0,
              attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              status: 'belum_absen',
              alasanIzin: response.message,
            );
      });
    } catch (e) {
      setState(() {
        _todayAttendance = AttendanceData(
          id: 0,
          attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          status: 'error_loading',
          alasanIzin: 'Gagal memuat status absensi: $e',
        );
      });
    } finally {
      setState(() => _isLoadingAttendance = false);
    }
  }

  Future<void> _fetchAttendanceStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final response = await _authService.fetchAttendanceStats();
      if (response.data != null) {
        setState(() => _attendanceStats = response.data);
      } else {
        if (!mounted) return;
        _showMessage(context, response.message, color: Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        context,
        'Gagal memuat statistik absensi: $e',
        color: Colors.red,
      );
    } finally {
      setState(() => _isLoadingStats = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 18) return 'Selamat Siang';
    return 'Selamat Malam';
  }

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

  Widget _buildStatRow({
    required String title,
    required int count,
    required Color color,
    required int total,
  }) {
    double percent = total > 0 ? count / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: $count (${(percent * 100).toStringAsFixed(1)}%)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.gray88,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.grey.shade300,
          color: color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColor.myblue,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColor.myblue.withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentDate,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, CheckInPage.id);
                      },
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text("Check In"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, CheckOutPage.id);
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text("Check Out"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child:
                      _isLoadingAttendance
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Hari Ini',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.myblue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_todayAttendance != null) ...[
                                _buildInfoRow(
                                  Icons.event_available,
                                  'Status',
                                  _todayAttendance!.status,
                                ),
                                if (_todayAttendance!.status == 'izin')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: _buildInfoRow(
                                      Icons.info_outline,
                                      'Alasan',
                                      _todayAttendance!.alasanIzin ?? '-',
                                    ),
                                  ),
                              ],
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Statistik Kehadiran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.myblue,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoadingStats)
                const Center(child: CircularProgressIndicator())
              else if (_attendanceStats != null)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow(
                          title: 'Hadir',
                          count: _attendanceStats!.totalMasuk,
                          color: Colors.green,
                          total:
                              _attendanceStats!.totalMasuk +
                              _attendanceStats!.totalIzin,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          title: 'Izin',
                          count: _attendanceStats!.totalIzin,
                          color: Colors.blueGrey,
                          total:
                              _attendanceStats!.totalMasuk +
                              _attendanceStats!.totalIzin,
                        ),
                        const SizedBox(height: 20),
                        AspectRatio(
                          aspectRatio: 1.3,
                          child: PieChart(
                            PieChartData(
                              sections: _getPieChartSections(_attendanceStats!),
                              centerSpaceRadius: 30,
                              sectionsSpace: 2,
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: AppColor.gray88),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showMessage(
    BuildContext context,
    String message, {
    Color color = Colors.black,
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
