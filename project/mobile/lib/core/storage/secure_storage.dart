import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ytu_assistant/core/constants/app_constants.dart';

/// Thin wrapper around [FlutterSecureStorage] for JWT + cached user data.
///
/// Every operation is defensive: `flutter_secure_storage` can throw on some
/// platforms (notably web, where the backing store may be unavailable or the
/// browser blocks it). A failure must never crash the app or blank the screen —
/// reads degrade to `null` (treated as "signed out") and writes are best-effort.
class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              webOptions: WebOptions(
                dbName: 'ytu_assistant',
                publicKey: 'ytu_assistant_secure',
              ),
            );

  final FlutterSecureStorage _storage;

  // ---- Token ----
  Future<void> saveToken(String token) =>
      _write(AppConstants.tokenKey, token);

  Future<String?> readToken() => _read(AppConstants.tokenKey);

  Future<void> deleteToken() => _delete(AppConstants.tokenKey);

  Future<bool> hasToken() async {
    final String? token = await readToken();
    return token != null && token.isNotEmpty;
  }

  // ---- Cached user ----
  Future<void> saveUser(Map<String, dynamic> userJson) =>
      _write(AppConstants.userKey, jsonEncode(userJson));

  Future<Map<String, dynamic>?> readUser() async {
    final String? raw = await _read(AppConstants.userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  // ---- Bulk ----
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (_) {
      // Best-effort wipe.
    }
  }

  // ---- Guarded primitives ----
  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Best-effort persistence.
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Best-effort delete.
    }
  }
}

/// Riverpod provider for the app-wide [SecureStorage] instance.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
