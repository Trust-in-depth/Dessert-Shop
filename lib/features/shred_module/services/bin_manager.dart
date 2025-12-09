// lib/features/shred_module/services/bin_manager.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BinManager {
  // Uygulamaya özel 'Bin' dizininin yolunu döndürür.
  Future<String> getBinDirectoryPath() async {
    // Uygulamanın dahili depolama alanına erişir
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String binPath = p.join(appDocDir.path, 'ShredrekBin');

    // Dizin mevcut değilse oluşturur
    final Directory binDir = Directory(binPath);
    if (!await binDir.exists()) {
      await binDir.create(recursive: true);
    }
    return binPath;
  }

  /// Dosyayı orijinal konumundan Bin dizinine taşır ve yeni yolu döndürür.
  Future<String> moveFileToBin(String originalFilePath) async {
    final binPath = await getBinDirectoryPath();
    final File originalFile = File(originalFilePath);

    // Dosyanın adını alır
    final String fileName = p.basename(originalFilePath);

    // Hedef dosya yolunu oluşturur
    final String destinationPath = p.join(binPath, fileName);

    try {
      // Dosyayı taşıma işlemi
      final File newFile = await originalFile.rename(destinationPath);
      return newFile.path;
    } catch (e) {
      throw Exception("Dosya Bin'e taşınırken hata oluştu: $e");
    }
  }
}
