// using Microsoft.AspNetCore.Http;
// using Microsoft.AspNetCore.Mvc;
// using Microsoft.EntityFrameworkCore;
// using TaoAPI.Entities;

// namespace TaoAPI.Controllers
// {
//     [Route("api/[controller]")]
//     [ApiController]
//     public class AdminController : ControllerBase
//     {
//         private readonly MobileAppContext _context;

//         public AdminController(MobileAppContext context)
//         {
//             _context = context;
//         }

//         // =====================================================
//         // TỔNG QUAN - DASHBOARD STATISTICS
//         // GET /api/admin/thong-ke
//         // =====================================================
//         [HttpGet("thong-ke")]
//         public async Task<IActionResult> GetThongKe()
//         {
//             var tongNguoiDung = await _context.UngViens.CountAsync();
//             var tongNhaTuyenDung = await _context.NhaTuyenDungs.CountAsync();
//             var tongTinTuyenDung = await _context.TinTuyenDungs.CountAsync();
//             var tongCv = await _context.HoSoCVs.CountAsync();
//             var tongUngTuyen = await _context.UngTuyens.CountAsync();

//             var ntdChoDuyet = await _context.TaiKhoans
//                 .Where(t => t.VaiTro == "nha_tuyen_dung" && t.TrangThai == false)
//                 .CountAsync();

//             var tinChoDuyet = await _context.TinTuyenDungs
//                 .Where(t => t.TrangThai == "Chờ duyệt")
//                 .CountAsync();

//             // Thống kê tin theo trạng thái
//             var tinTheoTrangThai = await _context.TinTuyenDungs
//                 .GroupBy(t => t.TrangThai)
//                 .Select(g => new { TrangThai = g.Key, SoLuong = g.Count() })
//                 .ToListAsync();

//             return Ok(new
//             {
//                 TongNguoiDung = tongNguoiDung,
//                 TongNhaTuyenDung = tongNhaTuyenDung,
//                 TongTinTuyenDung = tongTinTuyenDung,
//                 TongCv = tongCv,
//                 TongUngTuyen = tongUngTuyen,
//                 NtdChoDuyet = ntdChoDuyet,
//                 TinChoDuyet = tinChoDuyet,
//                 TinTheoTrangThai = tinTheoTrangThai
//             });
//         }

//         // =====================================================
//         // QUẢN LÝ NGƯỜI TÌM VIỆC
//         // =====================================================

//         // GET /api/admin/ung-vien?search=&page=1&pageSize=10
//         [HttpGet("ung-vien")]
//         public async Task<IActionResult> GetUngViens(
//             [FromQuery] string? search = null,
//             [FromQuery] int page = 1,
//             [FromQuery] int pageSize = 10)
//         {
//             var query = _context.UngViens
//                 .Include(u => u.TaiKhoan)
//                 .Include(u => u.HoSoCVs)
//                 .AsQueryable();

//             if (!string.IsNullOrWhiteSpace(search))
//             {
//                 search = search.ToLower();
//                 query = query.Where(u =>
//                     (u.HoTen != null && u.HoTen.ToLower().Contains(search)) ||
//                     u.IdUngVien.ToString().Contains(search) ||
//                     (u.TaiKhoan != null && u.TaiKhoan.Email.ToLower().Contains(search)));
//             }

//             var total = await query.CountAsync();
//             var data = await query
//                 .OrderByDescending(u => u.IdUngVien)
//                 .Skip((page - 1) * pageSize)
//                 .Take(pageSize)
//                 .Select(u => new
//                 {
//                     u.IdUngVien,
//                     u.HoTen,
//                     u.AnhDaiDien,
//                     u.ViTriUngTuyen,
//                     u.DiaChi,
//                     Email = u.TaiKhoan != null ? u.TaiKhoan.Email : null,
//                     SoDienThoai = u.TaiKhoan != null ? u.TaiKhoan.SoDienThoai : null,
//                     TrangThai = u.TaiKhoan != null ? u.TaiKhoan.TrangThai : true,
//                     NgayTao = u.TaiKhoan != null ? u.TaiKhoan.NgayTao : (DateTime?)null,
//                     SoCv = u.HoSoCVs.Count
//                 })
//                 .ToListAsync();

//             return Ok(new { Total = total, Page = page, PageSize = pageSize, Data = data });
//         }

//         // PUT /api/admin/ung-vien/{id}/trang-thai
//         // Body: { "trangThai": true/false }
//         [HttpPut("ung-vien/{id}/trang-thai")]
//         public async Task<IActionResult> UpdateTrangThaiUngVien(int id, [FromBody] UpdateTrangThaiRequest req)
//         {
//             var ungVien = await _context.UngViens
//                 .Include(u => u.TaiKhoan)
//                 .FirstOrDefaultAsync(u => u.IdUngVien == id);

//             if (ungVien == null) return NotFound(new { Message = "Không tìm thấy ứng viên." });
//             if (ungVien.TaiKhoan == null) return BadRequest(new { Message = "Tài khoản không tồn tại." });

//             ungVien.TaiKhoan.TrangThai = req.TrangThai;
//             await _context.SaveChangesAsync();

//             return Ok(new { Message = req.TrangThai ? "Đã mở khóa tài khoản." : "Đã khóa tài khoản." });
//         }

//         // =====================================================
//         // QUẢN LÝ NHÀ TUYỂN DỤNG
//         // =====================================================

//         // GET /api/admin/nha-tuyen-dung?trangThai=cho_duyet&page=1&pageSize=10
//         [HttpGet("nha-tuyen-dung")]
//         public async Task<IActionResult> GetNhaTuyenDungs(
//             [FromQuery] string? trangThai = null,
//             [FromQuery] string? search = null,
//             [FromQuery] int page = 1,
//             [FromQuery] int pageSize = 10)
//         {
//             var query = _context.NhaTuyenDungs
//                 .Include(n => n.TaiKhoan)
//                 .Include(n => n.TinTuyenDungs)
//                 .AsQueryable();

//             // Lọc theo trạng thái tài khoản
//             if (trangThai == "cho_duyet")
//                 query = query.Where(n => n.TaiKhoan != null && n.TaiKhoan.TrangThai == false);
//             else if (trangThai == "da_xac_thuc")
//                 query = query.Where(n => n.TaiKhoan != null && n.TaiKhoan.TrangThai == true);

//             if (!string.IsNullOrWhiteSpace(search))
//             {
//                 search = search.ToLower();
//                 query = query.Where(n =>
//                     n.TenCongTy.ToLower().Contains(search) ||
//                     (n.TaiKhoan != null && n.TaiKhoan.Email.ToLower().Contains(search)));
//             }

//             var total = await query.CountAsync();
//             var data = await query
//                 .OrderByDescending(n => n.IdNtd)
//                 .Skip((page - 1) * pageSize)
//                 .Take(pageSize)
//                 .Select(n => new
//                 {
//                     n.IdNtd,
//                     n.TenCongTy,
//                     n.Logo,
//                     n.DiaChi,
//                     n.LinhVuc,
//                     n.Website,
//                     Email = n.TaiKhoan != null ? n.TaiKhoan.Email : null,
//                     SoDienThoai = n.TaiKhoan != null ? n.TaiKhoan.SoDienThoai : null,
//                     TrangThai = n.TaiKhoan != null ? n.TaiKhoan.TrangThai : false,
//                     NgayTao = n.TaiKhoan != null ? n.TaiKhoan.NgayTao : (DateTime?)null,
//                     SoTinDang = n.TinTuyenDungs.Count
//                 })
//                 .ToListAsync();

//             return Ok(new { Total = total, Page = page, PageSize = pageSize, Data = data });
//         }

//         // PUT /api/admin/nha-tuyen-dung/{id}/duyet
//         // Duyệt hoặc từ chối nhà tuyển dụng
//         [HttpPut("nha-tuyen-dung/{id}/duyet")]
//         public async Task<IActionResult> DuyetNhaTuyenDung(int id, [FromBody] UpdateTrangThaiRequest req)
//         {
//             var ntd = await _context.NhaTuyenDungs
//                 .Include(n => n.TaiKhoan)
//                 .FirstOrDefaultAsync(n => n.IdNtd == id);

//             if (ntd == null) return NotFound(new { Message = "Không tìm thấy nhà tuyển dụng." });
//             if (ntd.TaiKhoan == null) return BadRequest(new { Message = "Tài khoản không tồn tại." });

//             ntd.TaiKhoan.TrangThai = req.TrangThai;
//             await _context.SaveChangesAsync();

//             return Ok(new { Message = req.TrangThai ? "Đã duyệt nhà tuyển dụng." : "Đã từ chối nhà tuyển dụng." });
//         }

//         // =====================================================
//         // QUẢN LÝ TIN TUYỂN DỤNG
//         // =====================================================

//         // GET /api/admin/tin-tuyen-dung?trangThai=&search=&page=1&pageSize=10
//         [HttpGet("tin-tuyen-dung")]
//         public async Task<IActionResult> GetTinTuyenDungs(
//             [FromQuery] string? trangThai = null,
//             [FromQuery] string? search = null,
//             [FromQuery] int page = 1,
//             [FromQuery] int pageSize = 10)
//         {
//             var query = _context.TinTuyenDungs
//                 .Include(t => t.NhaTuyenDung)
//                 .AsQueryable();

//             if (!string.IsNullOrWhiteSpace(trangThai))
//                 query = query.Where(t => t.TrangThai == trangThai);

//             if (!string.IsNullOrWhiteSpace(search))
//             {
//                 search = search.ToLower();
//                 query = query.Where(t =>
//                     t.TieuDe.ToLower().Contains(search) ||
//                     t.IdTin.ToString().Contains(search) ||
//                     (t.NhaTuyenDung != null && t.NhaTuyenDung.TenCongTy.ToLower().Contains(search)));
//             }

//             var total = await query.CountAsync();
//             var data = await query
//                 .OrderByDescending(t => t.NgayDang)
//                 .Skip((page - 1) * pageSize)
//                 .Take(pageSize)
//                 .Select(t => new
//                 {
//                     t.IdTin,
//                     t.TieuDe,
//                     t.DiaDiem,
//                     t.MucLuong,
//                     t.HinhThuc,
//                     t.NganhNghe,
//                     t.HanNop,
//                     t.TrangThai,
//                     t.NgayDang,
//                     TenCongTy = t.NhaTuyenDung != null ? t.NhaTuyenDung.TenCongTy : null,
//                     LogoCongTy = t.NhaTuyenDung != null ? t.NhaTuyenDung.Logo : null,
//                 })
//                 .ToListAsync();

//             return Ok(new { Total = total, Page = page, PageSize = pageSize, Data = data });
//         }

//         // PUT /api/admin/tin-tuyen-dung/{id}/trang-thai
//         // Body: { "trangThai": "Đang tuyển" | "Chờ duyệt" | "Đã đóng" | "Từ chối" }
//         [HttpPut("tin-tuyen-dung/{id}/trang-thai")]
//         public async Task<IActionResult> UpdateTrangThaiTin(int id, [FromBody] UpdateTrangThaiTinRequest req)
//         {
//             var tin = await _context.TinTuyenDungs.FindAsync(id);
//             if (tin == null) return NotFound(new { Message = "Không tìm thấy tin tuyển dụng." });

//             var validStatuses = new[] { "Đang tuyển", "Chờ duyệt", "Đã đóng", "Từ chối" };
//             if (!validStatuses.Contains(req.TrangThai))
//                 return BadRequest(new { Message = "Trạng thái không hợp lệ." });

//             tin.TrangThai = req.TrangThai;
//             await _context.SaveChangesAsync();

//             return Ok(new { Message = $"Đã cập nhật trạng thái tin: {req.TrangThai}" });
//         }

//         // PUT /api/admin/tin-tuyen-dung/{id}
//         // Chỉnh sửa nhanh tiêu đề + mô tả
//         [HttpPut("tin-tuyen-dung/{id}")]
//         public async Task<IActionResult> UpdateTin(int id, [FromBody] UpdateTinRequest req)
//         {
//             var tin = await _context.TinTuyenDungs.FindAsync(id);
//             if (tin == null) return NotFound(new { Message = "Không tìm thấy tin tuyển dụng." });

//             if (!string.IsNullOrWhiteSpace(req.TieuDe)) tin.TieuDe = req.TieuDe;
//             if (req.MoTaCongViec != null) tin.MoTaCongViec = req.MoTaCongViec;
//             if (req.YeuCau != null) tin.YeuCau = req.YeuCau;
//             if (req.MucLuong != null) tin.MucLuong = req.MucLuong;

//             await _context.SaveChangesAsync();
//             return Ok(new { Message = "Đã cập nhật tin tuyển dụng." });
//         }

//         // DELETE /api/admin/tin-tuyen-dung/{id}
//         [HttpDelete("tin-tuyen-dung/{id}")]
//         public async Task<IActionResult> DeleteTin(int id)
//         {
//             var tin = await _context.TinTuyenDungs
//                 .Include(t => t.UngTuyens)
//                 .Include(t => t.LuuTins)
//                 .FirstOrDefaultAsync(t => t.IdTin == id);

//             if (tin == null) return NotFound(new { Message = "Không tìm thấy tin tuyển dụng." });

//             // Xóa các bản ghi liên quan trước
//             _context.UngTuyens.RemoveRange(tin.UngTuyens);
//             _context.LuuTins.RemoveRange(tin.LuuTins);
//             _context.TinTuyenDungs.Remove(tin);

//             await _context.SaveChangesAsync();
//             return Ok(new { Message = "Đã xóa tin tuyển dụng." });
//         }
//     }

//     // =====================================================
//     // REQUEST DTOs
//     // =====================================================
//     public class UpdateTrangThaiRequest
//     {
//         public bool TrangThai { get; set; }
//     }

//     public class UpdateTrangThaiTinRequest
//     {
//         public string TrangThai { get; set; } = string.Empty;
//     }

//     public class UpdateTinRequest
//     {
//         public string? TieuDe { get; set; }
//         public string? MoTaCongViec { get; set; }
//         public string? YeuCau { get; set; }
//         public string? MucLuong { get; set; }
//     }
// }


using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaoAPI.Entities;

namespace TaoAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdminController : ControllerBase
    {
        private readonly MobileAppContext _context;

        public AdminController(MobileAppContext context)
        {
            _context = context;
        }

        // =====================================================
        // TỔNG QUAN — GET /api/admin/thong-ke
        // =====================================================
        [HttpGet("thong-ke")]
        public async Task<IActionResult> GetThongKe()
        {
            var tongNguoiDung    = await _context.UngViens.CountAsync();
            var tongNhaTuyenDung = await _context.NhaTuyenDungs.CountAsync();
            var tongTin          = await _context.TinTuyenDungs.CountAsync();
            var tongCv           = await _context.HoSoCvs.CountAsync();       // ← HoSoCvs
            var tongUngTuyen     = await _context.UngTuyens.CountAsync();

            var ntdChoDuyet = await _context.TaiKhoans
                .Where(t => t.VaiTro == "nha_tuyen_dung" && t.TrangThai == false)
                .CountAsync();

            var tinChoDuyet = await _context.TinTuyenDungs
                .Where(t => t.TrangThai == "Chờ duyệt")
                .CountAsync();

            var tinTheoTrangThai = await _context.TinTuyenDungs
                .GroupBy(t => t.TrangThai)
                .Select(g => new { TrangThai = g.Key, SoLuong = g.Count() })
                .ToListAsync();

            return Ok(new
            {
                TongNguoiDung    = tongNguoiDung,
                TongNhaTuyenDung = tongNhaTuyenDung,
                TongTinTuyenDung = tongTin,
                TongCv           = tongCv,
                TongUngTuyen     = tongUngTuyen,
                NtdChoDuyet      = ntdChoDuyet,
                TinChoDuyet      = tinChoDuyet,
                TinTheoTrangThai = tinTheoTrangThai
            });
        }

        // =====================================================
        // NGƯỜI TÌM VIỆC — GET /api/admin/ung-vien
        // =====================================================
        [HttpGet("ung-vien")]
        public async Task<IActionResult> GetUngViens(
            [FromQuery] string? search   = null,
            [FromQuery] int     page     = 1,
            [FromQuery] int     pageSize = 10)
        {
            var query = _context.UngViens
                .Include(u => u.IdTaikhoanNavigation)   // ← IdTaikhoanNavigation
                .Include(u => u.HoSoCvs)                // ← HoSoCvs
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var s = search.ToLower();
                query = query.Where(u =>
                    (u.HoTen != null && u.HoTen.ToLower().Contains(s)) ||
                    u.IdUngvien.ToString().Contains(s) ||                   // ← IdUngvien
                    (u.IdTaikhoanNavigation != null &&
                     u.IdTaikhoanNavigation.Email.ToLower().Contains(s)));
            }

            var total = await query.CountAsync();
            var data  = await query
                .OrderByDescending(u => u.IdUngvien)                        // ← IdUngvien
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(u => new
                {
                    IdUngVien     = u.IdUngvien,                            // ← IdUngvien
                    u.HoTen,
                    u.AnhDaiDien,
                    u.ViTriUngTuyen,
                    u.DiaChi,
                    Email       = u.IdTaikhoanNavigation != null ? u.IdTaikhoanNavigation.Email       : null,
                    SoDienThoai = u.IdTaikhoanNavigation != null ? u.IdTaikhoanNavigation.SoDienThoai : null,
                    TrangThai   = u.IdTaikhoanNavigation != null ? u.IdTaikhoanNavigation.TrangThai   : true,
                    NgayTao     = u.IdTaikhoanNavigation != null ? u.IdTaikhoanNavigation.NgayTao     : (DateTime?)null,
                    SoCv        = u.HoSoCvs.Count
                })
                .ToListAsync();

            return Ok(new { Total = total, Page = page, PageSize = pageSize, Data = data });
        }

        // PUT /api/admin/ung-vien/{id}/trang-thai
        [HttpPut("ung-vien/{id}/trang-thai")]
        public async Task<IActionResult> UpdateTrangThaiUngVien(
            int id, [FromBody] UpdateTrangThaiRequest req)
        {
            var uv = await _context.UngViens
                .Include(u => u.IdTaikhoanNavigation)
                .FirstOrDefaultAsync(u => u.IdUngvien == id);              // ← IdUngvien

            if (uv == null)
                return NotFound(new { Message = "Không tìm thấy ứng viên." });
            if (uv.IdTaikhoanNavigation == null)
                return BadRequest(new { Message = "Tài khoản không tồn tại." });

            uv.IdTaikhoanNavigation.TrangThai = req.TrangThai;
            await _context.SaveChangesAsync();

            return Ok(new { Message = req.TrangThai ? "Đã mở khóa tài khoản." : "Đã khóa tài khoản." });
        }

        // =====================================================
        // NHÀ TUYỂN DỤNG — GET /api/admin/nha-tuyen-dung
        // =====================================================
        [HttpGet("nha-tuyen-dung")]
        public async Task<IActionResult> GetNhaTuyenDungs(
            [FromQuery] string? trangThai = null,
            [FromQuery] string? search    = null,
            [FromQuery] int     page      = 1,
            [FromQuery] int     pageSize  = 10)
        {
            var query = _context.NhaTuyenDungs
                .Include(n => n.IdTaikhoanNavigation)   // ← IdTaikhoanNavigation
                .Include(n => n.TinTuyenDungs)
                .AsQueryable();

            if (trangThai == "cho_duyet")
                query = query.Where(n =>
                    n.IdTaikhoanNavigation != null &&
                    n.IdTaikhoanNavigation.TrangThai == false);
            else if (trangThai == "da_xac_thuc")
                query = query.Where(n =>
                    n.IdTaikhoanNavigation != null &&
                    n.IdTaikhoanNavigation.TrangThai == true);

            if (!string.IsNullOrWhiteSpace(search))
            {
                var s = search.ToLower();
                query = query.Where(n =>
                    n.TenCongTy.ToLower().Contains(s) ||
                    (n.IdTaikhoanNavigation != null &&
                     n.IdTaikhoanNavigation.Email.ToLower().Contains(s)));
            }

            var total = await query.CountAsync();
            var data  = await query
                .OrderByDescending(n => n.IdNtd)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(n => new
                {
                    n.IdNtd,
                    n.TenCongTy,
                    n.Logo,
                    n.DiaChi,
                    n.LinhVuc,
                    n.Website,
                    Email       = n.IdTaikhoanNavigation != null ? n.IdTaikhoanNavigation.Email       : null,
                    SoDienThoai = n.IdTaikhoanNavigation != null ? n.IdTaikhoanNavigation.SoDienThoai : null,
                    TrangThai   = n.IdTaikhoanNavigation != null ? n.IdTaikhoanNavigation.TrangThai   : false,
                    NgayTao     = n.IdTaikhoanNavigation != null ? n.IdTaikhoanNavigation.NgayTao     : (DateTime?)null,
                    SoTinDang   = n.TinTuyenDungs.Count
                })
                .ToListAsync();

            return Ok(new { Total = total, Page = page, PageSize = pageSize, Data = data });
        }

        // PUT /api/admin/nha-tuyen-dung/{id}/duyet
        [HttpPut("nha-tuyen-dung/{id}/duyet")]
        public async Task<IActionResult> DuyetNhaTuyenDung(
            int id, [FromBody] UpdateTrangThaiRequest req)
        {
            var ntd = await _context.NhaTuyenDungs
                .Include(n => n.IdTaikhoanNavigation)
                .FirstOrDefaultAsync(n => n.IdNtd == id);

            if (ntd == null)
                return NotFound(new { Message = "Không tìm thấy nhà tuyển dụng." });
            if (ntd.IdTaikhoanNavigation == null)
                return BadRequest(new { Message = "Tài khoản không tồn tại." });

            ntd.IdTaikhoanNavigation.TrangThai = req.TrangThai;
            await _context.SaveChangesAsync();

            return Ok(new { Message = req.TrangThai ? "Đã duyệt nhà tuyển dụng." : "Đã từ chối nhà tuyển dụng." });
        }

        // =====================================================
        // TIN TUYỂN DỤNG — GET /api/admin/tin-tuyen-dung
        // =====================================================
        [HttpGet("tin-tuyen-dung")]
        public async Task<IActionResult> GetTinTuyenDungs(
            [FromQuery] string? trangThai = null,
            [FromQuery] string? search    = null,
            [FromQuery] int     page      = 1,
            [FromQuery] int     pageSize  = 10)
        {
            var query = _context.TinTuyenDungs
                .Include(t => t.IdNtdNavigation)        // ← IdNtdNavigation
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(trangThai))
                query = query.Where(t => t.TrangThai == trangThai);

            if (!string.IsNullOrWhiteSpace(search))
            {
                var s = search.ToLower();
                query = query.Where(t =>
                    t.TieuDe.ToLower().Contains(s) ||
                    t.IdTin.ToString().Contains(s) ||
                    (t.IdNtdNavigation != null &&
                     t.IdNtdNavigation.TenCongTy.ToLower().Contains(s)));
            }

            var total = await query.CountAsync();
            var data  = await query
                .OrderByDescending(t => t.NgayDang)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(t => new
                {
                    t.IdTin,
                    t.TieuDe,
                    t.DiaDiem,
                    t.MucLuong,
                    t.HinhThuc,
                    t.NganhNghe,
                    t.HanNop,
                    t.TrangThai,
                    t.NgayDang,
                    TenCongTy  = t.IdNtdNavigation != null ? t.IdNtdNavigation.TenCongTy : null,
                    LogoCongTy = t.IdNtdNavigation != null ? t.IdNtdNavigation.Logo      : null,
                })
                .ToListAsync();

            return Ok(new { Total = total, Page = page, PageSize = pageSize, Data = data });
        }

        // PUT /api/admin/tin-tuyen-dung/{id}/trang-thai
        [HttpPut("tin-tuyen-dung/{id}/trang-thai")]
        public async Task<IActionResult> UpdateTrangThaiTin(
            int id, [FromBody] UpdateTrangThaiTinRequest req)
        {
            var tin = await _context.TinTuyenDungs.FindAsync(id);
            if (tin == null)
                return NotFound(new { Message = "Không tìm thấy tin tuyển dụng." });

            var valid = new[] { "Đang tuyển", "Chờ duyệt", "Đã đóng", "Từ chối" };
            if (!valid.Contains(req.TrangThai))
                return BadRequest(new { Message = "Trạng thái không hợp lệ." });

            tin.TrangThai = req.TrangThai;
            await _context.SaveChangesAsync();

            return Ok(new { Message = $"Đã cập nhật trạng thái: {req.TrangThai}" });
        }

        // PUT /api/admin/tin-tuyen-dung/{id}
        [HttpPut("tin-tuyen-dung/{id}")]
        public async Task<IActionResult> UpdateTin(
            int id, [FromBody] UpdateTinRequest req)
        {
            var tin = await _context.TinTuyenDungs.FindAsync(id);
            if (tin == null)
                return NotFound(new { Message = "Không tìm thấy tin tuyển dụng." });

            if (!string.IsNullOrWhiteSpace(req.TieuDe))  tin.TieuDe      = req.TieuDe;
            if (req.MoTaCongViec != null)                 tin.MoTaCongViec = req.MoTaCongViec;
            if (req.YeuCau       != null)                 tin.YeuCau       = req.YeuCau;
            if (req.MucLuong     != null)                 tin.MucLuong     = req.MucLuong;

            await _context.SaveChangesAsync();
            return Ok(new { Message = "Đã cập nhật tin tuyển dụng." });
        }

        // DELETE /api/admin/tin-tuyen-dung/{id}
        [HttpDelete("tin-tuyen-dung/{id}")]
        public async Task<IActionResult> DeleteTin(int id)
        {
            var tin = await _context.TinTuyenDungs
                .Include(t => t.UngTuyens)              // ← UngTuyens
                .Include(t => t.LuuTins)                // ← LuuTins
                .FirstOrDefaultAsync(t => t.IdTin == id);

            if (tin == null)
                return NotFound(new { Message = "Không tìm thấy tin tuyển dụng." });

            _context.UngTuyens.RemoveRange(tin.UngTuyens);
            _context.LuuTins.RemoveRange(tin.LuuTins);
            _context.TinTuyenDungs.Remove(tin);

            await _context.SaveChangesAsync();
            return Ok(new { Message = "Đã xóa tin tuyển dụng." });
        }

        // =====================================================
        // DTOs
        // =====================================================
        public class UpdateTrangThaiRequest
        {
            public bool TrangThai { get; set; }
        }

        public class UpdateTrangThaiTinRequest
        {
            public string TrangThai { get; set; } = string.Empty;
        }

        public class UpdateTinRequest
        {
            public string? TieuDe       { get; set; }
            public string? MoTaCongViec { get; set; }
            public string? YeuCau       { get; set; }
            public string? MucLuong     { get; set; }
        }
    }
}