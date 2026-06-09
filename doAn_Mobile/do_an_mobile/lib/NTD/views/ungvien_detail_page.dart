import 'package:flutter/material.dart';
import '../services/invitation_service.dart';

class UngVienDetailPage extends StatefulWidget {
  final Map<String, dynamic> cv;
  const UngVienDetailPage({super.key, required this.cv});

  @override
  State<UngVienDetailPage> createState() => _UngVienDetailPageState();
}

class _UngVienDetailPageState extends State<UngVienDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cv = widget.cv;
    final hoTen = cv['hoTen']?.toString() ?? '---';
    final viTri = cv['viTriUngTuyen']?.toString() ?? 'Chưa cập nhật';
    final kyNang = cv['kyNang']?.toString() ?? '';
    final kinhNghiem = cv['kinhNghiem']?.toString() ?? '';
    final idCv = cv['idCv']?.toString() ?? cv['id_cv']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Chi tiết Hồ sơ',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        tooltip: 'Gửi lời mời',
                        onPressed: () => _sendInvitation(idCv, hoTen, viTri),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      _Avatar(name: hoTen, radius: 40, fontSize: 24),
                      const SizedBox(height: 10),
                      Text(hoTen,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(viTri,
                          style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.shield_outlined, size: 14, color: Color(0xFFF57C00)),
                          SizedBox(width: 5),
                          Text('Thông tin cá nhân đã được bảo vệ',
                              style: TextStyle(color: Color(0xFFF57C00), fontSize: 11)),
                        ]),
                      ),
                      if (kyNang.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: kyNang.split(',').take(6).map((s) => _SkillChip(s.trim())).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF1B5E20),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF00C853),
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        tabs: const [
                          Tab(text: 'Công ty đã ứng tuyển'),
                          Tab(text: 'Kinh nghiệm'),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(children: [
                                Icon(Icons.lock, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text('Không có quyền xem mục này'),
                              ]),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          color: Colors.grey[100],
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              const Text(
                                'Lời mời từ nhà tuyển dụng',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('Bị vô hiệu hóa',
                                    style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCompaniesTab(cv),
                      _buildExperienceTab(kinhNghiem),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _sendInvitation(idCv, hoTen, viTri),
            icon: const Icon(Icons.send),
            label: const Text('Gửi lời mời ứng viên',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildCompaniesTab(Map<String, dynamic> cv) {
    final companies = _parseCompanies(cv);

    if (companies.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.business_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Chưa có thông tin ứng tuyển', style: TextStyle(color: Colors.grey)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: companies.length,
      itemBuilder: (_, i) {
        final company = companies[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business, color: Colors.green, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company['ten'] ?? 'Công ty',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if ((company['viTri'] ?? '').isNotEmpty)
                    Text(company['viTri']!, style: const TextStyle(color: Colors.green, fontSize: 13)),
                  if ((company['thoiGian'] ?? '').isNotEmpty)
                    Text(company['thoiGian']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  List<Map<String, String>> _parseCompanies(Map<String, dynamic> cv) {
    final raw = cv['congTyDaUngTuyen']?.toString() ?? cv['kinhNghiem']?.toString() ?? '';
    if (raw.isEmpty) return [];

    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.take(5).map((line) => {
      'ten': line.trim(),
      'viTri': cv['viTriUngTuyen']?.toString() ?? '',
      'thoiGian': '',
    }).toList();
  }

  Widget _buildExperienceTab(String kinhNghiem) {
    if (kinhNghiem.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.history_edu_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Chưa có kinh nghiệm làm việc', style: TextStyle(color: Colors.grey)),
        ]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.work_history, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Kinh nghiệm làm việc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            ]),
            const SizedBox(height: 12),
            Text(kinhNghiem, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Future<void> _sendInvitation(String idCv, String hoTen, String viTri) async {
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

    if (confirmed != true || !mounted) return;

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
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

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
