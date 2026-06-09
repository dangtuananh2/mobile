import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DangTuyenDungPage extends StatefulWidget {
  const DangTuyenDungPage({super.key});

  @override
  State<DangTuyenDungPage> createState() => _DangTuyenDungPageState();
}

class _DangTuyenDungPageState extends State<DangTuyenDungPage> {
  String? _selectedCategory;
  final List<String> _skills = [];
  final TextEditingController _skillCtrl = TextEditingController();
  final TextEditingController _tieuDeCtrl = TextEditingController();
  final TextEditingController _mucLuongCtrl = TextEditingController();
  final TextEditingController _diaDiemCtrl = TextEditingController();
  final TextEditingController _moTaCtrl = TextEditingController();
  final TextEditingController _yeuCauCtrl = TextEditingController();
  final TextEditingController _quyenLoiCtrl = TextEditingController();

  void _addSkill() {
    if (_skillCtrl.text.isNotEmpty) {
      setState(() {
        _skills.add(_skillCtrl.text);
        _skillCtrl.clear();
      });
    }
  }

  // Lưu bài đăng vào SharedPreferences để UV có thể thấy
  Future<void> _publishJob() async {
    final tieuDe = _tieuDeCtrl.text.trim();
    final mucLuong = _mucLuongCtrl.text.trim();
    final diaDiem = _diaDiemCtrl.text.trim();
    final moTa = _moTaCtrl.text.trim();

    if (tieuDe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề công việc'), backgroundColor: Colors.red),
      );
      return;
    }

    // Tạo bản ghi việc làm mới
    final newJob = <String, String>{
      'title': tieuDe,
      'company': 'Công ty TNHH Tango',
      'salary': mucLuong.isNotEmpty ? mucLuong : 'Thỏa thuận',
      'location': diaDiem.isNotEmpty ? diaDiem : 'Hồ Chí Minh',
      'description': moTa,
      'category': _selectedCategory ?? 'Khác',
      'skills': _skills.join(', '),
      'publishedAt': DateTime.now().toIso8601String(),
    };

    // Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString('ntd_published_jobs') ?? '[]';
    final List<dynamic> list = jsonDecode(raw);
    list.insert(0, newJob);
    await prefs.setString('ntd_published_jobs', jsonEncode(list));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Xuất bản tin thành công!'), backgroundColor: Colors.green),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF009688)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text("Tạo Tin Tuyển Dụng", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 48), // Spacer để căn giữa Text
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildFormCard(
                          title: "1. Thông tin cơ bản",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Tiêu đề công việc"),
                              _buildTextField("VD: Nhân viên Telesales B2C", controller: _tieuDeCtrl),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Mức lương"),
                                        _buildTextField("VD: 10 - 15 Tr", controller: _mucLuongCtrl),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Ngành nghề"),
                                        _buildDropdown(["Kinh doanh", "IT", "Marketing", "Giáo dục"]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _buildLabel("Địa điểm làm việc"),
                              _buildTextField("VD: 140 Lê Trọng Tấn, Tân Phú", controller: _diaDiemCtrl),
                            ],
                          ),
                        ),
                        _buildFormCard(
                          title: "2. Kỹ năng & Tags",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField("Nhập thẻ kỹ năng (VD: HSK3)...", controller: _skillCtrl, onSubmitted: (_) => _addSkill()),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                                    child: IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: _addSkill),
                                  ),
                                ],
                              ),
                              if (_skills.isNotEmpty) const SizedBox(height: 15),
                              if (_skills.isNotEmpty) Wrap(
                                spacing: 10, runSpacing: 10,
                                children: _skills.map((e) => Chip(
                                  label: Text(e),
                                  deleteIconColor: Colors.red,
                                  onDeleted: () => setState(() => _skills.remove(e)),
                                  backgroundColor: Colors.grey[200],
                                  side: BorderSide.none,
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                        _buildFormCard(
                          title: "3. Nội dung chi tiết",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Mô tả công việc"),
                              _buildTextField("Nhập mô tả...", maxLines: 4, controller: _moTaCtrl),
                              const SizedBox(height: 15),
                              _buildLabel("Yêu cầu ứng viên"),
                              _buildTextField("Nhập yêu cầu bằng cấp, kinh nghiệm...", maxLines: 4),
                              const SizedBox(height: 15),
                              _buildLabel("Quyền lợi được hưởng"),
                              _buildTextField("Nhập quyền lợi, bảo hiểm, thưởng...", maxLines: 3),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.save_outlined, color: Colors.green),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dạ lưu nháp tin tuyển dụng!'), backgroundColor: Colors.green));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _publishJob,
                child: const Text("XUẤT BẢN TIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
          const Divider(height: 25),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1, TextEditingController? controller, Function(String)? onSubmitted}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.all(15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.green)),
      ),
    );
  }

  Widget _buildDropdown(List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCategory,
          hint: const Text("Chọn..."),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }
}