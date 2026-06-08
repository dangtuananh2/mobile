import '../models/admin_user_model.dart';
import '../services/admin_service.dart';

class AdminController {
  final AdminService _adminService = AdminService();

  // Hàm lấy danh sách người dùng từ Service
  Future<List<AdminUserModel>> getUserList() {
    return _adminService.fetchUsers();
  }

  // Hàm gọi xử lý khóa/mở khóa tài khoản
  Future<bool> toggleUserStatus(int idTaiKhoan) {
    return _adminService.toggleUserStatus(idTaiKhoan);
  }
}