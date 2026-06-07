// lib/NTD/services/ntd_cv_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../UngVien/utils/api_constants.dart';
import '../utils/cv_masking.dart';

class NtdCvService {
  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  /// Lấy tất cả CV đang tìm việc (trangThaiTimViec = true) — dùng cho tab Khám phá
  Future<List<Map<String, dynamic>>> getAllPublicCvs() async {
    final response = await http
        .get(Uri.parse('${ApiConstants.hoSoCv}/dang-tim-viec'), headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Lỗi tải CV: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> list = decoded is List ? decoded : [];
    return list.cast<Map<String, dynamic>>().map(CvMasking.maskCv).toList();
  }

  /// Lấy CV theo tin tuyển dụng
  Future<List<Map<String, dynamic>>> getCvsByTinTuyenDung(int idTinTuyenDung) async {
    final response = await http
        .get(
          Uri.parse('${ApiConstants.hoSoCv}/by-tin-tuyen-dung/$idTinTuyenDung'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Lỗi tải danh sách CV: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> list = decoded is List ? decoded : [];
    return list.cast<Map<String, dynamic>>().map(CvMasking.maskCv).toList();
  }

  /// Lấy chi tiết 1 CV
  Future<Map<String, dynamic>> getCvById(int idCv) async {
    final response = await http
        .get(Uri.parse('${ApiConstants.hoSoCv}/$idCv'), headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 404) throw Exception('Không tìm thấy CV');
    if (response.statusCode != 200) throw Exception('Lỗi tải CV: ${response.statusCode}');

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return CvMasking.maskCv(data);
  }
}