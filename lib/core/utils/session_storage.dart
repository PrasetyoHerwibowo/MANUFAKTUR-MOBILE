import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Mengelola penyimpanan sesi login lokal yang persisten.
/// Sesi tetap tersimpan saat aplikasi ditutup atau dimatikan.
/// Sesi hanya terhapus ketika:
/// 1. Pengguna menekan Logout di Profil
/// 2. Pengguna melakukan "Hapus Cache / Hapus Data" di Pengaturan Aplikasi Android/iOS
class SessionStorage {
  static const String _sessionFileName = 'mdi_auth_session.json';

  /// Mendapatkan file penyimpanan sesi persisten
  static Future<File?> _getSessionFile() async {
    try {
      if (kIsWeb) return null;
      Directory dir;
      try {
        dir = await getApplicationDocumentsDirectory();
      } catch (_) {
        dir = await getTemporaryDirectory();
      }
      return File('${dir.path}/$_sessionFileName');
    } catch (e) {
      debugPrint('SessionStorage getSessionFile error: $e');
      return null;
    }
  }

  /// Simpan sesi pengguna saat berhasil login / registrasi / aktivasi / OAuth
  static Future<void> saveSession({
    required String token,
    required String email,
    required String name,
    required String company,
    required String phone,
    required String authProvider,
  }) async {
    try {
      final file = await _getSessionFile();
      if (file == null) return;

      final sessionData = {
        'token': token,
        'email': email,
        'name': name,
        'company': company,
        'phone': phone,
        'auth_provider': authProvider,
        'saved_at': DateTime.now().toIso8601String(),
      };

      await file.writeAsString(jsonEncode(sessionData), flush: true);
      debugPrint('SessionStorage: Sesi berhasil disimpan secara persisten di ${file.path}');
    } catch (e) {
      debugPrint('SessionStorage saveSession error: $e');
    }
  }

  /// Membaca sesi pengguna yang tersimpan saat aplikasi pertama kali dibuka
  static Future<Map<String, dynamic>?> loadSession() async {
    try {
      final file = await _getSessionFile();
      if (file == null || !await file.exists()) {
        debugPrint('SessionStorage: Tidak ada sesi tersimpan (perlu login).');
        return null;
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) return null;

      final data = jsonDecode(content);
      if (data is Map<String, dynamic> && data['token'] != null && data['token'].toString().isNotEmpty) {
        debugPrint('SessionStorage: Sesi persisten ditemukan untuk ${data['email']}');
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('SessionStorage loadSession error: $e');
      return null;
    }
  }

  /// Menghapus sesi persisten (saat pengguna Logout atau Clear Cache)
  static Future<void> clearSession() async {
    try {
      final file = await _getSessionFile();
      if (file != null && await file.exists()) {
        await file.delete();
        debugPrint('SessionStorage: Sesi persisten berhasil dihapus.');
      }
    } catch (e) {
      debugPrint('SessionStorage clearSession error: $e');
    }
  }
}

