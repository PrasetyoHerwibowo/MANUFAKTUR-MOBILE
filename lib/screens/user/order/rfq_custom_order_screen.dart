import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_picker_helper.dart';

class RfqCustomOrderScreen extends StatefulWidget {
  const RfqCustomOrderScreen({super.key});

  @override
  State<RfqCustomOrderScreen> createState() => _RfqCustomOrderScreenState();
}

class _RfqCustomOrderScreenState extends State<RfqCustomOrderScreen> {
  final _machineTypeController = TextEditingController(text: 'Custom 3-Group Espresso Line with Built-in Grinder Sync');
  final _capacityController = TextEditingController(text: '500 Cup / Hari');
  final _customFeaturesController = TextEditingController(text: 'Dual Steam Wand Auto-Foaming, Display Touchscreen per Group, Wooden Side Panel.');
  final _targetDateController = TextEditingController(text: '15 Nov 2026');

  String _selectedElectrical = '380V 3-Phase Industrial';
  String _selectedBudget = 'Rp 150.000.000 - Rp 250.000.000';
  String? _attachmentName;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Form Custom Order (RFQ)"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Info RFQ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.engineering, color: AppColors.secondary, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Request for Quotation (RFQ)",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Tim Engineer Pabrik akan merancang spesifikasi & mengirimkan Surat Penawaran Resmi.",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Jenis Mesin / Lini Produksi yang Diinginkan"),
                  TextField(
                    controller: _machineTypeController,
                    decoration: const InputDecoration(
                      hintText: "Contoh: Espresso 4-Group / Roaster 10kg Gas",
                      prefixIcon: Icon(Icons.coffee_maker),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Target Kapasitas Produksi per Hari / Jam"),
                  TextField(
                    controller: _capacityController,
                    decoration: const InputDecoration(
                      hintText: "Contoh: 600 Cup/Hari atau 15 kg/Batch",
                      prefixIcon: Icon(Icons.speed),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Spesifikasi Sumber Listrik di Lokasi Pabrik/Kafe"),
                  DropdownButtonFormField<String>(
                    value: _selectedElectrical,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.flash_on),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '220V 1-Phase (Standar)',
                        child: Text('220V 1-Phase (Standar Outlet)'),
                      ),
                      DropdownMenuItem(
                        value: '380V 3-Phase Industrial',
                        child: Text('380V 3-Phase (Heavy Duty Industrial)'),
                      ),
                      DropdownMenuItem(
                        value: 'Gas LPG + 220V 1-Phase',
                        child: Text('Gas LPG + 220V (Khusus Roaster)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedElectrical = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Fitur Khusus, Dual Boiler, Warna / Engraving Logo"),
                  TextField(
                    controller: _customFeaturesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Rincian material kayu, PID ganda, volumetrik khusus...",
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Perkiraan Range Budget Perusahaan"),
                  DropdownButtonFormField<String>(
                    value: _selectedBudget,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Rp 50.000.000 - Rp 100.000.000',
                        child: Text('Rp 50jt - Rp 100jt'),
                      ),
                      DropdownMenuItem(
                        value: 'Rp 100.000.000 - Rp 150.000.000',
                        child: Text('Rp 100jt - Rp 150jt'),
                      ),
                      DropdownMenuItem(
                        value: 'Rp 150.000.000 - Rp 250.000.000',
                        child: Text('Rp 150jt - Rp 250jt'),
                      ),
                      DropdownMenuItem(
                        value: 'Diatas Rp 250.000.000',
                        child: Text('> Rp 250jt (Custom Line)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedBudget = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Target Tanggal Pengiriman / Ready"),
                  TextField(
                    controller: _targetDateController,
                    decoration: const InputDecoration(
                      hintText: "Contoh: 15 November 2026",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Lampirkan File Referensi / Blueprint (Opsional)"),
                  InkWell(
                    onTap: () async {
                      final name = await FilePickerHelper.pickFileName();
                      setState(() {
                        _attachmentName = name ?? 'Blueprint_Custom_Layout_Kafe.pdf';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _attachmentName != null
                                ? Icons.attach_file
                                : Icons.upload_file,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _attachmentName ?? "Unggah dokumen spesifikasi PDF/Gambar",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: _attachmentName != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        appState.submitRFQ(
                          machineType: _machineTypeController.text,
                          capacity: _capacityController.text,
                          electrical: _selectedElectrical,
                          features: _customFeaturesController.text,
                          budget: _selectedBudget,
                          targetDate: _targetDateController.text,
                          attachment: _attachmentName,
                        );

                        Navigator.pop(context);
                      },
                      child: const Text("KIRIM PENGAJUAN CUSTOM RFQ"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
