import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../info/contact_whatsapp_screen.dart';

class RfqCustomOrderScreen extends StatefulWidget {
  final ProductModel baseProduct;

  const RfqCustomOrderScreen({super.key, required this.baseProduct});

  @override
  State<RfqCustomOrderScreen> createState() => _RfqCustomOrderScreenState();
}

class _RfqCustomOrderScreenState extends State<RfqCustomOrderScreen> {
  late final TextEditingController _customFeaturesController;
  late final TextEditingController _picNameController;
  late final TextEditingController _picPhoneController;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);

    _customFeaturesController = TextEditingController();
    _picNameController = TextEditingController(
      text: appState.userName.isNotEmpty ? appState.userName : '',
    );
    _picPhoneController = TextEditingController(
      text: appState.userPhone.isNotEmpty ? appState.userPhone : '',
    );
  }

  @override
  void dispose() {
    _customFeaturesController.dispose();
    _picNameController.dispose();
    _picPhoneController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final p = widget.baseProduct;

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
            "Kustomisasi Mesin",
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
                      child: const Icon(Icons.precision_manufacturing_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Spesifikasi Kustom Pabrik",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Pabrikasi fleksibel sesuai denah workshop, kapasitas produksi, & kebutuhan lini Anda.",
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

              // 2. KARTU MESIN ACUAN DASAR
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 10),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Acuan Dasar: ${p.specifications.kapasitas} • ${p.specifications.sumberListrik}",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: subtextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. RINCIAN MODIFIKASI & KEBUTUHAN KHUSUS
              _buildSectionLabel("Rincian Permintaan Modifikasi", textColor),
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
                      "Deskripsi Kebutuhan Teknis / Modifikasi",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Jelaskan modifikasi material (SS304/SS316), penambahan PLC/layar sentuh, penyesuaian dimensi, atau kebutuhan khusus lainnya.",
                      style: GoogleFonts.inter(fontSize: 11, color: subtextColor, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customFeaturesController,
                      maxLines: 4,
                      style: GoogleFonts.inter(fontSize: 12.5, color: textColor),
                      decoration: InputDecoration(
                        hintText: "Contoh: Mohon penambahan panel otomatisasi PLC touchscreen, material hopper dan drum full Stainless Steel 304, serta opsi warna finishing hitam matte...",
                        hintStyle: GoogleFonts.inter(fontSize: 11.5, color: subtextColor, height: 1.35),
                        contentPadding: const EdgeInsets.all(12),
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

              // 4. DATA KONTAK PIC PROCUREMENT (PENGADAAN)
              _buildSectionLabel("Kontak PIC Pengadaan (Procurement)", textColor),
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
                      "Nama Penanggung Jawab (PIC)",
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
                      "Nomor WhatsApp PIC",
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
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 5. BANNER DIRECT WHATSAPP GATEWAY
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Penerbitan Tiket RFQ & Diskusi WA",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Setelah form terkirim, nomor tiket resmi akan otomatis dibuat dan Anda dapat langsung mengirim foto sketsa/layout workshop via chat WhatsApp.",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: subtextColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),

        // Fixed Bottom Action Bar (Zinc Industrial Monokrom)
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
                        Text(
                          "Kajian Tim Engineer",
                          style: GoogleFonts.inter(fontSize: 10, color: subtextColor),
                        ),
                        Text(
                          "1x24 Jam Kerja",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        Text(
                          "Surat Penawaran Resmi & CAD",
                          style: GoogleFonts.inter(fontSize: 9.5, color: subtextColor),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final picName = _picNameController.text.trim();
                      final picPhone = _picPhoneController.text.trim();

                      if (picName.isEmpty || picPhone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF09090B),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            content: Text(
                              "Mohon lengkapi Nama PIC dan Nomor WhatsApp.",
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        );
                        return;
                      }

                      final machine = "${p.name} (Custom Edition)";
                      final capacity = p.specifications.kapasitas;
                      final features = _customFeaturesController.text.trim().isEmpty
                          ? "Penyesuaian spesifikasi standar pabrik (Kustomisasi Pabrikasi)."
                          : _customFeaturesController.text.trim();

                      appState.submitRFQ(
                        machineType: machine,
                        capacity: capacity,
                        electrical: p.specifications.sumberListrik,
                        features: features,
                        budget: "Konsultasi Teknis & Penawaran Resmi",
                        targetDate: "Sesuai Jadwal Fabrikasi (30 Hari)",
                        attachment: null,
                      );

                      final ticketNo = appState.customOrders.isNotEmpty
                          ? appState.customOrders.first.rfqNumber
                          : "RFQ-${DateTime.now().year}-051";

                      _showSuccessRfqDialog(context, machine, ticketNo, picName, isDark);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : const Color(0xFF09090B),
                      foregroundColor: isDark ? const Color(0xFF09090B) : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 0,
                    ),
                    icon: Icon(
                      Icons.chat_bubble_rounded,
                      size: 16,
                      color: isDark ? const Color(0xFF09090B) : Colors.white,
                    ),
                    label: Text(
                      "Kirim & Diskusi WA",
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

  void _showSuccessRfqDialog(
    BuildContext context,
    String machineName,
    String ticketNo,
    String picName,
    bool isDark,
  ) {
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
                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                "Tiket RFQ Diterbitkan!",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Pill Ticket Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE4E4E7)),
                ),
                child: Text(
                  "NO. TIKET: $ticketNo",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.white : const Color(0xFF09090B),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "Permintaan spesifikasi kustom untuk unit $machineName atas nama $picName telah tercatat dalam sistem antrean Lead Engineer PT MDI.",
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Langkah Selanjutnya:",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Anda dapat langsung mengirimkan foto sketsa, foto denah workshop, atau berdiskusi teknis via WhatsApp resmi PT MDI.",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // WhatsApp Direct Action Button (Pill 999)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactWhatsappScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                  label: Text(
                    "Buka WhatsApp Engineer Sekarang",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Secondary Dismiss Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Back to previous screen
                  },
                  child: Text(
                    "Kembali ke Detail Mesin",
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
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
