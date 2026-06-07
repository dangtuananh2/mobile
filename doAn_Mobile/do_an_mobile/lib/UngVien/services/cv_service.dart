import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/ho_so_cv_model.dart';
import '../utils/api_constants.dart';

class CvService {
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  Future<void> createCvByTaiKhoan({
    required int userId,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.hoSoCv}/create-by-taikhoan/$userId'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  Future<String> createCvByTaiKhoanReturnId({
    required int userId,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.hoSoCv}/create-by-taikhoan/$userId'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }

    if (response.body.trim().isEmpty) {
      throw Exception('API tạo CV chưa trả về dữ liệu CV');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final idCv = decoded['idCv'] ??
          decoded['id_cv'] ??
          decoded['idCV'] ??
          decoded['id'];

      if (idCv != null && idCv.toString().trim().isNotEmpty) {
        return idCv.toString();
      }
    }

    throw Exception('Không tìm thấy idCv trong response tạo CV');
  }

  Future<HoSoCvModel> getLatestCvByTaiKhoan(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.hoSoCv}/latest-by-taikhoan/$userId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return HoSoCvModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<HoSoCvModel>> getAllCvByTaiKhoan(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.hoSoCv}/by-taikhoan/$userId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map((item) => HoSoCvModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<HoSoCvModel> getCvById(String idCv) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.hoSoCv}/$idCv'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return HoSoCvModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> updateCvById({
    required String idCv,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.hoSoCv}/$idCv'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(response.body);
    }
  }

  Future<void> updateSearchStatus({
    required String idCv,
    required bool value,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.hoSoCv}/update-status/$idCv'),
      headers: _headers,
      body: jsonEncode({
        'trangThaiTimViec': value,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(response.body);
    }
  }
}