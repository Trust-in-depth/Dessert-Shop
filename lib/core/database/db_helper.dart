// lib/core/database/db_helper.dart

import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shredrek/models/log_entry.dart'; // LogEntry Modelini import ettik
import 'package:shredrek/models/settings.dart'; // Settings Modelini import ettik

class DbHelper {
  // Singleton pattern (Tekil Nesne)
  static final DbHelper instance = DbHelper._privateConstructor();
  static Database? _database;

  DbHelper._privateConstructor();

  // Veritabanı nesnesini döndürür, yoksa oluşturur.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Veritabanını başlatma ve tablo oluşturma fonksiyonu
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "shredrek.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Tabloları oluşturma
  Future _onCreate(Database db, int version) async {
    // 1. AYARLAR TABLOSU (settings) - PIN ve varsayılan yöntem için
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY,
        pinHash TEXT NOT NULL,
        defaultShredMethod TEXT NOT NULL,
        requireConfirmation INTEGER NOT NULL
      )
    ''');

    // 2. LOGLAR TABLOSU (shred_logs) - Geçmiş kayıtları için
    await db.execute('''
      CREATE TABLE shred_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileSize TEXT,
        shredMethod TEXT, 
        passCount INTEGER,
        status TEXT NOT NULL, -- 'SHREDDED', 'BINNED', 'SECRET' gibi durumları tutar
        timestamp INTEGER NOT NULL
      )
    ''');

    // Veritabanı ilk kez oluşturulurken varsayılan ayarları kaydet
    await db.insert('settings', {
      'id': 1,
      'pinHash': '', // Başlangıçta PIN yok
      'defaultShredMethod': '1-pass',
      'requireConfirmation': 1,
    });
  }

  /* ---------------------- AYARLAR İŞLEMLERİ ---------------------- */

  // Ayarları veritabanından çeker (tek kayıt olduğu için id=1 kullanılır)
  Future<Settings?> getSettings() async {
    Database db = await instance.database;
    var res = await db.query("settings", where: "id = ?", whereArgs: [1]);

    // Eğer kayıt varsa, Settings modeline dönüştürüp döndür.
    return res.isNotEmpty ? Settings.fromMap(res.first) : null;
  }

  // Ayarları günceller (PIN değiştirme, varsayılan yöntem değiştirme vb. için)
  Future<int> updateSettings(Settings settings) async {
    Database db = await instance.database;
    return await db.update(
      "settings",
      settings.toMap(),
      where: "id = ?",
      whereArgs: [1],
    );
  }

  // Sadece PIN'i güncellemek için yardımcı fonksiyon
  Future<int> updatePin(String newPinHash) async {
    Database db = await instance.database;
    return await db.update(
      "settings",
      {'pinHash': newPinHash},
      where: "id = ?",
      whereArgs: [1],
    );
  }

  Future<int> insertLog(LogEntry logEntry) async {
    Database db = await instance.database;
    return await db.insert('shred_logs', logEntry.toMap());
  }

  // Tüm logları çeker (Filtreleme olmadan)
  Future<List<LogEntry>> getLogs() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shred_logs',
      orderBy: 'timestamp DESC', // En yeniyi üste koy
    );
    return List.generate(maps.length, (i) {
      return LogEntry.fromMap(maps[i]);
    });
  }

  // Logları filtreleyerek çeker
  Future<List<LogEntry>> getFilteredLogs({
    String? status, // 'SHREDDED', 'BINNED', 'SECRET'
    String? extension, // ".pdf", ".jpg"
    int? startDate,
    int? endDate,
  }) async {
    Database db = await instance.database;
    
    // WHERE cümlesini oluşturmak için parametreler
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (status != null && status.isNotEmpty) {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }
    
    // Uzantıya göre filtreleme (filePath alanında LIKE operatörü ile yapılabilir)
    if (extension != null && extension.isNotEmpty) {
      whereClauses.add('fileName LIKE ?');
      whereArgs.add('%$extension'); // Dosya adının sonunda uzantı var mı?
    }

    // Zamana göre filtreleme
    if (startDate != null) {
      whereClauses.add('timestamp >= ?');
      whereArgs.add(startDate);
    }
    if (endDate != null) {
      whereClauses.add('timestamp <= ?');
      whereArgs.add(endDate);
    }
    
    final whereString = whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'shred_logs',
      where: whereString,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) {
      return LogEntry.fromMap(maps[i]);
    });
  }

  // Tek bir log kaydını silme (History Management) [cite: 43]
  Future<int> deleteLog(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'shred_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tüm logları temizleme (History Management) [cite: 44]
  Future<int> clearAllLogs() async {
    Database db = await instance.database;
    return await db.delete('shred_logs');
  }
}


