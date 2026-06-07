// lib/NTD/utils/cv_masking.dart

/// Utility để ẩn thông tin nhạy cảm của ứng viên khi hiển thị cho NTD.
///
/// Áp dụng cho:
///  - Thông tin cá nhân: tên, SĐT, email, địa chỉ, ngày sinh
///  - Lịch sử ứng tuyển: tên công ty đã từng nộp hồ sơ
class CvMasking {
  CvMasking._();

  // ─── Public entry-point ────────────────────────────────────────────────────

  /// Nhận 1 Map CV thô từ API → trả về Map đã mask.
  /// Không thay đổi dữ liệu gốc (immutable copy).
  static Map<String, dynamic> maskCv(Map<String, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);

    // Thông tin cá nhân
    m['hoTen']       = _maskName(raw['hoTen']);
    m['soDienThoai'] = _maskPhone(raw['soDienThoai']);
    m['email']       = _maskEmail(raw['email']);
    m['diaChi']      = _maskAddress(raw['diaChi']);
    m['ngaySinh']    = _maskDate(raw['ngaySinh']);

    // Lịch sử ứng tuyển — che tên công ty
    m['lichSuUngTuyen'] = _maskApplicationHistory(raw['lichSuUngTuyen']);

    // Các trường tự do có thể chứa tên công ty cũ (kinh nghiệm)
    m["kinhNghiem"] = maskCompanyNamesInText(raw['kinhNghiem']);

    return m;
  }

  // ─── Personal info masking ─────────────────────────────────────────────────

  /// "Nguyễn Văn An" → "Nguyễn V*** A***"
  static String? _maskName(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    final parts = val.toString().trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return '${parts[0][0]}***';
    return parts
        .map((p) => p.isEmpty ? p : '${p[0]}${'*' * (p.length - 1).clamp(1, 3)}')
        .join(' ');
  }

  /// "0912345678" → "091*****78"
  static String? _maskPhone(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    final s = val.toString().trim();
    if (s.length < 6) return '***';
    final visible = 3;
    return '${s.substring(0, visible)}${'*' * (s.length - visible - 2)}${s.substring(s.length - 2)}';
  }

  /// "user@gmail.com" → "us***@g***.com"
  static String? _maskEmail(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    final s = val.toString().trim();
    final atIdx = s.indexOf('@');
    if (atIdx <= 0) return '***';
    final local = s.substring(0, atIdx);
    final domain = s.substring(atIdx + 1);
    final dotIdx = domain.lastIndexOf('.');
    final maskedLocal = local.length <= 2
        ? '${local[0]}***'
        : '${local.substring(0, 2)}${'*' * (local.length - 2).clamp(1, 4)}';
    final maskedDomain = dotIdx > 0
        ? '${domain[0]}***${domain.substring(dotIdx)}'
        : '***';
    return '$maskedLocal@$maskedDomain';
  }

  /// "123 Nguyễn Trãi, Q5, HCM" → "*** ***, Q5, HCM" (giữ quận/tỉnh)
  static String? _maskAddress(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    final parts = val.toString().split(',');
    if (parts.length == 1) return '*** ***';
    // Giữ lại phần quận/huyện/tỉnh (phần tử thứ 2 trở đi)
    return ['*** ***', ...parts.skip(1)].join(',');
  }

  /// "1999-05-20" → "**/**/****"
  static String? _maskDate(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    return '**/**/****';
  }

  // ─── Application history masking ──────────────────────────────────────────

  /// Mask danh sách lịch sử ứng tuyển — che tên công ty.
  /// Input có thể là List<dynamic> hoặc null.
  static dynamic _maskApplicationHistory(dynamic val) {
    if (val == null) return null;
    if (val is List) {
      return val.map((item) {
        if (item is Map<String, dynamic>) {
          final copy = Map<String, dynamic>.from(item);
          copy['tenCongTy']  = _maskCompanyName(copy['tenCongTy']);
          copy['congTy']     = _maskCompanyName(copy['congTy']);
          copy['employer']   = _maskCompanyName(copy['employer']);
          copy['company']    = _maskCompanyName(copy['company']);
          copy['noiLamViec'] = _maskCompanyName(copy['noiLamViec']);
          return copy;
        }
        return item;
      }).toList();
    }
    return val;
  }

  /// "ABC Corporation" → "A*** C***"
  static String? _maskCompanyName(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    return val
        .toString()
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : '${w[0]}${'*' * w.length.clamp(2, 4)}')
        .join(' ');
  }

  // ─── Free-text masking ─────────────────────────────────────────────────────

  /// Che tên công ty trong văn bản tự do (trường kinhNghiem).
  /// Pattern: Từ/cụm từ xuất hiện sau "tại", "ở", "công ty", "company", "CTY"
  static String? maskCompanyNamesInText(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    String text = val.toString();

    // Các pattern thường gặp: "tại Công ty ABC", "ở CTY XYZ", "company XYZ"
    final patterns = [
      RegExp(r'(?<=\b(tại|ở|company|cty|công ty)\s{1,3})([A-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪỬỮỰỲỴÝỶỸ][^\s,\.;\n]{2,}(\s[A-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪỬỮỰỲỴÝỶỸ][^\s,\.;\n]{0,})*)', caseSensitive: false),
    ];

    for (final re in patterns) {
      text = text.replaceAllMapped(re, (m) {
        final company = m.group(0) ?? '';
        return _maskCompanyName(company) ?? company;
      });
    }
    return text;
  }

  /// Public helper — dùng trực tiếp từ UI để mask text kinh nghiệm
  static String maskKinhNghiem(String text) =>
      maskCompanyNamesInText(text) ?? text;
}