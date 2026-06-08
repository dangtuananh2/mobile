class AdminUserModel {
  final int idTaiKhoan;
  final int? idUngVien;
  final String email;
  final String hoTen;
  final String soDienThoai;
  final String? diaChi;
  final String viTriUngTuyen;
  bool trangThai;

  AdminUserModel({
    required this.idTaiKhoan,
    this.idUngVien,
    required this.email,
    required this.hoTen,
    required this.soDienThoai,
    this.diaChi,
    required this.viTriUngTuyen,
    required this.trangThai,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      idTaiKhoan: json['idTaiKhoan'],
      idUngVien: json['idUngVien'],
      email: json['email'] ?? '',
      hoTen: json['hoTen'] ?? 'Chưa cập nhật',
      soDienThoai: json['soDienThoai'] ?? '',
      diaChi: json['diaChi'],
      viTriUngTuyen: json['viTriUngTuyen'] ?? 'Chưa cập nhật',
      trangThai: json['trangThai'] ?? true,
    );
  }
}