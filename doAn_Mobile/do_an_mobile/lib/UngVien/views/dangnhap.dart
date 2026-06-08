import 'package:do_an_mobile/Admin/views/admin_layout.dart';
import 'package:flutter/material.dart';
import 'package:do_an_mobile/UngVien/views/quenmatkhau.dart';
import 'package:do_an_mobile/UngVien/views/dangky.dart';
import 'package:do_an_mobile/UngVien/views/trangchu.dart';
import 'package:do_an_mobile/NTD/views/home_ntd_page.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DangNhap extends StatefulWidget {
  const DangNhap({super.key});

  @override
  State<DangNhap> createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;

  static const Color primaryGreen = Colors.green;

  String get apiUrl {
    // Chạy Chrome/Desktop:
    return "http://localhost:5249/api/TaiKhoan/login";

    // Chạy Android Emulator thì dùng dòng dưới:
    // return "http://10.0.2.2:5249/api/TaiKhoan/login";
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
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

  Future<void> loginUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

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

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "matKhau": password}),
      );

      debugPrint("LOGIN STATUS: ${response.statusCode}");
      debugPrint("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        final int userId =
            userData['idTaikhoan'] ?? userData['IdTaikhoan'] ?? 0;

        final String userEmail =
            userData['email'] ?? userData['Email'] ?? email;

        final String vaiTro =
            userData['vaiTro'] ?? userData['VaiTro'] ?? "ung_vien";

        final String userName =
            userData['hoTen'] ??
            userData['HoTen'] ??
            userData['tenCongTy'] ??
            userData['TenCongTy'] ??
            "Người dùng";

        await prefs.setInt('userId', userId);
        await prefs.setString('userEmail', userEmail);
        await prefs.setString('userName', userName);
        await prefs.setString('vaiTro', vaiTro);

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đăng nhập thành công!")));

        if (vaiTro == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminLayout()),
          );
        } else if (vaiTro == "nha_tuyen_dung" || vaiTro == "ntd") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeNtdPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TrangChu()),
          );
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.body.isEmpty
                  ? "Email hoặc mật khẩu không chính xác"
                  : response.body,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Lỗi kết nối: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không kết nối được server")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('userEmail', account.email);
        await prefs.setString('userName', account.displayName ?? "Người dùng");
        await prefs.setString('vaiTro', "ung_vien");

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TrangChu()),
        );
      }
    } catch (e) {
      debugPrint("Google login error: $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget buildInput(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _hidePassword : false,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, color: primaryGreen),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => _hidePassword = !_hidePassword);
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

  Widget socialImage(String path, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            path,
            errorBuilder: (c, e, s) => const Icon(Icons.link),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      "Đăng nhập",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Đăng nhập để tiếp tục sử dụng JobGo",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),

                    const SizedBox(height: 30),

                    buildInput(
                      "Email",
                      _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 15),

                    buildInput(
                      "Nhập mật khẩu",
                      _passwordController,
                      isPassword: true,
                      icon: Icons.lock_outline,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuenMatKhau(),
                            ),
                          );
                        },
                        child: const Text(
                          "Quên mật khẩu?",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.green.withOpacity(
                            0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _isLoading ? null : loginUser,
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
                                "Đăng nhập",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Hoặc đăng nhập bằng",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        socialImage("assets/images/facebook.jpg", () {}),
                        const SizedBox(width: 20),
                        socialImage(
                          "assets/images/google.jpg",
                          () => signInWithGoogle(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Bạn chưa có tài khoản? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DangKy(),
                              ),
                            );
                          },
                          child: const Text(
                            "Đăng ký ngay",
                            style: TextStyle(
                              color: Colors.green,
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
