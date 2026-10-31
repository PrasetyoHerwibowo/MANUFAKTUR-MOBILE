import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  // Candidate URLs in priority order
  static final List<String> candidateBaseUrls = [
    'http://127.0.0.1:8000/api',       // Fast via ADB reverse on physical Android or Windows/Web
    'http://192.168.1.4:8000/api',     // Direct via Local Wi-Fi network (Physical Android)
    'http://10.0.2.2:8000/api',        // Android Emulator
    'http://localhost/MANUFAKTUR/public/api',
  ];

  static String baseUrl = 'http://127.0.0.1:8000/api';
  static String? authToken;
  static bool _baseUrlVerified = false;

  static void setBaseUrl(String url) {
    baseUrl = url;
    _baseUrlVerified = true;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  /// Helper untuk mengirim POST request dengan auto-fallback jika koneksi pertama gagal
  static Future<http.Response> _postRequest(
    String endpoint,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final payload = jsonEncode(body);
    List<String> urlsToTry = [baseUrl];
    if (!_baseUrlVerified) {
      for (final u in candidateBaseUrls) {
        if (!urlsToTry.contains(u)) urlsToTry.add(u);
      }
    }

    Exception? lastException;
    for (final base in urlsToTry) {
      try {
        final uri = Uri.parse('$base$endpoint');
        final res = await http.post(uri, headers: _headers, body: payload).timeout(timeout);
        baseUrl = base;
        _baseUrlVerified = true;
        return res;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint('ApiService POST connection failed on $base$endpoint: $e');
      }
    }
    throw lastException ?? Exception('Semua jalur koneksi backend gagal dihubungi.');
  }

  /// Helper untuk mengirim GET request dengan auto-fallback jika koneksi pertama gagal
  static Future<http.Response> _getRequest(
    String endpoint, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    List<String> urlsToTry = [baseUrl];
    if (!_baseUrlVerified) {
      for (final u in candidateBaseUrls) {
        if (!urlsToTry.contains(u)) urlsToTry.add(u);
      }
    }

    Exception? lastException;
    for (final base in urlsToTry) {
      try {
        final uri = Uri.parse('$base$endpoint');
        final res = await http.get(uri, headers: _headers).timeout(timeout);
        baseUrl = base;
        _baseUrlVerified = true;
        return res;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint('ApiService GET connection failed on $base$endpoint: $e');
      }
    }
    throw lastException ?? Exception('Semua jalur koneksi backend gagal dihubungi.');
  }

  // ==========================================
  // 1. AUTENTIKASI, AKTIVASI & SANCTUM
  // ==========================================

  /// Login Akun (Terproteksi cek aktivasi akun & hash password)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _postRequest(
        '/login',
        {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        authToken = data['token'];
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'message': data['message'] ?? 'Login berhasil',
        };
      } else if (response.statusCode == 403 && data['needs_activation'] == true) {
        return {
          'success': false,
          'needs_activation': true,
          'email': data['email'] ?? email,
          'message': data['message'] ?? 'Akun Anda belum diaktivasi. Silakan masukkan kode verifikasi 10 digit.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Email atau kata sandi tidak valid.',
        };
      }
    } catch (e) {
      debugPrint('ApiService login exception: $e');
      return {
        'success': false,
        'message': 'Gagal terhubung ke server backend: $e',
      };
    }
  }

  /// Registrasi Akun Baru (Memicu pengiriman 10 digit kode acak ke email aktif)
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? company,
    String? phone,
  }) async {
    try {
      final response = await _postRequest(
        '/register',
        {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'company': company,
          'phone': phone,
        },
        timeout: const Duration(seconds: 30),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || (response.statusCode == 200 && data['success'] == true)) {
        return {
          'success': true,
          'needs_activation': true,
          'email': data['email'] ?? email,
          'message': data['message'] ?? 'Pendaftaran berhasil. Silakan periksa email Anda.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Pendaftaran gagal. Periksa kembali kelengkapan data.',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      debugPrint('ApiService register exception: $e');
      return {
        'success': false,
        'message': 'Koneksi ke server gagal: $e',
      };
    }
  }

  /// Verifikasi Aktivasi Akun dengan 10 Digit Kode Acak dari Email
  static Future<Map<String, dynamic>> verifyActivation({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _postRequest(
        '/auth/verify-activation',
        {
          'email': email.trim(),
          'code': code.trim().toUpperCase(),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        authToken = data['token'];
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'message': data['message'] ?? 'Akun berhasil diaktivasi!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Kode verifikasi tidak cocok atau kadaluwarsa.',
        };
      }
    } catch (e) {
      debugPrint('ApiService verifyActivation exception: $e');
      return {
        'success': false,
        'message': 'Gagal melakukan verifikasi: $e',
      };
    }
  }

  /// Kirim Ulang 10 Digit Kode Aktivasi ke Email
  static Future<Map<String, dynamic>> resendActivationCode(String email) async {
    try {
      final response = await _postRequest(
        '/auth/resend-code',
        {'email': email.trim()},
        timeout: const Duration(seconds: 25),
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] == true,
        'message': data['message'] ?? 'Kode baru telah dikirimkan ke email Anda.',
      };
    } catch (e) {
      debugPrint('ApiService resendActivationCode exception: $e');
      return {
        'success': false,
        'message': 'Gagal mengirim ulang kode: $e',
      };
    }
  }

  /// Permintaan Reset Password (Kirim 10 digit kode acak ke email)
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _postRequest(
        '/auth/forgot-password',
        {'email': email.trim()},
        timeout: const Duration(seconds: 25),
      );

      final data = jsonDecode(response.body);
      return {
        'success': (response.statusCode == 200 || response.statusCode == 201) && data['success'] == true,
        'message': data['message'] ?? 'Kode pemulihan telah dikirimkan ke email Anda.',
      };
    } catch (e) {
      debugPrint('ApiService forgotPassword exception: $e');
      return {
        'success': false,
        'message': 'Gagal memproses permintaan reset password: $e',
      };
    }
  }

  /// Verifikasi 10 Digit Kode Reset Password dari Email
  static Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _postRequest(
        '/auth/verify-reset-code',
        {
          'email': email.trim(),
          'code': code.trim().toUpperCase(),
        },
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Kode verifikasi valid.',
      };
    } catch (e) {
      debugPrint('ApiService verifyResetCode exception: $e');
      return {
        'success': false,
        'message': 'Gagal memverifikasi kode: $e',
      };
    }
  }

  /// Reset Password Baru dengan 10 Digit Kode
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _postRequest(
        '/auth/reset-password',
        {
          'email': email.trim(),
          'code': code.trim().toUpperCase(),
          'password': newPassword,
          'password_confirmation': passwordConfirmation,
        },
        timeout: const Duration(seconds: 25),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Kata sandi berhasil diperbarui.',
      };
    } catch (e) {
      debugPrint('ApiService resetPassword exception: $e');
      return {
        'success': false,
        'message': 'Gagal memperbarui kata sandi: $e',
      };
    }
  }

  /// Autentikasi Google OAuth (Registrasi / Login Langsung)
  static Future<Map<String, dynamic>> googleAuth({
    required String email,
    required String name,
    String? googleId,
    String? avatar,
    String? phone,
    String? company,
  }) async {
    try {
      final response = await _postRequest(
        '/auth/google',
        {
          'email': email.trim(),
          'name': name.trim(),
          'google_id': googleId,
          'avatar': avatar,
          'phone': phone,
          'company': company,
        },
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        authToken = data['token'];
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'message': data['message'] ?? 'Autentikasi Google berhasil!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal masuk menggunakan akun Google.',
        };
      }
    } catch (e) {
      debugPrint('ApiService googleAuth exception: $e');
      return {
        'success': false,
        'message': 'Gagal menghubungkan akun Google: $e',
      };
    }
  }

  /// Logout Akun
  static Future<void> logout() async {
    try {
      if (authToken != null) {
        await _postRequest('/logout', {}, timeout: const Duration(seconds: 5));
      }
    } catch (e) {
      debugPrint('ApiService logout fallback: $e');
    } finally {
      authToken = null;
    }
  }

  /// Cek data pengguna yang sedang aktif
  static Future<Map<String, dynamic>?> getMe() async {
    try {
      if (authToken == null) return null;
      final response = await _getRequest('/me', timeout: const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService getMe exception: $e');
    }
    return null;
  }

  // ==========================================
  // 2. KATALOG PRODUK MESIN (PUBLIC)
  // ==========================================

  /// Mengambil daftar mesin yang tersedia dari backend Laravel
  static Future<List<ProductModel>?> fetchMachines() async {
    try {
      final response = await _getRequest('/machines', timeout: const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          final List rawList = body['data'];
          return rawList.map((item) => ProductModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService fetchMachines fallback to mock: $e');
    }
    return null;
  }

  // ==========================================
  // 3. PURCHASE ORDERS & SERVIS (PROTECTED)
  // ==========================================

  static Future<Map<String, dynamic>?> createOrder({
    required int machineId,
    required int quantity,
    required String deliveryAddress,
    String? customNotes,
    String? bankMethod,
    String? dpProof,
  }) async {
    try {
      final response = await _postRequest(
        '/orders',
        {
          'machine_id': machineId,
          'quantity': quantity,
          'delivery_address': deliveryAddress,
          'custom_notes': customNotes,
          'bank_method': bankMethod,
          'dp_proof': dpProof,
        },
        timeout: const Duration(seconds: 15),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService createOrder error: $e');
    }
    return null;
  }

  static Future<bool> uploadDpProof(String orderId, String proof) async {
    try {
      final response = await _postRequest(
        '/orders/$orderId/pay-dp',
        {'proof': proof},
        timeout: const Duration(seconds: 15),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService uploadDpProof error: $e');
      return false;
    }
  }

  static Future<bool> uploadPelunasanProof(String orderId, String proof) async {
    try {
      final response = await _postRequest(
        '/orders/$orderId/pay-pelunasan',
        {'proof': proof},
        timeout: const Duration(seconds: 15),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService uploadPelunasanProof error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchInvoiceData(String orderId) async {
    try {
      final response = await _getRequest('/orders/$orderId/invoice', timeout: const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'];
      }
    } catch (e) {
      debugPrint('ApiService fetchInvoiceData error: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> fetchPaymentLogs() async {
    try {
      final response = await _getRequest('/payments', timeout: const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'];
      }
    } catch (e) {
      debugPrint('ApiService fetchPaymentLogs error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> bookingService({
    required String serialNumber,
    required String machineModel,
    required String serviceType,
    required String scheduledDate,
    required String scheduledTime,
    required String address,
    required String issueDescription,
  }) async {
    try {
      final response = await _postRequest(
        '/services/bookings',
        {
          'serial_number': serialNumber,
          'machine_model': machineModel,
          'service_type': serviceType,
          'scheduled_date': scheduledDate,
          'scheduled_time': scheduledTime,
          'address': address,
          'issue_description': issueDescription,
        },
        timeout: const Duration(seconds: 15),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService bookingService error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> submitWarrantyClaim({
    required String serialNumber,
    required String purchaseDate,
    required String damageDescription,
    required String photo,
  }) async {
    try {
      final response = await _postRequest(
        '/services/warranty-claims',
        {
          'serial_number': serialNumber,
          'purchase_date': purchaseDate,
          'damage_description': damageDescription,
          'photo': photo,
        },
        timeout: const Duration(seconds: 15),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService submitWarrantyClaim error: $e');
    }
    return null;
  }
}
