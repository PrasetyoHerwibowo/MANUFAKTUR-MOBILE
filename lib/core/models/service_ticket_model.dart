enum ServiceTicketType {
  maintenanceRutin,
  kalibrasiBoiler,
  repairMesin,
  emergencyService,
}

enum TicketStatus {
  dijadwalkan,
  teknisiOtw,
  dalamPengerjaan,
  selesai,
}

class ServiceTicketModel {
  final String id;
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

  ServiceTicketModel({
    required this.id,
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
      case TicketStatus.dijadwalkan:
        return "Terjadwal";
      case TicketStatus.teknisiOtw:
        return "Dalam Proses";
      case TicketStatus.dalamPengerjaan:
        return "Proses Pengerjaan";
      case TicketStatus.selesai:
        return "Selesai";
    }
  }
}

class WarrantyClaimModel {
  final String id;
  final String claimNumber;
  final String serialNumber;
  final String purchaseDate;
  final String damageDescription;
  final String photoPath;
  String status; // Evaluasi, Disetujui, Ditolak

  WarrantyClaimModel({
    required this.id,
    required this.claimNumber,
    required this.serialNumber,
    required this.purchaseDate,
    required this.damageDescription,
    required this.photoPath,
    this.status = 'Evaluasi Tim Teknik',
  });
}
