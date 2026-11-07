import 'dart:async';
import 'package:flutter/material.dart';
import '../core/models/product_model.dart';
import '../core/models/order_model.dart';
import '../core/models/custom_order_model.dart';
import '../core/models/service_ticket_model.dart';
import '../core/models/sparepart_model.dart';
import '../core/constants/mock_data.dart';
import '../core/services/api_service.dart';
import '../core/utils/session_storage.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

class AppState extends ChangeNotifier {
  Timer? _orderPollingTimer;

  AppState() {
    _initSessionAndPolling();
    loadProductsFromBackend();
  }

  /// Inisialisasi sesi login persisten & polling status dari server
  Future<void> _initSessionAndPolling() async {
    try {
      final session = await SessionStorage.loadSession();
      if (session != null) {
        final token = session['token']?.toString();
        if (token != null && token.isNotEmpty) {
          ApiService.authToken = token;
          _isLoggedIn = true;
          _userEmail = session['email']?.toString() ?? '';
          _userName = session['name']?.toString() ?? '';
          _companyName = session['company']?.toString() ?? 'PT Kopi Nusantara Jaya';
          _userPhone = session['phone']?.toString() ?? '';
          _authProvider = session['auth_provider']?.toString() ?? 'email';
          notifyListeners();

          await loadOrdersFromBackend();
          _startOrderPolling();

          // Validasi sesi aktif di server Laravel secara background
          try {
            final me = await ApiService.getMe();
            if (me != null && me['success'] == true && me['user'] != null) {
              final u = me['user'];
              _userName = u['name'] ?? _userName;
              _companyName = u['company'] ?? _companyName;
              _userPhone = u['phone'] ?? _userPhone;
              notifyListeners();
            } else if (me != null && me['success'] == false) {
              await logout();
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('AppState _initSessionAndPolling error: $e');
    }
  }

  /// Mulai polling berkala setiap 5 detik saat pengguna login
  void _startOrderPolling() {
    _orderPollingTimer?.cancel();
    _orderPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_isLoggedIn) {
        await loadOrdersFromBackend();
      }
    });
  }

  /// Hentikan polling saat logout
  void _stopOrderPolling() {
    _orderPollingTimer?.cancel();
    _orderPollingTimer = null;
  }

  @override
  void dispose() {
    _stopOrderPolling();
    super.dispose();
  }

  // Navigation Tab State (0: Home, 1: Pesanan, 2: Servis, 3: Profil)
  int _userTabIndex = 0;
  int get userTabIndex => _userTabIndex;

  void setUserTabIndex(int index) {
    _userTabIndex = index;
    notifyListeners();
  }

  // Theme Mode (Light / Dark - matching website theme toggle)
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // ==========================================
  // AUTH STATE & SANCTUM INTEGRATION
  // Default is FALSE (harus register/login untuk Pesanan & Servis)
  // ==========================================
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String _authProvider = 'email'; // 'email', 'google'
  String get authProvider => _authProvider;
  bool get isSsoUser => _authProvider == 'google';

  String _userName = '';
  String get userName => _userName;

  String _companyName = '';
  String get companyName => _companyName;

  String _userEmail = '';
  String get userEmail => _userEmail;

  String _userPhone = '';
  String get userPhone => _userPhone;

  /// Login Akun (Memanggil Laravel Sanctum API)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiService.login(email, password);

    if (res['success'] == true) {
      _isLoggedIn = true;
      _authProvider = 'email';
      _userEmail = res['user']?['email'] ?? email;
      _userName = res['user']?['name'] ?? email.split('@').first;
      _companyName = res['user']?['company'] ?? 'PT Manufactur Dynamic Indonesia';
      _userPhone = res['user']?['phone'] ?? '';

      if (res['token'] != null) {
        SessionStorage.saveSession(
          token: res['token'].toString(),
          email: _userEmail,
          name: _userName,
          company: _companyName,
          phone: _userPhone,
          authProvider: _authProvider,
        );
      }

      _startOrderPolling();
      loadOrdersFromBackend();

      addNotification(
        'Login Berhasil',
        'Selamat datang kembali di Aplikasi Manufaktur, $_userName!',
      );
      notifyListeners();
    }
    return res;
  }

  /// Registrasi Akun Baru (Wajib email aktif -> kode 10 digit acak dikirim)
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? company,
    String? phone,
  }) async {
    return await ApiService.register(
      name: name,
      email: email,
      password: password,
      company: company,
      phone: phone,
    );
  }

  /// Verifikasi Aktivasi Akun dengan 10 digit kode acak
  Future<Map<String, dynamic>> verifyActivation({
    required String email,
    required String code,
  }) async {
    final res = await ApiService.verifyActivation(email: email, code: code);

    if (res['success'] == true) {
      _isLoggedIn = true;
      _authProvider = 'email';
      _userEmail = res['user']?['email'] ?? email;
      _userName = res['user']?['name'] ?? email.split('@').first;
      _companyName = res['user']?['company'] ?? 'PT Manufactur Dynamic Indonesia';
      _userPhone = res['user']?['phone'] ?? '';

      if (res['token'] != null) {
        SessionStorage.saveSession(
          token: res['token'].toString(),
          email: _userEmail,
          name: _userName,
          company: _companyName,
          phone: _userPhone,
          authProvider: _authProvider,
        );
      }

      _startOrderPolling();
      loadOrdersFromBackend();

      addNotification(
        'Aktivasi Berhasil',
        'Akun $_userName telah aktif dan siap melakukan pemesanan serta servis mesin.',
      );
      notifyListeners();
    }
    return res;
  }

  /// Kirim Ulang Kode Verifikasi
  Future<Map<String, dynamic>> resendActivationCode(String email) async {
    return await ApiService.resendActivationCode(email);
  }

  /// Lupa Password - Kirim 10 digit kode acak ke email
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await ApiService.forgotPassword(email);
  }

  /// Verifikasi 10 Digit Kode Reset Password
  Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    return await ApiService.verifyResetCode(email: email, code: code);
  }

  /// Ganti Password Baru dengan Kode 10 Digit
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    return await ApiService.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
      passwordConfirmation: passwordConfirmation,
    );
  }

  /// Login / Registrasi Google OAuth
  Future<Map<String, dynamic>> loginWithGoogle({
    required String email,
    required String name,
    String? googleId,
    String? avatar,
    String? phone,
    String? company,
  }) async {
    final res = await ApiService.googleAuth(
      email: email,
      name: name,
      googleId: googleId,
      avatar: avatar,
      phone: phone,
      company: company,
    );

    if (res['success'] == true) {
      _isLoggedIn = true;
      _authProvider = 'google';
      _userEmail = res['user']?['email'] ?? email;
      _userName = res['user']?['name'] ?? name;
      _companyName = res['user']?['company'] ?? 'Mitra $name';
      _userPhone = res['user']?['phone'] ?? (phone ?? '');

      if (res['token'] != null) {
        SessionStorage.saveSession(
          token: res['token'].toString(),
          email: _userEmail,
          name: _userName,
          company: _companyName,
          phone: _userPhone,
          authProvider: _authProvider,
        );
      }

      _startOrderPolling();
      loadOrdersFromBackend();

      addNotification(
        'Google Sign-In Berhasil',
        'Autentikasi akun Google terverifikasi. Selamat datang, $_userName!',
      );
      notifyListeners();
    }
    return res;
  }

  /// Logout Akun & Hapus Sesi Persisten
  Future<void> logout() async {
    _stopOrderPolling();
    await SessionStorage.clearSession();
    await ApiService.logout();
    _isLoggedIn = false;
    _authProvider = 'email';
    _userName = '';
    _userEmail = '';
    _companyName = '';
    _userPhone = '';
    _orders.clear();
    addNotification('Logout Berhasil', 'Sesi Anda telah berhasil diakhiri.');
    notifyListeners();
  }

  // ==========================================
  // PRODUCTS / KATALOG MESIN DARI BACKEND
  // ==========================================
  List<ProductModel>? _products;
  bool _isLoadingProducts = false;
  bool get isLoadingProducts => _isLoadingProducts;

  List<ProductModel> get products {
    if (_products == null || _products!.isEmpty) {
      return List<ProductModel>.from(MockData.initialProducts);
    }
    return _products!;
  }

  /// Memuat daftar mesin dari Laravel REST API
  Future<void> loadProductsFromBackend() async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      final backendMachines = await ApiService.fetchMachines();
      if (backendMachines != null && backendMachines.isNotEmpty) {
        _products = backendMachines;
      }
    } catch (e) {
      debugPrint('Fallback loading products: $e');
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  String? _searchQuery = '';
  String get searchQuery => _searchQuery ?? '';

  String? _selectedCommodity = 'Semua';
  String get selectedCommodity => _selectedCommodity ?? 'Semua';

  String? _selectedProcessStage = 'Semua';
  String get selectedProcessStage => _selectedProcessStage ?? 'Semua';

  String? _selectedMachineType = 'Semua';
  String get selectedMachineType => _selectedMachineType ?? 'Semua';

  String? _selectedCapacityScale = 'Semua';
  String get selectedCapacityScale => _selectedCapacityScale ?? 'Semua';

  String? _selectedCategory = 'Semua';
  String get selectedCategory => _selectedCategory ?? 'Semua';

  String? _selectedPowerSource = 'Semua';
  String get selectedPowerSource => _selectedPowerSource ?? 'Semua';

  String? _sortBy = 'Populer';
  String get sortBy => _sortBy ?? 'Populer';

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCommodityFilter(String commodity) {
    _selectedCommodity = commodity;
    _selectedMachineType = 'Semua';
    if (commodity == 'Kakao') {
      _selectedCapacityScale = 'Semua';
    }
    notifyListeners();
  }

  void setProcessStageFilter(String stage) {
    _selectedProcessStage = stage;
    _selectedMachineType = 'Semua';
    notifyListeners();
  }

  void setMachineTypeFilter(String type) {
    _selectedMachineType = type;
    notifyListeners();
  }

  void setCapacityScaleFilter(String scale) {
    _selectedCapacityScale = scale;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPowerSourceFilter(String power) {
    _selectedPowerSource = power;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  List<String> get availableCommodities => const ['Semua', 'Roaster Kopi', 'Mesin Kopi', 'Kakao'];
  List<String> get availableProcessStages => const ['Semua', 'Hulu', 'Hilir'];

  List<String> get availableMachineTypes {
    final curCommodity = selectedCommodity;
    final curStage = selectedProcessStage;
    final filtered = products.where((p) {
      final matchCommodity = curCommodity == 'Semua' ||
          p.commodity.toLowerCase() == curCommodity.toLowerCase();
      final matchStage = curStage == 'Semua' ||
          p.processStage.toLowerCase() == curStage.toLowerCase();
      return matchCommodity && matchStage;
    });

    final Set<String> types = {};
    for (final p in filtered) {
      if (p.machineType.isNotEmpty) {
        types.add(p.machineType);
      }
    }
    final sortedTypes = types.toList()..sort();
    return ['Semua', ...sortedTypes];
  }

  List<String> get availableCapacityScales => const [
        'Semua',
        'Mikro / Lab (< 3 kg)',
        'Komersial / UMKM (3 - 10 kg)',
        'Industri (> 10 kg)',
      ];

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedCommodity != 'Semua' ||
      selectedProcessStage != 'Semua' ||
      selectedMachineType != 'Semua' ||
      selectedCapacityScale != 'Semua' ||
      selectedCategory != 'Semua' ||
      selectedPowerSource != 'Semua' ||
      sortBy != 'Populer';

  int get activeFiltersCount {
    int count = 0;
    if (selectedCommodity != 'Semua') count++;
    if (selectedProcessStage != 'Semua') count++;
    if (selectedMachineType != 'Semua') count++;
    if (selectedCapacityScale != 'Semua') count++;
    if (selectedCategory != 'Semua') count++;
    if (selectedPowerSource != 'Semua') count++;
    if (sortBy != 'Populer') count++;
    return count;
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCommodity = 'Semua';
    _selectedProcessStage = 'Semua';
    _selectedMachineType = 'Semua';
    _selectedCapacityScale = 'Semua';
    _selectedCategory = 'Semua';
    _selectedPowerSource = 'Semua';
    _sortBy = 'Populer';
    notifyListeners();
  }

  List<ProductModel> get filteredProducts {
    final query = searchQuery.toLowerCase().trim();
    final curCommodity = selectedCommodity;
    final curStage = selectedProcessStage;
    final curMachineType = selectedMachineType;
    final curCapacityScale = selectedCapacityScale;
    final curCategory = selectedCategory;
    final curPower = selectedPowerSource;
    final curSort = sortBy;

    final list = products.where((prod) {
      final matchesSearch = query.isEmpty ||
          prod.name.toLowerCase().contains(query) ||
          prod.commodity.toLowerCase().contains(query) ||
          prod.processStage.toLowerCase().contains(query) ||
          prod.machineType.toLowerCase().contains(query) ||
          (prod.modelName != null && prod.modelName!.toLowerCase().contains(query)) ||
          prod.category.toLowerCase().contains(query) ||
          prod.specifications.tipe.toLowerCase().contains(query) ||
          prod.specifications.kapasitas.toLowerCase().contains(query) ||
          prod.specifications.sumberListrik.toLowerCase().contains(query) ||
          prod.description.toLowerCase().contains(query) ||
          prod.capacityModels.any((m) =>
              m.modelName.toLowerCase().contains(query) ||
              m.shortLabel.toLowerCase().contains(query) ||
              m.capacity.toLowerCase().contains(query));

      final matchesCommodity = curCommodity == 'Semua' ||
          (curCommodity == 'Roaster Kopi' && prod.name.toLowerCase().contains('roast')) ||
          (curCommodity == 'Mesin Kopi' && prod.commodity.toLowerCase() == 'kopi') ||
          prod.commodity.toLowerCase() == curCommodity.toLowerCase();

      final matchesStage = curStage == 'Semua' ||
          prod.processStage.toLowerCase() == curStage.toLowerCase();

      final matchesMachineType = curMachineType == 'Semua' ||
          prod.machineType.toLowerCase() == curMachineType.toLowerCase();

      final matchesCapacityScale = curCapacityScale == 'Semua' ||
          prod.capacityScale == curCapacityScale ||
          prod.capacityModels.any((m) => m.scale == curCapacityScale);

      final matchesCategory = curCategory == 'Semua' ||
          prod.category.toLowerCase() == curCategory.toLowerCase();

      final matchesPower = curPower == 'Semua' ||
          prod.specifications.sumberListrik
              .toLowerCase()
              .contains(curPower.toLowerCase());

      return matchesSearch &&
          matchesCommodity &&
          matchesStage &&
          matchesMachineType &&
          matchesCapacityScale &&
          matchesCategory &&
          matchesPower;
    }).toList();

    if (curSort == 'Harga Terendah') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (curSort == 'Harga Tertinggi') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (curSort == 'Rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  // Orders
  final List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  Future<OrderModel> createStandardPO({
    required ProductModel product,
    required int quantity,
    required String deliveryAddress,
    required String customNotes,
    required String bankAccount,
    required String proofPath,
  }) async {
    final total = product.price * quantity;
    final dp = total * 0.5;
    final pelunasan = total * 0.5;
    final newPoNumber = 'PO-2026-0${_orders.length + 90}';

    OrderModel newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      poNumber: newPoNumber,
      companyName: _companyName.isNotEmpty ? _companyName : 'PT Kopi Nusantara Jaya',
      contactPerson: _userName.isNotEmpty ? _userName : 'Perwakilan Procurement',
      productName: product.name,
      category: product.category,
      quantity: quantity,
      pricePerUnit: product.price,
      totalAmount: total,
      dpAmount: dp,
      pelunasanAmount: pelunasan,
      orderDate: '06 Okt 2026',
      estimatedCompletionDate: '24 Okt 2026',
      status: OrderStatus.verifikasiDp,
      dpProofPath: proofPath,
      deliveryAddress: deliveryAddress,
      customNotes: customNotes,
      serialNumber: 'SN-2026-MDI-8820',
    );

    // Kirim Purchase Order ke Backend Laravel & upload bukti ke Supabase Storage
    try {
      final machineIdInt = int.tryParse(product.id) ?? 1;
      final apiRes = await ApiService.createOrder(
        machineId: machineIdInt,
        quantity: quantity,
        deliveryAddress: deliveryAddress,
        customNotes: customNotes,
        bankMethod: bankAccount,
        dpProof: proofPath,
      );

      if (apiRes != null && apiRes['data'] != null) {
        final d = apiRes['data'];
        newOrder = OrderModel(
          id: d['id']?.toString() ?? newOrder.id,
          poNumber: d['po_number']?.toString() ?? newOrder.poNumber,
          companyName: d['company_name']?.toString() ?? newOrder.companyName,
          contactPerson: d['contact_person']?.toString() ?? newOrder.contactPerson,
          productName: d['product_name']?.toString() ?? product.name,
          category: d['category']?.toString() ?? product.category,
          quantity: d['quantity'] is int ? d['quantity'] : quantity,
          pricePerUnit: (d['price_per_unit'] is num ? d['price_per_unit'].toDouble() : product.price),
          totalAmount: (d['total_amount'] is num ? d['total_amount'].toDouble() : total),
          dpAmount: (d['dp_amount'] is num ? d['dp_amount'].toDouble() : dp),
          pelunasanAmount: (d['pelunasan_amount'] is num ? d['pelunasan_amount'].toDouble() : pelunasan),
          orderDate: d['order_date']?.toString() ?? '06 Okt 2026',
          estimatedCompletionDate: d['estimated_completion_date']?.toString() ?? '24 Okt 2026',
          status: OrderStatus.verifikasiDp,
          dpProofPath: d['dp_proof_path']?.toString() ?? proofPath,
          deliveryAddress: d['delivery_address']?.toString() ?? deliveryAddress,
          customNotes: d['custom_notes']?.toString() ?? customNotes,
          serialNumber: 'SN-2026-MDI-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        );
      }
    } catch (e) {
      debugPrint('createStandardPO backend sync error: $e');
    }

    _orders.insert(0, newOrder);
    addNotification(
      'Purchase Order Diterbitkan!',
      'PO ${newOrder.poNumber} berhasil dibuat. Bukti transfer DP 50% tersimpan di Supabase dan sedang diverifikasi tim finance.',
    );
    notifyListeners();
    return newOrder;
  }

  /// Sinkronisasi daftar pesanan dari backend Laravel & status Supabase
  Future<void> loadOrdersFromBackend() async {
    try {
      final orderData = await ApiService.fetchOrders();
      if (orderData != null && orderData.isNotEmpty) {
        final List<OrderModel> backendOrders = [];
        for (final item in orderData) {
          OrderStatus parsedStatus = OrderStatus.verifikasiDp;
          final prodStatus = (item['production_status'] ?? item['status'])?.toString().toLowerCase().trim();
          final paymentStatus = item['payment_status']?.toString().toLowerCase().trim();
          final pelunasanProof = item['pelunasan_proof_path']?.toString() ?? item['pelunasan_proof']?.toString();
          final dpProof = item['dp_proof_path']?.toString() ?? item['dp_proof']?.toString();
          final rejectionReason = item['rejection_reason']?.toString() ??
              item['catatan_penolakan']?.toString() ??
              item['catatan_admin']?.toString();

          switch (prodStatus) {
            case 'verifikasi_dp':
            case 'pending_dp':
            case 'menunggu_verifikasi_dp':
              if (item['is_dp_rejected'] == true) {
                parsedStatus = OrderStatus.dpDitolak;
              } else {
                parsedStatus = OrderStatus.verifikasiDp;
              }
              break;
            case 'dp_ditolak':
            case 'rejected_dp':
            case 'dp_rejected':
              parsedStatus = OrderStatus.dpDitolak;
              break;
            case 'persiapan_bahan':
            case 'material_prep':
              parsedStatus = OrderStatus.persiapanBahan;
              break;
            case 'proses_produksi':
            case 'in_production':
            case 'assembly':
              parsedStatus = OrderStatus.prosesProduksi;
              break;
            case 'quality_control':
            case 'qc':
              parsedStatus = OrderStatus.qualityControl;
              break;
            case 'menunggu_pelunasan':
            case 'pending_final_payment':
              if (item['is_pelunasan_rejected'] == true) {
                parsedStatus = OrderStatus.pelunasanDitolak;
              } else if (pelunasanProof != null && pelunasanProof.isNotEmpty) {
                parsedStatus = OrderStatus.verifikasiPelunasan;
              } else {
                parsedStatus = OrderStatus.menungguPelunasan;
              }
              break;
            case 'verifikasi_pelunasan':
            case 'menunggu_verifikasi_pelunasan':
            case 'pending_pelunasan':
              parsedStatus = OrderStatus.verifikasiPelunasan;
              break;
            case 'pelunasan_ditolak':
            case 'rejected_pelunasan':
            case 'pelunasan_rejected':
              parsedStatus = OrderStatus.pelunasanDitolak;
              break;
            case 'pengiriman_instalasi':
            case 'shipping':
            case 'delivery':
              parsedStatus = OrderStatus.pengirimanInstalasi;
              break;
            case 'after_sales_service':
            case 'completed':
            case 'selesai':
              parsedStatus = OrderStatus.afterSalesService;
              break;
            default:
              if (paymentStatus == 'dp_ditolak') {
                parsedStatus = OrderStatus.dpDitolak;
              } else if (paymentStatus == 'pelunasan_ditolak') {
                parsedStatus = OrderStatus.pelunasanDitolak;
              } else if (pelunasanProof != null &&
                  pelunasanProof.isNotEmpty &&
                  prodStatus != 'pengiriman_instalasi' &&
                  prodStatus != 'after_sales_service') {
                parsedStatus = OrderStatus.verifikasiPelunasan;
              } else {
                parsedStatus = OrderStatus.verifikasiDp;
              }
          }

          // Cek jika order sudah ada di memori lokal dan sedang menunggu verifikasi pelunasan
          final orderIdStr = item['id']?.toString() ?? '';
          final localIdx = _orders.indexWhere(
            (o) => o.id == orderIdStr || o.poNumber == item['po_number']?.toString(),
          );
          if (localIdx != -1) {
            final local = _orders[localIdx];
            if (parsedStatus == OrderStatus.menungguPelunasan &&
                item['is_pelunasan_rejected'] != true &&
                (local.status == OrderStatus.verifikasiPelunasan ||
                    (local.pelunasanProofPath != null && local.pelunasanProofPath!.isNotEmpty))) {
              parsedStatus = OrderStatus.verifikasiPelunasan;
            }
          }

          backendOrders.add(OrderModel(
            id: item['id']?.toString() ?? '',
            poNumber: item['po_number']?.toString() ?? 'PO-2026',
            companyName: item['company_name']?.toString() ?? 'PT Kopi Nusantara Jaya',
            contactPerson: item['contact_person']?.toString() ?? 'Perwakilan Procurement',
            productName: item['product_name']?.toString() ?? 'Mesin Industri',
            category: item['category']?.toString() ?? 'Commercial',
            quantity: item['quantity'] is int ? item['quantity'] : 1,
            pricePerUnit: (item['price_per_unit'] is num ? item['price_per_unit'].toDouble() : 0.0),
            totalAmount: (item['total_amount'] is num ? item['total_amount'].toDouble() : 0.0),
            dpAmount: (item['dp_amount'] is num ? item['dp_amount'].toDouble() : 0.0),
            pelunasanAmount: (item['pelunasan_amount'] is num ? item['pelunasan_amount'].toDouble() : 0.0),
            orderDate: item['order_date']?.toString() ?? '06 Okt 2026',
            estimatedCompletionDate: item['estimated_completion_date']?.toString() ?? '24 Okt 2026',
            status: parsedStatus,
            dpProofPath: dpProof ?? (localIdx != -1 ? _orders[localIdx].dpProofPath : null),
            pelunasanProofPath: pelunasanProof ?? (localIdx != -1 ? _orders[localIdx].pelunasanProofPath : null),
            rejectionReason: rejectionReason,
            deliveryAddress: item['delivery_address']?.toString() ?? '',
            customNotes: item['custom_notes']?.toString() ?? '',
            serialNumber: item['serial_number']?.toString() ?? 'SN-2026-MDI-8820',
          ));
        }

        // Deteksi perubahan status tiap pesanan untuk memicu notifikasi real-time ke mobile app!
        if (_orders.isNotEmpty) {
          for (final newOrder in backendOrders) {
            OrderModel? oldOrder;
            for (final o in _orders) {
              if (o.poNumber == newOrder.poNumber || o.id == newOrder.id) {
                oldOrder = o;
                break;
              }
            }
            if (oldOrder != null && oldOrder.status != newOrder.status) {
              _notifyStatusChange(oldOrder, newOrder);
            }
          }
        }

        _orders.clear();
        if (backendOrders.isNotEmpty) {
          _orders.addAll(backendOrders);
        }
        notifyListeners();
      } else {
        _orders.clear();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('loadOrdersFromBackend error: $e');
    }
  }

  /// Membuat notifikasi saat terdeteksi perubahan status pesanan oleh admin
  void _notifyStatusChange(OrderModel oldOrder, OrderModel newOrder) {
    String title = "Update Status: ${newOrder.poNumber}";
    String message = "Status produksi mesin telah diperbarui menjadi: ${newOrder.statusTitle}.";

    switch (newOrder.status) {
      case OrderStatus.dpDitolak:
        title = "Peringatan: Bukti DP Ditolak!";
        message = "Pesanan ${newOrder.poNumber}: Bukti transfer DP dinyatakan TIDAK VALID oleh admin. Alasan: ${newOrder.rejectionReason ?? 'Mutasi tidak ditemukan'}. Silakan unggah ulang bukti transfer yang valid.";
        break;
      case OrderStatus.persiapanBahan:
        title = "Bukti DP Diverifikasi Sah (Valid)!";
        message = "Pesanan ${newOrder.poNumber}: Pembayaran DP 50% disetujui sah oleh finance pabrik. Tim memulai Persiapan Bahan Baku.";
        break;
      case OrderStatus.prosesProduksi:
        title = "Proses Produksi / Assembly Dimulai";
        message = "Pesanan ${newOrder.poNumber}: Unit ${newOrder.productName} telah memasuki jalur perakitan dan fabrikasi pabrik.";
        break;
      case OrderStatus.qualityControl:
        title = "Uji Quality Control (QC)";
        message = "Pesanan ${newOrder.poNumber}: Mesin sedang menjalani pengujian QC, kalibrasi suhu & uji tekanan boiler.";
        break;
      case OrderStatus.menungguPelunasan:
        title = "Mesin Lolos QC Pabrik (Menunggu Pelunasan)";
        message = "Pesanan ${newOrder.poNumber}: Mesin telah lulus QC & siap dikirim. Silakan selesaikan pelunasan sisa 50%.";
        break;
      case OrderStatus.verifikasiPelunasan:
        title = "Bukti Pelunasan Sedang Diverifikasi";
        message = "Pesanan ${newOrder.poNumber}: Bukti transfer pelunasan 50% Anda sedang diverifikasi oleh Tim Finance Pabrik.";
        break;
      case OrderStatus.pelunasanDitolak:
        title = "Peringatan: Bukti Pelunasan Ditolak!";
        message = "Pesanan ${newOrder.poNumber}: Bukti transfer pelunasan dinyatakan TIDAK VALID. Alasan: ${newOrder.rejectionReason ?? 'Mutasi tidak ditemukan'}. Silakan unggah ulang bukti yang valid.";
        break;
      case OrderStatus.pengirimanInstalasi:
        title = "Pelunasan Diterima & Pengiriman Dijadwalkan";
        message = "Pesanan ${newOrder.poNumber}: Pembayaran lunas. Mesin dalam perjalanan kargo & teknisi pabrik siap instalasi.";
        break;
      case OrderStatus.afterSalesService:
        title = "Selamat! Garansi Resmi 2 Tahun Aktif";
        message = "Pesanan ${newOrder.poNumber}: Mesin aktif beroperasi. Layanan purna jual After-Sales & garansi 2 tahun telah aktif.";
        break;
      default:
        break;
    }

    _latestStatusNotification = "$title: $message";
    addNotification(title, message);
  }

  String? _latestStatusNotification;
  String? get latestStatusNotification => _latestStatusNotification;

  void clearLatestStatusNotification() {
    _latestStatusNotification = null;
  }

  /// Customer mengunggah bukti pelunasan sisa 50%
  /// Status berubah menjadi `verifikasiPelunasan` (Menunggu Verifikasi/ACC Admin Website).
  /// PENTING: Jangan langsung berpindah ke `pengirimanInstalasi` sebelum Admin menyatakan valid!
  Future<bool> uploadPelunasanProof(String orderId, String proofPath) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].pelunasanProofPath = proofPath;
      _orders[index].status = OrderStatus.verifikasiPelunasan;
      _orders[index].rejectionReason = null;
      addNotification(
        'Bukti Pelunasan Terkirim!',
        'Bukti pelunasan 50% untuk ${_orders[index].poNumber} berhasil diunggah. Menunggu verifikasi dan validasi dari Admin Finance Pabrik.',
      );
      notifyListeners();

      try {
        await ApiService.uploadPelunasanProof(orderId, proofPath);
      } catch (e) {
        debugPrint('uploadPelunasanProof ApiService error: $e');
      }
      return true;
    }
    return false;
  }

  /// Customer mengunggah ulang bukti DP 50% setelah ditolak oleh Admin
  Future<bool> reuploadDpProof(String orderId, String proofPath) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].dpProofPath = proofPath;
      _orders[index].status = OrderStatus.verifikasiDp;
      _orders[index].rejectionReason = null;
      addNotification(
        'Bukti DP Baru Terkirim!',
        'Bukti DP 50% untuk ${_orders[index].poNumber} berhasil diperbarui. Tim finance pabrik akan memverifikasi kembali.',
      );
      notifyListeners();

      try {
        await ApiService.uploadDpProof(orderId, proofPath);
      } catch (e) {
        debugPrint('reuploadDpProof ApiService error: $e');
      }
      return true;
    }
    return false;
  }

  void completeDeliveryAndOpenAfterSales(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = OrderStatus.afterSalesService;
      addNotification(
        'Unit Telah Diterima & Terpasang!',
        'Pesanan ${_orders[index].poNumber} telah aktif. Masa garansi 2 tahun & layanan after-sales purna jual kini dapat digunakan.',
      );
      notifyListeners();
    }
  }

  // Custom Orders / RFQ
  final List<CustomOrderModel> _customOrders = [];
  List<CustomOrderModel> get customOrders => _customOrders;

  void submitRFQ({
    required String machineType,
    required String capacity,
    required String electrical,
    required String features,
    required String budget,
    required String targetDate,
    String? attachment,
  }) {
    final newRfq = 'RFQ-2026-0${_customOrders.length + 50}';
    final newOrder = CustomOrderModel(
      id: 'RFQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      rfqNumber: newRfq,
      companyName: _companyName.isNotEmpty ? _companyName : 'Perusahaan Mitra',
      contactPerson: _userName.isNotEmpty ? _userName : 'Tim Procurement',
      phone: _userPhone,
      email: _userEmail,
      machineType: machineType,
      targetCapacity: capacity,
      electricalSpecs: electrical,
      customFeatures: features,
      budgetRange: budget,
      targetDeliveryDate: targetDate,
      requestDate: '06 Okt 2026',
      status: CustomOrderStatus.diajukan,
      attachmentFileName: attachment,
    );

    _customOrders.insert(0, newOrder);
    addNotification(
      'RFQ Custom Order Terkirim',
      'Permintaan custom $newRfq telah diterima. Tim Engineer akan mengkaji spesifikasi teknis dalam 1x24 jam.',
    );
    notifyListeners();
  }

  // Service Tickets
  final List<ServiceTicketModel> _serviceTickets = [];
  List<ServiceTicketModel> get serviceTickets => _serviceTickets;

  void createServiceTicket({
    required String serialNumber,
    required String machineModel,
    required ServiceTicketType type,
    required String preferredDate,
    required String preferredTime,
    required String address,
    required String issueDescription,
  }) {
    final newTck = 'SRV-2026-0${_serviceTickets.length + 95}';
    final newTicket = ServiceTicketModel(
      id: 'TCK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      ticketNumber: newTck,
      companyName: _companyName.isNotEmpty ? _companyName : 'PT Kopi Nusantara Jaya',
      serialNumber: serialNumber,
      machineModel: machineModel,
      type: type,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      address: address,
      issueDescription: issueDescription,
      status: TicketStatus.dijadwalkan,
      technicianName: 'Teknisi Senior Pabrik',
      technicianPhone: '0812-3344-5566',
    );

    _serviceTickets.insert(0, newTicket);
    addNotification(
      'Booking Servis Berhasil',
      'Tiket $newTck berhasil dibuat untuk tanggal $preferredDate.',
    );
    notifyListeners();
  }

  void updateTicketStatus(String ticketId, TicketStatus newStatus, String technician) {
    final index = _serviceTickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      _serviceTickets[index].status = newStatus;
      if (technician.isNotEmpty) {
        _serviceTickets[index].technicianName = technician;
      }
      addNotification(
        'Update Tiket Servis',
        'Status tiket ${_serviceTickets[index].ticketNumber} telah diubah ke: ${_serviceTickets[index].statusTitle}.',
      );
      notifyListeners();
    }
  }

  // Warranty Claims
  final List<WarrantyClaimModel> _warrantyClaims = [];
  List<WarrantyClaimModel> get warrantyClaims => _warrantyClaims;

  void submitWarrantyClaim({
    required String serialNumber,
    required String purchaseDate,
    required String damageDescription,
    required String photoPath,
  }) {
    final claimNum = 'CLM-2026-0${_warrantyClaims.length + 20}';
    final claim = WarrantyClaimModel(
      id: 'WMT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      claimNumber: claimNum,
      serialNumber: serialNumber,
      purchaseDate: purchaseDate,
      damageDescription: damageDescription,
      photoPath: photoPath,
    );

    _warrantyClaims.insert(0, claim);
    addNotification(
      'Klaim Garansi Diterima',
      'Klaim $claimNum untuk No. Seri $serialNumber sedang dievaluasi oleh Tim Garansi Pabrik.',
    );
    notifyListeners();
  }

  // Spareparts
  final List<SparepartModel> _spareparts = MockData.initialSpareparts;
  List<SparepartModel> get spareparts => _spareparts;

  // Notifications
  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  void addNotification(String title, String message) {
    _notifications.insert(
      0,
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        time: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }
}
