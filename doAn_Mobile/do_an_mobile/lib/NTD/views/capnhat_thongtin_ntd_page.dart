import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../UngVien/utils/api_constants.dart';

class CapNhatThongTinNtdPage extends StatefulWidget {
  const CapNhatThongTinNtdPage({super.key});

  @override
  State<CapNhatThongTinNtdPage> createState() => _CapNhatThongTinNtdPageState();
}

class _CapNhatThongTinNtdPageState extends State<CapNhatThongTinNtdPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _taxCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taxCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    if (userId != 0) {
      try {
        final res = await http.get(
          Uri.parse('${ApiConstants.taiKhoan}/$userId'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(res.body);
          final name = data['tenCongTy']?.toString() ?? 'Công ty TNHH Tango';
          final phone = data['soDienThoai']?.toString() ?? '0909123456';
          final address = data['diaChi']?.toString() ?? 'Quận 1, TP.HCM';

          await prefs.setString('ntd_company_name', name);
          await prefs.setString('ntd_company_phone', phone);
          await prefs.setString('ntd_company_address', address);
        }
      } catch (_) {}
    }

    setState(() {
      _nameCtrl.text = prefs.getString('ntd_company_name') ?? 'Công ty TNHH Tango';
      _taxCtrl.text = prefs.getString('ntd_company_tax') ?? '0123456789';
      _phoneCtrl.text = prefs.getString('ntd_company_phone') ?? '0909123456';
      _addressCtrl.text = prefs.getString('ntd_company_address') ?? 'Quận 1, TP.HCM';
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final tax = _taxCtrl.text.trim();

    if (userId != 0) {
      final res = await http.put(
        Uri.parse('${ApiConstants.taiKhoan}/nha-tuyen-dung/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tenCongTy': name,
          'soDienThoai': phone,
          'diaChi': address,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception('Lỗi cập nhật cơ sở dữ liệu: ${res.body}');
      }
    }

    await prefs.setString('ntd_company_name', name);
    await prefs.setString('ntd_company_tax', tax);
    await prefs.setString('ntd_company_phone', phone);
    await prefs.setString('ntd_company_address', address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Sửa thông tin", style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF00C853), Color(0xFF009688)]),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, size: 30, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextField(controller: _nameCtrl, decoration: _decor("Tên công ty")),
                  const SizedBox(height: 15),
                  TextField(controller: _taxCtrl, decoration: _decor("Mã số thuế")),
                  const SizedBox(height: 15),
                  TextField(controller: _phoneCtrl, decoration: _decor("Số điện thoại"), keyboardType: TextInputType.phone),
                  const SizedBox(height: 15),
                  TextField(controller: _addressCtrl, decoration: _decor("Địa chỉ")),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        await _saveData();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lưu thành công!"), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context, true);
                      },
                      child: const Text("LƯU THAY ĐỔI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  InputDecoration _decor(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      );
}