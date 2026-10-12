import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL config: 10.0.2.2 for Android Emulator, localhost for Web/Windows, or local IP
  static String baseUrl = kIsWeb
      ? 'http://localhost/MANUFAKTUR/public/api'
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2/MANUFAKTUR/public/api'
          : 'http://localhost/MANUFAKTUR/public/api');

  static String? authToken;

  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // 1. Authentication
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        authToken = data['token'];
        return data;
      }
    } catch (e) {
      debugPrint('ApiService login fallback: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
    String? company,
    String? phone,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'company': company,
              'phone': phone,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        authToken = data['token'];
        return data;
      }
    } catch (e) {
      debugPrint('ApiService register fallback: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> ssoAuth({
    required String provider,
    required String email,
    required String name,
    String? company,
    String? phone,
    String? avatar,
    String? providerId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/sso'),
            headers: _headers,
            body: jsonEncode({
              'provider': provider,
              'email': email,
              'name': name,
              'company': company,
              'phone': phone,
              'avatar': avatar,
              'provider_id': providerId,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        authToken = data['token'];
        return data;
      }
    } catch (e) {
      debugPrint('ApiService ssoAuth fallback: $e');
    }
    return null;
  }

  // 2. Mesin & Kategori
  static Future<List<dynamic>?> fetchMachines() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/machines'), headers: _headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'];
        }
      }
    } catch (e) {
      debugPrint('ApiService fetchMachines fallback: $e');
    }
    return null;
  }

  // 3. Purchase Orders & DP 50%
  static Future<Map<String, dynamic>?> createOrder({
    required int machineId,
    required int quantity,
    required String deliveryAddress,
    String? customNotes,
    String? bankMethod,
    String? dpProof,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders'),
            headers: _headers,
            body: jsonEncode({
              'machine_id': machineId,
              'quantity': quantity,
              'delivery_address': deliveryAddress,
              'custom_notes': customNotes,
              'bank_method': bankMethod,
              'dp_proof': dpProof,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService createOrder fallback: $e');
    }
    return null;
  }

  static Future<bool> uploadDpProof(String orderId, String proof) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/$orderId/pay-dp'),
            headers: _headers,
            body: jsonEncode({'proof': proof}),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService uploadDpProof fallback: $e');
      return false;
    }
  }

  static Future<bool> uploadPelunasanProof(String orderId, String proof) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/$orderId/pay-pelunasan'),
            headers: _headers,
            body: jsonEncode({'proof': proof}),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService uploadPelunasanProof fallback: $e');
      return false;
    }
  }

  // 4. Invoice & Payment Logs
  static Future<Map<String, dynamic>?> fetchInvoiceData(String orderId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/orders/$orderId/invoice'), headers: _headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'];
      }
    } catch (e) {
      debugPrint('ApiService fetchInvoiceData fallback: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> fetchPaymentLogs() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/payments'), headers: _headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'];
      }
    } catch (e) {
      debugPrint('ApiService fetchPaymentLogs fallback: $e');
    }
    return null;
  }

  // 5. Layanan Purna Jual & Servis
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
      final response = await http
          .post(
            Uri.parse('$baseUrl/services/bookings'),
            headers: _headers,
            body: jsonEncode({
              'serial_number': serialNumber,
              'machine_model': machineModel,
              'service_type': serviceType,
              'scheduled_date': scheduledDate,
              'scheduled_time': scheduledTime,
              'address': address,
              'issue_description': issueDescription,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService bookingService fallback: $e');
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
      final response = await http
          .post(
            Uri.parse('$baseUrl/services/warranty-claims'),
            headers: _headers,
            body: jsonEncode({
              'serial_number': serialNumber,
              'purchase_date': purchaseDate,
              'damage_description': damageDescription,
              'photo': photo,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService submitWarrantyClaim fallback: $e');
    }
    return null;
  }
}
