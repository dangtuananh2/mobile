import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:do_an_mobile/UngVien/controllers/ung_vien_profile_controller.dart';
import 'package:do_an_mobile/UngVien/models/ung_vien_profile_model.dart';
import 'package:image_picker/image_picker.dart';

import 'package:do_an_mobile/UngVien/views/trangchu.dart';
import 'package:do_an_mobile/UngVien/views/login.dart';
import 'package:do_an_mobile/UngVien/views/taocv.dart';
import 'package:do_an_mobile/UngVien/views/ntd_uv.dart';
import 'package:do_an_mobile/UngVien/views/thongbao.dart';
import 'package:do_an_mobile/UngVien/views/dscty.dart';
import 'package:do_an_mobile/UngVien/views/kinhnghiem.dart';
import 'package:do_an_mobile/UngVien/views/capnhatmatkhau.dart';

class TaiKhoan extends StatefulWidget {
  const TaiKhoan({super.key});

  @override
  State<TaiKhoan> createState() => _TaiKhoanState();
}

class _TaiKhoanState extends State<TaiKhoan> {
  final UngVienProfileController _profileController =
      UngVienProfileController();

  bool timViec = true;
  bool choPhepNTD = true;
  bool _isLoading = true;

  String userName = "Người dùng";
  String userEmail = "";
  String userCode = "...";
  String userPhone = "";
  String userAddress = "";
  String userGender = "";
  String userBirthDate = "";

  String avatarPath = "";
  String avatarBase64 = "";
  Uint8List? selectedAvatarBytes;

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color darkGreen = Color(0xFF0F7A35);
  static const Color bgColor = Color(0xFFF5F7F6);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _setAvatarFromStoredValue(String value) {
    avatarPath = value;
    avatarBase64 = value;

    if (value.trim().isEmpty) {
      selectedAvatarBytes = null;
      return;
    }

    try {
      selectedAvatarBytes = base64Decode(value);
    } catch (_) {
      selectedAvatarBytes = null;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final UngVienProfileModel localProfile =
          await _profileController.loadLocalProfile();

      if (mounted) {
        setState(() {
          userName = localProfile.userName;
          userEmail = localProfile.userEmail;
          userCode = localProfile.userCode;
          _setAvatarFromStoredValue(localProfile.avatarPath);
          _isLoading = false;
        });
      }

      final remoteProfile =
          await _profileController.fetchRemoteAccount(localProfile);

      if (remoteProfile == null || !mounted) return;

      setState(() {
        userName = remoteProfile.userName;
        userEmail = remoteProfile.userEmail;
        userCode = remoteProfile.userCode;

        if (remoteProfile.avatarPath.trim().isNotEmpty) {
          _setAvatarFromStoredValue(remoteProfile.avatarPath);
        }
      });
    } catch (e) {
      debugPrint("Lỗi tải tài khoản: $e");

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (image == null) return;

      final Uint8List bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);

      await _profileController.saveAvatarPath(base64Image);

      if (!mounted) return;

      setState(() {
        avatarBase64 = base64Image;
        avatarPath = base64Image;
        selectedAvatarBytes = bytes;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã cập nhật ảnh đại diện")),
      );
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi chọn ảnh: $e")),
      );
    }
  }

  void _goTo(Widget page, {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        _goTo(const TrangChu(), replace: true);
        break;
      case 1:
        _goTo(const TaoCV(), replace: true);
        break;
      case 2:
        _goTo(const NTD_UV());
        break;
      case 3:
        _goTo(const ThongBao(), replace: true);
        break;
      case 4:
        break;
    }
  }

  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Đăng xuất",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _profileController.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
  }

  void _showEditProfileSheet() {
    _nameController.text = userName;
    _phoneController.text = userPhone;
    _addressController.text = userAddress;
    _genderController.text = userGender;
    _birthDateController.text = userBirthDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 46,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Sửa thông tin ứng viên",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                _editInput(
                  controller: _nameController,
                  label: "Họ tên",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _editInput(
                  controller: _phoneController,
                  label: "Số điện thoại",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _editInput(
                  controller: _genderController,
                  label: "Giới tính",
                  icon: Icons.wc_outlined,
                ),
                const SizedBox(height: 12),
                _editInput(
                  controller: _birthDateController,
                  label: "Ngày sinh",
                  icon: Icons.calendar_month_outlined,
                  readOnly: true,
                  onTap: _pickBirthDate,
                ),
                const SizedBox(height: 12),
                _editInput(
                  controller: _addressController,
                  label: "Địa chỉ",
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _updateProfile,
                    child: const Text(
                      "Lưu thay đổi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _editInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryGreen),
        filled: true,
        fillColor: const Color(0xFFF5F7F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(_birthDateController.text) ?? DateTime(2002, 1, 1),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      _birthDateController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Họ tên không được để trống")),
      );
      return;
    }

    final localProfile = await _profileController.loadLocalProfile();
    final int userId = localProfile.userId;

    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không tìm thấy tài khoản")),
      );
      return;
    }

    try {
      await _profileController.updateProfile(
        userId: userId,
        hoTen: _nameController.text.trim(),
        soDienThoai: _phoneController.text.trim(),
        gioiTinh: _genderController.text.trim(),
        ngaySinh: _birthDateController.text.trim(),
        diaChi: _addressController.text.trim(),
        anhDaiDien: avatarBase64,
      );

      if (!mounted) return;

      setState(() {
        userName = _nameController.text.trim();
        userPhone = _phoneController.text.trim();
        userGender = _genderController.text.trim();
        userBirthDate = _birthDateController.text.trim();
        userAddress = _addressController.text.trim();
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thông tin thành công")),
      );
    } catch (e) {
      debugPrint("Lỗi cập nhật hồ sơ: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không kết nối được server")),
      );
    }
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "JobGo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Ứng dụng tìm việc làm dành cho ứng viên và nhà tuyển dụng.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  ImageProvider? _avatarImageProvider() {
    if (selectedAvatarBytes == null) {
      return null;
    }

    return MemoryImage(selectedAvatarBytes!);
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 54, 18, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [darkGreen, primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tài khoản",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: primaryGreen.withOpacity(0.12),
                        backgroundImage: _avatarImageProvider(),
                        child: selectedAvatarBytes == null
                            ? const Icon(
                                Icons.person_rounded,
                                color: primaryGreen,
                                size: 42,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: const BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail.isEmpty ? "Chưa có email" : userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Mã ứng viên: $userCode",
                          style: const TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _showEditProfileSheet,
                  icon: const Icon(Icons.edit_outlined, color: primaryGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _switchRow(
            icon: Icons.track_changes_rounded,
            title: "Trạng thái tìm việc",
            subtitle: "Bật để hồ sơ được ưu tiên hiển thị",
            value: timViec,
            onChanged: (val) => setState(() => timViec = val),
          ),
          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),
          _switchRow(
            icon: Icons.visibility_outlined,
            title: "Cho phép NTD tìm kiếm",
            subtitle: "Nhà tuyển dụng có thể chủ động kết nối",
            value: choPhepNTD,
            onChanged: (val) => setState(() => choPhepNTD = val),
          ),
        ],
      ),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        _iconBox(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(value: value, activeColor: primaryGreen, onChanged: onChanged),
      ],
    );
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: children),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading: _iconBox(icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: primaryGreen, size: 22),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 14,
      endIndent: 14,
      color: Colors.grey[200],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.red.withOpacity(0.08),
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          "Đăng xuất",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : RefreshIndicator(
              color: primaryGreen,
              onRefresh: _loadUserData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusCard(),
                          const SizedBox(height: 18),
                          _sectionTitle("Thông tin của tôi"),
                          const SizedBox(height: 10),
                          _buildMenuCard(
                            children: [
                              _menuItem(
                                icon: Icons.business_center_outlined,
                                title: "Công ty đã ứng tuyển",
                                subtitle: "Xem danh sách công ty bạn đã nộp CV",
                                onTap: () => _goTo(const DSCTY()),
                              ),
                              _divider(),
                              _menuItem(
                                icon: Icons.mail_outline,
                                title: "Lời mời từ nhà tuyển dụng",
                                subtitle: "Các lời mời phỏng vấn và kết nối",
                                onTap: () => _goTo(const NTD_UV()),
                              ),
                              _divider(),
                              _menuItem(
                                icon: Icons.history_edu,
                                title: "Kinh nghiệm làm việc",
                                subtitle: "Cập nhật kinh nghiệm cá nhân",
                                onTap: () => _goTo(const KinhNghiem()),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _sectionTitle("Cài đặt tài khoản"),
                          const SizedBox(height: 10),
                          _buildMenuCard(
                            children: [
                              _menuItem(
                                icon: Icons.lock_outline,
                                title: "Đổi mật khẩu",
                                subtitle: "Cập nhật mật khẩu đăng nhập",
                                onTap: () => _goTo(const CapNhatMatKhau()),
                              ),
                              _divider(),
                              _menuItem(
                                icon: Icons.info_outline,
                                title: "Thông tin ứng dụng",
                                subtitle: "JobGo - Ứng dụng tìm việc làm",
                                onTap: _showAppInfo,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _logoutButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: "Tạo CV",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: "NTD",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: "Thông báo",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Tài khoản",
          ),
        ],
      ),
    );
  }
}