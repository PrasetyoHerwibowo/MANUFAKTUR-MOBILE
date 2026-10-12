import 'package:flutter/material.dart';
import '../core/models/product_model.dart';
import '../core/models/order_model.dart';
import '../core/models/custom_order_model.dart';
import '../core/models/service_ticket_model.dart';
import '../core/models/sparepart_model.dart';
import '../core/constants/mock_data.dart';
import '../core/services/api_service.dart';


enum AppMode { user, admin }

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
  // App Mode (User Client vs Admin Dashboard)
  AppMode _appMode = AppMode.user;
  AppMode get appMode => _appMode;

  void toggleAppMode() {
    _appMode = _appMode == AppMode.user ? AppMode.admin : AppMode.user;
    notifyListeners();
  }

  void setAppMode(AppMode mode) {
    _appMode = mode;
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

  // Auth state
  bool _isLoggedIn = true;
  bool get isLoggedIn => _isLoggedIn;

  String _authProvider = 'email'; // 'email', 'google', 'microsoft'
  String get authProvider => _authProvider;
  bool get isSsoUser => _authProvider == 'google' || _authProvider == 'microsoft';

  String _userName = 'Budi Santoso';
  String get userName => _userName;

  String _companyName = 'PT Manufactur Dynamic Indonesia';
  String get companyName => _companyName;

  String _userEmail = 'procurement@kopinusantara.co.id';
  String get userEmail => _userEmail;

  String _userPhone = '0812-9876-5432';
  String get userPhone => _userPhone;

  void login(String email, String password, String company, {String name = 'Mitra Manufaktur'}) {
    _isLoggedIn = true;
    _authProvider = 'email';
    _userEmail = email;
    _userName = name;
    _companyName = company.isNotEmpty ? company : 'PT Manufactur Dynamic Indonesia';
    addNotification(
      'Login Berhasil',
      'Selamat datang kembali di E-Commerce Manufaktur Mesin, $_companyName!',
    );
    notifyListeners();
  }

  Future<void> loginWithSSO({
    required String provider,
    required String name,
    required String email,
    required String company,
    String? phone,
  }) async {
    _isLoggedIn = true;
    _authProvider = provider.toLowerCase();
    _userName = name;
    _userEmail = email;
    _companyName = company.isNotEmpty ? company : 'PT Manufactur Dynamic Indonesia';
    if (phone != null && phone.isNotEmpty) {
      _userPhone = phone;
    }

    // Call REST-API backend
    ApiService.ssoAuth(
      provider: _authProvider,
      email: email,
      name: name,
      company: company,
      phone: phone,
    );

    final providerDisplayName = provider.toLowerCase() == 'google' 
        ? 'Google Workspace' 
        : (provider.toLowerCase() == 'microsoft' ? 'Microsoft 365' : provider.toUpperCase());

    addNotification(
      'SSO Login Berhasil',
      'Autentikasi aman melalui $providerDisplayName untuk akun korporat $email terverifikasi.',
    );
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // Products
  List<ProductModel> _products = MockData.initialProducts;
  List<ProductModel> get products => _products;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = 'Semua';
  String get selectedCategory => _selectedCategory;

  String _selectedPowerSource = 'Semua';
  String get selectedPowerSource => _selectedPowerSource;

  void setSearchQuery(String query) {
    _searchQuery = query;
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

  List<ProductModel> get filteredProducts {
    return _products.where((prod) {
      final matchesSearch = prod.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prod.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'Semua' || prod.category == _selectedCategory;

      final matchesPower = _selectedPowerSource == 'Semua' ||
          prod.specifications.sumberListrik.contains(_selectedPowerSource);

      return matchesSearch && matchesCategory && matchesPower;
    }).toList();
  }

  // Product CRUD for Admin
  void addProduct(ProductModel product) {
    _products.insert(0, product);
    addNotification('Produk Baru', 'Produk "${product.name}" berhasil ditambahkan ke katalog.');
    notifyListeners();
  }

  void updateProduct(ProductModel updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      addNotification('Produk Diperbarui', 'Data produk "${updatedProduct.name}" telah disimpan.');
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    final prod = _products.firstWhere((p) => p.id == id);
    _products.removeWhere((p) => p.id == id);
    addNotification('Produk Dihapus', 'Produk "${prod.name}" telah dihapus dari sistem.');
    notifyListeners();
  }

  // Orders
  List<OrderModel> _orders = MockData.initialOrders;
  List<OrderModel> get orders => _orders;

  void createStandardPO({
    required ProductModel product,
    required int quantity,
    required String deliveryAddress,
    required String customNotes,
    required String bankAccount,
    required String proofPath,
  }) {
    final total = product.price * quantity;
    final dp = total * 0.5;
    final pelunasan = total * 0.5;
    final newPoNumber = 'PO-2026-0${_orders.length + 90}';

    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      poNumber: newPoNumber,
      companyName: _companyName,
      contactPerson: 'Perwakilan Procurement',
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
    );

    _orders.insert(0, newOrder);
    addNotification(
      'Purchase Order Terbuat!',
      'PO $newPoNumber berhasil dibuat. Menunggu verifikasi bukti DP 50% oleh Tim Finance Admin.',
    );
    notifyListeners();
  }

  void verifyDpProof(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = OrderStatus.persiapanBahan;
      addNotification(
        'DP Diverifikasi Admin!',
        'Bukti DP untuk ${_orders[index].poNumber} telah diverifikasi. Produksi memasuki tahap "Persiapan Bahan Baku".',
      );
      notifyListeners();
    }
  }

  void updateProductionStage(String orderId, OrderStatus nextStage) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = nextStage;
      addNotification(
        'Update Status Produksi',
        'Pesanan ${_orders[index].poNumber} kini berada di tahap: "${_orders[index].statusTitle}".',
      );
      notifyListeners();
    }
  }

  void uploadPelunasanProof(String orderId, String proofPath) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].pelunasanProofPath = proofPath;
      _orders[index].status = OrderStatus.pengirimanInstalasi;
      addNotification(
        'Bukti Pelunasan Terupload!',
        'Bukti pelunasan 50% untuk ${_orders[index].poNumber} berhasil diunggah! Tim akan menjadwalkan Pengiriman & Instalasi.',
      );
      notifyListeners();
    }
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
  List<CustomOrderModel> _customOrders = MockData.initialCustomOrders;
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
      companyName: _companyName,
      contactPerson: 'Admin Procurement',
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

  void sendQuotationOffer(String rfqId, String price, String notes) {
    final index = _customOrders.indexWhere((r) => r.id == rfqId);
    if (index != -1) {
      _customOrders[index].status = CustomOrderStatus.quotationTerkirim;
      _customOrders[index].quotationPrice = price;
      _customOrders[index].quotationNotes = notes;
      addNotification(
        'Quotation Terkirim ke Client',
        'Penawaran harga $price untuk ${_customOrders[index].rfqNumber} berhasil dikirimkan.',
      );
      notifyListeners();
    }
  }

  // Service Tickets
  List<ServiceTicketModel> _serviceTickets = MockData.initialServiceTickets;
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
      companyName: _companyName,
      serialNumber: serialNumber,
      machineModel: machineModel,
      type: type,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      address: address,
      issueDescription: issueDescription,
      status: TicketStatus.dijadwalkan,
      technicianName: 'Teknisi Senior B2B',
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
  List<WarrantyClaimModel> _warrantyClaims = MockData.initialWarrantyClaims;
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
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'N1',
      title: 'Update QC Mesin',
      message: 'Pesanan PO-2026-092 (Roaster 5kg) telah lulus pengujian tekanan & suhu.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'N2',
      title: 'Invoice Pelunasan Terbit',
      message: 'Silakan upload bukti pelunasan sisa 50% untuk pesanan PO-2026-095.',
      time: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];
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
}
