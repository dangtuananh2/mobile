import 'package:flutter/material.dart';
import 'package:do_an_mobile/NTD/services/invitation_service.dart';
import 'package:do_an_mobile/UngVien/views/trangchu.dart';
import 'package:do_an_mobile/UngVien/views/taikhoan.dart';
import 'package:do_an_mobile/UngVien/views/thongbao.dart';
import 'package:do_an_mobile/UngVien/views/taocv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NTD_UV extends StatefulWidget {
  const NTD_UV({super.key});

  @override
  State<NTD_UV> createState() => _NTD_UVState();
}

class _NTD_UVState extends State<NTD_UV> {
  int currentTab = 0;
  int _currentIndex = 2;

  List<Map<String, dynamic>> _allInvitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String raw = prefs.getString('uv_invitations') ?? '[]';
      final List<dynamic> list = jsonDecode(raw);
      setState(() {
        _allInvitations = list.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _pendingInvitations =>
      _allInvitations.where((inv) => inv['trangThai'] == 'Chờ phản hồi').toList();

  List<Map<String, dynamic>> get _respondedInvitations =>
      _allInvitations.where((inv) => inv['trangThai'] != 'Chờ phản hồi').toList();

  Future<void> _respond(Map<String, dynamic> invitation, String response) async {
    final idCv = invitation['idCv']?.toString() ?? '';
    final hoTen = invitation['hoTen']?.toString() ?? 'Ứng viên';

    try {
      await InvitationService.uvRespondToInvitation(
        idCv: idCv,
        response: response,
        hoTen: hoTen,
      );
      await _loadInvitations();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            Icon(
              response == 'Đồng ý' ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(response == 'Đồng ý'
                ? 'Bạn đã đồng ý lời mời!'
                : 'Bạn đã từ chối lời mời.'),
          ]),
          backgroundColor: response == 'Đồng ý' ? Colors.green : Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lời mời Cơ hội nghề nghiệp",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            onPressed: _loadInvitations,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "Các Nhà tuyển dụng đã ấn tượng và gửi lời mời cho bạn.\nHãy phản hồi để nhận cơ hội tốt hơn.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tabItem("Chờ phản hồi (${_pendingInvitations.length})", 0),
              _tabItem("Đã phản hồi (${_respondedInvitations.length})", 1),
              _tabItem("Quá hạn", 2),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  flex: currentTab == 0 ? 1 : 0,
                  child: Container(color: Colors.green),
                ),
                Expanded(
                  flex: currentTab == 1 ? 1 : 0,
                  child: Container(color: Colors.green),
                ),
                Expanded(
                  flex: currentTab == 2 ? 1 : 0,
                  child: Container(color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : RefreshIndicator(
                    onRefresh: _loadInvitations,
                    color: Colors.green,
                    child: _buildContent(),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TrangChu()),
            );
          }

          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TaoCV()),
            );
          }

          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ThongBao()),
            );
          }

          if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TaiKhoan()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
              icon: Icon(Icons.description), label: "Tạo CV"),
          BottomNavigationBarItem(
              icon: Icon(Icons.group), label: "NTD -> UV"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Thông báo"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (currentTab == 0) {
      if (_pendingInvitations.isEmpty) {
        return ListView(children: const [
          SizedBox(height: 60),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.mail_outline, size: 56, color: Colors.grey),
              SizedBox(height: 12),
              Text('Chưa có lời mời nào đang chờ',
                  style: TextStyle(color: Colors.grey)),
            ]),
          ),
        ]);
      }
      return ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _pendingInvitations.length,
        itemBuilder: (_, i) {
          final inv = _pendingInvitations[i];
          return _InvitationCard(
            invitation: inv,
            onAccept: () => _respond(inv, 'Đồng ý'),
            onReject: () => _respond(inv, 'Từ chối'),
          );
        },
      );
    }

    if (currentTab == 1) {
      if (_respondedInvitations.isEmpty) {
        return ListView(children: const [
          SizedBox(height: 60),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle_outline, size: 56, color: Colors.grey),
              SizedBox(height: 12),
              Text('Chưa có lời mời nào đã phản hồi',
                  style: TextStyle(color: Colors.grey)),
            ]),
          ),
        ]);
      }
      return ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _respondedInvitations.length,
        itemBuilder: (_, i) {
          final inv = _respondedInvitations[i];
          return _RespondedCard(invitation: inv);
        },
      );
    }

    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.access_time, size: 56, color: Colors.grey),
        SizedBox(height: 12),
        Text('Không có lời mời quá hạn', style: TextStyle(color: Colors.grey)),
      ]),
    );
  }

  Widget _tabItem(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentTab = index;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          color: currentTab == index ? Colors.green : Colors.grey,
          fontWeight:
              currentTab == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final Map<String, dynamic> invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _InvitationCard({
    required this.invitation,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final company = invitation['companyName']?.toString() ?? 'Nhà tuyển dụng';
    final jobTitle = invitation['jobTitle']?.toString() ?? 'Vị trí ứng tuyển';
    final salary = invitation['salary']?.toString() ?? 'Thỏa thuận';
    final location = invitation['location']?.toString() ?? 'Hồ Chí Minh';
    final thoiGian = invitation['thoiGian']?.toString();

    String timeDisplay = '';
    if (thoiGian != null) {
      try {
        final dt = DateTime.parse(thoiGian);
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 60) {
          timeDisplay = '${diff.inMinutes} phút trước';
        } else if (diff.inHours < 24) {
          timeDisplay = '${diff.inHours} giờ trước';
        } else {
          timeDisplay = '${diff.inDays} ngày trước';
        }
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
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
                  Text(jobTitle,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(company, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (timeDisplay.isNotEmpty)
              Text(timeDisplay,
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ]),

          const SizedBox(height: 10),

          Row(children: [
            _chip(salary, Icons.attach_money),
            const SizedBox(width: 8),
            _chip(location, Icons.location_on),
          ]),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: onReject,
                  child: const Text("Từ chối",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: onAccept,
                  child: const Text("Đồng ý",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    );
  }
}

class _RespondedCard extends StatelessWidget {
  final Map<String, dynamic> invitation;

  const _RespondedCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    final company = invitation['companyName']?.toString() ?? 'Nhà tuyển dụng';
    final jobTitle = invitation['jobTitle']?.toString() ?? 'Vị trí ứng tuyển';
    final trangThai = invitation['trangThai']?.toString() ?? '';
    final isAccepted = trangThai == 'Đồng ý';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isAccepted ? Colors.green.shade100 : Colors.red.shade100),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isAccepted ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isAccepted ? Icons.check_circle : Icons.cancel,
            color: isAccepted ? Colors.green : Colors.red,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(jobTitle,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              Text(company, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: (isAccepted ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            trangThai,
            style: TextStyle(
              color: isAccepted ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ]),
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String salary;
  final String location;

  const JobCard({
    super.key,
    required this.title,
    required this.company,
    required this.salary,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            company,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              chip(salary),
              const SizedBox(width: 10),
              chip(location),
            ],
          ),
        ],
      ),
    );
  }

  Widget chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }
}