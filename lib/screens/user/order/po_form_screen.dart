import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _uploadedProofName;
  UploadResult? _uploadedProof;

  late final TextEditingController _addressController;
  late final TextEditingController _engravingController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: 'Kawasan Industri MM2100 Blok C-4, Cikarang Barat, Bekasi',
    );
    _engravingController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _engravingController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$label ($text) berhasil disalin ke clipboard!",
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final p = widget.product;

    final double totalHarga = p.price * _quantity;
    final double dp50 = totalHarga * 0.5;

    final Color brandColor = p.commodity == 'Kopi'
        ? AppColors.brandCoffee
        : (p.commodity == 'Kakao' ? AppColors.brandCocoa : AppColors.secondary);

    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Formulir Pemesanan (PO)",
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ringkasan Mesin & Kuantitas
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          p.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 72,
                            height: 72,
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            child: Icon(
                              Icons.precision_manufacturing_rounded,
                              color: brandColor,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  p.category.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: brandColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  " • ",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: subtextColor,
                                  ),
                                ),
                                Text(
                                  p.stockStatus,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.amber.shade300 : const Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              p.name,
                              style: GoogleFonts.outfit(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatRupiah(p.price),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: borderColor, height: 1),
                  const SizedBox(height: 12),

                  // Integrated Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Jumlah Pesanan",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          Text(
                            "Subtotal: ${_formatRupiah(totalHarga)}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: _quantity > 1
                                      ? textColor
                                      : (isDark ? Colors.white24 : Colors.black26),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 32),
                              alignment: Alignment.center,
                              child: Text(
                                "$_quantity",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() => _quantity++),
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Alamat Pengiriman & Catatan
            _buildSectionLabel("Pengiriman & Kustomisasi", textColor),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Alamat Pengiriman & Instalasi Pabrik",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: textColor),
                    decoration: InputDecoration(
                      hintText: "Masukkan alamat lengkap pabrik / gudang tempat instalasi...",
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor),
                      prefixIcon: Icon(Icons.location_on_outlined, size: 18, color: subtextColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: brandColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    "Catatan Custom / Laser Engraving Logo (Opsional)",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _engravingController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: textColor),
                    decoration: InputDecoration(
                      hintText: "Contoh: Ukir nama brand 'Kopi Nusantara' pada cover stainless...",
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor),
                      prefixIcon: Icon(Icons.edit_note_rounded, size: 20, color: subtextColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: brandColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Pilihan Rekening Transfer DP
            _buildSectionLabel("Rekening Pembayaran DP 50%", textColor),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Transfer ke rekening resmi PT Manufactur Dynamic Indonesia:",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bank BCA Card
                  _buildBankOption(
                    bankCode: 'BCA Corporate (088-2930-112)',
                    bankTitle: 'Bank BCA Corporate',
                    accountNumber: '088-2930-112',
                    accountName: 'PT Manufactur Dynamic Indonesia',
                    isSelected: _selectedBank.contains('BCA'),
                    onSelect: () => setState(() => _selectedBank = 'BCA Corporate (088-2930-112)'),
                    onCopy: () => _copyToClipboard('0882930112', 'No. Rekening BCA'),
                    isDark: isDark,
                    brandColor: brandColor,
                  ),

                  const SizedBox(height: 8),

                  // Bank Mandiri Card
                  _buildBankOption(
                    bankCode: 'Mandiri B2B (137-0099-221)',
                    bankTitle: 'Bank Mandiri B2B',
                    accountNumber: '137-0099-221',
                    accountName: 'PT Manufactur Dynamic Indonesia',
                    isSelected: _selectedBank.contains('Mandiri'),
                    onSelect: () => setState(() => _selectedBank = 'Mandiri B2B (137-0099-221)'),
                    onCopy: () => _copyToClipboard('1370099221', 'No. Rekening Mandiri'),
                    isDark: isDark,
                    brandColor: brandColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Bukti Transfer DP 50%
            _buildSectionLabel("Bukti Transfer DP 50%", textColor),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      if (_uploadedProofName != null) {
                        FilePickerHelper.showProofPreviewDialog(
                          context: context,
                          fileName: _uploadedProofName!,
                          amount: dp50,
                          bankAccount: _selectedBank,
                          isDark: isDark,
                          brandColor: brandColor,
                        );
                        return;
                      }

                      final result = await FilePickerHelper.showUploadSourceSheet(
                        context: context,
                        title: "Unggah Bukti Transfer DP 50%",
                        subtitle: "Pilih foto struk ATM, screenshot m-Banking, atau file PDF",
                        isDark: isDark,
                        brandColor: brandColor,
                      );
                      if (result != null) {
                        setState(() {
                          _uploadedProof = result;
                          _uploadedProofName = result.fileName;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _uploadedProofName != null
                            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5))
                            : (isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _uploadedProofName != null
                              ? const Color(0xFF10B981)
                              : borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _uploadedProofName != null
                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                  : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _uploadedProofName != null
                                  ? (_uploadedProof?.sourceType == UploadSourceType.document
                                      ? Icons.picture_as_pdf_rounded
                                      : Icons.check_circle_rounded)
                                  : Icons.cloud_upload_outlined,
                              color: _uploadedProofName != null
                                  ? const Color(0xFF10B981)
                                  : brandColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _uploadedProofName != null
                                      ? "Bukti Transfer Terlampir"
                                      : "Ketuk untuk Unggah Bukti Transfer",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _uploadedProofName != null
                                      ? "$_uploadedProofName (${_uploadedProof?.fileSize ?? '1.5 MB'})"
                                      : "Kamera Struk, Galeri Foto, atau Dokumen PDF",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: _uploadedProofName != null
                                        ? const Color(0xFF10B981)
                                        : subtextColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final result = await FilePickerHelper.showUploadSourceSheet(
                                context: context,
                                title: "Unggah Bukti Transfer DP 50%",
                                subtitle: "Pilih foto struk ATM, screenshot m-Banking, atau file PDF",
                                isDark: isDark,
                                brandColor: brandColor,
                              );
                              if (result != null) {
                                setState(() {
                                  _uploadedProof = result;
                                  _uploadedProofName = result.fileName;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _uploadedProofName != null ? "Ganti" : "Pilih",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions if file is uploaded: Pratinjau & Hapus (Wrap - Zero Overflow Guarantee)
                  if (_uploadedProofName != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            FilePickerHelper.showProofPreviewDialog(
                              context: context,
                              fileName: _uploadedProofName!,
                              amount: dp50,
                              bankAccount: _selectedBank,
                              isDark: isDark,
                              brandColor: brandColor,
                            );
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 14),
                          label: Text(
                            "Lihat Bukti",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: brandColor,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _uploadedProofName = null;
                              _uploadedProof = null;
                            });
                          },
                          icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFEF4444)),
                          label: Text(
                            "Hapus",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Fixed Bottom Bar CTA
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Total DP 50%",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: subtextColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "(Saat Pesan)",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatRupiah(dp50),
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: brandColor,
                        ),
                      ),
                      Text(
                        "Sisa 50% dilunasi pasca uji QC pabrik",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final proof = _uploadedProofName ?? 'bukti_transfer_${_selectedBank.contains('BCA') ? 'bca' : 'mandiri'}.jpg';

                    appState.createStandardPO(
                      product: p,
                      quantity: _quantity,
                      deliveryAddress: _addressController.text.trim().isEmpty
                          ? 'Kawasan Industri MM2100, Cikarang Barat'
                          : _addressController.text.trim(),
                      customNotes: _engravingController.text.trim(),
                      bankAccount: _selectedBank,
                      proofPath: proof,
                    );

                    _showSuccessDialog(context, p, dp50, isDark, brandColor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Kirim Pesanan (PO)",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildBankOption({
    required String bankCode,
    required String bankTitle,
    required String accountNumber,
    required String accountName,
    required bool isSelected,
    required VoidCallback onSelect,
    required VoidCallback onCopy,
    required bool isDark,
    required Color brandColor,
  }) {
    final borderColor = isSelected
        ? brandColor
        : (isDark ? Colors.white10 : const Color(0xFFE2E8F0));

    final bgColor = isSelected
        ? (isDark ? brandColor.withValues(alpha: 0.12) : brandColor.withValues(alpha: 0.05))
        : (isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC));

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? brandColor : (isDark ? Colors.white30 : const Color(0xFF94A3B8)),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    accountNumber,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: brandColor,
                    ),
                  ),
                  Text(
                    accountName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded, size: 12, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    const SizedBox(width: 4),
                    Text(
                      "Salin",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    ProductModel p,
    double dpAmount,
    bool isDark,
    Color brandColor,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Pesanan PO Berhasil Dibuat!",
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "Pre-Order unit ${p.name} telah masuk ke sistem antrean pabrik PT Manufactur Dynamic Indonesia.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Nominal DP 50% Terverifikasi",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRupiah(dpAmount),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: brandColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Selesai & Lihat Status",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
