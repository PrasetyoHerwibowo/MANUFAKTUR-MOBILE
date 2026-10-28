import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_picker_helper.dart';
import '../info/contact_whatsapp_screen.dart';

class RfqCustomOrderScreen extends StatefulWidget {
  final ProductModel? baseProduct;

  const RfqCustomOrderScreen({super.key, this.baseProduct});

  @override
  State<RfqCustomOrderScreen> createState() => _RfqCustomOrderScreenState();
}

class _RfqCustomOrderScreenState extends State<RfqCustomOrderScreen> {
  late final TextEditingController _machineTypeController;
  late final TextEditingController _capacityController;
  late final TextEditingController _customFeaturesController;
  late final TextEditingController _targetDateController;

  String _selectedElectrical = '380V 3-Phase Industrial (Standar Pabrik)';
  String _selectedBudget = 'Sesuai Estimasi Standar Mesin';
  String? _attachmentName;
  UploadResult? _uploadedAttachment;

  final List<String> _budgetOptionsWithBase = [
    'Sesuai Estimasi Standar Mesin',
    '+ Upgrade Fitur 10% - 25%',
    '+ Upgrade Fitur 25% - 50%',
    'Custom Lini Khusus (> Rp 150 Jt)',
  ];

  final List<String> _budgetOptionsGeneral = [
    'Rp 50 Juta - Rp 100 Juta',
    'Rp 100 Juta - Rp 250 Juta',
    'Rp 250 Juta - Rp 500 Juta',
    '> Rp 500 Juta (Lini Pabrik Turnkey)',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.baseProduct;
    if (p != null) {
      _machineTypeController = TextEditingController(text: '${p.name} (Custom Edition)');
      _capacityController = TextEditingController(
        text: p.specifications.kapasitas != '-' ? p.specifications.kapasitas : 'Kapasitas Acuan Seri',
      );
      _customFeaturesController = TextEditingController();
      _selectedBudget = 'Sesuai Estimasi Standar Mesin';
    } else {
      _machineTypeController = TextEditingController();
      _capacityController = TextEditingController();
      _customFeaturesController = TextEditingController();
      _selectedBudget = 'Rp 100 Juta - Rp 250 Juta';
    }
    _targetDateController = TextEditingController(text: '30 Hari Pasca Persetujuan Desain');
  }

  @override
  void dispose() {
    _machineTypeController.dispose();
    _capacityController.dispose();
    _customFeaturesController.dispose();
    _targetDateController.dispose();
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
    final bool hasBaseProduct = p != null;

    final Color brandColor = hasBaseProduct
        ? (p.commodity == 'Kopi'
            ? AppColors.brandCoffee
            : (p.commodity == 'Kakao' ? AppColors.brandCocoa : AppColors.secondary))
        : AppColors.secondary;

    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final inputFill = isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC);

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
          hasBaseProduct ? "Kustomisasi Mesin" : "Konsultasi Custom Order (RFQ)",
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF16A34A), size: 20),
            tooltip: "Chat WhatsApp Engineer",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactWhatsappScreen()),
              );
            },
          ),
        ],
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
            // 1. Header Banner Ringkas
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A26) : const Color(0xFF0B111A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.engineering_rounded, color: AppColors.secondary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasBaseProduct ? "Spesifikasi Kustom Pabrik" : "Request for Quotation (RFQ)",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Tim Engineer PT MDI akan menyusun kalkulasi teknis & Surat Penawaran Resmi dalam 1x24 jam.",
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF94A3B8),
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. KARTU MESIN ACUAN (HANYA MUNCUL JIKA DIBUKA DARI DETAIL PRODUK)
            if (hasBaseProduct) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: brandColor.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            p.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 64,
                              height: 64,
                              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                              child: Icon(Icons.precision_manufacturing, color: brandColor, size: 26),
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
                                  Text(" • ", style: TextStyle(color: subtextColor, fontSize: 10)),
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
                              const SizedBox(height: 2),
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
                              const SizedBox(height: 3),
                              Text(
                                "Harga Basis: ${_formatRupiah(p.price)}",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
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
                        Icon(Icons.check_circle_outline_rounded, size: 14, color: brandColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Acuan Dasar: ${p.specifications.kapasitas} • ${p.specifications.sumberListrik}",
                            style: GoogleFonts.plusJakartaSans(
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
            ],

            // 3. JIKA DIBUKA DARI HOME TANPA MESIN ACUAN: TAMPILKAN INPUT MESIN & KAPASITAS
            if (!hasBaseProduct) ...[
              _buildSectionLabel("Target Mesin yang Diinginkan", textColor),
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
                      "Jenis Mesin / Lini Produksi",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _machineTypeController,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: textColor),
                      decoration: InputDecoration(
                        hintText: "Contoh: Lini Roasting 15kg / Huller Kopi Industri",
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor),
                        prefixIcon: Icon(Icons.precision_manufacturing_outlined, size: 18, color: subtextColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: inputFill,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brandColor)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Target Kapasitas Produksi",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _capacityController,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: textColor),
                      decoration: InputDecoration(
                        hintText: "Contoh: 15 kg/Batch atau 500 kg/Hari",
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor),
                        prefixIcon: Icon(Icons.speed_outlined, size: 18, color: subtextColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: inputFill,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brandColor)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Sumber Daya Listrik Pabrik",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedElectrical,
                      dropdownColor: cardBg,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textColor),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.flash_on_outlined, size: 18, color: subtextColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: inputFill,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brandColor)),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '380V 3-Phase Industrial (Standar Pabrik)',
                          child: Text('380V 3-Phase Industrial (Standar Pabrik)', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: '220V 1-Phase (Standar Outlet)',
                          child: Text('220V 1-Phase (Standar Komersial)', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Gas LPG / LNG + 220V 1-Phase',
                          child: Text('Gas LPG / LNG + Listrik 220V', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedElectrical = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 4. KARTU PERMINTAAN KUSTOMISASI & FITUR (INTI DARI FORMULIR)
            _buildSectionLabel("Rincian Permintaan Modifikasi", textColor),
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
                    "Jelaskan Modifikasi / Fitur yang Anda Butuhkan",
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _customFeaturesController,
                    maxLines: 3,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: textColor),
                    decoration: InputDecoration(
                      hintText: hasBaseProduct
                          ? "Contoh: Mohon buat warna bodi hitam matte, penambahan layar touchscreen PLC otomatis, dan laser engraving logo 'Kopi Nusantara' pada panel depan..."
                          : "Contoh: Lini pengolahan kakao dengan material full stainless 316, sistem konveyor otomatis, dan sertifikasi food grade...",
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: subtextColor),
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

            // 5. KARTU ESTIMASI BUDGET & TARGET WAKTU (RINGKAS)
            _buildSectionLabel("Estimasi Budget & Waktu Pemasangan", textColor),
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
                    "Alokasi Budget",
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBudget,
                    dropdownColor: cardBg,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 18, color: subtextColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: inputFill,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brandColor)),
                    ),
                    items: (hasBaseProduct ? _budgetOptionsWithBase : _budgetOptionsGeneral).map((opt) {
                      return DropdownMenuItem(
                        value: opt,
                        child: Text(opt, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedBudget = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "Target Waktu Mesin Siap Pasang",
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _targetDateController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: textColor),
                    decoration: InputDecoration(
                      hintText: "Contoh: 30 Hari Kerja atau 15 Nov 2026",
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor),
                      prefixIcon: Icon(Icons.event_outlined, size: 18, color: subtextColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

            // 6. LAMPIRAN DOKUMEN / BLUEPRINT / SKETSA (OPSIONAL)
            _buildSectionLabel("Lampiran Dokumen / Sketsa (Opsional)", textColor),
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
                      final result = await FilePickerHelper.showUploadSourceSheet(
                        context: context,
                        title: "Lampirkan Dokumen Referensi / CAD",
                        subtitle: "Pilih foto denah workshop, sketsa desain, atau file blueprint PDF",
                        isRfq: true,
                        isDark: isDark,
                        brandColor: brandColor,
                      );
                      if (result != null) {
                        setState(() {
                          _uploadedAttachment = result;
                          _attachmentName = result.fileName;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _attachmentName != null
                            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5))
                            : inputFill,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _attachmentName != null ? const Color(0xFF10B981) : borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _attachmentName != null
                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                  : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _attachmentName != null
                                  ? Icons.attach_file_rounded
                                  : Icons.upload_file_outlined,
                              color: _attachmentName != null ? const Color(0xFF10B981) : brandColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _attachmentName != null ? "Dokumen Terlampir" : "Ketuk untuk Lampirkan Berkas",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _attachmentName != null
                                      ? "$_attachmentName (${_uploadedAttachment?.fileSize ?? '2.1 MB'})"
                                      : "Foto Sketsa, Denah Workshop, atau Dokumen PDF",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: _attachmentName != null ? const Color(0xFF10B981) : subtextColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _attachmentName != null ? "Ganti" : "Pilih",
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_attachmentName != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _attachmentName = null;
                            _uploadedAttachment = null;
                          });
                        },
                        icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFEF4444)),
                        label: Text(
                          "Hapus Lampiran",
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFEF4444)),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 7. BANNER KONSULTASI CEPAT WHATSAPP ENGINEER
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.25) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Butuh Diskusi Cepat via WhatsApp?",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          "Konsultasi langsung dengan Lead Engineer pabrik.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactWhatsappScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF047857),
                      backgroundColor: isDark ? Colors.white12 : const Color(0xFFD1FAE5),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      "Chat WA",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // Fixed Bottom Action Bar
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
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: subtextColor),
                      ),
                      Text(
                        "1x24 Jam Kerja",
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: brandColor),
                      ),
                      Text(
                        "Surat Penawaran Resmi & CAD",
                        style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: subtextColor),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final machine = hasBaseProduct
                        ? "${p.name} (Custom Edition)"
                        : (_machineTypeController.text.trim().isEmpty
                            ? "Custom Industrial Machine"
                            : _machineTypeController.text.trim());

                    final capacity = hasBaseProduct
                        ? p.specifications.kapasitas
                        : (_capacityController.text.trim().isEmpty
                            ? "Kapasitas Standar Pabrik"
                            : _capacityController.text.trim());

                    final features = _customFeaturesController.text.trim().isEmpty
                        ? "Penyesuaian spesifikasi standar pabrik."
                        : _customFeaturesController.text.trim();

                    appState.submitRFQ(
                      machineType: machine,
                      capacity: capacity,
                      electrical: hasBaseProduct ? p.specifications.sumberListrik : _selectedElectrical,
                      features: features,
                      budget: _selectedBudget,
                      targetDate: _targetDateController.text.trim(),
                      attachment: _attachmentName,
                    );

                    _showSuccessRfqDialog(context, machine, isDark, brandColor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(
                    "Kirim Form RFQ",
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
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

  void _showSuccessRfqDialog(
    BuildContext context,
    String machineName,
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
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                "Pengajuan Custom (RFQ) Terkirim!",
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "Permintaan spesifikasi teknis untuk unit $machineName telah diterima oleh Lead Engineer PT MDI.",
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
                  border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Proses Selanjutnya:",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Tim Sales & Technical Engineer akan menghubungi kontak WhatsApp procurement Anda untuk pembahasan gambar teknik 3D dan penawaran harga resmi.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(
                    "Selesai & Kembali",
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold),
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
