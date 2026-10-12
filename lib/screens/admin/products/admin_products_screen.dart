import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/product_model.dart';
import '../../../core/theme/app_colors.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final products = appState.products;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Manajemen Produk Mesin Kopi",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      "Kelola katalog, spesifikasi teknis, & status stok manufaktur.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddProductModal(context, appState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah Produk Baru"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Product List Table/Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final prod = products[index];
                final priceFormatted =
                    "Rp ${prod.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          prod.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 70,
                            height: 70,
                            color: AppColors.primary,
                            child: const Icon(Icons.coffee_maker, color: AppColors.secondary, size: 28),
                          ),
                        ),

                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod.category.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                            Text(
                              prod.name,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Harga: $priceFormatted • ${prod.specifications.sumberListrik}",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons (Edit / Delete)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showEditProductModal(context, appState, prod),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              appState.deleteProduct(prod.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductModal(BuildContext context, AppState appState) {
    final nameCtrl = TextEditingController(text: 'TitanRoast Commercial 2kg');
    final categoryCtrl = TextEditingController(text: 'Coffee Roaster');
    final priceCtrl = TextEditingController(text: '95000000');
    final listrikCtrl = TextEditingController(text: '220V Gas LPG');
    final capacityCtrl = TextEditingController(text: '2kg / Batch');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tambah Mesin Baru", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Nama Produk"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga (Rp)"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: listrikCtrl,
                decoration: const InputDecoration(labelText: "Sumber Listrik"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: capacityCtrl,
                decoration: const InputDecoration(labelText: "Kapasitas"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final newProd = ProductModel(
                id: 'PROD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                name: nameCtrl.text,
                category: categoryCtrl.text,
                price: double.tryParse(priceCtrl.text) ?? 95000000,
                rating: 5.0,
                reviewsCount: 1,
                imageUrl:
                    'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=800&auto=format&fit=crop&q=80',
                description: 'Mesin kopi manufaktur presisi baru.',
                specifications: TechnicalSpec(
                  tipe: categoryCtrl.text,
                  kapasitas: capacityCtrl.text,
                  sumberListrik: listrikCtrl.text,
                  dayaListrik: '2200 Watt',
                  dimensi: '600 x 500 x 450 mm',
                  berat: '45 kg',
                  materialBoiler: 'Stainless Steel 304',
                  kapasitasBoiler: '6 Liter',
                ),
                manualBookPdfName: 'Manual_Book_New.pdf',
                videoReviewTitle: 'Review Standar Pabrik',
                videoReviewDuration: '05:00',
              );

              appState.addProduct(newProd);
              Navigator.pop(context);
            },
            child: const Text("Simpan Produk"),
          ),
        ],
      ),
    );
  }

  void _showEditProductModal(
      BuildContext context, AppState appState, ProductModel p) {
    final nameCtrl = TextEditingController(text: p.name);
    final priceCtrl = TextEditingController(text: p.price.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Produk", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Harga (Rp)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = ProductModel(
                id: p.id,
                name: nameCtrl.text,
                category: p.category,
                price: double.tryParse(priceCtrl.text) ?? p.price,
                rating: p.rating,
                reviewsCount: p.reviewsCount,
                imageUrl: p.imageUrl,
                description: p.description,
                specifications: p.specifications,
                manualBookPdfName: p.manualBookPdfName,
                videoReviewTitle: p.videoReviewTitle,
                videoReviewDuration: p.videoReviewDuration,
              );

              appState.updateProduct(updated);
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
