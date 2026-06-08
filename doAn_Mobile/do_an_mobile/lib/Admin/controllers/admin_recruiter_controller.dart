import 'package:flutter/material.dart';
import '../models/admin_recruiter_model.dart';
import '../services/admin_service.dart';

class AdminRecruiterController extends ChangeNotifier {
  final AdminService _service = AdminService();

  // ── State ──────────────────────────────────────
  List<AdminRecruiterModel> pendingList = [];   // Chờ phê duyệt
  List<AdminRecruiterModel> verifiedList = [];  // Đã xác thực

  bool isLoadingPending = false;
  bool isLoadingVerified = false;
  String? errorPending;
  String? errorVerified;

  String searchQuery = '';

  // ── Load dữ liệu ───────────────────────────────

  Future<void> loadPending() async {
    isLoadingPending = true;
    errorPending = null;
    notifyListeners();
    try {
      pendingList = await _service.fetchRecruiters(
        trangThai: 'cho_duyet',
        search: searchQuery.isEmpty ? null : searchQuery,
      );
    } catch (e) {
      errorPending = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingPending = false;
      notifyListeners();
    }
  }

  Future<void> loadVerified() async {
    isLoadingVerified = true;
    errorVerified = null;
    notifyListeners();
    try {
      verifiedList = await _service.fetchRecruiters(
        trangThai: 'da_xac_thuc',
        search: searchQuery.isEmpty ? null : searchQuery,
      );
    } catch (e) {
      errorVerified = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingVerified = false;
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    await Future.wait([loadPending(), loadVerified()]);
  }

  // ── Tìm kiếm ───────────────────────────────────

  void onSearch(String query) {
    searchQuery = query;
    loadAll();
  }

  // ── Duyệt / Từ chối ────────────────────────────

  /// Trả về message để hiển thị SnackBar
  Future<String> approveRecruiter(int idNtd) async {
    final ok = await _service.updateRecruiterStatus(idNtd, approve: true);
    if (ok) {
      // Di chuyển từ pending sang verified
      final rec = pendingList.firstWhere((r) => r.idNtd == idNtd);
      pendingList.removeWhere((r) => r.idNtd == idNtd);
      verifiedList.insert(0, AdminRecruiterModel(
        idNtd: rec.idNtd,
        tenCongTy: rec.tenCongTy,
        logo: rec.logo,
        diaChi: rec.diaChi,
        linhVuc: rec.linhVuc,
        website: rec.website,
        email: rec.email,
        soDienThoai: rec.soDienThoai,
        trangThai: true,
        ngayTao: rec.ngayTao,
        soTinDang: rec.soTinDang,
      ));
      notifyListeners();
      return 'Đã duyệt ${rec.tenCongTy}';
    }
    return 'Không thể duyệt. Vui lòng thử lại.';
  }

  Future<String> rejectRecruiter(int idNtd) async {
    final ok = await _service.updateRecruiterStatus(idNtd, approve: false);
    if (ok) {
      final rec = pendingList.firstWhere((r) => r.idNtd == idNtd);
      pendingList.removeWhere((r) => r.idNtd == idNtd);
      notifyListeners();
      return 'Đã từ chối ${rec.tenCongTy}';
    }
    return 'Không thể từ chối. Vui lòng thử lại.';
  }
}