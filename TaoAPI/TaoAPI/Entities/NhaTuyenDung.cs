using System;
using System.Collections.Generic;

namespace TaoAPI.Entities;

public partial class NhaTuyenDung
{
    public int IdNtd { get; set; }

    public int IdTaikhoan { get; set; }

    public string TenCongTy { get; set; } = null!;

    public string? Logo { get; set; }

    public string? DiaChi { get; set; }

    public string? MoTa { get; set; }

    public string? LinhVuc { get; set; }

    public string? Website { get; set; }

    public virtual TaiKhoan IdTaikhoanNavigation { get; set; } = null!;

    public virtual ICollection<TinTuyenDung> TinTuyenDungs { get; set; } = new List<TinTuyenDung>();
}
