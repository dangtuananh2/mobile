using System;
using System.Collections.Generic;

namespace TaoAPI.Entities;

public partial class UngTuyen
{
    public int IdUngtuyen { get; set; }

    public int IdTin { get; set; }

    public int IdCv { get; set; }

    public DateTime? NgayUngTuyen { get; set; }

    public string? TrangThai { get; set; }

    public virtual HoSoCv IdCvNavigation { get; set; } = null!;

    public virtual TinTuyenDung IdTinNavigation { get; set; } = null!;
}
