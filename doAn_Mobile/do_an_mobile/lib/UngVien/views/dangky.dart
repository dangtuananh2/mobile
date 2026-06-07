import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:do_an_mobile/UngVien/views/dangnhap.dart';

class DangKy extends StatefulWidget {
  const DangKy({super.key});

  @override
  State<DangKy> createState() => _DangKyState();
}

class _DangKyState extends State<DangKy> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _agree = false;

  String _vaiTro = "ung_vien";

  static const Color primaryGreen = Colors.green;

  String get apiUrl {
    // Chạy Chrome/Desktop:
    return "http://localhost:5249/api/TaiKhoan";

    // Chạy Android Emulator thì dùng dòng dưới:
    // return "http://10.0.2.2:5249/api/TaiKhoan";
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    if (phone.isEmpty) return true;
    return RegExp(r'^[0-9]{9,11}$').hasMatch(phone);
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }

    if (password.length < 8 || password.length > 32) {
      return "Mật khẩu phải từ 8 đến 32 ký tự";
    }

    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return "Mật khẩu phải có ít nhất 1 chữ cái";
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      return "Mật khẩu phải có ít nhất 1 chữ số";
    }

    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return "Mật khẩu phải có ít nhất 1 ký tự đặc biệt";
    }

    return null;
  }

  Future<void> registerUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();
    final String name = _nameController.text.trim();
    final String company = _companyController.text.trim();
    final String phone = _phoneController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập email")));
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email không hợp lệ")));
      return;
    }

    final String? passwordError = _validatePassword(password);
    if (passwordError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(passwordError)));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu nhập lại không khớp")),
      );
      return;
    }

    if (!_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số điện thoại không hợp lệ")),
      );
      return;
    }

    if (_vaiTro == "ung_vien" && name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập họ tên")));
      return;
    }

    if (_vaiTro == "nha_tuyen_dung" && company.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên công ty")),
      );
      return;
    }

    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đồng ý điều khoản")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "matKhau": password,
          "hoTen": name,
          "tenCongTy": company,
          "soDienThoai": phone,
          "vaiTro": _vaiTro,
        }),
      );

      debugPrint("REGISTER STATUS: ${response.statusCode}");
      debugPrint("REGISTER BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DangNhap()),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.body.isEmpty ? "Đăng ký thất bại" : response.body,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Lỗi đăng ký: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không kết nối được server")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget buildInput(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    final bool obscure = isPassword
        ? (isConfirmPassword ? _hideConfirmPassword : _hidePassword)
        : false;

    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, color: primaryGreen),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirmPassword) {
                      _hideConfirmPassword = !_hideConfirmPassword;
                    } else {
                      _hidePassword = !_hidePassword;
                    }
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _roleButton({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final bool selected = _vaiTro == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _vaiTro = value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? primaryGreen : Colors.grey[200],
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey[700]),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCandidate = _vaiTro == "ung_vien";

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 80,
                      child: Image.asset(
                        'assets/images/jobgo.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.work,
                              size: 50,
                              color: Colors.green,
                            ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Đăng ký",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Tạo tài khoản để sử dụng JobGo",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        _roleButton(
                          title: "Ứng viên",
                          value: "ung_vien",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(width: 12),
                        _roleButton(
                          title: "Nhà tuyển dụng",
                          value: "nha_tuyen_dung",
                          icon: Icons.business_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (isCandidate)
                      buildInput(
                        "Họ tên",
                        _nameController,
                        icon: Icons.person_outline,
                      )
                    else
                      buildInput(
                        "Tên công ty",
                        _companyController,
                        icon: Icons.business_outlined,
                      ),

                    const SizedBox(height: 15),

                    buildInput(
                      "Email",
                      _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 15),

                    buildInput(
                      "Số điện thoại",
                      _phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 15),

                    buildInput(
                      "Mật khẩu",
                      _passwordController,
                      isPassword: true,
                      icon: Icons.lock_outline,
                    ),

                    const SizedBox(height: 15),

                    buildInput(
                      "Nhập lại mật khẩu",
                      _confirmPasswordController,
                      isPassword: true,
                      isConfirmPassword: true,
                      icon: Icons.lock_reset_outlined,
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Mật khẩu 8-32 ký tự, có chữ, số và ký tự đặc biệt.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Checkbox(
                          value: _agree,
                          activeColor: primaryGreen,
                          onChanged: (value) {
                            setState(() => _agree = value ?? false);
                          },
                        ),
                        Expanded(
                          child: Text(
                            "Tôi đồng ý với điều khoản sử dụng",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          disabledBackgroundColor: primaryGreen.withOpacity(
                            0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Đăng ký",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Bạn đã có tài khoản? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DangNhap(),
                              ),
                            );
                          },
                          child: const Text(
                            "Đăng nhập",
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
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
