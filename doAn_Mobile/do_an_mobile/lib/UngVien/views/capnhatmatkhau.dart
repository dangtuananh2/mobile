import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:do_an_mobile/UngVien/views/dangnhap.dart';

class CapNhatMatKhau extends StatefulWidget {
  final String email;

  const CapNhatMatKhau({super.key, required this.email});

  @override
  State<CapNhatMatKhau> createState() => _CapNhatMatKhauState();
}

class _CapNhatMatKhauState extends State<CapNhatMatKhau> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  static const Color primaryGreen = Color(0xFF16A34A);

  String get apiUrl {
    // Chạy Chrome/Desktop:
    return "http://localhost:5249/api/TaiKhoan/reset-password";

    // Chạy Android Emulator thì dùng dòng dưới:
    // return "http://10.0.2.2:5249/api/TaiKhoan/reset-password";
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return "Vui lòng nhập mật khẩu mới";
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

  Future<void> _updatePassword() async {
    final String code = _codeController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (widget.email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thiếu email. Vui lòng quay lại bước quên mật khẩu."),
        ),
      );
      return;
    }

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập mã xác nhận")),
      );
      return;
    }

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mã xác nhận phải gồm 6 chữ số")),
      );
      return;
    }

    final String? passwordError = _validatePassword(newPassword);

    if (passwordError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(passwordError)));
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu nhập lại không khớp")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email.trim(),
          "code": code,
          "newPassword": newPassword,
        }),
      );

      debugPrint("RESET STATUS: ${response.statusCode}");
      debugPrint("RESET BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật mật khẩu thành công")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DangNhap()),
          (route) => false,
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.body)));
      }
    } catch (e) {
      debugPrint("Lỗi cập nhật mật khẩu: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không kết nối được server")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
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
        prefixIcon: Icon(icon, color: primaryGreen),
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

  @override
  Widget build(BuildContext context) {
    final String emailText = widget.email.isEmpty
        ? "Email chưa xác định"
        : widget.email;

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

                    const SizedBox(height: 25),

                    const Icon(
                      Icons.password_rounded,
                      size: 80,
                      color: primaryGreen,
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Tạo mật khẩu mới",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Mã xác nhận đã được gửi đến:\n$emailText",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),

                    const SizedBox(height: 30),

                    _input(
                      controller: _codeController,
                      hint: "Nhập mã xác nhận 6 số",
                      icon: Icons.verified_outlined,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 15),

                    _input(
                      controller: _newPasswordController,
                      hint: "Mật khẩu mới",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 15),

                    _input(
                      controller: _confirmPasswordController,
                      hint: "Nhập lại mật khẩu mới",
                      icon: Icons.lock_reset_outlined,
                      isPassword: true,
                      isConfirmPassword: true,
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Mật khẩu 8-32 ký tự, có chữ, số và ký tự đặc biệt.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updatePassword,
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
                                "Cập nhật mật khẩu",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Quay lại",
                        style: TextStyle(color: primaryGreen),
                      ),
                    ),
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
