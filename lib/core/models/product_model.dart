class TechnicalSpec {
  final String tipe; // Commercial Espresso / Roaster / Industrial Grinder / etc.
  final String kapasitas; // e.g. 250 Cups/Hour or 5 kg/Batch or 500 kg/Jam
  final String sumberListrik; // 220V 1-Phase / 380V 3-Phase / Gas + 220V
  final String dayaListrik; // e.g. 4500 Watt
  final String dimensi; // e.g. 780 x 540 x 520 mm
  final String berat; // e.g. 68 kg
  final String materialBoiler; // Stainless Steel 304 / Dual Copper / Cast Iron Drum
  final String kapasitasBoiler; // e.g. 11 Liters

  TechnicalSpec({
    required this.tipe,
    required this.kapasitas,
    required this.sumberListrik,
    required this.dayaListrik,
    required this.dimensi,
    required this.berat,
    required this.materialBoiler,
    required this.kapasitasBoiler,
  });
}

class CoffeeCapacityModel {
  final String modelName; // e.g. 'Model 1 kg / Batch (Sample/Lab)'
  final String shortLabel; // '1 kg'
  final String capacity; // '1 kg / Batch (4 kg / Jam)'
  final String power; // '550 Watt'
  final double price; // 55000000
  final String scale; // 'Mikro / Lab (< 3 kg)', 'Komersial / UMKM (3 - 10 kg)', 'Industri (> 10 kg)'

  const CoffeeCapacityModel({
    required this.modelName,
    required this.shortLabel,
    required this.capacity,
    required this.power,
    required this.price,
    required this.scale,
  });
}

class ProductModel {
  final String id;
  final String name;
  final String category; // Kept for backwards compatibility
  final String? _commodity;
  String get commodity => _commodity ?? 'Kopi';

  final String? _processStage;
  String get processStage => _processStage ?? 'Hilir';

  final String? _machineType;
  String get machineType => _machineType ?? '';

  final String? modelName; // Khusus kopi: model/kapasitas tertentu e.g. 'Model 5 kg / Batch'
  final String? capacityScale; // e.g. 'Mikro / Lab (< 3 kg)', 'Komersial / UMKM (3 - 10 kg)', 'Industri (> 10 kg)'
  final List<CoffeeCapacityModel>? _capacityModels;
  List<CoffeeCapacityModel> get capacityModels => _capacityModels ?? const [];

  final double price;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final String description;
  final TechnicalSpec specifications;
  final String manualBookPdfName;
  final String videoReviewTitle;
  final String videoReviewDuration;
  final bool isCustomizable;
  final String stockStatus; // Ready Stock, Pre-Order 14 Hari

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    String? commodity = 'Kopi',
    String? processStage = 'Hilir',
    String? machineType = '',
    this.modelName,
    this.capacityScale,
    List<CoffeeCapacityModel>? capacityModels = const [],
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.description,
    required this.specifications,
    required this.manualBookPdfName,
    required this.videoReviewTitle,
    required this.videoReviewDuration,
    this.isCustomizable = true,
    this.stockStatus = 'Pre-Order 14 Hari',
  })  : _commodity = commodity ?? 'Kopi',
        _processStage = processStage ?? 'Hilir',
        _machineType = machineType ?? '',
        _capacityModels = capacityModels ?? const [];
}
