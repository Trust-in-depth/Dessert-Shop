// lib/features/shred_module/screens/staging_screen.dart
// lib/features/shred_module/screens/staging_screen.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// Yeni importlar
import 'package:shredrek/features/shred_module/services/bin_manager.dart';
import 'package:shredrek/features/shred_module/services/secret_manager.dart';
import 'package:shredrek/core/database/db_helper.dart';
import 'package:shredrek/models/log_entry.dart';
import 'package:shredrek/features/shred_module/screens/shred_confirmation_screen.dart';
import 'package:shredrek/features/shred_module/screens/shred_result_screen.dart'; // Sonuç ekranı

// Aksiyon tipleri için Enum tanımlayalım
enum FileAction { shredder, bin, secret, none } // 'secret' aksiyonunu ekledik

class StagingScreen extends StatefulWidget {
  final List<PlatformFile> selectedFiles;

  const StagingScreen({super.key, required this.selectedFiles});

  @override
  State<StagingScreen> createState() => _StagingScreenState();
}

class _StagingScreenState extends State<StagingScreen> {
  final Map<String, FileAction> _fileActions = {};

  // Yöneticileri tanımlama
  final BinManager _binManager = BinManager();
  final SecretManager _secretManager = SecretManager();

  @override
  void initState() {
    super.initState();
    for (var file in widget.selectedFiles) {
      if (file.path != null) {
        _fileActions[file.path!] = FileAction.none;
      }
    }
  }

  void _updateAction(String filePath, FileAction action) {
    setState(() {
      _fileActions[filePath] = action;
    });
  }

  // İşlem Mantığı: Dosyaları Taşıma/Shred Onayına Yönlendirme
  void _processFiles() async {
    final bool allSelected = _fileActions.values.every(
      (action) => action != FileAction.none,
    );

    if (!allSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lütfen listedeki tüm dosyalar için bir aksiyon seçiniz.',
          ),
        ),
      );
      return;
    }

    // Aksiyonları gruplandır
    final List<PlatformFile> filesToShred = [];
    final List<PlatformFile> filesToBin = [];
    final List<PlatformFile> filesToSecret = [];

    for (var file in widget.selectedFiles) {
      if (file.path != null) {
        final action = _fileActions[file.path!];
        if (action == FileAction.shredder) {
          filesToShred.add(file);
        } else if (action == FileAction.bin) {
          filesToBin.add(file);
        } else if (action == FileAction.secret) {
          filesToSecret.add(file);
        }
      }
    }

    // Ekranı kapatmadan önce kullanıcıya işlem ilerlemesini göstermek için
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${filesToShred.length} Shred, ${filesToBin.length} Bin, ${filesToSecret.length} Secret işlemi başlatılıyor...',
          ),
        ),
      );
    }

    // --- 1. Gizli Alana Taşıma İşlemleri ---
    for (var file in filesToSecret) {
      if (file.path == null) continue;
      try {
        final newPath = await _secretManager.moveFileToSecret(file.path!);
        final logEntry = LogEntry(
          fileName: file.name,
          filePath: newPath, // Yeni gizli yol
          fileSize: '${(file.size / 1024).toStringAsFixed(2)} KB',
          status: 'SECRET',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        await DbHelper.instance.insertLog(logEntry);
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${file.name} gizli alana taşınamadı.'),
            ),
          );
      }
    }

    // --- 2. Bin'e Taşıma İşlemleri ---
    for (var file in filesToBin) {
      if (file.path == null) continue;
      try {
        final newPath = await _binManager.moveFileToBin(file.path!);
        final logEntry = LogEntry(
          fileName: file.name,
          filePath: newPath, // Yeni bin yolu
          fileSize: '${(file.size / 1024).toStringAsFixed(2)} KB',
          status: 'BINNED',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        await DbHelper.instance.insertLog(logEntry);
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${file.name} Bin\'e taşınamadı.')),
          );
      }
    }

    // --- 3. Shred İşlemleri (Onay Ekranına Yönlendirme) ---
    // Sadece ilk shred edilecek dosyayı onay ekranına gönderelim.
    // Gelişmiş uygulamalarda burada bir döngü kurulup tek tek onay alınabilir.
    if (filesToShred.isNotEmpty) {
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ShredConfirmationScreen(fileToShred: filesToShred.first),
          ),
        );
      }
    }

    // Ana sayfaya dön. İşlenen dosyalar listeden kaldırılır.
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dosya Aksiyonlarını Seç')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.selectedFiles.length,
              itemBuilder: (context, index) {
                final file = widget.selectedFiles[index];
                // PlatformFile'da path null olabilir, kontrol et
                if (file.path == null) {
                  return const SizedBox.shrink();
                }

                final filePath = file.path!;
                final currentAction = _fileActions[filePath] ?? FileAction.none;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(file.name),
                    subtitle: Text(
                      '${(file.size / 1024).toStringAsFixed(2)} KB',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Gizli Alan Butonu (YENİ EKLENEN)
                        IconButton(
                          icon: Icon(
                            Icons.lock_outline,
                            color: currentAction == FileAction.secret
                                ? Colors.purple
                                : Colors.grey,
                          ),
                          tooltip: 'Gizli Alana Taşı',
                          onPressed: () =>
                              _updateAction(filePath, FileAction.secret),
                        ),
                        // Shredder Butonu
                        IconButton(
                          icon: Icon(
                            Icons.delete_forever,
                            color: currentAction == FileAction.shredder
                                ? Colors.red
                                : Colors.grey,
                          ),
                          tooltip: 'Shredder (Kalıcı Silme)',
                          onPressed: () =>
                              _updateAction(filePath, FileAction.shredder),
                        ),
                        // Bin Butonu
                        IconButton(
                          icon: Icon(
                            Icons.restore_from_trash,
                            color: currentAction == FileAction.bin
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          tooltip: 'Bin (Geçici Saklama)',
                          onPressed: () =>
                              _updateAction(filePath, FileAction.bin),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _processFiles,
              child: const Text('Seçilen Aksiyonları Uygula'),
            ),
          ),
        ],
      ),
    );
  }
}
