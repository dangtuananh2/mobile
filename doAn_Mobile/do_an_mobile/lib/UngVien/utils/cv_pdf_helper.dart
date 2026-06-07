import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/ho_so_cv_model.dart';
import 'cv_data_utils.dart';

class CvPdfHelper {
  static Future<void> sharePdf(HoSoCvModel cv) async {
    final pdf = pw.Document();

    final tieuDeCv = cv.getValue(
      ['tieuDeCv', 'tieu_de_cv'],
      defaultValue: 'CV',
    );

    final avatarBase64 = cv.getValue(
      ['anhCv', 'anh_cv'],
      defaultValue: '',
    );

    Uint8List? avatarBytes;

    if (avatarBase64.trim().isNotEmpty) {
      try {
        avatarBytes = base64Decode(avatarBase64);
      } catch (_) {
        avatarBytes = null;
      }
    }

    final hoTen = cv.getValue(
      ['hoTen', 'ho_ten'],
      defaultValue: 'Chưa cập nhật',
    );

    final viTriUngTuyen = cv.getValue(
      ['viTriUngTuyen', 'vi_tri_ung_tuyen', 'nganhNghe', 'nganh_nghe'],
      defaultValue: 'Chưa cập nhật',
    );

    final soDienThoai = cv.getValue(
      ['soDienThoai', 'so_dien_thoai'],
      defaultValue: 'Chưa cập nhật',
    );

    final email = cv.getValue(
      ['email'],
      defaultValue: 'Chưa cập nhật',
    );

    final ngaySinh = cv.getValue(
      ['ngaySinh', 'ngay_sinh'],
      defaultValue: 'Chưa cập nhật',
    );

    final diaChi = cv.getValue(
      ['diaChi', 'dia_chi'],
      defaultValue: 'Chưa cập nhật',
    );

    final facebook = cv.getValue(
      ['profileFacebook', 'profile_facebook'],
      defaultValue: 'Chưa cập nhật',
    );

    final mucTieu = cv.getValue(
      ['mucTieu', 'muc_tieu'],
      defaultValue: 'Chưa cập nhật',
    );

    final hocVanRaw = cv.getValue(['hocVan', 'hoc_van']);
    final moTaHocVan = cv.getValue(['moTaHocVan', 'mo_ta_hoc_van']);
    final kinhNghiemRaw = cv.getValue(['kinhNghiem', 'kinh_nghiem']);

    final kyNang = cv.getValue(
      ['kyNang', 'ky_nang'],
      defaultValue: 'Chưa cập nhật',
    );

    final soThich = cv.getValue(
      ['soThich', 'so_thich'],
      defaultValue: 'Chưa cập nhật',
    );

    final chungChiRaw = cv.getValue(['chungChi', 'chung_chi']);
    final danhHieuRaw = cv.getValue(['danhHieu', 'danh_hieu']);
    final hoatDongRaw = cv.getValue(['hoatDong', 'hoat_dong']);

    final nguoiGioiThieu = cv.getValue(
      ['nguoiGioiThieu', 'nguoi_gioi_thieu'],
      defaultValue: 'Chưa cập nhật',
    );

    String decodeField(String value) {
      return value.trim().startsWith('{')
          ? CvDataUtils.formatMapData(CvDataUtils.parseJsonField(value))
          : value;
    }

    final hocVan = decodeField(hocVanRaw);
    final kinhNghiem = decodeField(kinhNghiemRaw);
    final chungChi = decodeField(chungChiRaw);
    final danhHieu = decodeField(danhHieuRaw);
    final hoatDong = decodeField(hoatDongRaw);

    String pdfText(String value) => CvDataUtils.pdfText(value);

    pw.Widget sectionTitle(String title) {
      return pw.Text(
        pdfText(title),
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
      );
    }

    pw.Widget avatarWidget() {
      if (avatarBytes == null) {
        return pw.Container(
          width: 90,
          height: 90,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(width: 1),
          ),
          child: pw.Center(
            child: pw.Text(
              'Avatar',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        );
      }

      return pw.Container(
        width: 90,
        height: 90,
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          image: pw.DecorationImage(
            image: pw.MemoryImage(avatarBytes!),
            fit: pw.BoxFit.cover,
          ),
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                avatarWidget(),
                pw.SizedBox(width: 18),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        pdfText(tieuDeCv),
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        pdfText(hoTen),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        pdfText(viTriUngTuyen),
                        style: const pw.TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            sectionTitle('Thông tin cá nhân'),
            pw.SizedBox(height: 8),
            pw.Text(pdfText('Họ tên: $hoTen')),
            pw.Text(pdfText('Vị trí ứng tuyển: $viTriUngTuyen')),
            pw.Text(pdfText('Số điện thoại: $soDienThoai')),
            pw.Text(pdfText('Email: $email')),
            pw.Text(pdfText('Ngày sinh: $ngaySinh')),
            pw.Text(pdfText('Địa chỉ: $diaChi')),
            pw.Text(pdfText('Profile Facebook: $facebook')),

            pw.SizedBox(height: 20),

            sectionTitle('Mục tiêu nghề nghiệp'),
            pw.SizedBox(height: 8),
            pw.Text(pdfText(mucTieu)),

            pw.SizedBox(height: 20),

            sectionTitle('Học vấn'),
            pw.SizedBox(height: 8),
            pw.Text(pdfText(hocVan.isEmpty ? 'Chưa cập nhật' : hocVan)),

            if (moTaHocVan.trim().isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text(pdfText('Mô tả học vấn: $moTaHocVan')),
            ],

            pw.SizedBox(height: 20),

            sectionTitle('Kinh nghiệm làm việc'),
            pw.SizedBox(height: 8),
            pw.Text(
              pdfText(kinhNghiem.isEmpty ? 'Chưa cập nhật' : kinhNghiem),
            ),

            pw.SizedBox(height: 20),

            sectionTitle('Kỹ năng'),
            pw.SizedBox(height: 8),
            pw.Text(pdfText(kyNang)),

            pw.SizedBox(height: 20),

            sectionTitle('Sở thích'),
            pw.SizedBox(height: 8),
            pw.Text(pdfText(soThich)),

            pw.SizedBox(height: 20),

            sectionTitle('Chứng chỉ'),
            pw.SizedBox(height: 8),
            pw.Text(pdfText(chungChi.isEmpty ? 'Chưa cập nhật' : chungChi)),

            pw.SizedBox(height: 20),

            sectionTitle('Danh hiệu'),
            pw.SizedBox(height: 8),
            pw.Text(pdfText(danhHieu.isEmpty ? 'Chưa cập nhật' : danhHieu)),

            pw.SizedBox(height: 20),

            sectionTitle('Hoạt động'),
            pw.SizedBox(height: 8),
            pw.Text(pdfText(hoatDong.isEmpty ? 'Chưa cập nhật' : hoatDong)),

            pw.SizedBox(height: 20),

            sectionTitle('Người giới thiệu'),
            pw.SizedBox(height: 8),
            pw.Text(pdfText(nguoiGioiThieu)),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          '${CvDataUtils.removeVietnameseAccent(tieuDeCv).replaceAll(' ', '_')}.pdf',
    );
  }
}