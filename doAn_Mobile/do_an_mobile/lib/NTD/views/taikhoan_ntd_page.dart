import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../UngVien/views/login.dart';
import 'capnhat_thongtin_ntd_page.dart'; // File này phải để cùng thư mục nhé

class TaiKhoanNtdPage extends StatefulWidget {
  const TaiKhoanNtdPage({super.key});

  @override
  State<TaiKhoanNtdPage> createState() => _TaiKhoanNtdPageState();
}

class _TaiKhoanNtdPageState extends State<TaiKhoanNtdPage> {
  bool trangThaiTuyenDung = true;
  bool nhanTinNhanTrucTiep = false;
  IconData _avatarIcon = Icons.business;
  String tenCongTy = 'Công ty TNHH Tango';
  String maSoThue = '0123456789';

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tenCongTy = prefs.getString('ntd_company_name') ?? 'Công ty TNHH Tango';
      maSoThue = prefs.getString('ntd_company_tax') ?? '0123456789';
    });
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Cập nhật Logo Công ty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text("Chọn ảnh từ thư viện"),
              onTap: () {
                setState(() => _avatarIcon = Icons.image);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật Logo mới!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text("Chụp ảnh mới"),
              onTap: () {
                setState(() => _avatarIcon = Icons.camera);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật Logo mới!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔰 HEADER
            Container(
              padding: const EdgeInsets.only(top: 60, left: 15, right: 15),
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E20),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              _avatarIcon,
                              size: 40,
                              color: Colors.green,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenCongTy,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Mã số thuế: $maSoThue",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔽 CONTENT
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  buildItem(
                    Icons.wallet,
                    "Ví tuyển dụng: Còn 150 điểm",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tính năng nạp điểm đang bảo trì"),
                        ),
                      );
                    },
                  ),

                  buildSwitch(
                    icon: Icons.campaign,
                    title: "Trạng thái tuyển dụng",
                    value: trangThaiTuyenDung,
                    onChanged: (value) {
                      setState(() {
                        trangThaiTuyenDung = value;
                      });
                    },
                    subtitle:
                        "Bật để hiển thị các tin tuyển dụng đang mở của công ty...",
                  ),

                  buildSwitch(
                    icon: Icons.chat,
                    title: "Cho phép UV nhắn tin",
                    value: nhanTinNhanTrucTiep,
                    onChanged: (value) {
                      setState(() {
                        nhanTinNhanTrucTiep = value;
                      });
                    },
                    subtitle:
                        "Cho phép ứng viên nhắn tin trực tiếp để hỏi về công việc...",
                  ),

                  const SizedBox(height: 10),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Quản lý công ty",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  buildItem(
                    Icons.edit_document,
                    "Cập nhật thông tin công ty",
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CapNhatThongTinNtdPage(),
                        ),
                      );
                      if (updated == true) {
                        _loadCompanyData();
                      }
                    },
                  ),

                  buildItem(
                    Icons.shopping_cart,
                    "Gói dịch vụ & Thanh toán",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Chuyển đến trang Gói dịch vụ"),
                        ),
                      );
                    },
                  ),

                  buildItem(
                    Icons.lock,
                    "Đổi mật khẩu",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Hiển thị form đổi mật khẩu"),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // 🔴 ĐĂNG XUẤT — điều hướng thật về Login
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            title: const Text("Xác nhận đăng xuất",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text(
                                "Bạn có chắc muốn đăng xuất khỏi tài khoản?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context), // Đóng dialog
                                child: const Text(
                                  "Hủy",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  // Đóng dialog trước
                                  Navigator.pop(context);
                                  // Điều hướng thẳng về trang Login, xóa toàn bộ stack
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const Login()),
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  "Đăng xuất",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        "Đăng xuất",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 ITEM
  Widget buildItem(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 🔹 SWITCH ITEM
  Widget buildSwitch({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.green,
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
