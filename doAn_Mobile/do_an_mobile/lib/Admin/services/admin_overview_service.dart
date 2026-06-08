import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_overview_model.dart';

class AdminOverviewService {
  static const String _base = "http://localhost:5249/api";

  Future<AdminOverviewModel> fetchThongKe() async {
    try {
      final response = await http.get(Uri.parse('$_base/admin/thong-ke'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return AdminOverviewModel.fromJson(json);
      } else {
        throw Exception('Không thể tải thống kê');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}