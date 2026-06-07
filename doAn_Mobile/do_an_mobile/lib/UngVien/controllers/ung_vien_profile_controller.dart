import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/ung_vien_profile_model.dart';
import '../services/ung_vien_profile_service.dart';
import 'cv_controller.dart';

class UngVienProfileController {
  final UngVienProfileService _service = UngVienProfileService();
  final CvController _cvController = CvController();

  // ================= PROFILE METHODS CŨ =================

  Future<UngVienProfileModel> loadLocalProfile() => _service.loadLocalProfile();

  Future<UngVienProfileModel?> fetchRemoteAccount(UngVienProfileModel current) {
    return _service.fetchRemoteAccount(current);
  }

  Future<void> saveAvatarPath(String path) => _service.saveAvatarPath(path);

  Future<void> logout() => _service.logout();

  Future<void> updateProfile({
    required int userId,
    required String hoTen,
    required String soDienThoai,
    required String gioiTinh,
    required String ngaySinh,
    required String diaChi,
    required String anhDaiDien,
  }) {
    return _service.updateProfile(
      userId: userId,
      hoTen: hoTen,
      soDienThoai: soDienThoai,
      gioiTinh: gioiTinh,
      ngaySinh: ngaySinh,
      diaChi: diaChi,
      anhDaiDien: anhDaiDien,
    );
  }

  // ================= AVATAR CHO CV =================

  Uint8List? avatarBytes;
  String? avatarBase64;
  String? avatarFileName;

  void setCvAvatar({
    required Uint8List bytes,
    required String fileName,
  }) {
    avatarBytes = bytes;
    avatarFileName = fileName;
    avatarBase64 = base64Encode(bytes);
  }

  void setCvAvatarFromBase64(String? value) {
    if (value == null || value.trim().isEmpty) return;

    try {
      avatarBase64 = value;
      avatarBytes = base64Decode(value);
    } catch (_) {
      avatarBase64 = null;
      avatarBytes = null;
    }
  }

  void clearCvAvatar() {
    avatarBytes = null;
    avatarBase64 = null;
    avatarFileName = null;
  }

  // ================= CONTROLLERS CHO TAOMAU.DART =================

  final TextEditingController tenCvController = TextEditingController();
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController viTriUngTuyenController = TextEditingController();
  final TextEditingController nganhNgheController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();
  final TextEditingController ngaySinhController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController diaChiController = TextEditingController();

  final TextEditingController nganhHocController = TextEditingController();
  final TextEditingController thoiGianHocController = TextEditingController();
  final TextEditingController tenTruongController = TextEditingController();
  final TextEditingController moTaHocVanController = TextEditingController();

  final TextEditingController mucTieuController = TextEditingController();

  final TextEditingController kinhNghiemViTriController =
      TextEditingController();
  final TextEditingController kinhNghiemTuController = TextEditingController();
  final TextEditingController kinhNghiemDenController = TextEditingController();
  final TextEditingController kinhNghiemCongTyController =
      TextEditingController();
  final TextEditingController kinhNghiemMoTaController =
      TextEditingController();

  final TextEditingController danhHieuThoiGianController =
      TextEditingController();
  final TextEditingController danhHieuTenController = TextEditingController();

  final TextEditingController chungChiThoiGianController =
      TextEditingController();
  final TextEditingController chungChiTenController = TextEditingController();

  final TextEditingController hoatDongViTriController = TextEditingController();
  final TextEditingController hoatDongTuController = TextEditingController();
  final TextEditingController hoatDongDenController = TextEditingController();
  final TextEditingController hoatDongToChucController =
      TextEditingController();
  final TextEditingController hoatDongMoTaController = TextEditingController();

  final TextEditingController kyNangController = TextEditingController();
  final TextEditingController soThichController = TextEditingController();
  final TextEditingController nguoiGioiThieuController =
      TextEditingController();

  // ================= NGÀY SINH =================

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Future<void> pickNgaySinh(BuildContext context) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (pickedDate != null) {
      ngaySinhController.text = formatDate(pickedDate);
    }
  }

  // ================= BUILD BODY CV =================

  Map<String, dynamic> _buildCvBody({
    required String type,
  }) {
    final hocVan = {
      "nganhHoc": nganhHocController.text.trim(),
      "thoiGian": thoiGianHocController.text.trim(),
      "tenTruong": tenTruongController.text.trim(),
      "moTa": moTaHocVanController.text.trim(),
    };

    final kinhNghiem = {
      "viTri": kinhNghiemViTriController.text.trim(),
      "tu": kinhNghiemTuController.text.trim(),
      "den": kinhNghiemDenController.text.trim(),
      "tenCongTy": kinhNghiemCongTyController.text.trim(),
      "moTa": kinhNghiemMoTaController.text.trim(),
    };

    final danhHieu = {
      "thoiGian": danhHieuThoiGianController.text.trim(),
      "ten": danhHieuTenController.text.trim(),
    };

    final chungChi = {
      "thoiGian": chungChiThoiGianController.text.trim(),
      "ten": chungChiTenController.text.trim(),
    };

    final hoatDong = {
      "viTri": hoatDongViTriController.text.trim(),
      "tu": hoatDongTuController.text.trim(),
      "den": hoatDongDenController.text.trim(),
      "toChuc": hoatDongToChucController.text.trim(),
      "moTa": hoatDongMoTaController.text.trim(),
    };

    final hoTen = hoTenController.text.trim();

    final tieuDeCv = tenCvController.text.trim().isEmpty
        ? "CV_$hoTen"
        : tenCvController.text.trim();

    return {
      "tieuDeCv": tieuDeCv,
      "tieu_de_cv": tieuDeCv,

      "anhCv": avatarBase64 ?? "",
      "anh_cv": avatarBase64 ?? "",

      "hoTen": hoTen,
      "ho_ten": hoTen,

      "viTriUngTuyen": viTriUngTuyenController.text.trim(),
      "vi_tri_ung_tuyen": viTriUngTuyenController.text.trim(),

      "soDienThoai": soDienThoaiController.text.trim(),
      "so_dien_thoai": soDienThoaiController.text.trim(),

      "ngaySinh": ngaySinhController.text.trim(),
      "ngay_sinh": ngaySinhController.text.trim(),

      "email": emailController.text.trim(),

      "profileFacebook": facebookController.text.trim(),
      "profile_facebook": facebookController.text.trim(),

      "diaChi": diaChiController.text.trim(),
      "dia_chi": diaChiController.text.trim(),

      "nguoiGioiThieu": nguoiGioiThieuController.text.trim(),
      "nguoi_gioi_thieu": nguoiGioiThieuController.text.trim(),

      "mucTieu": mucTieuController.text.trim(),
      "muc_tieu": mucTieuController.text.trim(),

      "hocVan": jsonEncode(hocVan),
      "hoc_van": jsonEncode(hocVan),

      "moTaHocVan": moTaHocVanController.text.trim(),
      "mo_ta_hoc_van": moTaHocVanController.text.trim(),

      "kinhNghiem": jsonEncode(kinhNghiem),
      "kinh_nghiem": jsonEncode(kinhNghiem),

      "kyNang": kyNangController.text.trim(),
      "ky_nang": kyNangController.text.trim(),

      "soThich": soThichController.text.trim(),
      "so_thich": soThichController.text.trim(),

      "chungChi": jsonEncode(chungChi),
      "chung_chi": jsonEncode(chungChi),

      "danhHieu": jsonEncode(danhHieu),
      "danh_hieu": jsonEncode(danhHieu),

      "hoatDong": jsonEncode(hoatDong),
      "hoat_dong": jsonEncode(hoatDong),

      "nganhNghe": nganhNgheController.text.trim(),
      "nganh_nghe": nganhNgheController.text.trim(),

      "trangThaiTimViec": true,
      "trang_thai_tim_viec": true,

      "loaiMauCv": type,
      "loai_mau_cv": type,
    };
  }

  // ================= LƯU CV TỪ TAOMAU.DART =================

  Future<String> createTaoMauCvToDatabase({
    required String type,
  }) async {
    final body = _buildCvBody(type: type);

    final idCv = await _cvController.createCvAndReturnId(body);

    return idCv;
  }

  Future<String> updateTaoMauCvToDatabase({
    required String idCv,
    required String type,
  }) async {
    final body = _buildCvBody(type: type);

    await _cvController.updateCvById(
      idCv: idCv,
      body: body,
    );

    return idCv;
  }

  Future<void> saveTaoMauCvToDatabase() async {
    final body = _buildCvBody(type: "simple");

    await _cvController.createCv(body);
  }

  // ================= DISPOSE CONTROLLERS =================

  void disposeTaoMauControllers() {
    tenCvController.dispose();
    hoTenController.dispose();
    viTriUngTuyenController.dispose();
    nganhNgheController.dispose();
    soDienThoaiController.dispose();
    ngaySinhController.dispose();
    emailController.dispose();
    facebookController.dispose();
    diaChiController.dispose();

    nganhHocController.dispose();
    thoiGianHocController.dispose();
    tenTruongController.dispose();
    moTaHocVanController.dispose();

    mucTieuController.dispose();

    kinhNghiemViTriController.dispose();
    kinhNghiemTuController.dispose();
    kinhNghiemDenController.dispose();
    kinhNghiemCongTyController.dispose();
    kinhNghiemMoTaController.dispose();

    danhHieuThoiGianController.dispose();
    danhHieuTenController.dispose();

    chungChiThoiGianController.dispose();
    chungChiTenController.dispose();

    hoatDongViTriController.dispose();
    hoatDongTuController.dispose();
    hoatDongDenController.dispose();
    hoatDongToChucController.dispose();
    hoatDongMoTaController.dispose();

    kyNangController.dispose();
    soThichController.dispose();
    nguoiGioiThieuController.dispose();
  }
}