import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/models/order_model.dart';
import '../core/models/custom_order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case OrderStatus.verifikasiDp:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        text = "Verifikasi DP";
        break;
      case OrderStatus.persiapanBahan:
        bg = const Color(0xFFE1F5FE);
        fg = const Color(0xFF0288D1);
        text = "Persiapan Bahan";
        break;
      case OrderStatus.prosesProduksi:
        bg = const Color(0xFFEDE7F6);
        fg = const Color(0xFF512DA8);
        text = "Proses Assembly";
        break;
      case OrderStatus.qualityControl:
        bg = const Color(0xFFF3E5F5);
        fg = const Color(0xFF7B1FA2);
        text = "Quality Control (QC)";
        break;
      case OrderStatus.menungguPelunasan:
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF57F17);
        text = "Menunggu Pelunasan (50%)";
        break;
      case OrderStatus.pengirimanInstalasi:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        text = "Pengiriman & Instalasi";
        break;
      case OrderStatus.afterSalesService:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF1B5E20);
        text = "After-Sales Service";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomOrderStatusBadge extends StatelessWidget {
  final CustomOrderStatus status;

  const CustomOrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case CustomOrderStatus.diajukan:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        text = "Pengajuan Baru";
        break;
      case CustomOrderStatus.dalamReview:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        text = "Dalam Review Teknik";
        break;
      case CustomOrderStatus.quotationTerkirim:
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade800;
        text = "Quotation Terkirim";
        break;
      case CustomOrderStatus.disetujui:
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        text = "Disetujui";
        break;
      case CustomOrderStatus.ditolak:
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        text = "Ditolak";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
