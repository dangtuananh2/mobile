class AdminJobModel {
  final int idTin;
  final String tieuDe;
  final String? diaDiem;
  final String? mucLuong;
  final String? hinhThuc;
  final String? nganhNghe;
  final String? hanNop;
  final String trangThai;
  final String? ngayDang;
  final String? tenCongTy;
  final String? logoCongTy;

  AdminJobModel({
    required this.idTin,
    required this.tieuDe,
    this.diaDiem,
    this.mucLuong,
    this.hinhThuc,
    this.nganhNghe,
    this.hanNop,
    required this.trangThai,
    this.ngayDang,
    this.tenCongTy,
    this.logoCongTy,
  });

  factory AdminJobModel.fromJson(Map<String, dynamic> json) {
    return AdminJobModel(
      idTin: json['idTin'] ?? 0,
      tieuDe: json['tieuDe']?.toString() ?? 'N/A',
      diaDiem: json['diaDiem'],
      mucLuong: json['mucLuong'],
      hinhThuc: json['hinhThuc'],
      nganhNghe: json['nganhNghe'],
      hanNop: json['hanNop'],
      trangThai: json['trangThai']?.toString() ?? 'Đang tuyển',
      ngayDang: json['ngayDang'],
      tenCongTy: json['tenCongTy'],
      logoCongTy: json['logoCongTy'],
    );
  }
}