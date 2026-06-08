import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_user_model.dart';
import '../models/admin_recruiter_model.dart';

class AdminService {
  // Base URL chung — chỉ đổi port ở đây là xong
  static const String _base = "http://localhost:5249/api";

  // ─────────────────────────────────────────────
  // NGƯỜI TÌM VIỆC
  // ─────────────────────────────────────────────
  Future<List<AdminUserModel>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$_base/TaiKhoan/users'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => AdminUserModel.fromJson(item)).toList();
      } else {
        throw Exception("Không thể tải danh sách người dùng");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối API: $e");
    }
  }

  Future<bool> toggleUserStatus(int idTaiKhoan) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/TaiKhoan/toggle-status/$idTaiKhoan'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // NHÀ TUYỂN DỤNG
  // ─────────────────────────────────────────────

  /// Lấy danh sách NTD
  /// [trangThai] = 'cho_duyet' | 'da_xac_thuc' | null (tất cả)
  /// [search]    = tên công ty hoặc email
  Future<List<AdminRecruiterModel>> fetchRecruiters({
  String? trangThai,
  String? search,
  int page = 1,
  int pageSize = 20,
}) async {
  try {
    final params = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (trangThai != null) 'trangThai': trangThai,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri = Uri.parse('$_base/Admin/nha-tuyen-dung')
        .replace(queryParameters: params);

    print('=== RECRUITER API CALL ===');
    print('URL: $uri');

    final response = await http.get(uri);

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      print('DATA COUNT: ${data.length}');
      return data.map((e) => AdminRecruiterModel.fromJson(e)).toList();
    } else {
      throw Exception("Không thể tải danh sách nhà tuyển dụng");
    }
  } catch (e) {
    print('ERROR: $e');
    throw Exception("Lỗi kết nối API: $e");
  }
}

  /// Duyệt hoặc từ chối NTD
  /// [approve] = true → duyệt, false → từ chối
  Future<bool> updateRecruiterStatus(int idNtd, {required bool approve}) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/Admin/nha-tuyen-dung/$idNtd/duyet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'trangThai': approve}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}