import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../UngVien/utils/api_constants.dart';

class InvitationService {
  static Future<void> sendInvitation({
    required String idCv,
    required String hoTen,
    required String viTri,
    required String companyName,
    required String jobTitle,
    String salary = 'Thỏa thuận',
    String location = 'Hồ Chí Minh',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final response = await http.post(
      Uri.parse(ApiConstants.loiMoi),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idCv': idCv,
        'idTaikhoan': userId,
        'tieuDe': jobTitle,
        'noiDung': 'Chào $hoTen, chúng tôi muốn mời bạn ứng tuyển cho vị trí $viTri.',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi gửi lời mời: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getInvitations() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final String role = prefs.getString('vaiTro') ?? '';

    final url = role == 'nha_tuyen_dung'
        ? '${ApiConstants.loiMoi}/recruiter/$userId'
        : '${ApiConstants.loiMoi}/candidate/$userId';

    final res = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Lỗi tải danh sách lời mời: ${res.body}');
    }
  }

  static Future<void> uvRespondToInvitation({
    required String idCv,
    required String response,
    required String hoTen,
  }) async {
    final res = await http.put(
      Uri.parse('${ApiConstants.loiMoi}/respond'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idCv': idCv,
        'response': response,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Lỗi phản hồi lời mời: ${res.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getNtdNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final res = await http.get(
      Uri.parse('${ApiConstants.loiMoi}/notifications/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Lỗi tải thông báo: ${res.body}');
    }
  }

  static Future<void> saveNtdNotifications(
      List<Map<String, dynamic>> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final res = await http.put(
      Uri.parse('${ApiConstants.loiMoi}/notifications/mark-all-read/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('Lỗi lưu trạng thái thông báo: ${res.body}');
    }
  }
}
