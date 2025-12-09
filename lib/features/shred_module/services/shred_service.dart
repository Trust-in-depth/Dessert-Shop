// lib/features/shred_module/services/shred_service.dart

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

class ShredService {
  // Rastgele bayt üreteci
  final Random _random = Random.secure();

  /// Dosyanın üzerine rastgele veri yazma işlemini simüle eder (overwrite).
  Future<void> _overwriteFile(File file, int passes) async {
    if (!await file.exists()) return;

    final int fileSize = await file.length();

    // Her geçişte rastgele baytlar ile dosyanın üzerine yazar.
    for (int i = 0; i < passes; i++) {
      // Dosyanın tamamını dolduracak rastgele baytları oluşturur.
      // Not: Performans nedeniyle gerçek bir mobil uygulamada baytlar parça parça yazılır.
      // Eğitim amaçlı olarak burada bir döngü simülasyonu yapıyoruz.

      // Bir miktar rastgele veri oluşturup dosyaya yazma işlemini simüle et:
      final sink = file.openSync(mode: FileMode.write);
      // Örneğin, 1MB (1024*1024) boyutunda rastgele veri yazma
      final data = Uint8List(1024 * 1024);
      for (int k = 0; k < data.length; k++) {
        data[k] = _random.nextInt(256); // 0-255 arasında rastgele bir tamsayı (bayt) doldur
      }
      sink.writeFromSync(data);
      // Gerçekte burada dosyanın tamamına yazma döngüsü olmalıdır.
      sink.closeSync();

      // print('Dosya ${file.path} üzerine ${i + 1}. geçiş tamamlandı.');
    }
  }

  /// Güvenli silme (shred) işlemini başlatır ve tamamlar.
  /// İşlem tamamlandığında dosyayı normal olarak siler.
  Future<void> shredFile(String filePath, {int passCount = 1}) async {
    final File file = File(filePath);

    if (!await file.exists()) {
      throw Exception("Dosya bulunamadı: $filePath");
    }

    // 1. Üzerine Yazma (Overwrite) İşlemi
    await _overwriteFile(file, passCount);

    // 2. Normal Silme İşlemi
    try {
      await file.delete(recursive: true);
    } catch (e) {
      throw Exception("Dosya silinirken hata oluştu: $e");
    }
  }
}
