using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Net;
using System.Net.Mail;
using System.Text.RegularExpressions;
using TaoAPI.Entities;

namespace TaoAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TaiKhoanController : ControllerBase
    {
        private readonly MobileAppContext _context;
        private readonly IConfiguration _configuration;
        private static readonly Dictionary<string, OtpInfo> OtpStore = new();

        public TaiKhoanController(MobileAppContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        // ── DTOs ─────────────────────────────────────────────
        public class RegisterRequest
        {
            public string? Email { get; set; }
            public string? MatKhau { get; set; }
            public string? HoTen { get; set; }
            public string? TenCongTy { get; set; }
            public string? SoDienThoai { get; set; }
            public string? VaiTro { get; set; }
        }

        public class LoginRequest
        {
            public string? Email { get; set; }
            public string? MatKhau { get; set; }
        }

        public class ForgotPasswordRequest
        {
            public string? Email { get; set; }
        }

        public class ResetPasswordRequest
        {
            public string? Email { get; set; }
            public string? Code { get; set; }
            public string? NewPassword { get; set; }
        }

        private class OtpInfo
        {
            public string Code { get; set; } = string.Empty;
            public DateTime ExpiresAt { get; set; }
        }

        // =====================================================
        // 1. GET api/TaiKhoan
        // =====================================================
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TaiKhoan>>> GetTaiKhoans()
        {
            return await _context.TaiKhoans.ToListAsync();
        }

        // =====================================================
        // 2. POST api/TaiKhoan — Đăng ký
        // =====================================================
        [HttpPost]
        public async Task<ActionResult> PostTaiKhoan(RegisterRequest request)
        {
            var email     = NormalizeEmail(request.Email);
            var password  = request.MatKhau?.Trim() ?? string.Empty;
            var phone     = request.SoDienThoai?.Trim();
            var hoTen     = request.HoTen?.Trim();
            var tenCongTy = request.TenCongTy?.Trim();

            if (!IsValidEmail(email))
                return BadRequest("Email không hợp lệ");

            var passwordError = ValidatePassword(password);
            if (passwordError != null)
                return BadRequest(passwordError);

            var vaiTro = request.VaiTro == "nha_tuyen_dung" ? "nha_tuyen_dung"
                       : request.VaiTro == "admin"          ? "admin"
                       : "ung_vien";

            if (vaiTro == "ung_vien" && string.IsNullOrWhiteSpace(hoTen))
                return BadRequest("Vui lòng nhập họ tên");

            if (vaiTro == "nha_tuyen_dung" && string.IsNullOrWhiteSpace(tenCongTy))
                return BadRequest("Vui lòng nhập tên công ty");

            var existed = await _context.TaiKhoans
                .AnyAsync(x => x.Email.ToLower() == email);

            if (existed)
                return BadRequest("Email đã tồn tại");

            var taiKhoan = new TaiKhoan
            {
                Email       = email,
                MatKhau     = password,
                SoDienThoai = phone,
                VaiTro      = vaiTro,
                TrangThai   = true,
                NgayTao     = DateTime.Now
            };

            _context.TaiKhoans.Add(taiKhoan);
            await _context.SaveChangesAsync();
            // IdTaikhoan đã được DB tự tăng, dùng ngay bên dưới

            if (vaiTro == "ung_vien")
            {
                _context.UngViens.Add(new UngVien
                {
                    IdTaikhoan = taiKhoan.IdTaikhoan,   // ← IdTaikhoan (chữ k thường)
                    HoTen      = hoTen
                });
            }
            else if (vaiTro == "nha_tuyen_dung")
            {
                _context.NhaTuyenDungs.Add(new NhaTuyenDung
                {
                    IdTaikhoan = taiKhoan.IdTaikhoan,   // ← IdTaikhoan (chữ k thường)
                    TenCongTy  = tenCongTy!
                });
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message    = "Đăng ký thành công!",
                idTaikhoan = taiKhoan.IdTaikhoan,
                email      = taiKhoan.Email,
                vaiTro     = taiKhoan.VaiTro
            });
        }

        // =====================================================
        // 3. POST api/TaiKhoan/login — Đăng nhập
        // =====================================================
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest loginInfo)
        {
            var email    = NormalizeEmail(loginInfo.Email);
            var password = loginInfo.MatKhau?.Trim() ?? string.Empty;

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
                return BadRequest("Vui lòng nhập email và mật khẩu");

            var user = await _context.TaiKhoans
                .FirstOrDefaultAsync(u =>
                    u.Email.ToLower() == email &&
                    u.MatKhau == password);

            if (user == null)
                return Unauthorized("Sai email hoặc mật khẩu");

            if (user.TrangThai == false)
                return Unauthorized("Tài khoản đã bị khóa");

            // Lấy tên hiển thị theo vai trò
            string? hoTen;
            switch (user.VaiTro)
            {
                case "ung_vien":
                    // Lấy HoTen từ bảng UngVien
                    hoTen = await _context.UngViens
                        .Where(u => u.IdTaikhoan == user.IdTaikhoan)  // ← IdTaikhoan
                        .Select(u => u.HoTen)
                        .FirstOrDefaultAsync();
                    break;

                case "nha_tuyen_dung":
                    // Lấy TenCongTy từ bảng NhaTuyenDung
                    hoTen = await _context.NhaTuyenDungs
                        .Where(n => n.IdTaikhoan == user.IdTaikhoan)  // ← IdTaikhoan
                        .Select(n => n.TenCongTy)
                        .FirstOrDefaultAsync();
                    break;

                case "admin":
                default:
                    // Admin không có trong UngVien/NhaTuyenDung
                    // → lấy phần trước @ của email làm tên hiển thị
                    var prefix = user.Email.Split('@')[0];
                    hoTen = char.ToUpper(prefix[0]) + prefix.Substring(1);
                    break;
            }

            return Ok(new
            {
                idTaikhoan = user.IdTaikhoan,           // ← IdTaikhoan
                email      = user.Email,
                vaiTro     = user.VaiTro,
                trangThai  = user.TrangThai,
                hoTen      = hoTen ?? "Người dùng",
                ngayTao    = user.NgayTao,
            });
        }

        // =====================================================
        // 4. GET api/TaiKhoan/{id} — Lấy 1 tài khoản
        // =====================================================
        [HttpGet("{id}")]
        public async Task<ActionResult> GetTaiKhoan(int id)
        {
            var data = await _context.TaiKhoans
                .Where(t => t.IdTaikhoan == id)         // ← IdTaikhoan
                .Select(t => new
                {
                    idTaikhoan  = t.IdTaikhoan,
                    email       = t.Email,
                    vaiTro      = t.VaiTro,
                    soDienThoai = t.SoDienThoai,
                    hoTen = _context.UngViens
                        .Where(u => u.IdTaikhoan == t.IdTaikhoan)
                        .Select(u => u.HoTen)
                        .FirstOrDefault(),
                    tenCongTy = _context.NhaTuyenDungs
                        .Where(n => n.IdTaikhoan == t.IdTaikhoan)
                        .Select(n => n.TenCongTy)
                        .FirstOrDefault(),
                    diaChi = _context.NhaTuyenDungs
                        .Where(n => n.IdTaikhoan == t.IdTaikhoan)
                        .Select(n => n.DiaChi)
                        .FirstOrDefault()
                })
                .FirstOrDefaultAsync();

            if (data == null)
                return NotFound("Không tìm thấy tài khoản");

            return Ok(data);
        }

        public class UpdateNtdProfileRequest
        {
            public string TenCongTy { get; set; } = null!;
            public string? SoDienThoai { get; set; }
            public string? DiaChi { get; set; }
            public string? Website { get; set; }
            public string? LinhVuc { get; set; }
            public string? MoTa { get; set; }
        }

        [HttpPut("nha-tuyen-dung/{idTaikhoan}")]
        public async Task<IActionResult> UpdateNtdProfile(int idTaikhoan, [FromBody] UpdateNtdProfileRequest req)
        {
            var user = await _context.TaiKhoans.FindAsync(idTaikhoan);
            if (user == null) return NotFound("Không tìm thấy tài khoản");

            var ntd = await _context.NhaTuyenDungs.FirstOrDefaultAsync(x => x.IdTaikhoan == idTaikhoan);
            if (ntd == null) return NotFound("Không tìm thấy thông tin Nhà tuyển dụng");

            if (!string.IsNullOrWhiteSpace(req.TenCongTy))
            {
                ntd.TenCongTy = req.TenCongTy;
            }
            if (req.DiaChi != null)
            {
                ntd.DiaChi = req.DiaChi;
            }
            if (req.Website != null)
            {
                ntd.Website = req.Website;
            }
            if (req.LinhVuc != null)
            {
                ntd.LinhVuc = req.LinhVuc;
            }
            if (req.MoTa != null)
            {
                ntd.MoTa = req.MoTa;
            }

            user.SoDienThoai = req.SoDienThoai;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật hồ sơ thành công!" });
        }

        // =====================================================
        // 5. GET api/TaiKhoan/users — Danh sách ứng viên
        // =====================================================
        [HttpGet("users")]
        public async Task<IActionResult> GetListUsers()
        {
            var users = await _context.TaiKhoans
                .Where(tk => tk.VaiTro == "ung_vien")
                .GroupJoin(
                    _context.UngViens,
                    tk => tk.IdTaikhoan,
                    uv => uv.IdTaikhoan,
                    (tk, uvGroup) => new { tk, uvGroup }
                )
                .SelectMany(
                    x => x.uvGroup.DefaultIfEmpty(),
                    (x, uv) => new
                    {
                        idTaiKhoan    = x.tk.IdTaikhoan,
                        idUngVien     = uv != null ? (int?)uv.IdUngvien : null,
                        email         = x.tk.Email,
                        hoTen         = uv != null ? uv.HoTen         : "Chưa cập nhật",
                        soDienThoai   = x.tk.SoDienThoai,
                        viTriUngTuyen = uv != null ? uv.ViTriUngTuyen : "Chưa cập nhật",
                        trangThai     = x.tk.TrangThai
                    }
                )
                .ToListAsync();

            return Ok(users);
        }

        // =====================================================
        // 6. PUT api/TaiKhoan/toggle-status/{id} — Khóa/Mở khóa
        // =====================================================
        [HttpPut("toggle-status/{id}")]
        public async Task<IActionResult> ToggleStatus(int id)
        {
            var taiKhoan = await _context.TaiKhoans.FindAsync(id);
            if (taiKhoan == null)
                return NotFound(new { message = "Không tìm thấy tài khoản!" });

            taiKhoan.TrangThai = taiKhoan.TrangThai == true ? false : true;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message      = "Cập nhật trạng thái thành công!",
                trangThaiMoi = taiKhoan.TrangThai
            });
        }

        // =====================================================
        // 7. POST api/TaiKhoan/forgot-password
        // =====================================================
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            var email = NormalizeEmail(request.Email);

            if (!IsValidEmail(email))
                return BadRequest("Email không hợp lệ");

            var user = await _context.TaiKhoans
                .FirstOrDefaultAsync(x => x.Email.ToLower() == email);

            if (user == null)
                return NotFound("Email chưa được đăng ký");

            var code = Random.Shared.Next(100000, 999999).ToString();

            OtpStore[email] = new OtpInfo
            {
                Code      = code,
                ExpiresAt = DateTime.Now.AddMinutes(10)
            };

            await SendOtpEmail(email, code);

            return Ok(new { message = "Mã xác nhận đã được gửi đến email của bạn" });
        }

        // =====================================================
        // 8. POST api/TaiKhoan/reset-password
        // =====================================================
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            var email       = NormalizeEmail(request.Email);
            var code        = request.Code?.Trim() ?? string.Empty;
            var newPassword = request.NewPassword?.Trim() ?? string.Empty;

            if (!IsValidEmail(email))
                return BadRequest("Email không hợp lệ");

            if (string.IsNullOrWhiteSpace(code))
                return BadRequest("Vui lòng nhập mã xác nhận");

            var passwordError = ValidatePassword(newPassword);
            if (passwordError != null)
                return BadRequest(passwordError);

            if (!OtpStore.TryGetValue(email, out var otp))
                return BadRequest("Bạn chưa yêu cầu mã xác nhận hoặc mã đã hết hạn");

            if (otp.ExpiresAt < DateTime.Now)
            {
                OtpStore.Remove(email);
                return BadRequest("Mã xác nhận đã hết hạn");
            }

            if (otp.Code != code)
                return BadRequest("Mã xác nhận không đúng");

            var user = await _context.TaiKhoans
                .FirstOrDefaultAsync(x => x.Email.ToLower() == email);

            if (user == null)
                return NotFound("Không tìm thấy tài khoản");

            user.MatKhau = newPassword;
            await _context.SaveChangesAsync();
            OtpStore.Remove(email);

            return Ok(new { message = "Cập nhật mật khẩu thành công" });
        }

        // =====================================================
        // HELPER METHODS
        // =====================================================
        private static string NormalizeEmail(string? email)
            => (email ?? string.Empty).Trim().ToLower();

        private static bool IsValidEmail(string email)
            => Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$");

        private static string? ValidatePassword(string password)
        {
            if (string.IsNullOrWhiteSpace(password))
                return "Vui lòng nhập mật khẩu";

            if (password.Length < 8 || password.Length > 32)
                return "Mật khẩu phải từ 8 đến 32 ký tự";

            if (!Regex.IsMatch(password, @"[A-Za-z]"))
                return "Mật khẩu phải có ít nhất 1 chữ cái";

            if (!Regex.IsMatch(password, @"\d"))
                return "Mật khẩu phải có ít nhất 1 chữ số";

            if (!Regex.IsMatch(password, @"[^A-Za-z0-9]"))
                return "Mật khẩu phải có ít nhất 1 ký tự đặc biệt";

            return null;
        }

        private async Task SendOtpEmail(string toEmail, string code)
        {
            var host           = _configuration["EmailSettings:SmtpHost"];
            var portText       = _configuration["EmailSettings:SmtpPort"];
            var senderEmail    = _configuration["EmailSettings:SenderEmail"];
            var senderPassword = _configuration["EmailSettings:SenderPassword"];
            var senderName     = _configuration["EmailSettings:SenderName"] ?? "JobGo";

            try
            {
                using var client = new SmtpClient(host, int.Parse(portText ?? "587"))
                {
                    EnableSsl   = true,
                    Credentials = new NetworkCredential(senderEmail, senderPassword)
                };

                using var mail = new MailMessage
                {
                    From       = new MailAddress(senderEmail!, senderName),
                    Subject    = "Mã xác nhận đổi mật khẩu JobGo",
                    Body       = $"Mã xác nhận của bạn là: {code}. Có hiệu lực trong 10 phút.",
                    IsBodyHtml = false
                };

                mail.To.Add(toEmail);
                await client.SendMailAsync(mail);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi SMTP: {ex.Message}");
                Console.WriteLine($"OTP cho {toEmail}: {code}");
            }
        }
    }
}