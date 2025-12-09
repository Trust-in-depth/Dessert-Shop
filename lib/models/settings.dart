// lib/models/settings.dart

class Settings {
  // Veritabanında tek bir ayar kaydı olacağı için ID'ye ihtiyacımız yok,
  // ancak PIN hash'i ve varsayılan shred yöntemi gibi alanlar kritik.
  final int id; // Genellikle 1 olur
  final String pinHash;
  final String defaultShredMethod; // '1-pass' veya '3-pass'
  final int requireConfirmation; // 1: ON, 0: OFF (Silmeden önce iki kez onay iste)

  Settings({
    required this.id,
    required this.pinHash,
    required this.defaultShredMethod,
    required this.requireConfirmation,
  });

  // Veritabanından gelen Map'i (anahtar-değer çifti) Settings nesnesine dönüştürür.
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'] as int,
      pinHash: map['pinHash'] as String,
      defaultShredMethod: map['defaultShredMethod'] as String,
      requireConfirmation: map['requireConfirmation'] as int,
    );
  }

  // Settings nesnesini veritabanına kaydetmek için Map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pinHash': pinHash,
      'defaultShredMethod': defaultShredMethod,
      'requireConfirmation': requireConfirmation,
    };
  }
}