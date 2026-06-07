import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class JobDetailPage extends StatefulWidget {
  final String title;
  final String company;
  final String salary;
  final String location;

  const JobDetailPage({
    super.key,
    required this.title,
    required this.company,
    required this.salary,
    required this.location,
  });

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage>
    with SingleTickerProviderStateMixin {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    String logo = widget.company.contains("TANGO")
        ? "assets/images/company.jpg"
        : "assets/images/company2.jpg";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          /// HEADER
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00C853),
                  Color(0xFF009688),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /// LOGO
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Image.asset(
                            logo,
                            height: 60,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// CARD INFO
                        Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.company,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  infoItem(
                                    Icons.attach_money,
                                    "Mức lương",
                                    widget.salary,
                                  ),
                                  infoItem(
                                    Icons.location_on,
                                    "Địa điểm",
                                    widget.location,
                                  ),
                                  infoItem(
                                    Icons.star,
                                    "Kinh nghiệm",
                                    "Dưới 1 năm",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        /// TAB
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            tabItem("Thông tin", 0),
                            tabItem("Công ty", 1),
                            tabItem("Mức độ cạnh tranh", 2),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// TAB CONTENT
                        if (tabIndex == 0) buildInfoTab(),
                        if (tabIndex == 1) buildCompanyTab(),
                        if (tabIndex == 2) buildLevelTab(),

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

      /// BUTTON
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.green,
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplyCvPage(
                        jobTitle: widget.title,
                        company: widget.company,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Ứng tuyển ngay",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TAB ITEM
  Widget tabItem(String title, int index) {
    return GestureDetector(
      onTap: () => setState(() => tabIndex = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: tabIndex == index ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (tabIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 5),
              height: 2,
              width: 40,
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  Widget buildInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        wrapChips([
          "Telesales",
          "B2C",
          "Giáo dục",
          "HSK 3",
          "Tuổi 18-26",
        ]),
        buildSection("Mô tả công việc", [
          "Trả lời tin nhắn khách hàng quan tâm đến khóa học",
          "Gọi điện tư vấn khách",
          "Hướng dẫn đăng ký và chăm sóc khách",
        ]),
        buildSection("Yêu cầu ứng viên", [
          "HSK 2 trở lên",
          "Tuổi 18-26",
          "Giao tiếp tốt",
          "Có kinh nghiệm telesales là lợi thế",
        ]),
      ],
    );
  }

  Widget buildCompanyTab() {
    return buildSection("Công ty", [
      "Môi trường trẻ",
      "Training đầy đủ",
    ]);
  }

  Widget buildLevelTab() {
    return buildSection("Thông tin chung", [
      "Nhân viên",
      "5 người",
      "Fulltime",
    ]);
  }

  Widget wrapChips(List<String> items) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items
            .map(
              (e) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(e),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget buildSection(String title, List<String> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          const SizedBox(height: 10),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text("• $e"),
              )),
        ],
      ),
    );
  }

  Widget infoItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// ===========================================================================
/// MÀN FORM ỨNG TUYỂN
/// ===========================================================================

class ApplyCvPage extends StatefulWidget {
  final String jobTitle;
  final String company;

  const ApplyCvPage({
    super.key,
    required this.jobTitle,
    required this.company,
  });

  @override
  State<ApplyCvPage> createState() => _ApplyCvPageState();
}

class _ApplyCvPageState extends State<ApplyCvPage> {
  int tabIndex = 0;

  Uint8List? avatarBytes;
  String? cvFileName;
  PlatformFile? cvFile;

  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final List<TextEditingController> kyNangControllers = [
    TextEditingController(),
  ];

  final List<TextEditingController> hocTapKinhNghiemControllers = [
    TextEditingController(),
  ];

  @override
  void dispose() {
    hoTenController.dispose();
    soDienThoaiController.dispose();
    emailController.dispose();

    for (final controller in kyNangControllers) {
      controller.dispose();
    }

    for (final controller in hocTapKinhNghiemControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      avatarBytes = result.files.first.bytes;
    });
  }

  Future<void> pickCvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      cvFile = result.files.first;
      cvFileName = result.files.first.name;
    });
  }

  void addKyNang() {
    setState(() {
      kyNangControllers.add(TextEditingController());
    });
  }

  void removeKyNang(int index) {
    if (kyNangControllers.length == 1) return;

    setState(() {
      kyNangControllers[index].dispose();
      kyNangControllers.removeAt(index);
    });
  }

  void addHocTapKinhNghiem() {
    setState(() {
      hocTapKinhNghiemControllers.add(TextEditingController());
    });
  }

  void removeHocTapKinhNghiem(int index) {
    if (hocTapKinhNghiemControllers.length == 1) return;

    setState(() {
      hocTapKinhNghiemControllers[index].dispose();
      hocTapKinhNghiemControllers.removeAt(index);
    });
  }

  void submitCv() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: Colors.green,
        content: const Text(
          "CV của bạn đã được gửi đi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(
          Icons.check_circle,
          color: Colors.white,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text(
              "Đóng",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: 190,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00C853),
                  Color(0xFF009688),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// APP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "Chi tiết Hồ sơ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildHeaderCard(),

                        const SizedBox(height: 20),

                        buildTabs(),

                        const SizedBox(height: 15),

                        if (tabIndex == 0) buildCvDetailTab(),
                        if (tabIndex == 1 ) buildAttachmentTab(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: pickAvatar,
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.green,
              backgroundImage:
                  avatarBytes != null ? MemoryImage(avatarBytes!) : null,
              child: avatarBytes == null
                  ? const Icon(
                      Icons.person,
                      size: 45,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Bấm vào avatar để tải ảnh lên",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          buildTextField(
            controller: hoTenController,
            label: "Họ tên",
            icon: Icons.person,
          ),

          const SizedBox(height: 12),

          buildTextField(
            controller: soDienThoaiController,
            label: "Số điện thoại",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 12),

          buildTextField(
            controller: emailController,
            label: "Email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget buildTabs() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          applyTabItem("Chi tiết CV", 0),
          applyTabItem("File đính kèm", 1),
        ],
      ),
    );
  }

  Widget applyTabItem(String title, int index) {
    final bool selected = tabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          tabIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: selected ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          if (selected)
            Container(
              height: 2,
              width: 55,
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  Widget buildCvDetailTab() {
    return Column(
      children: [
        buildDynamicSection(
          title: "Kỹ năng",
          controllers: kyNangControllers,
          hintText: "Nhập kỹ năng",
          onAdd: addKyNang,
          onRemove: removeKyNang,
        ),

        buildDynamicSection(
          title: "Học tập và kinh nghiệm",
          controllers: hocTapKinhNghiemControllers,
          hintText: "Nhập học tập / kinh nghiệm",
          onAdd: addHocTapKinhNghiem,
          onRemove: removeHocTapKinhNghiem,
          maxLines: 3,
        ),

        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: submitCv,
            child: const Text(
              "Ứng tuyển ngay",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAttachmentTab() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "File đính kèm",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.upload_file,
                  color: Colors.green,
                  size: 46,
                ),

                const SizedBox(height: 10),

                const Text(
                  "Tải CV lên",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  cvFileName == null
                      ? "Hỗ trợ file PDF, DOC, DOCX"
                      : "File đã chọn: $cvFileName",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cvFileName == null ? Colors.grey : Colors.black87,
                  ),
                ),

                const SizedBox(height: 15),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: pickCvFile,
                  icon: const Icon(
                    Icons.folder_open,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Tải lên",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: submitCv,
              child: const Text(
                "Ứng tuyển ngay",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDynamicSection({
    required String title,
    required List<TextEditingController> controllers,
    required String hintText,
    required VoidCallback onAdd,
    required void Function(int index) onRemove,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.green,
                ),
                label: const Text(
                  "Thêm",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...List.generate(controllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controllers[index],
                      maxLines: maxLines,
                      decoration: InputDecoration(
                        hintText: "$hintText ${index + 1}",
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: controllers.length == 1
                        ? null
                        : () => onRemove(index),
                    icon: Icon(
                      Icons.delete_outline,
                      color: controllers.length == 1
                          ? Colors.grey
                          : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.green,
        ),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}