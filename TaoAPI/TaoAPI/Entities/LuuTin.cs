using System;
using System.Collections.Generic;

namespace TaoAPI.Entities;

public partial class LuuTin
{
    public int IdLuu { get; set; }

    public int IdUngvien { get; set; }

    public int IdTin { get; set; }

    public DateTime? NgayLuu { get; set; }

    public virtual TinTuyenDung IdTinNavigation { get; set; } = null!;

    public virtual UngVien IdUngvienNavigation { get; set; } = null!;
}
