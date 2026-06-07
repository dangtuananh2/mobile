import 'package:flutter/material.dart';
import 'package:do_an_mobile/UngVien/controllers/ung_vien_profile_controller.dart';

class ProCvTemplate extends StatelessWidget {
  final UngVienProfileController profileController;
  final Future<void> Function() onPickAvatar;

  const ProCvTemplate({
    super.key,
    required this.profileController,
    required this.onPickAvatar,
  });

  UngVienProfileController get _profileController => profileController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(10),
        color: Colors.white,
        child: Row(
          children: [
            Container(
              width: 160,
              color: const Color.fromARGB(255, 218, 129, 206),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: onPickAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                _profileController.avatarBytes != null
                                    ? MemoryImage(
                                        _profileController.avatarBytes!,
                                      )
                                    : null,
                            child: _profileController.avatarBytes == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _profileController.hoTenController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: "Họ tên",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                  ),

                  TextField(
                    controller: _profileController.viTriUngTuyenController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: "Vị trí",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                  ),

                  const Divider(),

                  infoInput(
                    context,
                    Icons.cake,
                    "Ngày sinh",
                    controller: _profileController.ngaySinhController,
                    isDate: true,
                  ),

                  infoInput(
                    context,
                    Icons.phone,
                    "SĐT",
                    controller: _profileController.soDienThoaiController,
                  ),

                  infoInput(
                    context,
                    Icons.email,
                    "Email",
                    controller: _profileController.emailController,
                  ),

                  infoInput(
                    context,
                    Icons.location_on,
                    "Địa chỉ",
                    controller: _profileController.diaChiController,
                  ),

                  const SizedBox(height: 10),

                  sectionTitle("Học vấn"),

                  TextField(
                    controller: _profileController.nganhHocController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: "Nhập học vấn",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                  ),

                  sectionTitle("Kỹ năng"),

                  TextField(
                    controller: _profileController.kyNangController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Nhập kỹ năng",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    rightSection("Mục tiêu nghề nghiệp"),
                    rightSection("Kinh nghiệm làm việc"),
                    rightSection("Danh hiệu và giải thưởng"),
                    rightSection("Chứng chỉ"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoInput(
    BuildContext context,
    IconData icon,
    String hint, {
    TextEditingController? controller,
    bool isDate = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: isDate,
            onTap: isDate
                ? () => _profileController.pickNgaySinh(context)
                : null,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget rightSection(String title) {
    TextEditingController? controller;

    if (title == "Mục tiêu nghề nghiệp") {
      controller = _profileController.mucTieuController;
    } else if (title == "Kinh nghiệm làm việc") {
      controller = _profileController.kinhNghiemMoTaController;
    } else if (title == "Danh hiệu và giải thưởng") {
      controller = _profileController.danhHieuTenController;
    } else if (title == "Chứng chỉ") {
      controller = _profileController.chungChiTenController;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const Divider(),
          TextField(controller: controller),
        ],
      ),
    );
  }
}