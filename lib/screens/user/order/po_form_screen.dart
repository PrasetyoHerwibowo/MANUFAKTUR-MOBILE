import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_picker_helper.dart';

class PoFormScreen extends StatefulWidget {
  final ProductModel product;

  const PoFormScreen({super.key, required this.product});

  @override
  State<PoFormScreen> createState() => _PoFormScreenState();
}

class _PoFormScreenState extends State<PoFormScreen> {
  int _quantity = 1;
  String _selectedBank = 'BCA Corporate (088-2930-112)';
  String _deliveryAddress = 'Jl. Sudirman No. 45, Jakarta Selatan';
  String _customEngravingNotes = '';
  String? _uploadedProofName;

  final _addressController = TextEditingController(text: 'Jl. Sudirman No. 45, Jakarta Selatan');
  final _engravingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final p = widget.product;

    final double totalHarga = p.price * _quantity;
    final double dp50 = totalHarga * 0.5;
    final double sisa50 = totalHarga * 0.5;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Form Purchase Order (PO)"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      p.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.primary,
                        child: const Icon(Icons.coffee_maker, color: AppColors.secondary, size: 28),
                      ),
                    ),

                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.category.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          p.name,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Rp ${p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quantity & Customization Section
            _buildSectionHeader("Jumlah Unit & Custom Branding"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Jumlah Pesanan (Unit)",
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            "$_quantity",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    "Catatan Custom / Engraving Logo Laser (Opsional)",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _engravingController,
                    onChanged: (val) => _customEngravingNotes = val,
                    decoration: const InputDecoration(
                      hintText: "Contoh: Ukir logo 'Kopi Nusantara' pada panel stainless kanan.",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Delivery Address
            _buildSectionHeader("Alamat Pengiriman & Instalasi"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _addressController,
                onChanged: (val) => _deliveryAddress = val,
                maxLines: 2,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: "Alamat pabrik / cabang kafe tempat instalasi...",
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Automatic Calculation Summary Card
            _buildSectionHeader("Rincian Kalkulasi Pembayaran B2B"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildCalcRow("Total Harga (x$_quantity Unit)",
                      "Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                      isWhite: true),
                  const SizedBox(height: 8),
                  _buildCalcRow(
                    "Pilihan DP Mula: DP 50%",
                    "Rp ${dp50.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                    isHighlight: true,
                  ),
                  const SizedBox(height: 8),
                  _buildCalcRow(
                    "Sisa Pelunasan (Setelah QC)",
                    "Rp ${sisa50.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                    isWhite: true,
                  ),
                  const Divider(color: Colors.white30, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TOTAL DIBAYAR SEKARANG (DP 50%)",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Rp ${dp50.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                        style: GoogleFonts.outfit(
                          color: AppColors.secondaryLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bank Account Selection & Transfer Proof Upload
            _buildSectionHeader("Upload Bukti Transfer DP 50%"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pilih Rekening Tujuan Transfer",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBank,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'BCA Corporate (088-2930-112)',
                        child: Text('BCA Corporate: 088-2930-112 (a.n. PT Manufactur Dynamic Indonesia)', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Mandiri B2B (137-0099-221)',
                        child: Text('Mandiri B2B: 137-0099-221 (a.n. PT Manufactur Dynamic Indonesia)', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedBank = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "Unggah Bukti Transfer DP (Image / PDF)",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Upload Button / Preview
                  InkWell(
                    onTap: () async {
                      final picked = await FilePickerHelper.pickFileName(
                          allowedExtensions: ['jpg', 'png', 'pdf']);
                      setState(() {
                        _uploadedProofName =
                            picked ?? 'bukti_dp_bca_b2b_transfer.jpg';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _uploadedProofName != null
                            ? Colors.green.shade50
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _uploadedProofName != null
                              ? Colors.green
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              _uploadedProofName != null
                                  ? Icons.check_circle
                                  : Icons.cloud_upload_outlined,
                              color: _uploadedProofName != null
                                  ? Colors.green
                                  : AppColors.secondary,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _uploadedProofName != null
                                  ? "File Terunggah: $_uploadedProofName"
                                  : "Klik di sini untuk unggah foto / PDF bukti transfer",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _uploadedProofName != null
                                    ? Colors.green.shade800
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Submit PO Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  _uploadedProofName ??= 'bukti_dp_bca_b2b_transfer.jpg';

                  appState.createStandardPO(
                    product: p,
                    quantity: _quantity,
                    deliveryAddress: _deliveryAddress,
                    customNotes: _customEngravingNotes,
                    bankAccount: _selectedBank,
                    proofPath: _uploadedProofName!,
                  );

                  Navigator.pop(context);
                },
                child: const Text("SUBMIT PURCHASE ORDER SEKARANG"),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCalcRow(String label, String value,
      {bool isWhite = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: isHighlight
                ? AppColors.secondaryLight
                : (isWhite ? Colors.white70 : AppColors.textSecondary),
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: isHighlight ? AppColors.secondaryLight : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
