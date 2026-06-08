import 'package:do_an_mobile/Admin/utils/app_colors.dart';
import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';
import '../models/admin_user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminController _controller = AdminController();
  String _search = '';
  String _filterStatus = 'all'; // 'all' | 'active' | 'locked'
  late Future<List<AdminUserModel>> _userFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _userFuture = _controller.getUserList();
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.red : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Hộp thoại lọc ──────────────────────────────────────
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Lọc người dùng',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              const Text('Trạng thái tài khoản',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5)),
              const SizedBox(height: 10),
              ...[
                ('all', 'Tất cả', Icons.people_alt_rounded),
                ('active', 'Đang hoạt động', Icons.check_circle_outline_rounded),
                ('locked', 'Bị khóa', Icons.lock_outline_rounded),
              ].map((item) {
                final (value, label, icon) = item;
                final selected = _filterStatus == value;
                return GestureDetector(
                  onTap: () {
                    setModalState(() {});
                    setState(() => _filterStatus = value);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryLight
                          : AppColors.bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(icon,
                            size: 18,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Text(label,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textPrimary)),
                        const Spacer(),
                        if (selected)
                          const Icon(Icons.check_rounded,
                              size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hộp thoại chỉnh sửa ────────────────────────────────
  void _showEditDialog(AdminUserModel user) {
    final hoTenCtrl =
        TextEditingController(text: user.hoTen);
    final viTriCtrl =
        TextEditingController(text: user.viTriUngTuyen);
    final sdtCtrl =
        TextEditingController(text: user.soDienThoai ?? '');
    final diaChiCtrl =
        TextEditingController(text: user.diaChi ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Chỉnh sửa thông tin',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EditField(
                  label: 'Họ và tên',
                  controller: hoTenCtrl,
                  icon: Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _EditField(
                  label: 'Vị trí ứng tuyển',
                  controller: viTriCtrl,
                  icon: Icons.work_outline_rounded),
              const SizedBox(height: 12),
              _EditField(
                  label: 'Số điện thoại',
                  controller: sdtCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _EditField(
                  label: 'Địa chỉ',
                  controller: diaChiCtrl,
                  icon: Icons.location_on_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // TODO: gọi API cập nhật thông tin
              // await _controller.updateUser(user.idTaiKhoan, hoTenCtrl.text, ...);
              _showSnack('Đã cập nhật thông tin ${hoTenCtrl.text}');
              _refreshUsers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Lưu',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Hộp thoại xác nhận xóa ─────────────────────────────
  void _showDeleteConfirm(AdminUserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.red, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Xác nhận xóa',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
            children: [
              const TextSpan(text: 'Bạn có chắc muốn xóa tài khoản của\n'),
              TextSpan(
                text: '"${user.hoTen}"',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              const TextSpan(
                  text: ' không?\n\nHành động này không thể hoàn tác.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // TODO: gọi API xóa tài khoản
              // bool ok = await _controller.deleteUser(user.idTaiKhoan);
              _showSnack('Đã xóa tài khoản ${user.hoTen}');
              _refreshUsers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Top bar ──────────────────────────────────────
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(child: _searchField()),
              const SizedBox(width: 12),
              _filterButton(),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.border),

        // ── Badge lọc đang active ─────────────────────────
        if (_filterStatus != 'all')
          Container(
            color: AppColors.primaryLight,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Đang lọc: ${_filterStatus == 'active' ? 'Hoạt động' : 'Bị khóa'}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _filterStatus = 'all'),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.primary),
                ),
              ],
            ),
          ),

        // ── Danh sách ────────────────────────────────────
        Expanded(
          child: FutureBuilder<List<AdminUserModel>>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 12),
                      Text('Lỗi: ${snapshot.error}',
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refreshUsers,
                        icon: const Icon(Icons.refresh_rounded,
                            size: 16),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline_rounded,
                          color: AppColors.textMuted, size: 48),
                      SizedBox(height: 12),
                      Text('Không có người dùng nào.',
                          style:
                              TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }

              // Áp dụng tìm kiếm + lọc
              final filtered = snapshot.data!.where((u) {
                final matchSearch =
                    u.hoTen.toLowerCase().contains(_search.toLowerCase()) ||
                    u.email.toLowerCase().contains(_search.toLowerCase());
                final matchFilter = _filterStatus == 'all'
                    ? true
                    : _filterStatus == 'active'
                        ? u.trangThai == true
                        : u.trangThai == false;
                return matchSearch && matchFilter;
              }).toList();

              return Column(
                children: [
                  // Số lượng kết quả
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Row(
                      children: [
                        Text('${filtered.length} người dùng',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontSize: 16)),
                      ],
                    ),
                  ),

                  // Danh sách
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => _refreshUsers(),
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text('Không tìm thấy kết quả.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)))
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) => _UserCard(
                                user: filtered[i],
                                onStatusChanged: () async {
                                  final ok = await _controller
                                      .toggleUserStatus(
                                          filtered[i].idTaiKhoan);
                                  if (ok) {
                                    _showSnack(
                                        'Đã cập nhật trạng thái tài khoản');
                                    _refreshUsers();
                                  } else {
                                    _showSnack('Thao tác thất bại',
                                        isError: true);
                                  }
                                },
                                onEdit: () =>
                                    _showEditDialog(filtered[i]),
                                onDelete: () =>
                                    _showDeleteConfirm(filtered[i]),
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        decoration: const InputDecoration(
          hintText: 'Tìm theo tên hoặc Email...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _filterButton() {
    final isActive = _filterStatus != 'all';
    return GestureDetector(
      onTap: _showFilterDialog,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list_rounded,
                size: 18,
                color: isActive ? Colors.white : AppColors.primary),
            const SizedBox(width: 6),
            Text('Lọc',
                style: TextStyle(
                    color: isActive ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            if (isActive) ...[
              const SizedBox(width: 4),
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// USER CARD
// ─────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = user.trangThai;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryLight
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  user.hoTen.isNotEmpty
                      ? user.hoTen[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? AppColors.primary
                          : Colors.grey,
                      fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.hoTen,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(user.email,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    user.viTriUngTuyen.isNotEmpty
                        ? user.viTriUngTuyen
                        : 'Chưa cập nhật',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Các nút hành động
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Badge trạng thái (bấm để toggle)
                GestureDetector(
                  onTap: onStatusChanged,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryLight
                          : AppColors.redLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? 'Hoạt động' : 'Bị khóa',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Nút Sửa + Xóa
                Row(
                  children: [
                    _IconBtn(
                      icon: Icons.edit_rounded,
                      color: AppColors.primary,
                      bg: AppColors.primaryLight,
                      onTap: onEdit,
                      tooltip: 'Chỉnh sửa',
                    ),
                    const SizedBox(width: 6),
                    _IconBtn(
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.red,
                      bg: AppColors.redLight,
                      onTap: onDelete,
                      tooltip: 'Xóa tài khoản',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final VoidCallback onTap;
  final String tooltip;
  const _IconBtn(
      {required this.icon,
      required this.color,
      required this.bg,
      required this.onTap,
      required this.tooltip});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: color),
          ),
        ),
      );
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  const _EditField(
      {required this.label,
      required this.controller,
      required this.icon,
      this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );
}