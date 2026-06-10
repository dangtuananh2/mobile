using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaoAPI.Entities;

namespace TaoAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LoiMoiController : ControllerBase
    {
        private readonly MobileAppContext _context;

        public LoiMoiController(MobileAppContext context)
        {
            _context = context;
        }

        public class SendInvitationRequest
        {
            public string IdCv { get; set; } = null!;
            public int IdTaikhoan { get; set; } // Recruiter's TaiKhoan ID
            public string? TieuDe { get; set; }
            public string? NoiDung { get; set; }
        }

        public class RespondRequest
        {
            public string IdCv { get; set; } = null!;
            public string Response { get; set; } = null!; // "Đồng ý" or "Từ chối"
        }

        // 1. POST api/LoiMoi — Gửi lời mời
        [HttpPost]
        public async Task<IActionResult> SendInvitation([FromBody] SendInvitationRequest req)
        {
            if (!int.TryParse(req.IdCv, out int cvId))
            {
                return BadRequest("idCv không hợp lệ");
            }

            var ntd = await _context.NhaTuyenDungs.FirstOrDefaultAsync(x => x.IdTaikhoan == req.IdTaikhoan);
            if (ntd == null) return NotFound("Không tìm thấy Nhà tuyển dụng");

            // Kiểm tra xem đã có lời mời cho CV này chưa
            var existing = await _context.LoiMoiUngViens
                .FirstOrDefaultAsync(x => x.IdNtd == ntd.IdNtd && x.IdCv == cvId);

            if (existing != null)
            {
                existing.TieuDe = req.TieuDe ?? existing.TieuDe;
                existing.NoiDung = req.NoiDung ?? existing.NoiDung;
                existing.TrangThai = "Chờ phản hồi";
                existing.NgayGui = DateTime.Now;
            }
            else
            {
                var newLoiMoi = new LoiMoiUngVien
                {
                    IdNtd = ntd.IdNtd,
                    IdCv = cvId,
                    TieuDe = req.TieuDe,
                    NoiDung = req.NoiDung,
                    TrangThai = "Chờ phản hồi",
                    NgayGui = DateTime.Now
                };
                _context.LoiMoiUngViens.Add(newLoiMoi);
            }

            await _context.SaveChangesAsync();

            // Tạo thông báo cho ứng viên (UV)
            var cv = await _context.HoSoCvs
                .Include(c => c.IdUngvienNavigation)
                .FirstOrDefaultAsync(c => c.IdCv == cvId);

            if (cv != null)
            {
                var thongBao = new ThongBao
                {
                    IdTaikhoan = cv.IdUngvienNavigation.IdTaikhoan,
                    TieuDe = $"Lời mời nhận cơ hội nghề nghiệp từ {ntd.TenCongTy}",
                    NoiDung = $"Bạn nhận được lời mời ứng tuyển vị trí {req.TieuDe ?? "Công việc mới"} từ công ty {ntd.TenCongTy}.",
                    ThoiGian = DateTime.Now,
                    DaDoc = false,
                    Loai = "invitation"
                };
                _context.ThongBaos.Add(thongBao);
                await _context.SaveChangesAsync();
            }

            return Ok(new { message = "Gửi lời mời thành công!" });
        }

        // 2. GET api/LoiMoi/recruiter/{idTaikhoan}
        [HttpGet("recruiter/{idTaikhoan}")]
        public async Task<IActionResult> GetRecruiterInvitations(int idTaikhoan)
        {
            var ntd = await _context.NhaTuyenDungs.FirstOrDefaultAsync(x => x.IdTaikhoan == idTaikhoan);
            if (ntd == null) return NotFound("Không tìm thấy Nhà tuyển dụng");

            var list = await _context.LoiMoiUngViens
                .Where(x => x.IdNtd == ntd.IdNtd)
                .Include(x => x.IdCvNavigation.IdUngvienNavigation)
                .Select(x => new
                {
                    idLoiMoi = x.IdLoiMoi,
                    idCv = x.IdCv.ToString(),
                    hoTen = x.IdCvNavigation.IdUngvienNavigation.HoTen ?? "Ứng viên",
                    viTri = x.IdCvNavigation.IdUngvienNavigation.ViTriUngTuyen ?? "Chưa cập nhật",
                    companyName = ntd.TenCongTy,
                    jobTitle = x.TieuDe ?? "Vị trí ứng tuyển",
                    salary = "Thỏa thuận",
                    location = ntd.DiaChi ?? "Hồ Chí Minh",
                    trangThai = x.TrangThai ?? "Chờ phản hồi",
                    thoiGian = x.NgayGui.HasValue ? x.NgayGui.Value.ToString("yyyy-MM-ddTHH:mm:ss") : ""
                })
                .ToListAsync();

            return Ok(list);
        }

        // 3. GET api/LoiMoi/candidate/{idTaikhoan}
        [HttpGet("candidate/{idTaikhoan}")]
        public async Task<IActionResult> GetCandidateInvitations(int idTaikhoan)
        {
            var uv = await _context.UngViens.FirstOrDefaultAsync(x => x.IdTaikhoan == idTaikhoan);
            if (uv == null) return NotFound("Không tìm thấy ứng viên");

            var list = await _context.LoiMoiUngViens
                .Where(x => x.IdCvNavigation.IdUngvien == uv.IdUngvien)
                .Include(x => x.IdNtdNavigation)
                .Select(x => new
                {
                    idLoiMoi = x.IdLoiMoi,
                    idCv = x.IdCv.ToString(),
                    hoTen = uv.HoTen ?? "Ứng viên",
                    viTri = uv.ViTriUngTuyen ?? "Chưa cập nhật",
                    companyName = x.IdNtdNavigation.TenCongTy,
                    jobTitle = x.TieuDe ?? "Vị trí ứng tuyển",
                    salary = "Thỏa thuận",
                    location = x.IdNtdNavigation.DiaChi ?? "Hồ Chí Minh",
                    trangThai = x.TrangThai ?? "Chờ phản hồi",
                    thoiGian = x.NgayGui.HasValue ? x.NgayGui.Value.ToString("yyyy-MM-ddTHH:mm:ss") : ""
                })
                .ToListAsync();

            return Ok(list);
        }

        // 4. PUT api/LoiMoi/respond
        [HttpPut("respond")]
        public async Task<IActionResult> Respond([FromBody] RespondRequest req)
        {
            if (!int.TryParse(req.IdCv, out int cvId))
            {
                return BadRequest("idCv không hợp lệ");
            }

            var loiMoi = await _context.LoiMoiUngViens
                .Include(x => x.IdNtdNavigation)
                .Include(x => x.IdCvNavigation.IdUngvienNavigation)
                .OrderByDescending(x => x.NgayGui)
                .FirstOrDefaultAsync(x => x.IdCv == cvId);

            if (loiMoi == null) return NotFound("Không tìm thấy lời mời cho CV này");

            loiMoi.TrangThai = req.Response;
            loiMoi.NgayPhanHoi = DateTime.Now;
            await _context.SaveChangesAsync();

            // Tạo thông báo cho Nhà tuyển dụng (NTD)
            var hoTen = loiMoi.IdCvNavigation?.IdUngvienNavigation?.HoTen ?? "Ứng viên";
            var thongBao = new ThongBao
            {
                IdTaikhoan = loiMoi.IdNtdNavigation.IdTaikhoan,
                TieuDe = req.Response == "Đồng ý" ? $"{hoTen} đã đồng ý lời mời" : $"{hoTen} đã từ chối lời mời",
                NoiDung = req.Response == "Đồng ý"
                    ? $"{hoTen} đã chấp nhận lời mời kết nối từ công ty bạn. Hãy liên hệ sớm!"
                    : $"{hoTen} đã từ chối lời mời. Bạn có thể thử với ứng viên khác.",
                ThoiGian = DateTime.Now,
                DaDoc = false,
                Loai = req.Response == "Đồng ý" ? "accepted" : "rejected"
            };

            _context.ThongBaos.Add(thongBao);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Phản hồi lời mời thành công!" });
        }

        // 5. GET api/LoiMoi/notifications/{idTaikhoan}
        [HttpGet("notifications/{idTaikhoan}")]
        public async Task<IActionResult> GetNotifications(int idTaikhoan)
        {
            var list = await _context.ThongBaos
                .Where(x => x.IdTaikhoan == idTaikhoan)
                .OrderByDescending(x => x.ThoiGian)
                .Select(x => new
                {
                    id = x.IdThongbao,
                    title = x.TieuDe,
                    sub = x.NoiDung,
                    time = x.ThoiGian.HasValue ? x.ThoiGian.Value.ToString("yyyy-MM-ddTHH:mm:ss") : "",
                    unread = x.DaDoc == false,
                    type = x.Loai
                })
                .ToListAsync();

            return Ok(list);
        }

        // 6. PUT api/LoiMoi/notifications/mark-all-read/{idTaikhoan}
        [HttpPut("notifications/mark-all-read/{idTaikhoan}")]
        public async Task<IActionResult> MarkAllRead(int idTaikhoan)
        {
            var unread = await _context.ThongBaos
                .Where(x => x.IdTaikhoan == idTaikhoan && x.DaDoc == false)
                .ToListAsync();

            foreach (var n in unread)
            {
                n.DaDoc = true;
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã đánh dấu tất cả là đã đọc" });
        }
    }
}
