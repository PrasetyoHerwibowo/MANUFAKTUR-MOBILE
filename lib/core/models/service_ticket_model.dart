enum ServiceTicketType {
  maintenanceRutin,
  kalibrasiBoiler,
  repairMesin,
  emergencyService,
}

enum TicketStatus {
  menungguVerifikasi,
  dijadwalkan,
  teknisiOtw,
  dalamPengerjaan,
  selesai,
  dibatalkan,
}

class ServiceTicketModel {
  final String id;
  final String? orderId;
  final String ticketNumber;
  final String companyName;
  final String serialNumber;
  final String machineModel;
  final ServiceTicketType type;
  final String preferredDate;
  final String preferredTime;
  final String address;
  final String issueDescription;
  TicketStatus status;
  String? technicianName;
  String? technicianPhone;
  String? adminNotes;
  final String? createdAt;

  ServiceTicketModel({
    required this.id,
    this.orderId,
    required this.ticketNumber,
    required this.companyName,
    required this.serialNumber,
    required this.machineModel,
    required this.type,
    required this.preferredDate,
    required this.preferredTime,
    required this.address,
    required this.issueDescription,
    required this.status,
    this.technicianName,
    this.technicianPhone,
    this.adminNotes,
    this.createdAt,
  });

  String get typeName {
    switch (type) {
      case ServiceTicketType.maintenanceRutin:
        return "Maintenance Rutin (6 Bulan)";
      case ServiceTicketType.kalibrasiBoiler:
        return "Kalibrasi & Descaling Boiler";
      case ServiceTicketType.repairMesin:
        return "Perbaikan / Repair Mesin";
      case ServiceTicketType.emergencyService:
        return "Emergency Service 24/7";
    }
  }

  String get statusTitle {
    switch (status) {
      case TicketStatus.menungguVerifikasi:
        return "Menunggu Verifikasi";
      case TicketStatus.dijadwalkan:
        return "Jadwal Dikonfirmasi";
      case TicketStatus.teknisiOtw:
        return "Teknisi OTW";
      case TicketStatus.dalamPengerjaan:
        return "Dalam Pengerjaan";
      case TicketStatus.selesai:
        return "Selesai";
      case TicketStatus.dibatalkan:
        return "Dibatalkan";
    }
  }
}

class WarrantyClaimModel {
  final String id;
  final String? orderId;
  final String claimNumber;
  final String serialNumber;
  final String machineModel;
  final String purchaseDate;
  final String damageDescription;
  final String photoPath;
  final String fileType; // 'image' or 'video'
  String
  status; // Evaluasi, Kunjungan Dijadwalkan, Teknisi OTW, Selesai, Ditolak
  final String
  verificationStatus; // 'menunggu_verifikasi', 'valid', 'tidak_valid'
  final String warrantyStatus; // 'dalam_garansi', 'lewat_garansi'
  final String? scheduledVisitDate;
  final String? scheduledVisitTime;
  final String? visitAddress;
  final String? technicianName;
  final String? technicianPhone;
  final String? responseNotes;
  final String? createdAt;

  WarrantyClaimModel({
    required this.id,
    this.orderId,
    required this.claimNumber,
    required this.serialNumber,
    this.machineModel = 'Mesin Industri MDI',
    required this.purchaseDate,
    required this.damageDescription,
    required this.photoPath,
    this.fileType = 'image',
    this.status = 'Dalam Peninjauan Tim Engineering',
    this.verificationStatus = 'menunggu_verifikasi',
    this.warrantyStatus = 'dalam_garansi',
    this.scheduledVisitDate,
    this.scheduledVisitTime,
    this.visitAddress,
    this.technicianName,
    this.technicianPhone,
    this.responseNotes,
    this.createdAt,
  });

  bool get isVideo =>
      fileType == 'video' || photoPath.toLowerCase().endsWith('.mp4');

  bool get hasScheduledVisit =>
      scheduledVisitDate != null && scheduledVisitDate!.isNotEmpty;

  String get friendlyStatus {
    if (status.toLowerCase().contains('kunjungan') ||
        status.toLowerCase().contains('dijadwalkan')) {
      return "Kunjungan Teknisi Terjadwal";
    }
    if (status.toLowerCase().contains('otw')) {
      return "Teknisi Menuju Lokasi";
    }
    if (status.toLowerCase().contains('selesai')) {
      return "Perbaikan Tuntas";
    }
    if (status.toLowerCase().contains('tolak')) {
      return "Klaim Ditolak";
    }
    return "Menunggu Verifikasi Bukti";
  }
}
