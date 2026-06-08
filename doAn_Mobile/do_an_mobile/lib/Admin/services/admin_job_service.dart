import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_job_model.dart';

class AdminJobService {
  static const String _base = "http://localhost:5249/api";

  Future<List<AdminJobModel>> fetchJobs({
    String? trangThai,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final params = <String, String>{
        'page': '$page',
        'pageSize': '$pageSize',
        if (trangThai != null && trangThai.isNotEmpty) 'trangThai': trangThai,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      final uri = Uri.parse('$_base/admin/tin-tuyen-dung')
          .replace(queryParameters: params);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data.map((e) => AdminJobModel.fromJson(e)).toList();
      } else {
        throw Exception('Không thể tải danh sách tin');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  Future<bool> updateTrangThai(int idTin, String trangThai) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/admin/tin-tuyen-dung/$idTin/trang-thai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'trangThai': trangThai}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTin(int idTin,
      {String? tieuDe, String? moTaCongViec, String? yeuCau, String? mucLuong}) async {
    try {
      final body = <String, dynamic>{};
      if (tieuDe != null) body['tieuDe'] = tieuDe;
      if (moTaCongViec != null) body['moTaCongViec'] = moTaCongViec;
      if (yeuCau != null) body['yeuCau'] = yeuCau;
      if (mucLuong != null) body['mucLuong'] = mucLuong;

      final response = await http.put(
        Uri.parse('$_base/admin/tin-tuyen-dung/$idTin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTin(int idTin) async {
    try {
      final response = await http.delete(
        Uri.parse('$_base/admin/tin-tuyen-dung/$idTin'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}