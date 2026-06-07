using System;

namespace TaoAPI.Entities;

public partial class HoSoCv
{
    public int IdCv { get; set; }

    public int IdUngvien { get; set; }

    public string? LoaiMauCv { get; set; }

    public string? TieuDeCv { get; set; }

    public string? AnhCv { get; set; }

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

    public bool? TrangThai { get; set; }

    public DateTime? NgayTao { get; set; }

    public DateTime? NgayCapNhat { get; set; }

    public virtual UngVien IdUngvienNavigation { get; set; } = null!;
}