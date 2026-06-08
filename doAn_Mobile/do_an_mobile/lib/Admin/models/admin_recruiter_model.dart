class AdminRecruiterModel {
  final int idNtd;
  final String tenCongTy;
  final String? logo;
  final String? diaChi;
  final String? linhVuc;
  final String? website;
  final String? email;
  final String? soDienThoai;
  final bool trangThai;
  final DateTime? ngayTao;
  final int soTinDang;

  AdminRecruiterModel({
    required this.idNtd,
    required this.tenCongTy,
    this.logo,
    this.diaChi,
    this.linhVuc,
    this.website,
    this.email,
    this.soDienThoai,
    required this.trangThai,
    this.ngayTao,
    required this.soTinDang,
  });

  factory AdminRecruiterModel.fromJson(Map<String, dynamic> json) {
  return AdminRecruiterModel(
    idNtd: json['idNtd'] ?? 0,
    tenCongTy: json['tenCongTy']?.toString() ?? 'N/A',  // ✅ sửa
    logo: json['logo'],
    diaChi: json['diaChi'],
    linhVuc: json['linhVuc'],
    website: json['website'],
    email: json['email'],
    soDienThoai: json['soDienThoai'],
    trangThai: json['trangThai'] ?? false,
    ngayTao: json['ngayTao'] != null ? DateTime.tryParse(json['ngayTao']) : null,
    soTinDang: (json['soTinDang'] ?? 0) as int,  // ✅ sửa
  );
}
}