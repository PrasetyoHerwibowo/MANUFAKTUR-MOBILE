enum OrderStatus {
  verifikasiDp, // Step 1: Verifikasi DP
  persiapanBahan, // Step 2: Persiapan Bahan Baku
  prosesProduksi, // Step 3: Proses Produksi/Assembly
  qualityControl, // Step 4: Quality Control (QC)
  menungguPelunasan, // Step 5: Menunggu Pelunasan (Sisa 50%)
  pengirimanInstalasi, // Step 6: Pengiriman & Instalasi
  afterSalesService, // Step 7: After-Sales Service (Layanan Purna Jual)
}

class OrderModel {
  final String id;
  final String poNumber;
  final String companyName;
  final String contactPerson;
  final String productName;
  final String category;
  final int quantity;
  final double pricePerUnit;
  final double totalAmount;
  final double dpAmount; // 50%
  final double pelunasanAmount; // 50%
  final String orderDate;
  final String estimatedCompletionDate;
  OrderStatus status;
  String? dpProofPath; // path or mock indicator
  String? pelunasanProofPath;
  final String deliveryAddress;
  final String customNotes;
  final String serialNumber;

  OrderModel({
    required this.id,
    required this.poNumber,
    required this.companyName,
    required this.contactPerson,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.dpAmount,
    required this.pelunasanAmount,
    required this.orderDate,
    required this.estimatedCompletionDate,
    required this.status,
    this.dpProofPath,
    this.pelunasanProofPath,
    required this.deliveryAddress,
    this.customNotes = '',
    this.serialNumber = 'SN-2026-MDI-8820',
  });

  int get currentStageIndex {
    switch (status) {
      case OrderStatus.verifikasiDp:
        return 0;
      case OrderStatus.persiapanBahan:
        return 1;
      case OrderStatus.prosesProduksi:
        return 2;
      case OrderStatus.qualityControl:
        return 3;
      case OrderStatus.menungguPelunasan:
        return 4;
      case OrderStatus.pengirimanInstalasi:
        return 5;
      case OrderStatus.afterSalesService:
        return 6;
    }
  }

  String get statusTitle {
    switch (status) {
      case OrderStatus.verifikasiDp:
        return "Verifikasi DP";
      case OrderStatus.persiapanBahan:
        return "Persiapan Bahan Baku";
      case OrderStatus.prosesProduksi:
        return "Proses Produksi / Assembly";
      case OrderStatus.qualityControl:
        return "Quality Control (QC)";
      case OrderStatus.menungguPelunasan:
        return "Menunggu Pelunasan";
      case OrderStatus.pengirimanInstalasi:
        return "Pengiriman & Instalasi";
      case OrderStatus.afterSalesService:
        return "After-Sales Service (Layanan Purna Jual)";
    }
  }

  static const List<String> timelineTitles = [
    "1. Verifikasi DP 50%",
    "2. Persiapan Bahan Baku",
    "3. Proses Produksi / Assembly",
    "4. Quality Control (QC)",
    "5. Menunggu Pelunasan Sisa 50%",
    "6. Pengiriman & Instalasi",
    "7. After-Sales Service (Layanan Purna Jual)",
  ];

  static const List<String> timelineSubtitles = [
    "Pengecekan bukti transfer DP 50% oleh Tim Finance Pabrik.",
    "Sourcing rangka stainless steel 304, boiler & motor transmisi.",
    "Pengerjaan pengelasan presisi, assembly kelistrikan & piping.",
    "Uji tekanan boiler 100 Bar, kalibrasi suhu & sertifikasi QC.",
    "Tagihan pelunasan sisa 50% diterbitkan sebelum pengiriman.",
    "Ekspedisi kargo industri, pengantaran on-site & instalasi teknisi.",
    "Unit aktif beroperasi, garansi 2 tahun & booking teknisi berkala.",
  ];
}

