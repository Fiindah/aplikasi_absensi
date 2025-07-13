import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Contoh data dummy
  final List<Map<String, dynamic>> history = [
    {
      'date': DateTime.now().subtract(const Duration(days: 0)),
      'status': 'Masuk',
      'time': '08:05',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Izin',
      'time': '-',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Masuk',
      'time': '08:12',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Kehadiran'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body:
          history.isEmpty
              ? const Center(
                child: Text(
                  'Belum ada data kehadiran.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final formattedDate = DateFormat(
                    'EEEE, dd MMMM yyyy',
                    'id_ID',
                  ).format(item['date']);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(
                        item['status'] == 'Masuk'
                            ? Icons.check_circle
                            : Icons.info,
                        color:
                            item['status'] == 'Masuk'
                                ? Colors.green
                                : Colors.orange,
                      ),
                      title: Text(
                        formattedDate,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Status: ${item['status']}'),
                      trailing: Text(item['time']),
                    ),
                  );
                },
              ),
    );
  }
}
