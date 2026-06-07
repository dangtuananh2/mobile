using System;
using System.Collections.Generic;

namespace TaoAPI.Entities;

public partial class UngVien
{
    public int IdUngvien { get; set; }

    public int IdTaikhoan { get; set; }

    public string? HoTen { get; set; }

    public string? AnhDaiDien { get; set; }

    public DateOnly? NgaySinh { get; set; }

    public string? GioiTinh { get; set; }

    public string? DiaChi { get; set; }

    public string? ViTriUngTuyen { get; set; }

    public string? ProfileFacebook { get; set; }

    public string? NguoiGioiThieu { get; set; }

    public virtual ICollection<HoSoCv> HoSoCvs { get; set; } = new List<HoSoCv>();

    public virtual TaiKhoan IdTaikhoanNavigation { get; set; } = null!;

    public virtual ICollection<LuuTin> LuuTins { get; set; } = new List<LuuTin>();
}
