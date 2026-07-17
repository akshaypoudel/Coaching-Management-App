import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: "token", value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: "token");
  }

  static Future<void> logout() async {
    await _storage.delete(key: "token");
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
