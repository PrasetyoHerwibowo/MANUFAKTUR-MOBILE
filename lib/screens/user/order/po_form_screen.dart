import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

  late final TextEditingController _picNameController;
  late final TextEditingController _picPhoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);

    _picNameController = TextEditingController(
      text: appState.userName.isNotEmpty ? appState.userName : '',
    );
    _picPhoneController = TextEditingController(
      text: appState.userPhone.isNotEmpty ? appState.userPhone : '',
    );
    _addressController = TextEditingController(
      text: 'Kawasan Industri MM2100 Blok C-4, Cikarang Barat, Bekasi',
    );
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _picNameController.dispose();
    _picPhoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF09090B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          "$label ($text) berhasil disalin!",
          style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
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

    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? AppColors.darkTextSecondary : AppColors.textMuted;
    final inputFill = isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);
    final brandColor = isDark ? Colors.white : AppColors.primary;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Formulir Pre-Order (PO)",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
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
              // 1. Header Banner Ringkas (Industrial Zinc Monokrom)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : const Color(0xFF09090B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pre-Order Resmi Pabrikasi",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Masa fabrikasi 30 hari kalender dengan komitmen DP 50%. Sisa 50% dilunasi setelah uji QC pabrik.",
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. KARTU MESIN & JUMLAH PESANAN
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            p.imageUrl,
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 68,
                              height: 68,
                              color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                              child: Icon(Icons.precision_manufacturing, color: subtextColor, size: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: borderColor, width: 0.8),
                                    ),
                                    child: Text(
                                      p.commodity == 'Kakao' ? 'MD-COCOA' : 'MD-COFFEE',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: borderColor, width: 0.8),
                                    ),
                                    child: Text(
                                      p.stockStatus,
                                      style: GoogleFonts.inter(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                p.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  letterSpacing: -0.2,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (p.modelCodeDisplay.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  "KODE MODEL: ${p.modelCodeDisplay}",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                "Harga Basis: ${_formatRupiah(p.price)}",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
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

                    // Integrated Stepper Kuantitas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Jumlah Unit Pesanan",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "Subtotal: ${_formatRupiah(totalHarga)}",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: inputFill,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(999)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Icon(
                                    Icons.remove,
                                    size: 15,
                                    color: _quantity > 1 ? textColor : (isDark ? Colors.white24 : Colors.black26),
                                  ),
                                ),
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 32),
                                alignment: Alignment.center,
                                child: Text(
                                  "$_quantity",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => _quantity++),
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(999)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Icon(
                                    Icons.add,
                                    size: 15,
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

              const SizedBox(height: 14),

              // 3. DATA PIC PENGADAAN & PENGIRIMAN
              _buildSectionLabel("Informasi PIC & Alamat Pengiriman", textColor),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama Lengkap PIC Pemesan",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _picNameController,
                      style: GoogleFonts.inter(fontSize: 12.5, color: textColor),
                      decoration: InputDecoration(
                        hintText: "Contoh: Bpk. Bambang Hendrawan",
                        hintStyle: GoogleFonts.inter(fontSize: 12, color: subtextColor),
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: subtextColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        filled: true,
                        fillColor: inputFill,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brandColor)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Nomor WhatsApp PIC (Ekspedisi & Koordinasi)",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _picPhoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.inter(fontSize: 12.5, color: textColor),
                      decoration: InputDecoration(
                        hintText: "Contoh: 0812-3456-7890",
                        hintStyle: GoogleFonts.inter(fontSize: 12, color: subtextColor),
                        prefixIcon: Icon(Icons.phone_outlined, size: 18, color: subtextColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        filled: true,
                        fillColor: inputFill,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brandColor)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Alamat Lengkap Pengiriman Pabrik / Workshop",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      style: GoogleFonts.inter(fontSize: 12.5, color: textColor),
                      decoration: InputDecoration(
                        hintText: "Masukkan nama jalan, nomor gedung, blok, kawasan industri, kota/provinsi...",
                        hintStyle: GoogleFonts.inter(fontSize: 12, color: subtextColor),
                        prefixIcon: Icon(Icons.location_on_outlined, size: 18, color: subtextColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        filled: true,
                        fillColor: inputFill,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brandColor)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Catatan Tambahan untuk Admin (Opsional)",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Bukan instruksi custom mesin. Silakan tulis instruksi khusus pengiriman atau jam operasional gudang.",
                      style: GoogleFonts.inter(fontSize: 10.5, color: subtextColor),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      style: GoogleFonts.inter(fontSize: 12.5, color: textColor),
                      decoration: InputDecoration(
                        hintText: "Contoh: Mohon konfirmasi via WA 1 hari sebelum pengiriman unit...",
                        hintStyle: GoogleFonts.inter(fontSize: 12, color: subtextColor),
                        prefixIcon: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: subtextColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        filled: true,
                        fillColor: inputFill,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brandColor)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. PILIHAN REKENING PEMBAYARAN DP 50%
              _buildSectionLabel("Rekening Pembayaran DP 50%", textColor),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Silakan transfer DP 50% ke rekening resmi korporat PT MDI:",
                      style: GoogleFonts.inter(
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
                      bankCode: 'Mandiri (137-0099-221)',
                      bankTitle: 'Bank Mandiri',
                      accountNumber: '137-0099-221',
                      accountName: 'PT Manufactur Dynamic Indonesia',
                      isSelected: _selectedBank.contains('Mandiri'),
                      onSelect: () => setState(() => _selectedBank = 'Mandiri (137-0099-221)'),
                      onCopy: () => _copyToClipboard('1370099221', 'No. Rekening Mandiri'),
                      isDark: isDark,
                      brandColor: brandColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 5. UPLOAD BUKTI TRANSFER DP 50%
              _buildSectionLabel("Bukti Transfer DP 50%", textColor),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
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
                            uploadResult: _uploadedProof,
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _uploadedProofName != null
                              ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                              : inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _uploadedProofName != null ? brandColor : borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : const Color(0xFFE4E4E7),
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _uploadedProof != null && _uploadedProof!.isImage && _uploadedProof!.fileBytes != null
                                  ? Image.memory(_uploadedProof!.fileBytes!, fit: BoxFit.cover)
                                  : (_uploadedProof != null && _uploadedProof!.isImage && _uploadedProof!.filePath != null && !kIsWeb && File(_uploadedProof!.filePath!).existsSync())
                                      ? Image.file(File(_uploadedProof!.filePath!), fit: BoxFit.cover)
                                      : Center(
                                          child: Icon(
                                            _uploadedProofName != null
                                                ? (_uploadedProof?.sourceType == UploadSourceType.document
                                                    ? Icons.picture_as_pdf_rounded
                                                    : Icons.check_circle_rounded)
                                                : Icons.cloud_upload_outlined,
                                            color: textColor,
                                            size: 20,
                                          ),
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
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _uploadedProofName != null
                                        ? "$_uploadedProofName (${_uploadedProof?.fileSize ?? '1.5 MB'})"
                                        : "Struk ATM, Screenshot m-Banking, atau Dokumen PDF",
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: subtextColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white12 : const Color(0xFFE4E4E7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _uploadedProofName != null ? "Ganti" : "Pilih",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

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
                                uploadResult: _uploadedProof,
                                isDark: isDark,
                                brandColor: brandColor,
                              );
                            },
                            icon: const Icon(Icons.visibility_outlined, size: 14),
                            label: Text(
                              "Lihat Bukti",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: textColor,
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
                                fontWeight: FontWeight.w700,
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

        // Fixed Bottom Bar CTA (Zinc Industrial Monokrom)
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(top: BorderSide(color: borderColor, width: 1)),
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
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                color: subtextColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "(Saat Pesan)",
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatRupiah(dp50),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        Text(
                          "Sisa 50% dilunasi pasca uji QC pabrik",
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final picName = _picNameController.text.trim();
                      final picPhone = _picPhoneController.text.trim();
                      final address = _addressController.text.trim();

                      if (picName.isEmpty || picPhone.isEmpty || address.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF09090B),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            content: Text(
                              "Mohon lengkapi Nama PIC, Nomor WhatsApp, dan Alamat Pengiriman.",
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        );
                        return;
                      }

                      if (_uploadedProof == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF09090B),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            content: Text(
                              "Harap unggah bukti transfer DP 50% terlebih dahulu.",
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        );
                        return;
                      }

                      Uint8List? bytes = _uploadedProof!.fileBytes;
                      if (bytes == null && _uploadedProof!.filePath != null) {
                        try {
                          bytes = await File(_uploadedProof!.filePath!).readAsBytes();
                        } catch (_) {}
                      }

                      String proof = _uploadedProofName ?? 'bukti_dp.jpg';
                      if (bytes != null) {
                        final name = _uploadedProof!.fileName.toLowerCase();
                        String mime = 'jpeg';
                        if (name.endsWith('.png')) {
                          mime = 'png';
                        } else if (name.endsWith('.webp')) {
                          mime = 'webp';
                        } else if (name.endsWith('.pdf')) {
                          mime = 'pdf';
                        }

                        final prefix = mime == 'pdf' ? 'data:application/pdf;base64,' : 'data:image/$mime;base64,';
                        proof = '$prefix${base64Encode(bytes)}';
                      }

                      if (!context.mounted) return;

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: brandColor),
                                const SizedBox(height: 14),
                                Text(
                                  "Menerbitkan Purchase Order...",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Merekam data pesanan resmi pabrik",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      await appState.createStandardPO(
                        product: p,
                        quantity: _quantity,
                        deliveryAddress: address,
                        customNotes: _notesController.text.trim(),
                        bankAccount: _selectedBank,
                        proofPath: proof,
                      );

                      if (context.mounted) {
                        Navigator.pop(context); // Close loading dialog
                        _showSuccessDialog(context, p, dp50, picName, isDark);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : const Color(0xFF09090B),
                      foregroundColor: isDark ? const Color(0xFF09090B) : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 0,
                    ),
                    child: Text(
                      "Kirim Pesanan (PO)",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
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
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.2,
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
        ? (isDark ? Colors.white : const Color(0xFF09090B))
        : (isDark ? AppColors.darkBorder : AppColors.border);

    final bgColor = isSelected
        ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
        : (isDark ? AppColors.darkSurface : Colors.white);

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? (isDark ? Colors.white : const Color(0xFF09090B)) : const Color(0xFF94A3B8),
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    accountNumber,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white : const Color(0xFF09090B),
                    ),
                  ),
                  Text(
                    accountName,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : const Color(0xFFE4E4E7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded, size: 12, color: isDark ? Colors.white : const Color(0xFF09090B)),
                    const SizedBox(width: 4),
                    Text(
                      "Salin",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF09090B),
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
    String picName,
    bool isDark,
  ) {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFF09090B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Pesanan PO Berhasil Dibuat!",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "Pre-Order unit ${p.name} atas nama $picName telah tercatat dalam sistem antrean pabrik PT Manufactur Dynamic Indonesia.",
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Pill Ticket Badge for DP
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Nominal DP 50% Terverifikasi",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRupiah(dpAmount),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF09090B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    appState.setUserTabIndex(1); // Navigasikan langsung ke Tab Pesanan Saya
                    Navigator.pop(ctx); // Tutup dialog sukses
                    Navigator.of(context).popUntil((route) => route.isFirst); // Kembali ke Root Main Layout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : const Color(0xFF09090B),
                    foregroundColor: isDark ? const Color(0xFF09090B) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Selesai & Lihat Status Pesanan",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
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
