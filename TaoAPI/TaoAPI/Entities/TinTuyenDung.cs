using System;
using System.Collections.Generic;

namespace TaoAPI.Entities;

public partial class TinTuyenDung
{
    public int IdTin { get; set; }

    public int IdNtd { get; set; }

    public string TieuDe { get; set; } = null!;

    public string? MoTaCongViec { get; set; }

    public string? YeuCau { get; set; }

    public string? QuyenLoi { get; set; }

    public string? DiaDiem { get; set; }

    public string? MucLuong { get; set; }

    public string? KinhNghiem { get; set; }

    public string? HinhThuc { get; set; }

    public string? NganhNghe { get; set; }

    public DateOnly? HanNop { get; set; }

    public string? TrangThai { get; set; }

    public DateTime? NgayDang { get; set; }

    public virtual NhaTuyenDung IdNtdNavigation { get; set; } = null!;

    public virtual ICollection<LuuTin> LuuTins { get; set; } = new List<LuuTin>();

    public virtual ICollection<UngTuyen> UngTuyens { get; set; } = new List<UngTuyen>();
}
