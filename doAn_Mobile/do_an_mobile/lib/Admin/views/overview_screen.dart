import 'package:do_an_mobile/Admin/models/admin_overview_model.dart';
import 'package:do_an_mobile/Admin/services/admin_overview_service.dart';
import 'package:do_an_mobile/Admin/utils/app_colors.dart';
import 'package:flutter/material.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final AdminOverviewService _service = AdminOverviewService();
  AdminOverviewModel? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchThongKe();
      if (mounted) setState(() => _data = data);
    } catch (e) {
      if (mounted)
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
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

    final d = _data!;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatGrid(context, d),
            const SizedBox(height: 28),
            _buildSystemStatus(d),
            const SizedBox(height: 28),
            _buildTinTheoTrangThai(d),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────
  Widget _buildHeader() {
    final now = DateTime.now();
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, Admin 👋',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5),
              ),
              SizedBox(height: 4),
              Text(
                'Đây là tổng quan hệ thống hôm nay',
                style:
                    TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Tháng ${now.month}, ${now.year}',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stat Grid ───────────────────────────────────────────
  Widget _buildStatGrid(BuildContext context, AdminOverviewModel d) {
    final double w = MediaQuery.of(context).size.width;
    final int cols = w >= 1100 ? 4 : (w >= 700 ? 2 : 1);

    final cards = [
      _StatCardData(
        title: 'Người tìm việc',
        value: '${d.tongNguoiDung}',
        icon: Icons.people_alt_rounded,
        color: AppColors.blue,
        bgColor: AppColors.blueLight,
      ),
      _StatCardData(
        title: 'Nhà tuyển dụng',
        value: '${d.tongNhaTuyenDung}',
        icon: Icons.business_rounded,
        color: AppColors.orange,
        bgColor: AppColors.orangeLight,
      ),
      _StatCardData(
        title: 'Tin tuyển dụng',
        value: '${d.tongTinTuyenDung}',
        icon: Icons.work_rounded,
        color: AppColors.primary,
        bgColor: AppColors.primaryLight,
      ),
      _StatCardData(
        title: 'CV đã tạo',
        value: '${d.tongCv}',
        icon: Icons.description_rounded,
        color: AppColors.purple,
        bgColor: AppColors.purpleLight,
      ),
      _StatCardData(
        title: 'Lượt ứng tuyển',
        value: '${d.tongUngTuyen}',
        icon: Icons.send_rounded,
        color: AppColors.primary,
        bgColor: AppColors.primaryLight,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.9,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) => _StatCard(data: cards[i]),
    );
  }

  // ── System Status ────────────────────────────────────────
  Widget _buildSystemStatus(AdminOverviewModel d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tình trạng hệ thống',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _StatusRow(
                label: 'NTD chờ phê duyệt',
                value: '${d.ntdChoDuyet} hồ sơ',
                color: d.ntdChoDuyet > 0 ? AppColors.orange : AppColors.primary,
              ),
              _divider(),
              _StatusRow(
                label: 'Tin chờ phê duyệt',
                value: '${d.tinChoDuyet} tin',
                color: d.tinChoDuyet > 0 ? AppColors.orange : AppColors.primary,
              ),
              _divider(),
              _StatusRow(
                label: 'Tổng lượt ứng tuyển',
                value: '${d.tongUngTuyen} lượt',
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tin theo trạng thái ──────────────────────────────────
  Widget _buildTinTheoTrangThai(AdminOverviewModel d) {
    if (d.tinTheoTrangThai.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tin tuyển dụng theo trạng thái',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: d.tinTheoTrangThai.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final colors = [
                AppColors.primary,
                AppColors.orange,
                AppColors.red,
                AppColors.blue,
              ];
              final color = colors[i % colors.length];
              return Column(
                children: [
                  if (i > 0) _divider(),
                  _StatusRow(
                    label: item.trangThai,
                    value: '${item.soLuong} tin',
                    color: color,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
        height: 1,
        color: AppColors.borderLight,
        margin: const EdgeInsets.symmetric(horizontal: 20),
      );
}

// ─────────────────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────────────────
class _StatCardData {
  final String title, value;
  final IconData icon;
  final Color color, bgColor;
  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;
  const _StatCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(data.icon, size: 20, color: data.color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 2),
              Text(
                data.title,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STATUS ROW
// ─────────────────────────────────────────────────────────
class _StatusRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatusRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      );
}