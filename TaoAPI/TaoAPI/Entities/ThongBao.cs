using System;
using System.Collections.Generic;

namespace TaoAPI.Entities;

public partial class ThongBao
{
    public int IdThongbao { get; set; }

    public int IdTaikhoan { get; set; }

    public string TieuDe { get; set; } = null!;

    public string NoiDung { get; set; } = null!;

    public DateTime? ThoiGian { get; set; }

    public bool? DaDoc { get; set; }

    public string Loai { get; set; } = null!;

    public virtual TaiKhoan IdTaikhoanNavigation { get; set; } = null!;
}
