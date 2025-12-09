// lib/models/log_entry.dart

class LogEntry {
  final int? id; // Veritabanı otomatik artan ID
  final String fileName;
  final String filePath; // Dosyanın tam yolu
  final String fileSize;
  final String status; // 'SHREDDED', 'BINNED', 'SECRET'
  final String? shredMethod; // '1-pass' veya '3-pass' (Sadece SHREDDED için)
  final int? passCount; // Kaç geçiş uygulandığı
  final int timestamp; // Kaydın oluşturulma zamanı (Unix zamanı)

  LogEntry({
    this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.status,
    this.shredMethod,
    this.passCount,
    required this.timestamp,
  });

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'] as int,
      fileName: map['fileName'] as String,
      filePath: map['filePath'] as String,
      fileSize: map['fileSize'] as String,
      status: map['status'] as String,
      shredMethod: map['shredMethod'] as String?,
      passCount: map['passCount'] as int?,
      timestamp: map['timestamp'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'status': status,
      'shredMethod': shredMethod,
      'passCount': passCount,
      'timestamp': timestamp,
    };
  }
}
