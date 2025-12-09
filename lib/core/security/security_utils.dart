// lib/core/security/security_utils.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  // Hashleme için kullanılacak bir SALT (tuz) tanımlayın.
  // Gerçek uygulamalarda bu rastgele ve güvenli bir yerde saklanmalıdır.
  // Şimdilik sabit bir değer kullanabiliriz:
  static const String _salt = "ShredrekAppSecretSalt1946";

  /// Verilen PIN'i SHA-256 algoritması kullanarak hash'ler.
  /// Hashleme, PIN'in veritabanında güvenli saklanmasını sağlar.
  static String hashPin(String pin) {
    // PIN ve tuzu (salt) birleştirir
    final String saltedPin = pin + _salt;

    // UTF-8 olarak kodlar ve SHA256 ile hash'ler
    final List<int> bytes = utf8.encode(saltedPin);
    final Digest digest = sha256.convert(bytes);

    // Hash değerini onaltılık (hex) dize olarak döndürür
    return digest.toString();
  }

  /// Kullanıcının girdiği PIN'in, veritabanında saklanan hash ile eşleşip eşleşmediğini kontrol eder.
  static bool verifyPin(String enteredPin, String storedHash) {
    // Girilen PIN'i aynı yöntemle hash'le
    final String enteredPinHash = hashPin(enteredPin);

    // Yeni hash ile depolanan hash'i karşılaştır
    return enteredPinHash == storedHash;
  }
}
