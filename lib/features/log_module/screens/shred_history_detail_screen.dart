// lib/features/log_module/screens/shred_history_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:shredrek/models/log_entry.dart';
import 'package:shredrek/core/database/db_helper.dart';

class ShredHistoryDetailScreen extends StatelessWidget {
  final LogEntry logEntry;

  const ShredHistoryDetailScreen({super.key, required this.logEntry});

  // Log kaydını silme
  void _deleteLog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Kaydını Sil'),
        content: const Text(
          'Bu log kaydını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (result == true) {
      await DbHelper.instance.deleteLog(
        logEntry.id!,
      ); // Tek bir log kaydını silme [cite: 43]
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Log kaydı silindi.')));
        Navigator.of(
          context,
        ).pop(true); // Geri dönerek listeyi yenilemeyi tetikle
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _deleteLog(context),
            tooltip: 'Bu Kaydı Sil',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildDetailTile(
              context,
              'Dosya Adı',
              logEntry.fileName,
              Icons.description,
            ),
            _buildDetailTile(
              context,
              'Aksiyon',
              logEntry.status,
              logEntry.status == 'SHREDDED'
                  ? Icons.delete_forever
                  : Icons.restore_from_trash,
            ),
            _buildDetailTile(
              context,
              'Tarih/Saat',
              DateTime.fromMillisecondsSinceEpoch(
                logEntry.timestamp,
              ).toString().substring(0, 16),
              Icons.calendar_today,
            ), // Tarih/saat bilgisi [cite: 39]
            _buildDetailTile(
              context,
              'Dosya Boyutu',
              logEntry.fileSize,
              Icons.calculate,
            ),
            if (logEntry.status == 'SHREDDED') ...[
              const Divider(height: 30),
              _buildDetailTile(
                context,
                'Shred Yöntemi',
                logEntry.shredMethod!,
                Icons.vpn_key,
              ), // Shred metodu [cite: 39]
              _buildDetailTile(
                context,
                'Pass Sayısı',
                logEntry.passCount.toString(),
                Icons.repeat,
              ), // Pass sayısı [cite: 41]
              _buildDetailTile(
                context,
                'Dosya Yolu',
                'Kalıcı olarak silindi.',
                Icons.visibility_off,
              ),
            ] else if (logEntry.status == 'BINNED') ...[
              const Divider(height: 30),
              _buildDetailTile(
                context,
                'Dosya Yolu',
                logEntry.filePath,
                Icons.folder,
              ), // Tam dosya yolu [cite: 41]
              const Text(
                'Bu dosya şu anda Bin klasöründe güvenle saklanmaktadır.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
