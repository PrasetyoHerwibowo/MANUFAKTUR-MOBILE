class TechnicalSpec {
  final String tipe; // Commercial Espresso / Roaster / Industrial Grinder
  final String kapasitas; // e.g. 250 Cups/Hour or 5 kg/Batch
  final String sumberListrik; // 220V 1-Phase / 380V 3-Phase / Gas + 220V
  final String dayaListrik; // e.g. 4500 Watt
  final String dimensi; // e.g. 780 x 540 x 520 mm
  final String berat; // e.g. 68 kg
  final String materialBoiler; // Stainless Steel 304 / Dual Copper
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

class ProductModel {
  final String id;
  final String name;
  final String category; // Commercial Espresso, Coffee Roaster, Grinder, Water Treatment
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
  });
}
