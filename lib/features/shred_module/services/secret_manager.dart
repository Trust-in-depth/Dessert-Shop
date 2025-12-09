// lib/features/shred_module/services/secret_manager.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SecretManager {
  // Uygulamaya özel 'Secret' dizininin yolunu döndürür.
  Future<String> getSecretDirectoryPath() async {
    // Uygulamanın dahili depolama alanına erişir
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String secretPath = p.join(appDocDir.path, 'ShredrekSecret');

    // Dizin mevcut değilse oluşturur
    final Directory secretDir = Directory(secretPath);
    if (!await secretDir.exists()) {
      await secretDir.create(recursive: true);
    }
    return secretPath;
  }

  /// Dosyayı orijinal konumundan Gizli alana taşır ve yeni yolu döndürür.
  Future<String> moveFileToSecret(String originalFilePath) async {
    final secretPath = await getSecretDirectoryPath();
    final File originalFile = File(originalFilePath);

    final String fileName = p.basename(originalFilePath);
    final String destinationPath = p.join(secretPath, fileName);

    try {
      // Dosyayı taşıma işlemi
      final File newFile = await originalFile.rename(destinationPath);
      return newFile.path;
    } catch (e) {
      throw Exception("Dosya Gizli Alan'a taşınırken hata oluştu: $e");
    }
  }

  /// Gizli alandan dosyaları normal bir konuma geri taşır.
  Future<void> restoreFileFromSecret(
    String secretFilePath,
    String destinationPath,
  ) async {
    final File secretFile = File(secretFilePath);

    try {
      // Dosyayı taşıma işlemi
      await secretFile.rename(destinationPath);
    } catch (e) {
      throw Exception("Dosya geri taşınırken hata oluştu: $e");
    }
  }

  /// Gizli alandaki tüm dosyaların listesini döndürür.
  Future<List<FileSystemEntity>> getSecretFiles() async {
    final secretPath = await getSecretDirectoryPath();
    final Directory secretDir = Directory(secretPath);

    if (!await secretDir.exists()) {
      return [];
    }
    return secretDir.listSync();
  }
}
