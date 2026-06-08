import 'package:do_an_mobile/Admin/models/admin_job_model.dart';
import 'package:do_an_mobile/Admin/services/admin_job_service.dart';
import 'package:do_an_mobile/Admin/utils/app_colors.dart';
import 'package:flutter/material.dart';

class JobPostManagementScreen extends StatefulWidget {
  const JobPostManagementScreen({super.key});

  @override
  State<JobPostManagementScreen> createState() =>
      _JobPostManagementScreenState();
}

class _JobPostManagementScreenState extends State<JobPostManagementScreen> {
  final AdminJobService _service = AdminJobService();
  final TextEditingController _searchController = TextEditingController();

  List<AdminJobModel> _list = [];
  bool _isLoading = true;
  String? _error;
  String _selectedTrangThai = ''; // '' = tất cả

  final List<Map<String, String>> _filterOptions = [
    {'label': 'Tất cả', 'value': ''},
    {'label': 'Đang tuyển', 'value': 'Đang tuyển'},
    {'label': 'Chờ duyệt', 'value': 'Chờ duyệt'},
    {'label': 'Đã đóng', 'value': 'Đã đóng'},
    {'label': 'Từ chối', 'value': 'Từ chối'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchJobs(
        trangThai: _selectedTrangThai.isEmpty ? null : _selectedTrangThai,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      if (mounted) setState(() => _list = data);
    } catch (e) {
      if (mounted)
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.red : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _handleDelete(AdminJobModel job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Bạn có chắc muốn xóa tin "${job.tieuDe}" không?',
            style: const TextStyle(color: AppColors.textSecondary)),
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
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await _service.deleteTin(job.idTin);
      if (mounted) {
        if (ok) {
          setState(() => _list.removeWhere((j) => j.idTin == job.idTin));
          _showSnack('Đã xóa tin tuyển dụng');
        } else {
          _showSnack('Không thể xóa tin', isError: true);
        }
      }
    }
  }

  Future<void> _handleUpdateTrangThai(AdminJobModel job, String trangThai) async {
    final ok = await _service.updateTrangThai(job.idTin, trangThai);
    if (mounted) {
      if (ok) {
        setState(() {
          final idx = _list.indexWhere((j) => j.idTin == job.idTin);
          if (idx != -1) {
            _list[idx] = AdminJobModel(
              idTin: job.idTin,
              tieuDe: job.tieuDe,
              diaDiem: job.diaDiem,
              mucLuong: job.mucLuong,
              hinhThuc: job.hinhThuc,
              nganhNghe: job.nganhNghe,
              hanNop: job.hanNop,
              trangThai: trangThai,
              ngayDang: job.ngayDang,
              tenCongTy: job.tenCongTy,
              logoCongTy: job.logoCongTy,
            );
          }
        });
        _showSnack('Đã cập nhật trạng thái');
      } else {
        _showSnack('Không thể cập nhật', isError: true);
      }
    }
  }

  void _showEditDialog(AdminJobModel job) {
    final tieuDeCtrl = TextEditingController(text: job.tieuDe);
    final mucLuongCtrl = TextEditingController(text: job.mucLuong ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chỉnh sửa tin tuyển dụng',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Tiêu đề tin',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              _inputField(controller: tieuDeCtrl),
              const SizedBox(height: 14),

              const Text('Mức lương',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              _inputField(
                  controller: mucLuongCtrl,
                  hintText: 'VD: 10-15 triệu'),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _dialogBtn('Hủy',
                        onTap: () => Navigator.pop(ctx),
                        isPrimary: false),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dialogBtn('Lưu thay đổi',
                        onTap: () async {
                          Navigator.pop(ctx);
                          final ok = await _service.updateTin(
                            job.idTin,
                            tieuDe: tieuDeCtrl.text,
                            mucLuong: mucLuongCtrl.text,
                          );
                          if (mounted) {
                            if (ok) {
                              _loadData();
                              _showSnack('Đã cập nhật tin tuyển dụng');
                            } else {
                              _showSnack('Không thể cập nhật', isError: true);
                            }
                          }
                        },
                        isPrimary: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrangThaiDialog(AdminJobModel job) {
    final options = ['Đang tuyển', 'Chờ duyệt', 'Đã đóng', 'Từ chối'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cập nhật trạng thái',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final isSelected = job.trangThai == opt;
            return ListTile(
              onTap: () {
                Navigator.pop(ctx);
                if (!isSelected) _handleUpdateTrangThai(job, opt);
              },
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              title: Text(opt,
                  style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400)),
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Top bar ──────────────────────────────────
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            children: [
              // Search
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _loadData(),
                  decoration: const InputDecoration(
                    hintText: 'Tìm tiêu đề hoặc tên công ty...',
                    hintStyle:
                        TextStyle(color: AppColors.textMuted, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _filterOptions.map((opt) {
                    final isSelected = _selectedTrangThai == opt['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(
                              () => _selectedTrangThai = opt['value']!);
                          _loadData();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            opt['label']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.border),

        // ── Content ──────────────────────────────────
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
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
    if (_list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_off_rounded,
                color: AppColors.textMuted, size: 48),
            SizedBox(height: 12),
            Text('Không có tin tuyển dụng nào',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _JobCard(
          job: _list[i],
          onEdit: () => _showEditDialog(_list[i]),
          onDelete: () => _handleDelete(_list[i]),
          onUpdateTrangThai: () => _showTrangThaiDialog(_list[i]),
        ),
      ),
    );
  }

  Widget _inputField(
      {TextEditingController? controller,
      int maxLines = 1,
      String? hintText}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _dialogBtn(String label,
      {required VoidCallback onTap, required bool isPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          border: isPrimary ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    isPrimary ? Colors.white : AppColors.textSecondary,
              )),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// JOB CARD
// ─────────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final AdminJobModel job;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUpdateTrangThai;

  const _JobCard({
    required this.job,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdateTrangThai,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Đang tuyển':
        return AppColors.primary;
      case 'Chờ duyệt':
        return AppColors.orange;
      case 'Đã đóng':
        return AppColors.textMuted;
      case 'Từ chối':
        return AppColors.red;
      default:
        return AppColors.textMuted;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Đang tuyển':
        return AppColors.primaryLight;
      case 'Chờ duyệt':
        return AppColors.orangeLight;
      case 'Đã đóng':
        return AppColors.borderLight;
      case 'Từ chối':
        return AppColors.redLight;
      default:
        return AppColors.borderLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.work_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.tieuDe,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      if (job.tenCongTy != null && job.tenCongTy!.isNotEmpty)
                        Text(job.tenCongTy!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                    ],
                  ),
                ),

                // Menu
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'status') onUpdateTrangThai();
                    if (v == 'delete') onDelete();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded,
                              size: 16, color: AppColors.blue),
                          SizedBox(width: 8),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'status',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz_rounded,
                              size: 16, color: AppColors.orange),
                          SizedBox(width: 8),
                          Text('Đổi trạng thái'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_rounded,
                              size: 16, color: AppColors.red),
                          SizedBox(width: 8),
                          Text('Xóa tin',
                              style: TextStyle(color: AppColors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.more_vert_rounded,
                        size: 18, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 10),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // Trạng thái
                GestureDetector(
                  onTap: onUpdateTrangThai,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg(job.trangThai),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(job.trangThai,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(job.trangThai))),
                  ),
                ),
                if (job.diaDiem != null && job.diaDiem!.isNotEmpty)
                  _Tag(Icons.location_on_outlined, job.diaDiem!),
                if (job.mucLuong != null && job.mucLuong!.isNotEmpty)
                  _Tag(Icons.attach_money_rounded, job.mucLuong!),
                if (job.hinhThuc != null && job.hinhThuc!.isNotEmpty)
                  _Tag(Icons.work_outline_rounded, job.hinhThuc!),
              ],
            ),

            if (job.ngayDang != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 11, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'ID: #${job.idTin}  •  ${_formatDate(job.ngayDang!)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tag(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(text,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      );
}