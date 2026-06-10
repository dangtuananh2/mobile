using System;
using System.Collections.Generic;

namespace TaoAPI.Entities;

public partial class LoiMoiUngVien
{
    public int IdLoiMoi { get; set; }

    public int IdNtd { get; set; }

    public int IdCv { get; set; }

    public string? TieuDe { get; set; }

    public string? NoiDung { get; set; }

    public string? TrangThai { get; set; }

    public DateTime? NgayGui { get; set; }

    public DateTime? NgayPhanHoi { get; set; }

    public virtual HoSoCv IdCvNavigation { get; set; } = null!;

    public virtual NhaTuyenDung IdNtdNavigation { get; set; } = null!;
}
