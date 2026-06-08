import 'package:do_an_mobile/Admin/utils/app_colors.dart';
import 'package:do_an_mobile/Admin/views/job_post_management_screen.dart';
import 'package:do_an_mobile/Admin/views/overview_screen.dart';
import 'package:do_an_mobile/Admin/views/recruiter_management_screen.dart';
import 'package:do_an_mobile/Admin/views/user_management_screen.dart';
import 'package:do_an_mobile/UngVien/views/login.dart';
import 'package:flutter/material.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Tổng quan'),
    _NavItem(icon: Icons.people_alt_rounded, label: 'Người tìm việc'),
    _NavItem(icon: Icons.business_rounded, label: 'Nhà tuyển dụng'),
    _NavItem(icon: Icons.work_rounded, label: 'Quản lý tin'),
  ];

  Widget _buildPageForIndex(int index) {
    switch (index) {
      case 0:
        return const OverviewScreen();
      case 1:
        return const UserManagementScreen();
      case 2:
        return const RecruiterManagementScreen();
      case 3:
        return const JobPostManagementScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState != null && scaffoldState.isDrawerOpen) {
      scaffoldState.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return isDesktop ? _buildDesktop() : _buildMobile();
  }

  Widget _buildDesktop() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          _AdminSidebar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onTap: _onNavTap,
            onLogout: _handleLogout,
          ),
          Container(width: 1, color: AppColors.border),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: IndexedStack(
                  index: _selectedIndex,
                  children: List.generate(
                    _navItems.length,
                    (i) => _buildPageForIndex(i),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: _AdminSidebar(
          navItems: _navItems,
          selectedIndex: _selectedIndex,
          onTap: _onNavTap,
          onLogout: _handleLogout,
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
          _navItems.length,
          (i) => _buildPageForIndex(i),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
      title: Text(
        _navItems[_selectedIndex].label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontSize: 18,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      actions: [_NotificationButton(), const SizedBox(width: 8)],
    );
  }

  void _handleLogout() {
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState != null && scaffoldState.isDrawerOpen) {
      scaffoldState.closeDrawer();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _navigateToLogin();
      });
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => Login()),
      (route) => false,
    );
  }
}

// ============================================================
// SIDEBAR WIDGET
// ============================================================
class _AdminSidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onLogout;

  const _AdminSidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.onTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Column(
        children: [
          _buildBrand(),
          Container(height: 1, color: AppColors.borderLight, margin: const EdgeInsets.symmetric(horizontal: 16)),
          const SizedBox(height: 16),
          _buildUserCard(),
          const SizedBox(height: 20),
          _buildSectionLabel('ĐIỀU HƯỚNG'),
          const SizedBox(height: 8),
          ...List.generate(navItems.length, (i) => _NavTile(
            item: navItems[i],
            isSelected: selectedIndex == i,
            onTap: () => onTap(i),
          )),
          const Spacer(),
          Container(height: 1, color: AppColors.borderLight, margin: const EdgeInsets.symmetric(horizontal: 16)),
          _buildLogoutButton(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('JobsGo',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16,
                    color: AppColors.textPrimary, letterSpacing: -0.3)),
              Text('Admin Panel',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('NK',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nguyễn Văn Khải',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryDark),
                  overflow: TextOverflow.ellipsis),
                Text('Quản trị viên',
                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              color: AppColors.textMuted, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: onLogout,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.red, size: 18),
            ),
            const SizedBox(width: 12),
            const Text('Đăng xuất',
              style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ─── Nav Tile ───────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavTile({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(item.label,
              style: TextStyle(fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary)),
            if (isSelected) ...[
              const Spacer(),
              Container(width: 5, height: 5,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Notification Button ─────────────────────────────────────
class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 24, color: AppColors.textSecondary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Bạn không có thông báo mới nào.'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        ),
        Positioned(
          top: 10, right: 10,
          child: Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: AppColors.red, shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Data class ──────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}