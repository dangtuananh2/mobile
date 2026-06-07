import 'package:flutter/material.dart';
import 'package:do_an_mobile/UngVien/controllers/ung_vien_profile_controller.dart';

class SimpleCvTemplate extends StatefulWidget {
  final UngVienProfileController profileController;
  final Future<void> Function() onPickAvatar;

  const SimpleCvTemplate({
    super.key,
    required this.profileController,
    required this.onPickAvatar,
  });

  @override
  State<SimpleCvTemplate> createState() => _SimpleCvTemplateState();
}

class _SimpleCvTemplateState extends State<SimpleCvTemplate> {
  final List<ExperienceInput> experienceInputs = [];
  final List<ActivityInput> activityInputs = [];
  final List<CertificateInput> certificateInputs = [];
  final List<AwardInput> awardInputs = [];
  final List<TextEditingController> skillControllers = [];
  final List<TextEditingController> hobbyControllers = [];

  UngVienProfileController get _profileController => widget.profileController;

  @override
  void initState() {
    super.initState();
    _initListControllers();
  }

  void _initListControllers() {
    skillControllers.addAll(
      _splitToControllers(_profileController.kyNangController.text),
    );

    hobbyControllers.addAll(
      _splitToControllers(_profileController.soThichController.text),
    );

    certificateInputs.addAll(
      _initCertificateInputs(),
    );

    awardInputs.addAll(
      _initAwardInputs(),
    );

    experienceInputs.addAll(
      _initExperienceInputs(),
    );

    activityInputs.addAll(
      _initActivityInputs(),
    );

    _syncAllToProfileController();
  }

  List<TextEditingController> _splitToControllers(String value) {
    final items = value
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (items.isEmpty) {
      return [TextEditingController()];
    }

    return items.map((e) => TextEditingController(text: e)).toList();
  }

  List<CertificateInput> _initCertificateInputs() {
    final times = _splitTextLines(_profileController.chungChiThoiGianController.text);
    final names = _splitTextLines(_profileController.chungChiTenController.text);

    final maxLength = _maxLength([times.length, names.length]);

    if (maxLength == 0) {
      return [CertificateInput()];
    }

    return List.generate(maxLength, (index) {
      return CertificateInput(
        thoiGian: index < times.length ? times[index] : '',
        ten: index < names.length ? names[index] : '',
      );
    });
  }

  List<AwardInput> _initAwardInputs() {
    final times = _splitTextLines(_profileController.danhHieuThoiGianController.text);
    final names = _splitTextLines(_profileController.danhHieuTenController.text);

    final maxLength = _maxLength([times.length, names.length]);

    if (maxLength == 0) {
      return [AwardInput()];
    }

    return List.generate(maxLength, (index) {
      return AwardInput(
        thoiGian: index < times.length ? times[index] : '',
        ten: index < names.length ? names[index] : '',
      );
    });
  }

  List<ExperienceInput> _initExperienceInputs() {
    final positions = _splitTextLines(_profileController.kinhNghiemViTriController.text);
    final fromDates = _splitTextLines(_profileController.kinhNghiemTuController.text);
    final toDates = _splitTextLines(_profileController.kinhNghiemDenController.text);
    final companies = _splitTextLines(_profileController.kinhNghiemCongTyController.text);
    final descriptions = _splitTextLines(_profileController.kinhNghiemMoTaController.text);

    final maxLength = _maxLength([
      positions.length,
      fromDates.length,
      toDates.length,
      companies.length,
      descriptions.length,
    ]);

    if (maxLength == 0) {
      return [ExperienceInput()];
    }

    return List.generate(maxLength, (index) {
      return ExperienceInput(
        viTri: index < positions.length ? positions[index] : '',
        tu: index < fromDates.length ? fromDates[index] : '',
        den: index < toDates.length ? toDates[index] : '',
        congTy: index < companies.length ? companies[index] : '',
        moTa: index < descriptions.length ? descriptions[index] : '',
      );
    });
  }

  List<ActivityInput> _initActivityInputs() {
    final positions = _splitTextLines(_profileController.hoatDongViTriController.text);
    final fromDates = _splitTextLines(_profileController.hoatDongTuController.text);
    final toDates = _splitTextLines(_profileController.hoatDongDenController.text);
    final organizations = _splitTextLines(_profileController.hoatDongToChucController.text);
    final descriptions = _splitTextLines(_profileController.hoatDongMoTaController.text);

    final maxLength = _maxLength([
      positions.length,
      fromDates.length,
      toDates.length,
      organizations.length,
      descriptions.length,
    ]);

    if (maxLength == 0) {
      return [ActivityInput()];
    }

    return List.generate(maxLength, (index) {
      return ActivityInput(
        viTri: index < positions.length ? positions[index] : '',
        tu: index < fromDates.length ? fromDates[index] : '',
        den: index < toDates.length ? toDates[index] : '',
        toChuc: index < organizations.length ? organizations[index] : '',
        moTa: index < descriptions.length ? descriptions[index] : '',
      );
    });
  }

  List<String> _splitTextLines(String value) {
    return value
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  int _maxLength(List<int> values) {
    if (values.isEmpty) return 0;

    int max = 0;

    for (final value in values) {
      if (value > max) {
        max = value;
      }
    }

    return max;
  }

  String _joinControllers(List<TextEditingController> controllers) {
    return controllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n');
  }

  void _syncAllToProfileController() {
    _profileController.kyNangController.text = _joinControllers(skillControllers);
    _profileController.soThichController.text = _joinControllers(hobbyControllers);

    _profileController.chungChiThoiGianController.text = certificateInputs
        .map((e) => e.thoiGianController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.chungChiTenController.text = certificateInputs
        .map((e) => e.tenController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.danhHieuThoiGianController.text = awardInputs
        .map((e) => e.thoiGianController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.danhHieuTenController.text = awardInputs
        .map((e) => e.tenController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.kinhNghiemViTriController.text = experienceInputs
        .map((e) => e.viTriController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.kinhNghiemTuController.text = experienceInputs
        .map((e) => e.tuController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.kinhNghiemDenController.text = experienceInputs
        .map((e) => e.denController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.kinhNghiemCongTyController.text = experienceInputs
        .map((e) => e.congTyController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.kinhNghiemMoTaController.text = experienceInputs
        .map((e) => e.moTaController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.hoatDongViTriController.text = activityInputs
        .map((e) => e.viTriController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.hoatDongTuController.text = activityInputs
        .map((e) => e.tuController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.hoatDongDenController.text = activityInputs
        .map((e) => e.denController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.hoatDongToChucController.text = activityInputs
        .map((e) => e.toChucController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    _profileController.hoatDongMoTaController.text = activityInputs
        .map((e) => e.moTaController.text.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');
  }

  Future<void> _handlePickAvatar() async {
    await widget.onPickAvatar();

    if (!mounted) return;

    setState(() {});
  }

  void _addSkill() {
    _syncAllToProfileController();

    setState(() {
      skillControllers.add(TextEditingController());
    });
  }

  void _addHobby() {
    _syncAllToProfileController();

    setState(() {
      hobbyControllers.add(TextEditingController());
    });
  }

  void _addCertificate() {
    _syncAllToProfileController();

    setState(() {
      certificateInputs.add(CertificateInput());
    });
  }

  void _addAward() {
    _syncAllToProfileController();

    setState(() {
      awardInputs.add(AwardInput());
    });
  }

  void _addExperience() {
    _syncAllToProfileController();

    setState(() {
      experienceInputs.add(ExperienceInput());
    });
  }

  void _addActivity() {
    _syncAllToProfileController();

    setState(() {
      activityInputs.add(ActivityInput());
    });
  }

  @override
  void dispose() {
    for (final controller in skillControllers) {
      controller.dispose();
    }

    for (final controller in hobbyControllers) {
      controller.dispose();
    }

    for (final item in certificateInputs) {
      item.dispose();
    }

    for (final item in awardInputs) {
      item.dispose();
    }

    for (final item in experienceInputs) {
      item.dispose();
    }

    for (final item in activityInputs) {
      item.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _syncAllToProfileController();

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(10),
        color: Colors.white,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 150,
                height: double.infinity,
                color: const Color(0xFF5D4037),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _handlePickAvatar,
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

                    const SizedBox(height: 20),

                    TextField(
                      controller: _profileController.hoTenController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
                        hintText: "Vị trí ứng tuyển",
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Divider(color: Colors.white),

                    infoInput(
                      Icons.phone,
                      "Số điện thoại",
                      controller: _profileController.soDienThoaiController,
                    ),

                    infoInput(
                      Icons.calendar_today,
                      "Ngày sinh",
                      controller: _profileController.ngaySinhController,
                      isDate: true,
                    ),

                    infoInput(
                      Icons.email,
                      "Email",
                      controller: _profileController.emailController,
                    ),

                    infoInput(
                      Icons.person,
                      "Profile Facebook",
                      controller: _profileController.facebookController,
                    ),

                    infoInput(
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
                      decoration: const InputDecoration(
                        hintText: "Ngành học / Môn học",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),

                    TextField(
                      controller: _profileController.thoiGianHocController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: "Bắt đầu - Kết thúc",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),

                    TextField(
                      controller: _profileController.tenTruongController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: "Tên trường học",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),

                    TextField(
                      controller: _profileController.moTaHocVanController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "Mô tả quá trình học",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),

                    const SizedBox(height: 10),

                    sectionTitle("Kỹ năng"),

                    ...skillControllers.map(
                      (controller) => TextField(
                        controller: controller,
                        onChanged: (_) => _syncAllToProfileController(),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          hintText: "Tên kỹ năng",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: _addSkill,
                      child: const Text(
                        "+ Thêm",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 10),

                    sectionTitle("Sở thích"),

                    ...hobbyControllers.map(
                      (controller) => TextField(
                        controller: controller,
                        onChanged: (_) => _syncAllToProfileController(),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          hintText: "Tên sở thích",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: _addHobby,
                      child: const Text(
                        "+ Thêm",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 10),

                    sectionTitle("Người giới thiệu"),

                    TextField(
                      controller: _profileController.nguoiGioiThieuController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "Tên, chức vụ, liên hệ",
                        hintStyle: TextStyle(color: Colors.white70),
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
                      buildCareerGoal(),
                      buildExperienceSection(),
                      buildAwardSection(),
                      buildCertificateSection(),
                      buildActivitySection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget brownTitle(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF5D4037),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildCareerGoal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        brownTitle("Mục tiêu nghề nghiệp"),
        TextField(
          controller: _profileController.mucTieuController,
          maxLines: 3,
        ),
        const Divider(),
      ],
    );
  }

  Widget buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        brownTitle("Kinh nghiệm làm việc"),

        ...experienceInputs.map(
          (item) => experienceItem(item),
        ),

        TextButton(
          onPressed: _addExperience,
          child: const Text("+ Thêm"),
        ),

        const Divider(),
      ],
    );
  }

  Widget experienceItem(ExperienceInput item) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: item.viTriController,
                onChanged: (_) => _syncAllToProfileController(),
                decoration: const InputDecoration(hintText: "Vị trí"),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: TextField(
                controller: item.tuController,
                onChanged: (_) => _syncAllToProfileController(),
                decoration: const InputDecoration(hintText: "Từ"),
              ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: 70,
              child: TextField(
                controller: item.denController,
                onChanged: (_) => _syncAllToProfileController(),
                decoration: const InputDecoration(hintText: "Đến"),
              ),
            ),
          ],
        ),
        TextField(
          controller: item.congTyController,
          onChanged: (_) => _syncAllToProfileController(),
          decoration: const InputDecoration(hintText: "Tên công ty"),
        ),
        TextField(
          controller: item.moTaController,
          onChanged: (_) => _syncAllToProfileController(),
          maxLines: 2,
          decoration: const InputDecoration(hintText: "Mô tả"),
        ),
      ],
    );
  }

  Widget buildAwardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        brownTitle("Danh hiệu"),

        ...awardInputs.map(
          (item) => Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item.thoiGianController,
                  onChanged: (_) => _syncAllToProfileController(),
                  decoration: const InputDecoration(hintText: "Thời gian"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: item.tenController,
                  onChanged: (_) => _syncAllToProfileController(),
                  decoration: const InputDecoration(hintText: "Tên"),
                ),
              ),
            ],
          ),
        ),

        TextButton(
          onPressed: _addAward,
          child: const Text("+ Thêm"),
        ),

        const Divider(),
      ],
    );
  }

  Widget buildCertificateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        brownTitle("Chứng chỉ"),

        ...certificateInputs.map(
          (item) => Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item.thoiGianController,
                  onChanged: (_) => _syncAllToProfileController(),
                  decoration: const InputDecoration(hintText: "Thời gian"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: item.tenController,
                  onChanged: (_) => _syncAllToProfileController(),
                  decoration: const InputDecoration(hintText: "Tên"),
                ),
              ),
            ],
          ),
        ),

        TextButton(
          onPressed: _addCertificate,
          child: const Text("+ Thêm"),
        ),

        const Divider(),
      ],
    );
  }

  Widget buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        brownTitle("Hoạt động"),

        ...activityInputs.map(
          (item) => activityItem(item),
        ),

        TextButton(
          onPressed: _addActivity,
          child: const Text("+ Thêm"),
        ),

        const Divider(),
      ],
    );
  }

  Widget activityItem(ActivityInput item) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: item.viTriController,
                onChanged: (_) => _syncAllToProfileController(),
                decoration: const InputDecoration(hintText: "Vị trí"),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: TextField(
                controller: item.tuController,
                onChanged: (_) => _syncAllToProfileController(),
                decoration: const InputDecoration(hintText: "Từ"),
              ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: 70,
              child: TextField(
                controller: item.denController,
                onChanged: (_) => _syncAllToProfileController(),
                decoration: const InputDecoration(hintText: "Đến"),
              ),
            ),
          ],
        ),
        TextField(
          controller: item.toChucController,
          onChanged: (_) => _syncAllToProfileController(),
          decoration: const InputDecoration(hintText: "Tổ chức"),
        ),
        TextField(
          controller: item.moTaController,
          onChanged: (_) => _syncAllToProfileController(),
          decoration: const InputDecoration(hintText: "Mô tả"),
        ),
      ],
    );
  }

  Widget infoInput(
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
}

class ExperienceInput {
  final TextEditingController viTriController;
  final TextEditingController tuController;
  final TextEditingController denController;
  final TextEditingController congTyController;
  final TextEditingController moTaController;

  ExperienceInput({
    String viTri = '',
    String tu = '',
    String den = '',
    String congTy = '',
    String moTa = '',
  })  : viTriController = TextEditingController(text: viTri),
        tuController = TextEditingController(text: tu),
        denController = TextEditingController(text: den),
        congTyController = TextEditingController(text: congTy),
        moTaController = TextEditingController(text: moTa);

  void dispose() {
    viTriController.dispose();
    tuController.dispose();
    denController.dispose();
    congTyController.dispose();
    moTaController.dispose();
  }
}

class ActivityInput {
  final TextEditingController viTriController;
  final TextEditingController tuController;
  final TextEditingController denController;
  final TextEditingController toChucController;
  final TextEditingController moTaController;

  ActivityInput({
    String viTri = '',
    String tu = '',
    String den = '',
    String toChuc = '',
    String moTa = '',
  })  : viTriController = TextEditingController(text: viTri),
        tuController = TextEditingController(text: tu),
        denController = TextEditingController(text: den),
        toChucController = TextEditingController(text: toChuc),
        moTaController = TextEditingController(text: moTa);

  void dispose() {
    viTriController.dispose();
    tuController.dispose();
    denController.dispose();
    toChucController.dispose();
    moTaController.dispose();
  }
}

class CertificateInput {
  final TextEditingController thoiGianController;
  final TextEditingController tenController;

  CertificateInput({
    String thoiGian = '',
    String ten = '',
  })  : thoiGianController = TextEditingController(text: thoiGian),
        tenController = TextEditingController(text: ten);

  void dispose() {
    thoiGianController.dispose();
    tenController.dispose();
  }
}

class AwardInput {
  final TextEditingController thoiGianController;
  final TextEditingController tenController;

  AwardInput({
    String thoiGian = '',
    String ten = '',
  })  : thoiGianController = TextEditingController(text: thoiGian),
        tenController = TextEditingController(text: ten);

  void dispose() {
    thoiGianController.dispose();
    tenController.dispose();
  }
}