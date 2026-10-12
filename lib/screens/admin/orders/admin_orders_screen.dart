import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/status_badge.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final orders = appState.orders;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manajemen Purchase Order (PO) & Lini Produksi",
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              "Verifikasi pembayaran DP, perbarui tahap manufaktur pabrik, & kirim tagihan pelunasan.",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final o = orders[index];
                final dpFormatted =
                    "Rp ${o.dpAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
                final totalFormatted =
                    "Rp ${o.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                o.poNumber,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                "${o.companyName} • ${o.orderDate}",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          OrderStatusBadge(status: o.status),
                        ],
                      ),
                      const Divider(height: 20),

                      Text(
                        "Item: ${o.productName} (x${o.quantity} Unit)",
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text("Total PO: $totalFormatted • DP 50%: $dpFormatted",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: AppColors.textMuted)),

                      const SizedBox(height: 16),

                      // ADMIN ACTION BUTTONS BAR
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // 1. Verifikasi Bukti DP Button
                          if (o.status == OrderStatus.verifikasiDp)
                            ElevatedButton.icon(
                              onPressed: () {
                                _showVerifyDpDialog(context, appState, o);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                              ),
                              icon: const Icon(Icons.verified, size: 16),
                              label: const Text("Verifikasi Bukti DP"),
                            ),

                          // 2. Update Status Produksi Dropdown Dialog
                          OutlinedButton.icon(
                            onPressed: () {
                              _showUpdateStageDialog(context, appState, o);
                            },
                            icon: const Icon(Icons.published_with_changes, size: 16),
                            label: Text("Update Status: ${o.statusTitle}"),
                          ),

                          // 3. Kirim Tagihan Pelunasan Button
                          if (o.status == OrderStatus.qualityControl)
                            ElevatedButton.icon(
                              onPressed: () {
                                appState.updateProductionStage(
                                    o.id, OrderStatus.menungguPelunasan);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Tagihan Pelunasan (50%) terkirim ke ${o.companyName}!"),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                              ),
                              icon: const Icon(Icons.send, size: 16),
                              label: const Text("Kirim Tagihan Pelunasan"),
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

  void _showVerifyDpDialog(
      BuildContext context, AppState appState, OrderModel o) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Verifikasi Bukti Transfer DP 50%",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("No. PO: ${o.poNumber}"),
            Text("Perusahaan: ${o.companyName}"),
            Text(
              "Jumlah DP: Rp ${o.dpAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold, color: AppColors.secondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.image, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("Bukti Transfer: bukti_dp_nusantara.jpg"),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tolak"),
          ),
          ElevatedButton(
            onPressed: () {
              appState.verifyDpProof(o.id);
              Navigator.pop(context);
            },
            child: const Text("Setujui & Verifikasi"),
          ),
        ],
      ),
    );
  }

  void _showUpdateStageDialog(
      BuildContext context, AppState appState, OrderModel o) {
    OrderStatus selected = o.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Update Status Lini Produksi",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: OrderStatus.values.map((stg) {
              return RadioListTile<OrderStatus>(
                title: Text(
                  OrderModel(
                    id: '',
                    poNumber: '',
                    companyName: '',
                    contactPerson: '',
                    productName: '',
                    category: '',
                    quantity: 1,
                    pricePerUnit: 0,
                    totalAmount: 0,
                    dpAmount: 0,
                    pelunasanAmount: 0,
                    orderDate: '',
                    estimatedCompletionDate: '',
                    status: stg,
                    deliveryAddress: '',
                  ).statusTitle,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12),
                ),
                value: stg,
                groupValue: selected,
                onChanged: (val) {
                  setDialogState(() {
                    selected = val!;
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                appState.updateProductionStage(o.id, selected);
                Navigator.pop(context);
              },
              child: const Text("Simpan Status"),
            ),
          ],
        ),
      ),
    );
  }
}
