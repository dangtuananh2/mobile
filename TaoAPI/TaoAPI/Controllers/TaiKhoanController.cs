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

        public class RegisterRequest
        {
            public string? Email { get; set; }
            public string? MatKhau { get; set; }
            public string? HoTen { get; set; }
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

        [HttpGet]
        public async Task<ActionResult<IEnumerable<TaiKhoan>>> GetTaiKhoans()
        {
            return await _context.TaiKhoans.ToListAsync();
        }

        [HttpPost]
        public async Task<ActionResult> PostTaiKhoan(RegisterRequest request)
        {
            var email = NormalizeEmail(request.Email);
            var password = request.MatKhau?.Trim() ?? string.Empty;
            var phone = request.SoDienThoai?.Trim();
            var hoTen = request.HoTen?.Trim();

            if (!IsValidEmail(email))
                return BadRequest("Email không hợp lệ");

            var passwordError = ValidatePassword(password);
            if (passwordError != null)
                return BadRequest(passwordError);

            if (string.IsNullOrWhiteSpace(hoTen))
                return BadRequest("Vui lòng nhập họ tên");

            var existed = await _context.TaiKhoans
                .AnyAsync(x => x.Email.ToLower() == email);

            if (existed)
                return BadRequest("Email đã tồn tại");

            var vaiTro = request.VaiTro == "admin"
                ? "admin"
                : "ung_vien";

            var taiKhoan = new TaiKhoan
            {
                Email = email,
                MatKhau = password,
                SoDienThoai = phone,
                VaiTro = vaiTro,
                TrangThai = true,
                NgayTao = DateTime.Now
            };

            _context.TaiKhoans.Add(taiKhoan);
            await _context.SaveChangesAsync();

            if (vaiTro == "ung_vien")
            {
                var ungVien = new UngVien
                {
                    IdTaikhoan = taiKhoan.IdTaikhoan,
                    HoTen = hoTen
                };

                _context.UngViens.Add(ungVien);
                await _context.SaveChangesAsync();
            }

            return Ok(new
            {
                message = "Đăng ký thành công!",
                idTaikhoan = taiKhoan.IdTaikhoan,
                email = taiKhoan.Email,
                vaiTro = taiKhoan.VaiTro
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest loginInfo)
        {
            var email = NormalizeEmail(loginInfo.Email);
            var password = loginInfo.MatKhau?.Trim() ?? string.Empty;

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
                return BadRequest("Vui lòng nhập email và mật khẩu");

            var user = await _context.TaiKhoans
                .FirstOrDefaultAsync(u => u.Email.ToLower() == email && u.MatKhau == password);

            if (user == null)
                return Unauthorized("Sai email hoặc mật khẩu");

            if (user.TrangThai == false)
                return Unauthorized("Tài khoản đã bị khóa");

            var hoTen = await _context.UngViens
                .Where(u => u.IdTaikhoan == user.IdTaikhoan)
                .Select(u => u.HoTen)
                .FirstOrDefaultAsync();

            return Ok(new
            {
                idTaikhoan = user.IdTaikhoan,
                email = user.Email,
                vaiTro = user.VaiTro,
                hoTen = hoTen ?? "Người dùng"
            });
        }

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
                Code = code,
                ExpiresAt = DateTime.Now.AddMinutes(10)
            };

            await SendOtpEmail(email, code);

            return Ok(new
            {
                message = "Mã xác nhận đã được gửi đến email của bạn"
            });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            var email = NormalizeEmail(request.Email);
            var code = request.Code?.Trim() ?? string.Empty;
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

            return Ok(new
            {
                message = "Cập nhật mật khẩu thành công"
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult> GetTaiKhoan(int id)
        {
            var data = await _context.TaiKhoans
                .Where(t => t.IdTaikhoan == id)
                .Select(t => new
                {
                    idTaikhoan = t.IdTaikhoan,
                    email = t.Email,
                    vaiTro = t.VaiTro,
                    soDienThoai = t.SoDienThoai,
                    hoTen = _context.UngViens
                        .Where(u => u.IdTaikhoan == t.IdTaikhoan)
                        .Select(u => u.HoTen)
                        .FirstOrDefault()
                })
                .FirstOrDefaultAsync();

            if (data == null)
                return NotFound("Không tìm thấy tài khoản");

            return Ok(data);
        }

        private static string NormalizeEmail(string? email)
        {
            return (email ?? string.Empty).Trim().ToLower();
        }

        private static bool IsValidEmail(string email)
        {
            return Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$");
        }

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
            var host = _configuration["EmailSettings:SmtpHost"];
            var portText = _configuration["EmailSettings:SmtpPort"];
            var senderEmail = _configuration["EmailSettings:SenderEmail"];
            var senderPassword = _configuration["EmailSettings:SenderPassword"];
            var senderName = _configuration["EmailSettings:SenderName"] ?? "JobGo";

            if (string.IsNullOrWhiteSpace(host) ||
                string.IsNullOrWhiteSpace(portText) ||
                string.IsNullOrWhiteSpace(senderEmail) ||
                string.IsNullOrWhiteSpace(senderPassword))
            {
                Console.WriteLine($"OTP đổi mật khẩu cho {toEmail}: {code}");
                return;
            }

            using var client = new SmtpClient(host, int.Parse(portText))
            {
                EnableSsl = true,
                Credentials = new NetworkCredential(senderEmail, senderPassword)
            };

            using var mail = new MailMessage
            {
                From = new MailAddress(senderEmail, senderName),
                Subject = "Mã xác nhận đổi mật khẩu JobGo",
                Body = $"Mã xác nhận đổi mật khẩu của bạn là: {code}. Mã có hiệu lực trong 10 phút.",
                IsBodyHtml = false
            };

            mail.To.Add(toEmail);

            await client.SendMailAsync(mail);
        }
    }
}