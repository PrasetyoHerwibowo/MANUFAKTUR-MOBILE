class SparepartModel {
  final String id;
  final String name;
  final String category; // Seal & Gasket, Grinder Burr, Solenoid, Steam Wand, Filter Basket
  final double price;
  final String compatibility; // Suitable for Linea PB, Espresso Craft Pro 2G, etc.
  final String imageUrl;
  final int stock;
  final String partNumber;

  SparepartModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.compatibility,
    required this.imageUrl,
    required this.stock,
    required this.partNumber,
  });
}
