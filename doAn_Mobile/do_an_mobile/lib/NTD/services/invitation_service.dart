import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InvitationService {
  static const String _invitationsKey = 'ntd_invitations';
  static const String _notificationsKey = 'ntd_notifications';

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

    final List<Map<String, dynamic>> invitations = await getInvitations();

    final existing = invitations.indexWhere((inv) => inv['idCv'] == idCv);
    if (existing != -1) {
      invitations[existing] = {
        'idCv': idCv,
        'hoTen': hoTen,
        'viTri': viTri,
        'companyName': companyName,
        'jobTitle': jobTitle,
        'salary': salary,
        'location': location,
        'trangThai': 'Chờ phản hồi',
        'thoiGian': DateTime.now().toIso8601String(),
      };
    } else {
      invitations.add({
        'idCv': idCv,
        'hoTen': hoTen,
        'viTri': viTri,
        'companyName': companyName,
        'jobTitle': jobTitle,
        'salary': salary,
        'location': location,
        'trangThai': 'Chờ phản hồi',
        'thoiGian': DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString(_invitationsKey, jsonEncode(invitations));

    await _syncToUv(
      idCv: idCv,
      hoTen: hoTen,
      viTri: viTri,
      companyName: companyName,
      jobTitle: jobTitle,
      salary: salary,
      location: location,
    );
  }

  static Future<void> _syncToUv({
    required String idCv,
    required String hoTen,
    required String viTri,
    required String companyName,
    required String jobTitle,
    required String salary,
    required String location,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString('uv_invitations') ?? '[]';
    final List<dynamic> list = jsonDecode(raw);
    final List<Map<String, dynamic>> uvInvitations =
        list.cast<Map<String, dynamic>>();

    final existing = uvInvitations.indexWhere((inv) => inv['idCv'] == idCv);
    final entry = {
      'idCv': idCv,
      'hoTen': hoTen,
      'viTri': viTri,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'salary': salary,
      'location': location,
      'trangThai': 'Chờ phản hồi',
      'thoiGian': DateTime.now().toIso8601String(),
    };

    if (existing != -1) {
      uvInvitations[existing] = entry;
    } else {
      uvInvitations.add(entry);
    }

    await prefs.setString('uv_invitations', jsonEncode(uvInvitations));
  }

  static Future<List<Map<String, dynamic>>> getInvitations() async {
    final prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString(_invitationsKey) ?? '[]';
    final List<dynamic> list = jsonDecode(raw);
    return list.cast<Map<String, dynamic>>();
  }

  static Future<void> uvRespondToInvitation({
    required String idCv,
    required String response,
    required String hoTen,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final invitations = await getInvitations();
    final idx = invitations.indexWhere((inv) => inv['idCv'] == idCv);
    if (idx != -1) {
      invitations[idx]['trangThai'] = response;
      await prefs.setString(_invitationsKey, jsonEncode(invitations));
    }

    final String uvRaw = prefs.getString('uv_invitations') ?? '[]';
    final List<dynamic> uvList = jsonDecode(uvRaw);
    final List<Map<String, dynamic>> uvInvitations =
        uvList.cast<Map<String, dynamic>>();
    final uvIdx = uvInvitations.indexWhere((inv) => inv['idCv'] == idCv);
    if (uvIdx != -1) {
      uvInvitations[uvIdx]['trangThai'] = response;
      await prefs.setString('uv_invitations', jsonEncode(uvInvitations));
    }

    await _addNtdNotification(
      title: response == 'Đồng ý'
          ? '$hoTen đã đồng ý lời mời'
          : '$hoTen đã từ chối lời mời',
      body: response == 'Đồng ý'
          ? '$hoTen đã chấp nhận lời mời kết nối từ công ty bạn. Hãy liên hệ sớm!'
          : '$hoTen đã từ chối lời mời. Bạn có thể thử với ứng viên khác.',
      isAccepted: response == 'Đồng ý',
    );
  }

  static Future<void> _addNtdNotification({
    required String title,
    required String body,
    required bool isAccepted,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString(_notificationsKey) ?? '[]';
    final List<dynamic> list = jsonDecode(raw);
    final List<Map<String, dynamic>> notifications =
        list.cast<Map<String, dynamic>>();

    notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'sub': body,
      'time': 'Vừa xong',
      'unread': true,
      'type': isAccepted ? 'accepted' : 'rejected',
    });

    await prefs.setString(_notificationsKey, jsonEncode(notifications));
  }

  static Future<List<Map<String, dynamic>>> getNtdNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString(_notificationsKey) ?? '[]';
    final List<dynamic> list = jsonDecode(raw);
    return list.cast<Map<String, dynamic>>();
  }

  static Future<void> saveNtdNotifications(
      List<Map<String, dynamic>> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsKey, jsonEncode(notifications));
  }
}
