import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  // Clave de 32 caracteres requerida para AES-256. 
  // (Nota: En una app de producción, esta llave se genera dinámicamente 
  // y se guarda en el Keystore/Keychain nativo del dispositivo).
  static final _key = encrypt.Key.fromUtf8('MiSuperClaveSecretaDe32Caracters'); 
  static final _iv = encrypt.IV.fromLength(16); // Vector de inicialización
  
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  // Función para cifrar texto antes de mandarlo a SQLite
  static String encryptText(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  // Función para descifrar texto al leerlo de SQLite
  static String decryptText(String encryptedText) {
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      // Por si hay notas viejas en la BD que no estaban cifradas
      return encryptedText; 
    }
  }
}