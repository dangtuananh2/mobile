import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:do_an_mobile/UngVien/controllers/ung_vien_profile_controller.dart';
import 'package:do_an_mobile/UngVien/controllers/cv_controller.dart';
import 'package:do_an_mobile/UngVien/models/ho_so_cv_model.dart';
import 'package:do_an_mobile/UngVien/views/luucv.dart';
import 'package:do_an_mobile/UngVien/views/cv_templates/simple_cv_template.dart';
import 'package:do_an_mobile/UngVien/views/cv_templates/pro_cv_template.dart';

class TaoMau extends StatefulWidget {
  final String type;
  final bool isEdit;
  final String? idCv;

  const TaoMau({
    super.key,
    this.type = "simple",
    this.isEdit = false,
    this.idCv,
  });

  @override
  State<TaoMau> createState() => _TaoMauState();
}

class _TaoMauState extends State<TaoMau> {
  final UngVienProfileController _profileController =
      UngVienProfileController();

  final CvController _cvController = CvController();

  bool isSaving = false;
  bool isLoadingOldCv = false;
  bool isPickingAvatar = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.idCv != null) {
      isLoadingOldCv = true;
      loadCvById(widget.idCv!);
    }
  }

  Future<void> pickCvAvatar() async {
    if (isPickingAvatar) return;

    setState(() {
      isPickingAvatar = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        setState(() {
          isPickingAvatar = false;
        });
        return;
      }

      final file = result.files.first;

      if (file.bytes == null) {
        setState(() {
          isPickingAvatar = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không đọc được ảnh đã chọn"),
          ),
        );
        return;
      }

      setState(() {
        _profileController.setCvAvatar(
          bytes: file.bytes!,
          fileName: file.name,
        );
        isPickingAvatar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã chọn ảnh: ${file.name}"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPickingAvatar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi chọn ảnh: $e"),
        ),
      );
    }
  }

  Future<void> loadCvById(String idCv) async {
    try {
      final HoSoCvModel cv = await _cvController.getCvById(idCv);

      if (!mounted) return;

      _fillControllersFromCv(cv);

      setState(() {
        isLoadingOldCv = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingOldCv = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải dữ liệu CV: $e")),
      );
    }
  }

  void _fillControllersFromCv(HoSoCvModel cv) {
    String getValue(List<String> keys, {String defaultValue = ""}) {
      return cv.getValue(keys, defaultValue: defaultValue);
    }

    Map<String, dynamic> parseJsonMap(String value) {
      if (value.trim().isEmpty) return {};

      try {
        final decoded = jsonDecode(value);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {};
      } catch (_) {
        return {};
      }
    }

    String firstText(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        final value = map[key];

        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }

      return "";
    }

    _profileController.tenCvController.text = getValue(
      ["tieuDeCv", "tieu_de_cv"],
    );

    _profileController.setCvAvatarFromBase64(
      getValue(["anhCv", "anh_cv"]),
    );

    _profileController.hoTenController.text = getValue(
      ["hoTen", "ho_ten"],
    );

    _profileController.viTriUngTuyenController.text = getValue(
      ["viTriUngTuyen", "vi_tri_ung_tuyen"],
    );

    _profileController.soDienThoaiController.text = getValue(
      ["soDienThoai", "so_dien_thoai"],
    );

    _profileController.ngaySinhController.text = getValue(
      ["ngaySinh", "ngay_sinh"],
    );

    _profileController.emailController.text = getValue(
      ["email"],
    );

    _profileController.facebookController.text = getValue(
      ["profileFacebook", "profile_facebook"],
    );

    _profileController.diaChiController.text = getValue(
      ["diaChi", "dia_chi"],
    );

    _profileController.nguoiGioiThieuController.text = getValue(
      ["nguoiGioiThieu", "nguoi_gioi_thieu"],
    );

    _profileController.mucTieuController.text = getValue(
      ["mucTieu", "muc_tieu"],
    );

    _profileController.moTaHocVanController.text = getValue(
      ["moTaHocVan", "mo_ta_hoc_van"],
    );

    final hocVan = parseJsonMap(
      getValue(["hocVan", "hoc_van"]),
    );

    _profileController.nganhHocController.text = firstText(
      hocVan,
      ["nganhHoc", "nganh_hoc", "nganh", "monHoc", "mon_hoc"],
    );

    _profileController.thoiGianHocController.text = firstText(
      hocVan,
      ["thoiGianHoc", "thoi_gian_hoc", "thoiGian", "thoi_gian"],
    );

    _profileController.tenTruongController.text = firstText(
      hocVan,
      ["tenTruong", "ten_truong", "truong", "truongHoc", "truong_hoc"],
    );

    final kinhNghiem = parseJsonMap(
      getValue(["kinhNghiem", "kinh_nghiem"]),
    );

    _profileController.kinhNghiemViTriController.text = firstText(
      kinhNghiem,
      ["viTri", "vi_tri", "chucVu", "chuc_vu"],
    );

    _profileController.kinhNghiemTuController.text = firstText(
      kinhNghiem,
      ["tu", "tuNgay", "tu_ngay", "batDau", "bat_dau"],
    );

    _profileController.kinhNghiemDenController.text = firstText(
      kinhNghiem,
      ["den", "denNgay", "den_ngay", "ketThuc", "ket_thuc"],
    );

    _profileController.kinhNghiemCongTyController.text = firstText(
      kinhNghiem,
      ["congTy", "cong_ty", "tenCongTy", "ten_cong_ty"],
    );

    _profileController.kinhNghiemMoTaController.text = firstText(
      kinhNghiem,
      ["moTa", "mo_ta", "moTaCongViec", "mo_ta_cong_viec"],
    );

    _profileController.kyNangController.text = getValue(
      ["kyNang", "ky_nang"],
    );

    _profileController.soThichController.text = getValue(
      ["soThich", "so_thich"],
    );

    final chungChi = parseJsonMap(
      getValue(["chungChi", "chung_chi"]),
    );

    _profileController.chungChiThoiGianController.text = firstText(
      chungChi,
      ["thoiGian", "thoi_gian"],
    );

    _profileController.chungChiTenController.text = firstText(
      chungChi,
      ["ten", "tenChungChi", "ten_chung_chi", "chungChi", "chung_chi"],
    );

    final danhHieu = parseJsonMap(
      getValue(["danhHieu", "danh_hieu"]),
    );

    _profileController.danhHieuThoiGianController.text = firstText(
      danhHieu,
      ["thoiGian", "thoi_gian"],
    );

    _profileController.danhHieuTenController.text = firstText(
      danhHieu,
      ["ten", "tenDanhHieu", "ten_danh_hieu", "danhHieu", "danh_hieu"],
    );

    final hoatDong = parseJsonMap(
      getValue(["hoatDong", "hoat_dong"]),
    );

    _profileController.hoatDongViTriController.text = firstText(
      hoatDong,
      ["viTri", "vi_tri", "vaiTro", "vai_tro"],
    );

    _profileController.hoatDongTuController.text = firstText(
      hoatDong,
      ["tu", "tuNgay", "tu_ngay", "batDau", "bat_dau"],
    );

    _profileController.hoatDongDenController.text = firstText(
      hoatDong,
      ["den", "denNgay", "den_ngay", "ketThuc", "ket_thuc"],
    );

    _profileController.hoatDongToChucController.text = firstText(
      hoatDong,
      ["toChuc", "to_chuc", "tenToChuc", "ten_to_chuc"],
    );

    _profileController.hoatDongMoTaController.text = firstText(
      hoatDong,
      ["moTa", "mo_ta"],
    );
  }

  Future<void> saveCvToDatabase() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      String savedIdCv;

      if (widget.isEdit && widget.idCv != null) {
        savedIdCv = await _profileController.updateTaoMauCvToDatabase(
          idCv: widget.idCv!,
          type: widget.type,
        );
      } else {
        savedIdCv = await _profileController.createTaoMauCvToDatabase(
          type: widget.type,
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LuuCvPage(
            showDownloadButton: true,
            showEditButton: true,
            idCv: savedIdCv,
            type: widget.type,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi lưu CV: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _profileController.disposeTaoMauControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget cvTemplate = widget.type == "pro"
        ? ProCvTemplate(
            profileController: _profileController,
            onPickAvatar: pickCvAvatar,
          )
        : SimpleCvTemplate(
            profileController: _profileController,
            onPickAvatar: pickCvAvatar,
          );

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: _profileController.tenCvController,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: "Tên CV",
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.grey),
        ),
        centerTitle: true,
      ),
      body: isLoadingOldCv
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : cvTemplate,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: isSaving || isLoadingOldCv || isPickingAvatar
                ? null
                : saveCvToDatabase,
            child: Text(
              isSaving ? "Đang lưu..." : "Lưu CV",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}