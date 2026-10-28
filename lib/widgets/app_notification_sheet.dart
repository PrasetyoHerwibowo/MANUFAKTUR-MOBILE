import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../core/theme/app_colors.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  IconData _getNotificationIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('qc') || lower.contains('uji') || lower.contains('lulus')) {
      return Icons.verified_outlined;
    }
    if (lower.contains('invoice') ||
        lower.contains('bayar') ||
        lower.contains('pelunasan') ||
        lower.contains('po') ||
        lower.contains('pesanan')) {
      return Icons.receipt_long_outlined;
    }
    if (lower.contains('login') ||
        lower.contains('sso') ||
        lower.contains('keamanan')) {
      return Icons.shield_outlined;
    }
    if (lower.contains('produk') || lower.contains('katalog')) {
      return Icons.inventory_2_outlined;
    }
    return Icons.notifications_active_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final notifications = appState.notifications;
    final isDark = appState.isDarkMode;
    final unreadCount = appState.unreadNotificationsCount;

    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final dividerColor = isDark ? Colors.white10 : AppColors.border;
    final unreadTileBg = isDark
        ? AppColors.secondary.withValues(alpha: 0.10)
        : AppColors.secondary.withValues(alpha: 0.05);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: isDark
            ? const Border(top: BorderSide(color: Colors.white12, width: 1))
            : null,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.secondary
                              .withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Notifikasi",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "$unreadCount Baru",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (unreadCount > 0)
                    TextButton.icon(
                      onPressed: () {
                        appState.markAllNotificationsAsRead();
                      },
                      icon: const Icon(
                        Icons.done_all_rounded,
                        size: 15,
                        color: AppColors.secondary,
                      ),
                      label: Text(
                        "Tandai Dibaca",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                  else
                    Text(
                      "Semua Terbaca",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: isDark ? Colors.white38 : AppColors.textMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: dividerColor, height: 1),
              const SizedBox(height: 8),

              // Body: Empty State or Notification List
              if (notifications.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 44,
                          color: isDark
                              ? Colors.white24
                              : AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Tidak ada notifikasi baru",
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Pembaruan status fabrikasi & pesanan akan tampil di sini.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => Divider(
                      color: dividerColor,
                      height: 1,
                      indent: 54,
                    ),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return InkWell(
                        onTap: () {
                          appState.markNotificationAsRead(notif.id);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: notif.isRead ? Colors.transparent : unreadTileBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: notif.isRead
                                    ? (isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : const Color(0xFFF1F5F9))
                                    : AppColors.secondary.withValues(
                                        alpha: isDark ? 0.22 : 0.12),
                                child: Icon(
                                  _getNotificationIcon(notif.title),
                                  size: 18,
                                  color: notif.isRead
                                      ? (isDark
                                          ? Colors.white38
                                          : AppColors.textMuted)
                                      : AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: notif.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.bold,
                                              fontSize: 13,
                                              color: notif.isRead
                                                  ? (isDark
                                                      ? Colors.white70
                                                      : AppColors.textPrimary)
                                                  : (isDark
                                                      ? Colors.white
                                                      : AppColors.textPrimary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${notif.time.hour.toString().padLeft(2, '0')}:${notif.time.minute.toString().padLeft(2, '0')}",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            color: isDark
                                                ? Colors.white38
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif.message,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        height: 1.35,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!notif.isRead) ...[
                                const SizedBox(width: 6),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
