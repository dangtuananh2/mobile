using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaoAPI.Entities;
using System.Globalization;

namespace TaoAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class HoSoCVController : ControllerBase
    {
        private readonly MobileAppContext _context;

        public HoSoCVController(MobileAppContext context)
        {
            _context = context;
        }

        // POST: api/HoSoCV/create-by-taikhoan/1
        [HttpPost("create-by-taikhoan/{idTaiKhoan}")]
        public async Task<ActionResult> CreateByTaiKhoan(
            int idTaiKhoan,
            [FromBody] CreateHoSoCvRequest request)
        {
            try
            {
                var ungVien = await _context.UngViens
                    .FirstOrDefaultAsync(x => x.IdTaikhoan == idTaiKhoan);

                if (ungVien == null)
                {
                    return NotFound(new
                    {
                        message = "Không tìm thấy ứng viên theo tài khoản này"
                    });
                }

                var taiKhoan = await _context.TaiKhoans
                    .FirstOrDefaultAsync(x => x.IdTaikhoan == idTaiKhoan);

                if (taiKhoan == null)
                {
                    return NotFound(new
                    {
                        message = "Không tìm thấy tài khoản"
                    });
                }

                var check = await UpdateUngVienAndTaiKhoan(
                    ungVien,
                    taiKhoan,
                    request,
                    idTaiKhoan
                );

                if (check != null)
                {
                    return check;
                }

                var cv = new HoSoCv
                {
                    IdUngvien = ungVien.IdUngvien,
                    LoaiMauCv = NormalizeLoaiMauCv(request.LoaiMauCv),
                    TieuDeCv = request.TieuDeCv,
                    AnhCv = request.AnhCv,
                    MucTieu = request.MucTieu,
                    HocVan = request.HocVan,
                    MoTaHocVan = request.MoTaHocVan,
                    KinhNghiem = request.KinhNghiem,
                    KyNang = request.KyNang,
                    SoThich = request.SoThich,
                    ChungChi = request.ChungChi,
                    DanhHieu = request.DanhHieu,
                    HoatDong = request.HoatDong,
                    NganhNghe = request.NganhNghe,
                    TrangThaiTimViec = request.TrangThaiTimViec ?? true,
                    TrangThai = true,
                    NgayTao = DateTime.Now,
                    NgayCapNhat = null
                };

                _context.HoSoCvs.Add(cv);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "Lưu CV thành công",
                    idCv = cv.IdCv,
                    loaiMauCv = cv.LoaiMauCv
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Lỗi khi lưu CV",
                    error = ex.Message,
                    inner = ex.InnerException?.Message
                });
            }
        }

        // GET: api/HoSoCV/latest-by-taikhoan/1
        [HttpGet("latest-by-taikhoan/{idTaiKhoan}")]
        public async Task<ActionResult> GetLatestByTaiKhoan(int idTaiKhoan)
        {
            try
            {
                var data = await GetBaseCvQuery(idTaiKhoan)
                    .OrderByDescending(x => x.Cv.IdCv)
                    .FirstOrDefaultAsync();

                if (data == null)
                {
                    return NotFound(new
                    {
                        message = "Chưa có CV nào"
                    });
                }

                return Ok(ToCvResponse(data.Cv, data.UngVien, data.TaiKhoan));
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Lỗi khi lấy CV",
                    error = ex.Message,
                    inner = ex.InnerException?.Message
                });
            }
        }

        // GET: api/HoSoCV/by-taikhoan/1
        [HttpGet("by-taikhoan/{idTaiKhoan}")]
        public async Task<ActionResult> GetAllByTaiKhoan(int idTaiKhoan)
        {
            try
            {
                var list = await GetBaseCvQuery(idTaiKhoan)
                    .OrderByDescending(x => x.Cv.IdCv)
                    .ToListAsync();

                var result = list.Select(x => ToCvResponse(
                    x.Cv,
                    x.UngVien,
                    x.TaiKhoan
                ));

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Lỗi khi lấy danh sách CV",
                    error = ex.Message,
                    inner = ex.InnerException?.Message
                });
            }
        }

        // GET: api/HoSoCV/5
        [HttpGet("{idCv}")]
        public async Task<ActionResult> GetById(int idCv)
        {
            try
            {
                var data = await (
                    from cv in _context.HoSoCvs
                    join uv in _context.UngViens
                        on cv.IdUngvien equals uv.IdUngvien
                    join tk in _context.TaiKhoans
                        on uv.IdTaikhoan equals tk.IdTaikhoan
                    where cv.IdCv == idCv
                    select new CvJoinResult
                    {
                        Cv = cv,
                        UngVien = uv,
                        TaiKhoan = tk
                    }
                ).FirstOrDefaultAsync();

                if (data == null)
                {
                    return NotFound(new
                    {
                        message = "Không tìm thấy CV"
                    });
                }

                return Ok(ToCvResponse(data.Cv, data.UngVien, data.TaiKhoan));
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Lỗi khi lấy CV theo id",
                    error = ex.Message,
                    inner = ex.InnerException?.Message
                });
            }
        }

        // PUT: api/HoSoCV/5
        [HttpPut("{idCv}")]
        public async Task<ActionResult> UpdateById(
            int idCv,
            [FromBody] CreateHoSoCvRequest request)
        {
            try
            {
                var cv = await _context.HoSoCvs
                    .FirstOrDefaultAsync(x => x.IdCv == idCv);

                if (cv == null)
                {
                    return NotFound(new
                    {
                        message = "Không tìm thấy CV"
                    });
                }

                var ungVien = await _context.UngViens
                    .FirstOrDefaultAsync(x => x.IdUngvien == cv.IdUngvien);

                if (ungVien == null)
                {
                    return NotFound(new
                    {
                        message = "Không tìm thấy ứng viên"
                    });
                }

                var taiKhoan = await _context.TaiKhoans
                    .FirstOrDefaultAsync(x => x.IdTaikhoan == ungVien.IdTaikhoan);

                if (taiKhoan == null)
                {
                    return NotFound(new
                    {
                        message = "Không tìm thấy tài khoản"
                    });
                }

                var check = await UpdateUngVienAndTaiKhoan(
                    ungVien,
                    taiKhoan,
                    request,
                    ungVien.IdTaikhoan
                );

                if (check != null)
                {
                    return check;
                }

                cv.LoaiMauCv = NormalizeLoaiMauCv(request.LoaiMauCv);
                cv.TieuDeCv = request.TieuDeCv;
                cv.AnhCv = request.AnhCv;
                cv.MucTieu = request.MucTieu;
                cv.HocVan = request.HocVan;
                cv.MoTaHocVan = request.MoTaHocVan;
                cv.KinhNghiem = request.KinhNghiem;
                cv.KyNang = request.KyNang;
                cv.SoThich = request.SoThich;
                cv.ChungChi = request.ChungChi;
                cv.DanhHieu = request.DanhHieu;
                cv.HoatDong = request.HoatDong;
                cv.NganhNghe = request.NganhNghe;
                cv.TrangThaiTimViec = request.TrangThaiTimViec ?? cv.TrangThaiTimViec;
                cv.TrangThai = true;
                cv.NgayCapNhat = DateTime.Now;

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "Cập nhật CV thành công",
                    idCv = cv.IdCv,
                    loaiMauCv = cv.LoaiMauCv
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Lỗi khi cập nhật CV",
                    error = ex.Message,
                    inner = ex.InnerException?.Message
                });
            }
        }

        // PUT: api/HoSoCV/update-status/5
        [HttpPut("update-status/{idCv}")]
        public async Task<ActionResult> UpdateStatus(
            int idCv,
            [FromBody] UpdateCvStatusRequest request)
        {
            try
            {
                var cv = await _context.HoSoCvs.FindAsync(idCv);

                if (cv == null)
                {
                    return NotFound(new
                    {
                        message = "Không tìm thấy CV"
                    });
                }

                cv.TrangThaiTimViec = request.TrangThaiTimViec;
                cv.NgayCapNhat = DateTime.Now;

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "Cập nhật trạng thái CV thành công"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Lỗi khi cập nhật trạng thái CV",
                    error = ex.Message,
                    inner = ex.InnerException?.Message
                });
            }
        }

        private IQueryable<CvJoinResult> GetBaseCvQuery(int idTaiKhoan)
        {
            return
                from uv in _context.UngViens
                join tk in _context.TaiKhoans
                    on uv.IdTaikhoan equals tk.IdTaikhoan
                join cv in _context.HoSoCvs
                    on uv.IdUngvien equals cv.IdUngvien
                where uv.IdTaikhoan == idTaiKhoan
                select new CvJoinResult
                {
                    Cv = cv,
                    UngVien = uv,
                    TaiKhoan = tk
                };
        }

        private object ToCvResponse(
            HoSoCv cv,
            UngVien ungVien,
            TaiKhoan taiKhoan)
        {
            return new
            {
                idCv = cv.IdCv,
                id_cv = cv.IdCv,

                idUngvien = cv.IdUngvien,
                id_ungvien = cv.IdUngvien,

                loaiMauCv = cv.LoaiMauCv,
                loai_mau_cv = cv.LoaiMauCv,

                tieuDeCv = cv.TieuDeCv,
                tieu_de_cv = cv.TieuDeCv,

                anhCv = cv.AnhCv,
                anh_cv = cv.AnhCv,

                hoTen = ungVien.HoTen,
                ho_ten = ungVien.HoTen,

                soDienThoai = taiKhoan.SoDienThoai,
                so_dien_thoai = taiKhoan.SoDienThoai,

                email = taiKhoan.Email,

                ngaySinh = ungVien.NgaySinh.HasValue
                    ? ungVien.NgaySinh.Value.ToString("dd/MM/yyyy")
                    : null,
                ngay_sinh = ungVien.NgaySinh.HasValue
                    ? ungVien.NgaySinh.Value.ToString("dd/MM/yyyy")
                    : null,

                gioiTinh = ungVien.GioiTinh,
                gioi_tinh = ungVien.GioiTinh,

                diaChi = ungVien.DiaChi,
                dia_chi = ungVien.DiaChi,

                anhDaiDien = ungVien.AnhDaiDien,
                anh_dai_dien = ungVien.AnhDaiDien,

                viTriUngTuyen = ungVien.ViTriUngTuyen,
                vi_tri_ung_tuyen = ungVien.ViTriUngTuyen,

                profileFacebook = ungVien.ProfileFacebook,
                profile_facebook = ungVien.ProfileFacebook,

                nguoiGioiThieu = ungVien.NguoiGioiThieu,
                nguoi_gioi_thieu = ungVien.NguoiGioiThieu,

                mucTieu = cv.MucTieu,
                muc_tieu = cv.MucTieu,

                hocVan = cv.HocVan,
                hoc_van = cv.HocVan,

                moTaHocVan = cv.MoTaHocVan,
                mo_ta_hoc_van = cv.MoTaHocVan,

                kinhNghiem = cv.KinhNghiem,
                kinh_nghiem = cv.KinhNghiem,

                kyNang = cv.KyNang,
                ky_nang = cv.KyNang,

                soThich = cv.SoThich,
                so_thich = cv.SoThich,

                chungChi = cv.ChungChi,
                chung_chi = cv.ChungChi,

                danhHieu = cv.DanhHieu,
                danh_hieu = cv.DanhHieu,

                hoatDong = cv.HoatDong,
                hoat_dong = cv.HoatDong,

                nganhNghe = cv.NganhNghe,
                nganh_nghe = cv.NganhNghe,

                trangThaiTimViec = cv.TrangThaiTimViec,
                trang_thai_tim_viec = cv.TrangThaiTimViec,

                trangThai = cv.TrangThai,
                trang_thai = cv.TrangThai,

                ngayTao = cv.NgayTao,
                ngay_tao = cv.NgayTao,

                ngayCapNhat = cv.NgayCapNhat,
                ngay_cap_nhat = cv.NgayCapNhat
            };
        }

        private async Task<ActionResult?> UpdateUngVienAndTaiKhoan(
            UngVien ungVien,
            TaiKhoan taiKhoan,
            CreateHoSoCvRequest request,
            int idTaiKhoan)
        {
            if (!string.IsNullOrWhiteSpace(request.HoTen))
            {
                ungVien.HoTen = request.HoTen;
            }

            if (!string.IsNullOrWhiteSpace(request.DiaChi))
            {
                ungVien.DiaChi = request.DiaChi;
            }

            if (!string.IsNullOrWhiteSpace(request.ViTriUngTuyen))
            {
                ungVien.ViTriUngTuyen = request.ViTriUngTuyen;
            }

            if (!string.IsNullOrWhiteSpace(request.ProfileFacebook))
            {
                ungVien.ProfileFacebook = request.ProfileFacebook;
            }

            if (!string.IsNullOrWhiteSpace(request.NguoiGioiThieu))
            {
                ungVien.NguoiGioiThieu = request.NguoiGioiThieu;
            }

            if (!string.IsNullOrWhiteSpace(request.NgaySinh))
            {
                var formats = new[]
                {
                    "dd/MM/yyyy",
                    "d/M/yyyy",
                    "yyyy-MM-dd",
                    "MM/dd/yyyy"
                };

                if (DateOnly.TryParseExact(
                    request.NgaySinh,
                    formats,
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out var ngaySinh))
                {
                    ungVien.NgaySinh = ngaySinh;
                }
                else if (DateTime.TryParse(request.NgaySinh, out var dateTime))
                {
                    ungVien.NgaySinh = DateOnly.FromDateTime(dateTime);
                }
            }

            if (!string.IsNullOrWhiteSpace(request.Email) &&
                request.Email != taiKhoan.Email)
            {
                var emailDaTonTai = await _context.TaiKhoans
                    .AnyAsync(x =>
                        x.Email == request.Email &&
                        x.IdTaikhoan != idTaiKhoan);

                if (emailDaTonTai)
                {
                    return BadRequest(new
                    {
                        message = "Email này đã được tài khoản khác sử dụng"
                    });
                }

                taiKhoan.Email = request.Email;
            }

            if (!string.IsNullOrWhiteSpace(request.SoDienThoai))
            {
                taiKhoan.SoDienThoai = request.SoDienThoai;
            }

            return null;
        }

        private string NormalizeLoaiMauCv(string? loaiMauCv)
        {
            if (string.IsNullOrWhiteSpace(loaiMauCv))
            {
                return "simple";
            }

            var value = loaiMauCv.Trim().ToLower();

            if (value == "pro")
            {
                return "pro";
            }

            return "simple";
        }
    }

    public class CvJoinResult
    {
        public HoSoCv Cv { get; set; } = null!;

        public UngVien UngVien { get; set; } = null!;

        public TaiKhoan TaiKhoan { get; set; } = null!;
    }

    public class CreateHoSoCvRequest
    {
        public string? TieuDeCv { get; set; }

        public string? AnhCv { get; set; }

        public string? HoTen { get; set; }

        public string? ViTriUngTuyen { get; set; }

        public string? SoDienThoai { get; set; }

        public string? NgaySinh { get; set; }

        public string? Email { get; set; }

        public string? ProfileFacebook { get; set; }

        public string? DiaChi { get; set; }

        public string? NguoiGioiThieu { get; set; }

        public string? MucTieu { get; set; }

        public string? HocVan { get; set; }

        public string? MoTaHocVan { get; set; }

        public string? KinhNghiem { get; set; }

        public string? KyNang { get; set; }

        public string? SoThich { get; set; }

        public string? ChungChi { get; set; }

        public string? DanhHieu { get; set; }

        public string? HoatDong { get; set; }

        public string? NganhNghe { get; set; }

        public bool? TrangThaiTimViec { get; set; }

        public string? LoaiMauCv { get; set; }
    }

    public class UpdateCvStatusRequest
    {
        public bool TrangThaiTimViec { get; set; }
    }
}