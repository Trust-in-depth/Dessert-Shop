// lib/features/log_module/screens/shred_history_list_screen.dart

import 'package:flutter/material.dart';
import 'package:shredrek/core/database/db_helper.dart';
import 'package:shredrek/models/log_entry.dart';
import 'package:shredrek/features/log_module/screens/shred_history_detail_screen.dart'; // Detay ekranı

class ShredHistoryListScreen extends StatefulWidget {
  const ShredHistoryListScreen({super.key});

  @override
  State<ShredHistoryListScreen> createState() => _ShredHistoryListScreenState();
}

class _ShredHistoryListScreenState extends State<ShredHistoryListScreen> {
  Future<List<LogEntry>>? _logsFuture;
  String? _selectedStatus; // Filtre: SHREDDED, BINNED vb.
  String? _selectedExtension; // Filtre: .pdf, .jpg vb.

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  // Logları veritabanından çeken fonksiyon
  void _fetchLogs() {
    setState(() {
      _logsFuture = DbHelper.instance.getFilteredLogs(
        status: _selectedStatus,
        extension: _selectedExtension,
        // Zaman ve boyut filtreleri de buraya eklenebilir
      );
    });
  }

  // Filtre Seçim Diyaloğu
  void _showFilterDialog() {
    // Burada daha gelişmiş bir filtreleme formu gösterilebilir.
    showDialog(
      context: context,
      builder: (context) {
        // Basit bir örnek için sadece durum filtresini kullanalım
        String tempStatus = _selectedStatus ?? '';
        String tempExtension = _selectedExtension ?? '';

        return AlertDialog(
          title: const Text('Logları Filtrele'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Durum Filtresi
              DropdownButtonFormField<String>(
                value: tempStatus.isEmpty ? null : tempStatus,
                decoration: const InputDecoration(labelText: 'Aksiyon Tipi'),
                items: const [
                  DropdownMenuItem(value: 'SHREDDED', child: Text('Shredded')),
                  DropdownMenuItem(
                    value: 'BINNED',
                    child: Text('Bin\'e Atıldı'),
                  ),
                ],
                onChanged: (val) => tempStatus = val ?? '',
              ),
              const SizedBox(height: 10),
              // Uzantı Filtresi
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Uzantı (örn: .pdf)',
                ),
                onChanged: (val) => tempExtension = val.toLowerCase(),
                controller: TextEditingController(text: tempExtension),
              ),
              // Boyut, Tarih filtreleri de buraya eklenebilir.
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _selectedStatus = null;
                _selectedExtension = null;
                _fetchLogs();
                Navigator.pop(context);
              },
              child: const Text('Filtreyi Temizle'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = tempStatus.isEmpty ? null : tempStatus;
                  _selectedExtension = tempExtension.isEmpty
                      ? null
                      : tempExtension;
                });
                _fetchLogs();
                Navigator.pop(context);
              },
              child: const Text('Uygula'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş Logları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<LogEntry>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Filtreye uygun log kaydı bulunamadı.'),
            );
          }

          final logs = snapshot.data!;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                leading: Icon(
                  log.status == 'SHREDDED'
                      ? Icons.delete_forever
                      : Icons.restore_from_trash,
                  color: log.status == 'SHREDDED' ? Colors.red : Colors.orange,
                ),
                title: Text(log.fileName),
                subtitle: Text(
                  'Aksiyon: ${log.status}, Tarih: ${DateTime.fromMillisecondsSinceEpoch(log.timestamp).toString().substring(0, 16)}',
                ),
                trailing: Text(log.fileSize), // Boyut bilgisi [cite: 39]
                onTap: () {
                  // Detay ekranına git
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ShredHistoryDetailScreen(logEntry: log),
                        ),
                      )
                      .then(
                        (_) => _fetchLogs(),
                      ); // Detaydan dönünce listeyi yenile
                },
              );
            },
          );
        },
      ),
    );
  }
}
