class TinTheoTrangThai {
  final String trangThai;
  final int soLuong;

  TinTheoTrangThai({required this.trangThai, required this.soLuong});

  factory TinTheoTrangThai.fromJson(Map<String, dynamic> json) {
    return TinTheoTrangThai(
      trangThai: json['trangThai']?.toString() ?? '',
      soLuong: json['soLuong'] ?? 0,
    );
  }
}

class AdminOverviewModel {
  final int tongNguoiDung;
  final int tongNhaTuyenDung;
  final int tongTinTuyenDung;
  final int tongCv;
  final int tongUngTuyen;
  final int ntdChoDuyet;
  final int tinChoDuyet;
  final List<TinTheoTrangThai> tinTheoTrangThai;

  AdminOverviewModel({
    required this.tongNguoiDung,
    required this.tongNhaTuyenDung,
    required this.tongTinTuyenDung,
    required this.tongCv,
    required this.tongUngTuyen,
    required this.ntdChoDuyet,
    required this.tinChoDuyet,
    required this.tinTheoTrangThai,
  });

  factory AdminOverviewModel.fromJson(Map<String, dynamic> json) {
    return AdminOverviewModel(
      tongNguoiDung: json['tongNguoiDung'] ?? 0,
      tongNhaTuyenDung: json['tongNhaTuyenDung'] ?? 0,
      tongTinTuyenDung: json['tongTinTuyenDung'] ?? 0,
      tongCv: json['tongCv'] ?? 0,
      tongUngTuyen: json['tongUngTuyen'] ?? 0,
      ntdChoDuyet: json['ntdChoDuyet'] ?? 0,
      tinChoDuyet: json['tinChoDuyet'] ?? 0,
      tinTheoTrangThai: (json['tinTheoTrangThai'] as List<dynamic>? ?? [])
          .map((e) => TinTheoTrangThai.fromJson(e))
          .toList(),
    );
  }
}