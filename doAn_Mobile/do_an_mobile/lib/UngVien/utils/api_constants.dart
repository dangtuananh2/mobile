class ApiConstants {
  static const String baseUrl = 'http://localhost:5249/api';

  // Nếu chạy Android Emulator thì đổi thành:
  // static const String baseUrl = 'http://10.0.2.2:5249/api';

  static const String taiKhoan = '$baseUrl/TaiKhoan';
  static const String login = '$baseUrl/TaiKhoan/login';
  static const String hoSoCv = '$baseUrl/HoSoCV';
  static const String ungVien = '$baseUrl/UngVien';
  static const String loiMoi = '$baseUrl/LoiMoi';
}
