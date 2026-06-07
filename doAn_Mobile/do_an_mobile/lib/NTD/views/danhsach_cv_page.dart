// lib/NTD/views/danhsach_cv_page.dart
//
// THAY THẾ HOÀN TOÀN file cũ tại: do_an_mobile/lib/NTD/views/danhsach_cv_page.dart
 
import 'package:do_an_mobile/NTD/services/ntd_cv_service.dart';
import 'package:flutter/material.dart';

 
class DanhSachCvPage extends StatefulWidget {
  /// idTinTuyenDung truyền từ trangchu_ntd.dart khi bấm "Quản lý CV"
  /// Nếu chưa có id thật, mặc định = 0 để test
  final int idTinTuyenDung;
 
  const DanhSachCvPage({super.key, this.idTinTuyenDung = 0});
 
  @override
  State<DanhSachCvPage> createState() => _DanhSachCvPageState();
}
 
class _DanhSachCvPageState extends State<DanhSachCvPage> {
  final NtdCvService _service = NtdCvService();
 
  List<Map<String, dynamic>> _allCvs = [];
  Map<String, dynamic>? _selectedCv;
  bool _isLoading = true;
  String? _error;
 
  // Tab filter
  static const _tabs = ['Tất cả', 'Mới', 'Phỏng vấn', 'Đạt', 'Đã loại'];
  int _tabIndex = 0;
 
  @override
  void initState() {
    super.initState();
    _loadCvs();
  }
 
  Future<void> _loadCvs() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final list = await _service.getCvsByTinTuyenDung(widget.idTinTuyenDung);
      setState(() => _allCvs = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
 
  List<Map<String, dynamic>> get _filtered {
    if (_tabIndex == 0) return _allCvs;
    final statusMap = {1: 'Mới', 2: 'Phỏng vấn', 3: 'Đạt', 4: 'Đã loại'};
    return _allCvs
        .where((cv) => cv['trangThaiUngTuyen'] == statusMap[_tabIndex])
        .toList();
  }
 
  void _selectCv(Map<String, dynamic> cv) async {
    setState(() => _selectedCv = cv);
    try {
      final idCv = int.tryParse(cv['idCv']?.toString() ?? '');
      if (idCv != null) {
        final detail = await _service.getCvById(idCv);
        if (mounted) setState(() => _selectedCv = detail);
      }
    } catch (_) {}
  }
 
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Quản lý Hồ sơ CV',
              style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF009688)]),
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: _tabs
                .map((t) => Tab(
                      text: t == 'Tất cả'
                          ? '$t (${_allCvs.length})'
                          : '$t (${_allCvs.where((cv) => cv['trangThaiUngTuyen'] == t).length})',
                    ))
                .toList(),
            onTap: (i) => setState(() { _tabIndex = i; _selectedCv = null; }),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }
 
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)));
    }
    if (_error != null) {
      return _ErrorView(error: _error!, onRetry: _loadCvs);
    }
 
    final isWide = MediaQuery.of(context).size.width >= 700;
 
    if (isWide && _selectedCv != null) {
      // Layout tablet: danh sách | chi tiết
      return Row(
        children: [
          Expanded(flex: 5, child: _buildList()),
          Container(
            width: 360,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: _CvDetailPanel(
              cv: _selectedCv!,
              onClose: () => setState(() => _selectedCv = null),
            ),
          ),
        ],
      );
    }
 
    return Stack(
      children: [
        _buildList(),
        if (_selectedCv != null)
          _CvDetailModal(
            cv: _selectedCv!,
            onClose: () => setState(() => _selectedCv = null),
          ),
      ],
    );
  }
 
  Widget _buildList() {
    final cvs = _filtered;
    if (cvs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Chưa có hồ sơ nào', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
 
    return RefreshIndicator(
      onRefresh: _loadCvs,
      color: const Color(0xFF00C853),
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: cvs.length,
        itemBuilder: (context, index) {
          final cv = cvs[index];
          return _CvCard(
            cv: cv,
            isSelected: _selectedCv?['idCv'] == cv['idCv'],
            onTap: () => _selectCv(cv),
          );
        },
      ),
    );
  }
}
 
// ─── CV Card ────────────────────────────────────────────────────────────────
 
class _CvCard extends StatelessWidget {
  const _CvCard({required this.cv, required this.onTap, this.isSelected = false});
 
  final Map<String, dynamic> cv;
  final VoidCallback onTap;
  final bool isSelected;
 
  @override
  Widget build(BuildContext context) {
    final hoTen = cv['hoTen']?.toString() ?? '---';
    final viTri = cv['viTriUngTuyen']?.toString() ?? 'Chưa cập nhật';
    final kyNang = cv['kyNang']?.toString() ?? '';
    final trangThai = cv['trangThaiUngTuyen']?.toString() ?? 'Mới';
    final ngayTao = cv['ngayTao']?.toString();
    final statusColor = _statusColor(trangThai);
 
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C853) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar initials
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF00C853),
                    child: Text(
                      _initials(hoTen),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hoTen,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            // Masked icon
                            const Icon(Icons.lock_outline,
                                size: 13, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(viTri,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(trangThai,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              // Kỹ năng chips
              if (kyNang.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: kyNang
                      .split(',')
                      .take(4)
                      .map((s) => _SkillChip(label: s.trim()))
                      .toList(),
                ),
              ],
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (ngayTao != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(_formatDate(ngayTao),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00C853),
                      side: const BorderSide(color: Color(0xFF00C853)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onTap,
                    child: const Text('Chi tiết & Đánh giá CV',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Color _statusColor(String status) {
    return switch (status) {
      'Đạt' => Colors.green,
      'Phỏng vấn' => Colors.blue,
      'Đã loại' => Colors.red,
      _ => Colors.orange,
    };
  }
 
  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    return parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
  }
 
  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
 
// ─── Detail Panel (tablet) ──────────────────────────────────────────────────
 
class _CvDetailPanel extends StatelessWidget {
  const _CvDetailPanel({required this.cv, required this.onClose});
  final Map<String, dynamic> cv;
  final VoidCallback onClose;
 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
          ),
          child: Row(
            children: [
              const Text('Chi tiết hồ sơ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),
        ),
        Expanded(child: _CvDetailContent(cv: cv)),
      ],
    );
  }
}
 
// ─── Detail Modal (mobile) ──────────────────────────────────────────────────
 
class _CvDetailModal extends StatelessWidget {
  const _CvDetailModal({required this.cv, required this.onClose});
  final Map<String, dynamic> cv;
  final VoidCallback onClose;
 
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black45,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(child: _CvDetailContent(cv: cv)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 
// ─── Detail Content — dùng chung cho panel và modal ─────────────────────────
 
class _CvDetailContent extends StatefulWidget {
  const _CvDetailContent({required this.cv});
  final Map<String, dynamic> cv;
 
  @override
  State<_CvDetailContent> createState() => _CvDetailContentState();
}
 
class _CvDetailContentState extends State<_CvDetailContent> {
  int _tab = 0;
  int _rating = 0;
  final TextEditingController _noteCtrl = TextEditingController();
 
  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final cv = widget.cv;
    final hoTen = cv['hoTen']?.toString() ?? '---';
    final viTri = cv['viTriUngTuyen']?.toString() ?? '';
    final email = cv['email']?.toString() ?? '---';
    final sdt = cv['soDienThoai']?.toString() ?? '---';
    final tieuDe = cv['tieuDeCv']?.toString() ?? 'CV';
 
    return Column(
      children: [
        // Header gradient
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF009688)]),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white24,
                child: Text(
                  _initials(hoTen),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(hoTen,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              if (viTri.isNotEmpty)
                Text(viTri,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(tieuDe,
                  style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
 
        // Tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _tabBtn('Chi tiết CV', 0),
            _tabBtn('Ghi chú & Đánh giá', 1),
            _tabBtn('File đính kèm', 2),
          ],
        ),
 
        // Tab content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: [
              _buildDetailTab(cv, email, sdt),
              _buildRatingTab(),
              _buildFileTab(hoTen),
            ][_tab],
          ),
        ),
 
        // Action buttons
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.shade200, blurRadius: 10,
                  offset: const Offset(0, -2))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () => _showSnack('Đã chuyển CV vào danh sách loại!'),
                  child: const Text('TỪ CHỐI',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () =>
                      _showSnack('Đã lưu và gửi email hẹn lịch!', success: true),
                  child: const Text('HẸN PHỎNG VẤN',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
 
  Widget _buildDetailTab(Map<String, dynamic> cv, String email, String sdt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Masked contact + lock indicator
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: const [
              Icon(Icons.lock_outline, size: 14, color: Color(0xFFF57C00)),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Thông tin cá nhân đã được ẩn. Liên hệ qua hệ thống để trao đổi.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
                ),
              ),
            ],
          ),
        ),
        _infoRow(Icons.phone_outlined, 'Điện thoại', sdt),
        _infoRow(Icons.email_outlined, 'Email', email),
        _infoRow(Icons.location_on_outlined, 'Địa chỉ',
            cv['diaChi']?.toString() ?? '---'),
 
        if (_isNotEmpty(cv['mucTieu']))
          _section('Mục tiêu nghề nghiệp', cv['mucTieu']),
        if (_isNotEmpty(cv['kyNang']))
          _section('Kỹ năng', cv['kyNang']),
        if (_isNotEmpty(cv['hocVan']))
          _section('Học vấn', '${cv['hocVan']}${_isNotEmpty(cv['moTaHocVan']) ? "\n${cv['moTaHocVan']}" : ""}'),
        if (_isNotEmpty(cv['kinhNghiem']))
          _section('Kinh nghiệm làm việc', cv['kinhNghiem']),
        if (_isNotEmpty(cv['chungChi']))
          _section('Chứng chỉ', cv['chungChi']),
        if (_isNotEmpty(cv['hoatDong']))
          _section('Hoạt động', cv['hoatDong']),
      ],
    );
  }
 
  Widget _buildRatingTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Đánh giá của HR',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            5,
            (i) => IconButton(
              icon: Icon(
                i < _rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 30,
              ),
              onPressed: () => setState(() => _rating = i + 1),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Nhập ghi chú nội bộ về ứng viên này...',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              _showSnack('Đã lưu ghi chú nội bộ!');
            },
            child: const Text('Lưu Ghi Chú',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
 
  Widget _buildFileTab(String hoTen) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 56, color: Colors.red),
          const SizedBox(height: 10),
          Text('CV_${hoTen.replaceAll(' ', '_')}.pdf',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800]),
            onPressed: () => _showSnack('Đang tải file PDF...'),
            icon: const Icon(Icons.file_download,
                color: Colors.white, size: 18),
            label: const Text('Tải file CV',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
 
  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFF00C853) : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (active)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 36,
                color: const Color(0xFF00C853),
              ),
          ],
        ),
      ),
    );
  }
 
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.lock, size: 12, color: Color(0xFFBDBDBD)),
        ],
      ),
    );
  }
 
  Widget _section(String title, dynamic content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content.toString(),
              style: const TextStyle(fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
 
  bool _isNotEmpty(dynamic val) =>
      val != null && val.toString().trim().isNotEmpty;
 
  String _initials(String name) {
    final parts = name.trim().split(' ');
    return parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
  }
 
  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : null,
    ));
  }
}
 
// ─── Widgets phụ ────────────────────────────────────────────────────────────
 
class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});
  final String label;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF00C853))),
    );
  }
}
 
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            Text('Không thể tải dữ liệu',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 6),
            Text(error,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853)),
              onPressed: onRetry,
              child: const Text('Thử lại',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
 