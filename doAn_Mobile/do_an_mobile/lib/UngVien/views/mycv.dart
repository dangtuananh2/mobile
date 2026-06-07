import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:do_an_mobile/UngVien/controllers/cv_controller.dart';
import 'package:do_an_mobile/UngVien/models/ho_so_cv_model.dart';
import 'package:do_an_mobile/UngVien/views/taocv.dart';
import 'package:do_an_mobile/UngVien/views/taomau.dart';

class MyCV extends StatefulWidget {
  const MyCV({super.key});

  @override
  State<MyCV> createState() => _MyCVState();
}

class _MyCVState extends State<MyCV> {
  final CvController _cvController = CvController();

  PlatformFile? uploadedCvFile;
  bool isPickingFile = false;

  bool isLoading = true;
  List<HoSoCvModel> cvList = [];

  @override
  void initState() {
    super.initState();
    _loadAllCv();
    _loadUploadedCvFile();
  }

  Future<void> _loadAllCv() async {
    setState(() {
      isLoading = true;
    });

    try {
      final list = await _cvController.getAllCvByTaiKhoan();

      if (!mounted) return;

      setState(() {
        cvList = list;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        cvList = [];
        isLoading = false;
      });
    }
  }

  Future<void> _loadUploadedCvFile() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('uploaded_cv_name');
    final size = prefs.getInt('uploaded_cv_size') ?? 0;

    if (name == null || name.trim().isEmpty) return;
    if (!mounted) return;

    setState(() {
      uploadedCvFile = PlatformFile(
        name: name,
        size: size,
      );
    });
  }

  Future<void> _saveUploadedCvFile(PlatformFile file) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('uploaded_cv_name', file.name);
    await prefs.setInt('uploaded_cv_size', file.size);
  }

  Future<void> _deleteUploadedCvFile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('uploaded_cv_name');
    await prefs.remove('uploaded_cv_size');

    if (!mounted) return;

    setState(() {
      uploadedCvFile = null;
    });
  }

  String getValue(
    HoSoCvModel cv,
    List<String> keys, {
    String defaultValue = '',
  }) {
    return cv.getValue(keys, defaultValue: defaultValue);
  }

  Future<void> _pickCvFile() async {
    if (isPickingFile) return;

    setState(() {
      isPickingFile = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: true,
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        setState(() {
          isPickingFile = false;
        });
        return;
      }

      final selectedFile = result.files.first;

      await _saveUploadedCvFile(selectedFile);

      if (!mounted) return;

      setState(() {
        uploadedCvFile = selectedFile;
        isPickingFile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chọn file: ${selectedFile.name}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPickingFile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi chọn file: $e'),
        ),
      );
    }
  }

  Future<void> _goToCreateCv() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaoCV(),
      ),
    );

    await _loadAllCv();
  }

  Future<void> _openSavedCv(HoSoCvModel cv) async {
    final idCv = getValue(cv, ["idCv", "id_cv"]);
    final type = getValue(
      cv,
      ["loaiMauCv", "loai_mau_cv"],
      defaultValue: "simple",
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaoMau(
          type: type,
          isEdit: true,
          idCv: idCv,
        ),
      ),
    );

    await _loadAllCv();
  }

  @override
  Widget build(BuildContext context) {
    final hasCreatedCv = cvList.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xfff6f8f8),
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff243746),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CV của tôi',
          style: TextStyle(
            color: Color(0xff243746),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xff00b14f),
        onRefresh: _loadAllCv,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCreatedCvHeader(),
              const SizedBox(height: 28),
              if (isLoading)
                const SizedBox(
                  height: 230,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff00b14f),
                    ),
                  ),
                )
              else if (hasCreatedCv)
                Wrap(
                  spacing: 18,
                  runSpacing: 24,
                  children: cvList.map((cv) {
                    return _buildCreatedCvCard(cv);
                  }).toList(),
                )
              else
                _buildEmptyCreatedCv(),
              const SizedBox(height: 54),
              const Text(
                'CV đã tải lên JobGo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff243746),
                ),
              ),
              const SizedBox(height: 50),
              _buildUploadedEmpty(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatedCvHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'CV đã tạo trên JobGo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xff243746),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _goToCreateCv,
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 26,
          ),
          label: const Text(
            'Tạo CV',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff00b14f),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 11,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatedCvCard(HoSoCvModel cv) {
    final tieuDeCv = getValue(
      cv,
      ['tieuDeCv', 'tieu_de_cv'],
      defaultValue: 'CV của tôi',
    );

    final hoTen = getValue(
      cv,
      ['hoTen', 'ho_ten'],
      defaultValue: 'Ứng viên',
    );

    final ngayTao = getValue(
      cv,
      ['ngayTao', 'ngay_tao'],
      defaultValue: '',
    );

    final type = getValue(
      cv,
      ['loaiMauCv', 'loai_mau_cv'],
      defaultValue: 'simple',
    );

    return GestureDetector(
      onTap: () => _openSavedCv(cv),
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: const Color(0xffe2e6ea),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: type == "pro"
                        ? const Color(0xfffff1f6)
                        : const Color(0xfff4f8fa),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(9),
                      topRight: Radius.circular(9),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(9),
                      topRight: Radius.circular(9),
                    ),
                    child: _buildCvPreview(hoTen, type),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: type == "pro"
                          ? Colors.pink.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type == "pro" ? "Pro" : "Simple",
                      style: TextStyle(
                        color: type == "pro"
                            ? Colors.pink.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: GestureDetector(
                    onTap: () => _openSavedCv(cv),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xff7f8d98),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 5),
              child: Text(
                tieuDeCv,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff243746),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ngayTao.isEmpty ? 'CV đã lưu' : ngayTao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff8b8f94),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.more_horiz,
                    color: Color(0xff8b8f94),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCvPreview(String hoTen, String type) {
    if (type == "pro") {
      return Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xfffff7fa),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: const Color(0xff5d4037),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Color(0xff5d4037),
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hoTen.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < 8; i++) ...[
                      Container(
                        height: 5,
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.4),
                      ),
                      const SizedBox(height: 7),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < 15; i++) ...[
                    Container(
                      width: i.isEven ? 120 : 95,
                      height: 5,
                      color: const Color(0xffd9c4c8),
                    ),
                    const SizedBox(height: 7),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Color(0xffd9e8ef),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xff2685a9),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hoTen.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff2685a9),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                for (int i = 0; i < 13; i++) ...[
                  Container(
                    width: i.isEven ? 125 : 95,
                    height: 5,
                    color: const Color(0xffe3e8eb),
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xffedf5f7),
              padding: const EdgeInsets.all(9),
              child: Column(
                children: [
                  for (int i = 0; i < 8; i++) ...[
                    Row(
                      children: [
                        Container(
                          width: 13,
                          height: 13,
                          decoration: const BoxDecoration(
                            color: Color(0xff2685a9),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            height: 5,
                            color: const Color(0xffccd8dd),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCreatedCv() {
    return SizedBox(
      width: double.infinity,
      height: 260,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 95,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'Chưa có CV nào được tạo',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedEmpty() {
    if (uploadedCvFile != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xffe2e6ea),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xffe9f8f0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description,
                color: Color(0xff00b14f),
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    uploadedCvFile!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff243746),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    uploadedCvFile!.size > 0
                        ? '${(uploadedCvFile!.size / 1024).toStringAsFixed(1)} KB'
                        : 'File đã chọn',
                    style: const TextStyle(
                      color: Color(0xff8b8f94),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Chọn file khác',
              onPressed: isPickingFile ? null : _pickCvFile,
              icon: const Icon(
                Icons.upload_file,
                color: Color(0xff00b14f),
              ),
            ),
            IconButton(
              tooltip: 'Xóa file đã chọn',
              onPressed: _deleteUploadedCvFile,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Center(
          child: Icon(
            Icons.cloud_upload,
            size: 100,
            color: Colors.grey[300],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Chưa có CV nào được tải lên',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 19,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: ElevatedButton.icon(
            onPressed: isPickingFile ? null : _pickCvFile,
            icon: const Icon(
              Icons.upload_file,
              color: Colors.white,
            ),
            label: Text(
              isPickingFile ? 'Đang mở...' : 'Tải CV lên',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff00b14f),
              disabledBackgroundColor: Colors.grey,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}