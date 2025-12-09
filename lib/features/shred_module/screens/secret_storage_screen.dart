// lib/features/shred_module/screens/secret_storage_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shredrek/features/shred_module/services/secret_manager.dart';
import 'package:shredrek/features/shred_module/screens/shred_confirmation_screen.dart';
import 'package:file_picker/file_picker.dart'; // Dosyayı shred ekranına göndermek için gerekli

class SecretStorageScreen extends StatefulWidget {
  const SecretStorageScreen({super.key});

  @override
  State<SecretStorageScreen> createState() => _SecretStorageScreenState();
}

class _SecretStorageScreenState extends State<SecretStorageScreen> {
  Future<List<FileSystemEntity>>? _secretFilesFuture;
  final SecretManager _secretManager = SecretManager();

  @override
  void initState() {
    super.initState();
    _fetchSecretFiles();
  }

  void _fetchSecretFiles() {
    setState(() {
      _secretFilesFuture = _secretManager.getSecretFiles();
    });
  }

  // Dosyayı Gizli Alandan geri alma (Normal bir konuma taşır)
  void _restoreFile(String filePath, String fileName) async {
    // Kullanıcıya dosyayı nereye kaydetmek istediğini sorabiliriz (ya da varsayılan indirme klasörüne atarız)

    // Basitlik için dosya seçiciyi kullanarak hedef klasörü seçtirelim
    String? outputDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Dosyayı kaydetmek istediğiniz konumu seçin',
    );

    if (outputDir != null) {
      final destinationPath = p.join(outputDir, fileName);
      try {
        await _secretManager.restoreFileFromSecret(filePath, destinationPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$fileName, $outputDir konumuna geri yüklendi.'),
            ),
          );
          _fetchSecretFiles(); // Listeyi yenile
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dosya geri yüklenirken hata oluştu.'),
            ),
          );
        }
      }
    }
  }

  // Gizli alandaki dosyayı shred etme
  void _shredSecretFile(String filePath, String fileName, int fileSize) {
    // PlatformFile oluşturup shred onay ekranına gönder
    final fileToShred = PlatformFile(
      name: fileName,
      path: filePath,
      size: fileSize,
    );

    // Shred Onay Ekranına yönlendirme
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                ShredConfirmationScreen(fileToShred: fileToShred),
          ),
        )
        .then((_) => _fetchSecretFiles()); // İşlem bitince listeyi yenile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔐 Gizli Depolama Alanı')),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _secretFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Gizli alanda hiçbir dosya bulunmamaktadır.'),
            );
          }

          final files = snapshot.data!;

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final filePath = file.path;
              final fileName = p.basename(filePath);
              final fileSize = File(filePath).lengthSync();

              return ListTile(
                leading: const Icon(Icons.folder_shared, color: Colors.purple),
                title: Text(fileName),
                subtitle: Text('${(fileSize / 1024).toStringAsFixed(2)} KB'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Geri Yükle
                    IconButton(
                      icon: const Icon(Icons.undo, color: Colors.green),
                      tooltip: 'Geri Yükle',
                      onPressed: () => _restoreFile(filePath, fileName),
                    ),
                    // Shred Et
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      tooltip: 'Kalıcı Sil',
                      onPressed: () =>
                          _shredSecretFile(filePath, fileName, fileSize),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
