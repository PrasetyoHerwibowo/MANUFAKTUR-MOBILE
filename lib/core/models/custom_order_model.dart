enum CustomOrderStatus {
  diajukan, // User submitted RFQ
  dalamReview, // Admin reviewing specs
  quotationTerkirim, // Admin sent quotation PDF & price
  disetujui, // User accepted & created PO
  ditolak,
}

class CustomOrderModel {
  final String id;
  final String rfqNumber;
  final String companyName;
  final String contactPerson;
  final String phone;
  final String email;
  final String machineType; // Commercial Espresso, Roaster, Custom Line
  final String targetCapacity; // e.g. 500 Cups/day, 10kg/batch
  final String electricalSpecs; // 220V 1-Phase / 380V 3-Phase
  final String customFeatures; // Dual Boiler, Custom Wood Handle, Engraved Logo
  final String budgetRange; // e.g. Rp 80jt - Rp 150jt
  final String targetDeliveryDate;
  final String requestDate;
  CustomOrderStatus status;
  String? quotationPrice; // e.g. Rp 115.000.000
  String? quotationNotes;
  String? attachmentFileName;

  CustomOrderModel({
    required this.id,
    required this.rfqNumber,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.machineType,
    required this.targetCapacity,
    required this.electricalSpecs,
    required this.customFeatures,
    required this.budgetRange,
    required this.targetDeliveryDate,
    required this.requestDate,
    required this.status,
    this.quotationPrice,
    this.quotationNotes,
    this.attachmentFileName,
  });

  String get statusTitle {
    switch (status) {
      case CustomOrderStatus.diajukan:
        return "Pengajuan Baru";
      case CustomOrderStatus.dalamReview:
        return "Dalam Review Tim Teknik";
      case CustomOrderStatus.quotationTerkirim:
        return "Penawaran / Quotation Terkirim";
      case CustomOrderStatus.disetujui:
        return "Disetujui (Siap PO)";
      case CustomOrderStatus.ditolak:
        return "Ditolak";
    }
  }
}
