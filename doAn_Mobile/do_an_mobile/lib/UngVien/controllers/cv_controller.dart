import 'package:shared_preferences/shared_preferences.dart';

import '../models/ho_so_cv_model.dart';
import '../services/cv_service.dart';

class CvController {
  final CvService _cvService = CvService();

  Future<int> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Không tìm thấy tài khoản đăng nhập');
    }

    return userId;
  }

  Future<void> createCv(Map<String, dynamic> body) async {
    final userId = await getCurrentUserId();

    await _cvService.createCvByTaiKhoan(
      userId: userId,
      body: body,
    );
  }

  Future<String> createCvAndReturnId(Map<String, dynamic> body) async {
    final userId = await getCurrentUserId();

    final idCv = await _cvService.createCvByTaiKhoanReturnId(
      userId: userId,
      body: body,
    );

    return idCv;
  }

  Future<HoSoCvModel> getLatestCv() async {
    final userId = await getCurrentUserId();

    return _cvService.getLatestCvByTaiKhoan(userId);
  }

  Future<List<HoSoCvModel>> getAllCvByTaiKhoan() async {
    final userId = await getCurrentUserId();

    return _cvService.getAllCvByTaiKhoan(userId);
  }

  Future<HoSoCvModel> getCvById(String idCv) async {
    if (idCv.trim().isEmpty) {
      throw Exception('idCv không hợp lệ');
    }

    return _cvService.getCvById(idCv);
  }

  Future<void> updateCvById({
    required String idCv,
    required Map<String, dynamic> body,
  }) async {
    if (idCv.trim().isEmpty) {
      throw Exception('idCv không hợp lệ');
    }

    await _cvService.updateCvById(
      idCv: idCv,
      body: body,
    );
  }

  Future<void> updateSearchStatus({
    required String idCv,
    required bool value,
  }) {
    if (idCv.trim().isEmpty) {
      return Future.value();
    }

    return _cvService.updateSearchStatus(
      idCv: idCv,
      value: value,
    );
  }
}