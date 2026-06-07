// lib/NTD/views/kham_pha_cv_page.dart
import 'package:flutter/material.dart';
import '../services/ntd_cv_service.dart';
import '../utils/cv_masking.dart';

class KhamPhaCvPage extends StatefulWidget {
  const KhamPhaCvPage({super.key});
  @override
  State<KhamPhaCvPage> createState() => _KhamPhaCvPageState();
}

class _KhamPhaCvPageState extends State<KhamPhaCvPage> {
  final NtdCvService _service = NtdCvService();
  List<Map<String, dynamic>> _cvs = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final list = await _service.getAllPublicCvs();
      setState(() => _cvs = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _cvs;
    final q = _search.toLowerCase();
    return _cvs.where((cv) {
      final vitri = cv['viTriUngTuyen']?.toString().toLowerCase() ?? '';
      final kyNang = cv['kyNang']?.toString().toLowerCase() ?? '';
      final tieuDe = cv['tieuDeCv']?.toString().toLowerCase() ?? '';
      return vitri.contains(q) || kyNang.contains(q) || tieuDe.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.explore, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  const Text('Khám phá ứng viên',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${_cvs.length} CV',
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo vị trí, kỹ năng...',
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
                : _error != null
                    ? _buildError()
                    : _filtered.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: const Color(0xFF00C853),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(14),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _CvFeedCard(
                                cv: _filtered[i],
                                onViewProfile: () => _showProfile(_filtered[i]),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _showProfile(Map<String, dynamic> cv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(cv: cv),
    );
  }

  Widget _buildError() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853)),
            onPressed: _load,
            child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );

  Widget _buildEmpty() => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.people_outline, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Text('Chưa có ứng viên nào', style: TextStyle(color: Colors.grey)),
        ]),
      );
}

// ─── Feed Card ───────────────────────────────────────────────────────────────

class _CvFeedCard extends StatelessWidget {
  const _CvFeedCard({required this.cv, required this.onViewProfile});
  final Map<String, dynamic> cv;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    final hoTen    = cv['hoTen']?.toString() ?? '---';
    final viTri    = cv['viTriUngTuyen']?.toString() ?? 'Chưa cập nhật';
    final tieuDe   = cv['tieuDeCv']?.toString() ?? '';
    final kyNang   = cv['kyNang']?.toString() ?? '';
    final mucTieu  = cv['mucTieu']?.toString() ?? '';
    final ngayTao  = cv['ngayTao']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header — avatar + info + mask badge
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              _Avatar(name: hoTen),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(hoTen,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      // Masked badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(children: [
                          Icon(Icons.lock_outline, size: 11, color: Color(0xFFF57C00)),
                          SizedBox(width: 3),
                          Text('Đã ẩn', style: TextStyle(fontSize: 10, color: Color(0xFFF57C00))),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 3),
                    Text(viTri, style: const TextStyle(color: Color(0xFF00C853), fontSize: 13, fontWeight: FontWeight.w500)),
                    if (tieuDe.isNotEmpty)
                      Text(tieuDe, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ]),
          ),

          // Mục tiêu
          if (mucTieu.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                mucTieu,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
            ),

          // Kỹ năng chips
          if (kyNang.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: kyNang
                    .split(',')
                    .take(5)
                    .map((s) => _SkillChip(s.trim()))
                    .toList(),
              ),
            ),

          const SizedBox(height: 10),
          const Divider(height: 1),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              if (ngayTao != null) ...[
                const Icon(Icons.access_time, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(_formatDate(ngayTao),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00C853),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: onViewProfile,
                icon: const Icon(Icons.person_outline, size: 16),
                label: const Text('Xem hồ sơ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
    } catch (_) { return iso; }
  }
}

// ─── Profile Bottom Sheet ─────────────────────────────────────────────────────

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({required this.cv});
  final Map<String, dynamic> cv;

  @override
  Widget build(BuildContext context) {
    final hoTen   = cv['hoTen']?.toString() ?? '---';
    final viTri   = cv['viTriUngTuyen']?.toString() ?? '';
    final email   = cv['email']?.toString() ?? '---';
    final sdt     = cv['soDienThoai']?.toString() ?? '---';
    final diaChi  = cv['diaChi']?.toString() ?? '---';
    final kyNang  = cv['kyNang']?.toString() ?? '';
    final hocVan  = cv['hocVan']?.toString() ?? '';
    final kinhNghiem = cv['kinhNghiem']?.toString() ?? '';
    final mucTieu = cv['mucTieu']?.toString() ?? '';
    final chungChi = cv['chungChi']?.toString() ?? '';
    final hoatDong = cv['hoatDong']?.toString() ?? '';

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 10),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

          // Gradient header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF43A047)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(children: [
              _Avatar(name: hoTen, radius: 36, fontSize: 22),
              const SizedBox(height: 10),
              Text(hoTen, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (viTri.isNotEmpty)
                Text(viTri, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              // Mask notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.shield_outlined, size: 13, color: Colors.white70),
                  SizedBox(width: 5),
                  Text('Thông tin cá nhân đã được bảo vệ',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
              ),
            ]),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin cá nhân (đã mask)
                  _sectionTitle('Thông tin liên hệ'),
                  _maskedInfoRow(Icons.phone_outlined, 'Điện thoại', sdt),
                  _maskedInfoRow(Icons.email_outlined, 'Email', email),
                  _maskedInfoRow(Icons.location_on_outlined, 'Địa chỉ', diaChi),
                  const SizedBox(height: 8),

                  if (mucTieu.isNotEmpty) ...[
                    _sectionTitle('Mục tiêu nghề nghiệp'),
                    _contentBox(mucTieu),
                  ],
                  if (kyNang.isNotEmpty) ...[
                    _sectionTitle('Kỹ năng'),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: kyNang.split(',').map((s) => _SkillChip(s.trim())).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (hocVan.isNotEmpty) ...[
                    _sectionTitle('Học vấn'),
                    _contentBox(hocVan),
                  ],
                  if (kinhNghiem.isNotEmpty) ...[
                    _sectionTitle('Kinh nghiệm làm việc'),
                    // Hiển thị kinh nghiệm đã mask tên công ty
                    _contentBox(CvMasking.maskKinhNghiem(kinhNghiem)),
                  ],
                  if (chungChi.isNotEmpty) ...[
                    _sectionTitle('Chứng chỉ'),
                    _contentBox(chungChi),
                  ],
                  if (hoatDong.isNotEmpty) ...[
                    _sectionTitle('Hoạt động'),
                    _contentBox(hoatDong),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
      );

  Widget _maskedInfoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14)),
            ]),
          ),
          const Icon(Icons.lock, size: 12, color: Color(0xFFBDBDBD)),
        ]),
      );

  Widget _contentBox(String text) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5)),
      );
}

// ─── Shared widgets ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.radius = 24, this.fontSize = 15});
  final String name;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ');
    final initials = parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF00C853),
      child: Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize)),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF00C853))),
      );
}