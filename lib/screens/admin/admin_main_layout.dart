import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'products/admin_products_screen.dart';
import 'orders/admin_orders_screen.dart';
import 'custom_orders/admin_rfq_screen.dart';
import 'service_tickets/admin_tickets_screen.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedAdminIndex = 0;

  final List<Widget> _adminPages = [
    const AdminDashboardScreen(),
    const AdminProductsScreen(),
    const AdminOrdersScreen(),
    const AdminRfqScreen(),
    const AdminTicketsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PANEL ADMIN B2B",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Dashboard Manufaktur Mesin Kopi Web",
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.secondaryLight,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                appState.toggleAppMode();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.phone_android, size: 16),
              label: const Text("Mode User Mobile"),
            ),
          ),
        ],
      ),
      drawer: !isDesktop ? _buildAdminDrawer() : null,
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 250,
              color: AppColors.primaryLight,
              child: _buildAdminNavList(),
            ),
          Expanded(
            child: _adminPages[_selectedAdminIndex],
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _selectedAdminIndex,
              onTap: (index) {
                setState(() {
                  _selectedAdminIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.secondary,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2),
                  label: 'Produk',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Pesanan PO',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.request_quote),
                  label: 'RFQ Custom',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.build),
                  label: 'Servis',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      child: Container(
        color: AppColors.primary,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.coffee_maker,
                      color: AppColors.secondary, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    "PABRIK MANUFAKTUR B2B",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Admin Control Panel",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildAdminNavList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminNavList() {
    final navItems = [
      {'icon': Icons.dashboard, 'label': 'Dashboard Statistik'},
      {'icon': Icons.inventory_2, 'label': 'Manajemen Produk'},
      {'icon': Icons.shopping_bag, 'label': 'Manajemen PO & Produksi'},
      {'icon': Icons.request_quote, 'label': 'Manajemen Custom Order (RFQ)'},
      {'icon': Icons.build, 'label': 'Manajemen Tiket Servis'},
    ];

    return ListView.builder(
      itemCount: navItems.length,
      itemBuilder: (context, index) {
        final item = navItems[index];
        final isSel = _selectedAdminIndex == index;

        return ListTile(
          leading: Icon(
            item['icon'] as IconData,
            color: isSel ? AppColors.secondary : Colors.white70,
          ),
          title: Text(
            item['label'] as String,
            style: GoogleFonts.plusJakartaSans(
              color: isSel ? Colors.white : Colors.white70,
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          selected: isSel,
          selectedTileColor: AppColors.secondary.withOpacity(0.2),
          onTap: () {
            setState(() {
              _selectedAdminIndex = index;
            });
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }
}
