// lib/NTD/views/kham_pha_cv_page.dart
import 'package:flutter/material.dart';
import '../services/ntd_cv_service.dart';
import '../services/invitation_service.dart';
import 'ungvien_detail_page.dart';

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
                                onViewProfile: () => _goToProfile(_filtered[i]),
                                onSendInvitation: () => _sendInvitation(_filtered[i]),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _goToProfile(Map<String, dynamic> cv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UngVienDetailPage(cv: cv),
      ),
    );
  }

  Future<void> _sendInvitation(Map<String, dynamic> cv) async {
    final hoTen = cv['hoTen']?.toString() ?? 'Ứng viên';
    final viTri = cv['viTriUngTuyen']?.toString() ?? 'Chưa cập nhật';
    final idCv = cv['idCv']?.toString() ?? cv['id_cv']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Show dialog xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(children: [
          Icon(Icons.send, color: Colors.green),
          SizedBox(width: 8),
          Text('Gửi lời mời', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn muốn gửi lời mời đến:', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(hoTen, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(viTri, style: const TextStyle(color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Gửi lời mời', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await InvitationService.sendInvitation(
        idCv: idCv,
        hoTen: hoTen,
        viTri: viTri,
        companyName: 'Công ty của bạn',
        jobTitle: viTri,
        salary: 'Thỏa thuận',
        location: 'Hồ Chí Minh',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Đã gửi lời mời đến $hoTen!'),
          ]),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi lời mời: $e'), backgroundColor: Colors.red),
      );
    }
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
  const _CvFeedCard({
    required this.cv,
    required this.onViewProfile,
    required this.onSendInvitation,
  });
  final Map<String, dynamic> cv;
  final VoidCallback onViewProfile;
  final VoidCallback onSendInvitation;

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
              // Avatar - có thể click để xem profile
              GestureDetector(
                onTap: onViewProfile,
                child: _Avatar(name: hoTen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onViewProfile,
                          child: Text(hoTen,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                                  decoration: TextDecoration.underline, decorationColor: Colors.green),
                          ),
                        ),
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
              // Nút Xem hồ sơ
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00C853),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: onViewProfile,
                icon: const Icon(Icons.person_outline, size: 16),
                label: const Text('Xem hồ sơ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 4),
              // Nút Lời mời ứng viên
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: onSendInvitation,
                icon: const Icon(Icons.send, size: 14),
                label: const Text('Mời', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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