import 'package:do_an_mobile/Admin/controllers/admin_recruiter_controller.dart';
import 'package:do_an_mobile/Admin/models/admin_recruiter_model.dart';
import 'package:do_an_mobile/Admin/utils/app_colors.dart';
import 'package:flutter/material.dart';

class RecruiterManagementScreen extends StatefulWidget {
  const RecruiterManagementScreen({super.key});

  @override
  State<RecruiterManagementScreen> createState() =>
      _RecruiterManagementScreenState();
}

class _RecruiterManagementScreenState extends State<RecruiterManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AdminRecruiterController _controller = AdminRecruiterController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.red : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _handleApprove(AdminRecruiterModel rec) async {
    final msg = await _controller.approveRecruiter(rec.idNtd);
    if (mounted) _showSnack(msg, isError: msg.contains('Không thể'));
  }

  Future<void> _handleReject(AdminRecruiterModel rec) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận từ chối',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Bạn có chắc muốn từ chối hồ sơ của "${rec.tenCongTy}" không?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final msg = await _controller.rejectRecruiter(rec.idNtd);
      if (mounted) _showSnack(msg, isError: msg.contains('Không thể'));
    }
  }

  void _showDetail(AdminRecruiterModel rec) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(rec: rec),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search Bar ──────────────────────────────
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _controller.onSearch(v),
              decoration: const InputDecoration(
                hintText: 'Tìm công ty hoặc email...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // ── TabBar ──────────────────────────────────
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w400),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Chờ phê duyệt'),
                    if (_controller.pendingList.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _Badge(
                          count: _controller.pendingList.length,
                          color: AppColors.orange),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Đã xác thực'),
                    if (_controller.verifiedList.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _Badge(
                          count: _controller.verifiedList.length,
                          color: AppColors.primary),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.border),

        // ── TabBarView ───────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _RecruiterListView(
                isLoading: _controller.isLoadingPending,
                error: _controller.errorPending,
                list: _controller.pendingList,
                isPending: true,
                onRefresh: _controller.loadPending,
                onApprove: _handleApprove,
                onReject: _handleReject,
                onTap: _showDetail,
              ),
              _RecruiterListView(
                isLoading: _controller.isLoadingVerified,
                error: _controller.errorVerified,
                list: _controller.verifiedList,
                isPending: false,
                onRefresh: _controller.loadVerified,
                onApprove: _handleApprove,
                onReject: _handleReject,
                onTap: _showDetail,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// LIST VIEW
// ─────────────────────────────────────────────────────────
class _RecruiterListView extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<AdminRecruiterModel> list;
  final bool isPending;
  final Future<void> Function() onRefresh;
  final Future<void> Function(AdminRecruiterModel) onApprove;
  final Future<void> Function(AdminRecruiterModel) onReject;
  final void Function(AdminRecruiterModel) onTap;

  const _RecruiterListView({
    required this.isLoading,
    required this.error,
    required this.list,
    required this.isPending,
    required this.onRefresh,
    required this.onApprove,
    required this.onReject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(error!,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
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
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPending
                  ? Icons.pending_actions_rounded
                  : Icons.verified_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              isPending
                  ? 'Không có hồ sơ chờ duyệt'
                  : 'Chưa có nhà tuyển dụng nào',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _RecruiterCard(
          rec: list[i],
          isPending: isPending,
          onApprove: () => onApprove(list[i]),
          onReject: () => onReject(list[i]),
          onTap: () => onTap(list[i]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// CARD
// ─────────────────────────────────────────────────────────
class _RecruiterCard extends StatelessWidget {
  final AdminRecruiterModel rec;
  final bool isPending;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onTap;

  const _RecruiterCard({
    required this.rec,
    required this.isPending,
    required this.onApprove,
    required this.onReject,
    required this.onTap,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    if (name.length == 1) return name.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(rec.tenCongTy);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPending ? AppColors.orangeLight : AppColors.border,
            width: isPending ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isPending
                          ? AppColors.orangeLight
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: rec.logo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              rec.logo!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _AvatarText(
                                  text: initials, isPending: isPending),
                            ),
                          )
                        : _AvatarText(text: initials, isPending: isPending),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.tenCongTy.isEmpty ? 'N/A' : rec.tenCongTy,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        if (rec.linhVuc != null && rec.linhVuc!.isNotEmpty)
                          Text(rec.linhVuc!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (!isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Đã xác thực',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 10),

              if (rec.email != null && rec.email!.isNotEmpty)
                _InfoRow(icon: Icons.email_outlined, text: rec.email!),
              if (rec.diaChi != null && rec.diaChi!.isNotEmpty)
                _InfoRow(icon: Icons.location_on_outlined, text: rec.diaChi!),

              // ✅ Row dùng mainAxisSize.min để tránh unconstrained
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InfoRow(
                      icon: Icons.article_outlined,
                      text: '${rec.soTinDang} tin đăng'),
                  if (rec.ngayTao != null) ...[
                    const SizedBox(width: 16),
                    _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        text:
                            '${rec.ngayTao!.day}/${rec.ngayTao!.month}/${rec.ngayTao!.year}'),
                  ],
                ],
              ),

              if (isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Duyệt',
                        icon: Icons.check_rounded,
                        color: AppColors.primary,
                        bg: AppColors.primaryLight,
                        onTap: onApprove,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Từ chối',
                        icon: Icons.close_rounded,
                        color: AppColors.red,
                        bg: AppColors.redLight,
                        onTap: onReject,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// BOTTOM SHEET CHI TIẾT
// ─────────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final AdminRecruiterModel rec;
  const _DetailSheet({required this.rec});

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    if (name.length == 1) return name.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(rec.tenCongTy);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: rec.logo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(rec.logo!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                    child: Text(initials,
                                        style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18)),
                                  )))
                      : Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18)),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rec.tenCongTy.isEmpty ? 'N/A' : rec.tenCongTy,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      if (rec.linhVuc != null && rec.linhVuc!.isNotEmpty)
                        Text(rec.linhVuc!,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: rec.trangThai
                        ? AppColors.primaryLight
                        : AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rec.trangThai ? 'Đã xác thực' : 'Chờ duyệt',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: rec.trangThai
                            ? AppColors.primary
                            : AppColors.orange),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text('Thông tin công ty',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5)),
            const SizedBox(height: 12),

            _DetailRow(
                icon: Icons.tag_rounded,
                label: 'ID',
                value: '#${rec.idNtd}'),
            if (rec.email != null && rec.email!.isNotEmpty)
              _DetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: rec.email!),
            if (rec.soDienThoai != null && rec.soDienThoai!.isNotEmpty)
              _DetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Điện thoại',
                  value: rec.soDienThoai!),
            if (rec.diaChi != null && rec.diaChi!.isNotEmpty)
              _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Địa chỉ',
                  value: rec.diaChi!),
            if (rec.website != null && rec.website!.isNotEmpty)
              _DetailRow(
                  icon: Icons.language_outlined,
                  label: 'Website',
                  value: rec.website!),
            _DetailRow(
                icon: Icons.article_outlined,
                label: 'Số tin đăng',
                value: '${rec.soTinDang} tin'),
            if (rec.ngayTao != null)
              _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Ngày tham gia',
                  value:
                      '${rec.ngayTao!.day}/${rec.ngayTao!.month}/${rec.ngayTao!.year}'),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Đóng',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
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
class _AvatarText extends StatelessWidget {
  final String text;
  final bool isPending;
  const _AvatarText({required this.text, required this.isPending});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(text,
            style: TextStyle(
                color: isPending ? AppColors.orange : AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min, // ✅ fix unconstrained
          children: [
            Icon(icon, size: 13, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, bg;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.bg,
      required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
            ),
          ],
        ),
      );
}

class _Badge extends StatelessWidget {
  final int count;
  final Color color;
  const _Badge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10)),
        child: Text('$count',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      );
}