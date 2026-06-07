using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace TaoAPI.Entities;

public partial class MobileAppContext : DbContext
{
    public MobileAppContext()
    {
    }

    public MobileAppContext(DbContextOptions<MobileAppContext> options)
        : base(options)
    {
    }

    public virtual DbSet<HoSoCv> HoSoCvs { get; set; }

    public virtual DbSet<LuuTin> LuuTins { get; set; }

    public virtual DbSet<NhaTuyenDung> NhaTuyenDungs { get; set; }

    public virtual DbSet<TaiKhoan> TaiKhoans { get; set; }

    public virtual DbSet<TinTuyenDung> TinTuyenDungs { get; set; }

    public virtual DbSet<UngTuyen> UngTuyens { get; set; }

    public virtual DbSet<UngVien> UngViens { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=.;Database=mobile_app;Trusted_Connection=True;TrustServerCertificate=True;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<HoSoCv>(entity =>
        {
            entity.HasKey(e => e.IdCv).HasName("PK__HoSoCV__00B7DEE5B189FAF8");

            entity.ToTable("HoSoCV");

            entity.HasIndex(e => e.IdUngvien, "IX_HoSoCV_IdUngVien");

            entity.HasIndex(e => e.LoaiMauCv, "IX_HoSoCV_LoaiMauCv");

            entity.Property(e => e.IdCv).HasColumnName("id_cv");
            entity.Property(e => e.AnhCv).HasColumnName("anh_cv");
            entity.Property(e => e.ChungChi).HasColumnName("chung_chi");
            entity.Property(e => e.DanhHieu).HasColumnName("danh_hieu");
            entity.Property(e => e.HoatDong).HasColumnName("hoat_dong");
            entity.Property(e => e.HocVan).HasColumnName("hoc_van");
            entity.Property(e => e.IdUngvien).HasColumnName("id_ungvien");
            entity.Property(e => e.KinhNghiem).HasColumnName("kinh_nghiem");
            entity.Property(e => e.KyNang).HasColumnName("ky_nang");
            entity.Property(e => e.LoaiMauCv)
                .HasMaxLength(50)
                .HasDefaultValue("simple")
                .HasColumnName("loai_mau_cv");
            entity.Property(e => e.MoTaHocVan).HasColumnName("mo_ta_hoc_van");
            entity.Property(e => e.MucTieu).HasColumnName("muc_tieu");
            entity.Property(e => e.NganhNghe).HasColumnName("nganh_nghe");
            entity.Property(e => e.NgayCapNhat)
                .HasColumnType("datetime")
                .HasColumnName("ngay_cap_nhat");
            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("ngay_tao");
            entity.Property(e => e.SoThich).HasColumnName("so_thich");
            entity.Property(e => e.TieuDeCv)
                .HasMaxLength(150)
                .HasColumnName("tieu_de_cv");
            entity.Property(e => e.TrangThai)
                .HasDefaultValue(true)
                .HasColumnName("trang_thai");
            entity.Property(e => e.TrangThaiTimViec)
                .HasDefaultValue(true)
                .HasColumnName("trang_thai_tim_viec");

            entity.HasOne(d => d.IdUngvienNavigation).WithMany(p => p.HoSoCvs)
                .HasForeignKey(d => d.IdUngvien)
                .HasConstraintName("FK_HoSoCV_UngVien");
        });

        modelBuilder.Entity<LuuTin>(entity =>
        {
            entity.HasKey(e => e.IdLuu).HasName("PK__LuuTin__6CC980C44755DCCB");

            entity.ToTable("LuuTin");

            entity.HasIndex(e => e.IdTin, "IX_LuuTin_IdTin");

            entity.HasIndex(e => e.IdUngvien, "IX_LuuTin_IdUngVien");

            entity.HasIndex(e => new { e.IdUngvien, e.IdTin }, "UQ_LuuTin_UngVien_Tin").IsUnique();

            entity.Property(e => e.IdLuu).HasColumnName("id_luu");
            entity.Property(e => e.IdTin).HasColumnName("id_tin");
            entity.Property(e => e.IdUngvien).HasColumnName("id_ungvien");
            entity.Property(e => e.NgayLuu)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("ngay_luu");

            entity.HasOne(d => d.IdTinNavigation).WithMany(p => p.LuuTins)
                .HasForeignKey(d => d.IdTin)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_LuuTin_TinTuyenDung");

            entity.HasOne(d => d.IdUngvienNavigation).WithMany(p => p.LuuTins)
                .HasForeignKey(d => d.IdUngvien)
                .HasConstraintName("FK_LuuTin_UngVien");
        });

        modelBuilder.Entity<NhaTuyenDung>(entity =>
        {
            entity.HasKey(e => e.IdNtd).HasName("PK__NhaTuyen__6E4DBC882DABEBA5");

            entity.ToTable("NhaTuyenDung");

            entity.HasIndex(e => e.IdTaikhoan, "IX_NhaTuyenDung_IdTaiKhoan");

            entity.HasIndex(e => e.IdTaikhoan, "UQ_NhaTuyenDung_TaiKhoan").IsUnique();

            entity.Property(e => e.IdNtd).HasColumnName("id_ntd");
            entity.Property(e => e.DiaChi)
                .HasMaxLength(255)
                .HasColumnName("dia_chi");
            entity.Property(e => e.IdTaikhoan).HasColumnName("id_taikhoan");
            entity.Property(e => e.LinhVuc)
                .HasMaxLength(100)
                .HasColumnName("linh_vuc");
            entity.Property(e => e.Logo).HasColumnName("logo");
            entity.Property(e => e.MoTa).HasColumnName("mo_ta");
            entity.Property(e => e.TenCongTy)
                .HasMaxLength(150)
                .HasColumnName("ten_cong_ty");
            entity.Property(e => e.Website)
                .HasMaxLength(255)
                .HasColumnName("website");

            entity.HasOne(d => d.IdTaikhoanNavigation).WithOne(p => p.NhaTuyenDung)
                .HasForeignKey<NhaTuyenDung>(d => d.IdTaikhoan)
                .HasConstraintName("FK_NhaTuyenDung_TaiKhoan");
        });

        modelBuilder.Entity<TaiKhoan>(entity =>
        {
            entity.HasKey(e => e.IdTaikhoan).HasName("PK__TaiKhoan__353EB507CD99FE47");

            entity.ToTable("TaiKhoan");

            entity.HasIndex(e => e.Email, "UQ__TaiKhoan__AB6E61640B877D05").IsUnique();

            entity.Property(e => e.IdTaikhoan).HasColumnName("id_taikhoan");
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .HasColumnName("email");
            entity.Property(e => e.MatKhau)
                .HasMaxLength(255)
                .HasColumnName("mat_khau");
            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("ngay_tao");
            entity.Property(e => e.SoDienThoai)
                .HasMaxLength(15)
                .HasColumnName("so_dien_thoai");
            entity.Property(e => e.TrangThai)
                .HasDefaultValue(true)
                .HasColumnName("trang_thai");
            entity.Property(e => e.VaiTro)
                .HasMaxLength(20)
                .HasDefaultValue("ung_vien")
                .HasColumnName("vai_tro");
        });

        modelBuilder.Entity<TinTuyenDung>(entity =>
        {
            entity.HasKey(e => e.IdTin).HasName("PK__TinTuyen__6A28C2CAC6B5FBD6");

            entity.ToTable("TinTuyenDung");

            entity.HasIndex(e => e.IdNtd, "IX_TinTuyenDung_IdNtd");

            entity.Property(e => e.IdTin).HasColumnName("id_tin");
            entity.Property(e => e.DiaDiem)
                .HasMaxLength(255)
                .HasColumnName("dia_diem");
            entity.Property(e => e.HanNop).HasColumnName("han_nop");
            entity.Property(e => e.HinhThuc)
                .HasMaxLength(50)
                .HasColumnName("hinh_thuc");
            entity.Property(e => e.IdNtd).HasColumnName("id_ntd");
            entity.Property(e => e.KinhNghiem)
                .HasMaxLength(100)
                .HasColumnName("kinh_nghiem");
            entity.Property(e => e.MoTaCongViec).HasColumnName("mo_ta_cong_viec");
            entity.Property(e => e.MucLuong)
                .HasMaxLength(100)
                .HasColumnName("muc_luong");
            entity.Property(e => e.NganhNghe)
                .HasMaxLength(100)
                .HasColumnName("nganh_nghe");
            entity.Property(e => e.NgayDang)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("ngay_dang");
            entity.Property(e => e.QuyenLoi).HasColumnName("quyen_loi");
            entity.Property(e => e.TieuDe)
                .HasMaxLength(200)
                .HasColumnName("tieu_de");
            entity.Property(e => e.TrangThai)
                .HasMaxLength(50)
                .HasDefaultValue("Đang tuyển")
                .HasColumnName("trang_thai");
            entity.Property(e => e.YeuCau).HasColumnName("yeu_cau");

            entity.HasOne(d => d.IdNtdNavigation).WithMany(p => p.TinTuyenDungs)
                .HasForeignKey(d => d.IdNtd)
                .HasConstraintName("FK_TinTuyenDung_NhaTuyenDung");
        });

        modelBuilder.Entity<UngTuyen>(entity =>
        {
            entity.HasKey(e => e.IdUngtuyen).HasName("PK__UngTuyen__2C8B8D3674F30F36");

            entity.ToTable("UngTuyen");

            entity.HasIndex(e => e.IdCv, "IX_UngTuyen_IdCv");

            entity.HasIndex(e => e.IdTin, "IX_UngTuyen_IdTin");

            entity.HasIndex(e => new { e.IdTin, e.IdCv }, "UQ_UngTuyen_Tin_CV").IsUnique();

            entity.Property(e => e.IdUngtuyen).HasColumnName("id_ungtuyen");
            entity.Property(e => e.IdCv).HasColumnName("id_cv");
            entity.Property(e => e.IdTin).HasColumnName("id_tin");
            entity.Property(e => e.NgayUngTuyen)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("ngay_ung_tuyen");
            entity.Property(e => e.TrangThai)
                .HasMaxLength(50)
                .HasDefaultValue("Chờ duyệt")
                .HasColumnName("trang_thai");

            entity.HasOne(d => d.IdCvNavigation).WithMany(p => p.UngTuyens)
                .HasForeignKey(d => d.IdCv)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UngTuyen_HoSoCV");

            entity.HasOne(d => d.IdTinNavigation).WithMany(p => p.UngTuyens)
                .HasForeignKey(d => d.IdTin)
                .HasConstraintName("FK_UngTuyen_TinTuyenDung");
        });

        modelBuilder.Entity<UngVien>(entity =>
        {
            entity.HasKey(e => e.IdUngvien).HasName("PK__UngVien__D132BE7A7489CE7A");

            entity.ToTable("UngVien");

            entity.HasIndex(e => e.IdTaikhoan, "IX_UngVien_IdTaiKhoan");

            entity.HasIndex(e => e.IdTaikhoan, "UQ_UngVien_TaiKhoan").IsUnique();

            entity.Property(e => e.IdUngvien).HasColumnName("id_ungvien");
            entity.Property(e => e.AnhDaiDien).HasColumnName("anh_dai_dien");
            entity.Property(e => e.DiaChi)
                .HasMaxLength(255)
                .HasColumnName("dia_chi");
            entity.Property(e => e.GioiTinh)
                .HasMaxLength(10)
                .HasColumnName("gioi_tinh");
            entity.Property(e => e.HoTen)
                .HasMaxLength(100)
                .HasColumnName("ho_ten");
            entity.Property(e => e.IdTaikhoan).HasColumnName("id_taikhoan");
            entity.Property(e => e.NgaySinh).HasColumnName("ngay_sinh");
            entity.Property(e => e.NguoiGioiThieu).HasColumnName("nguoi_gioi_thieu");
            entity.Property(e => e.ProfileFacebook)
                .HasMaxLength(255)
                .HasColumnName("profile_facebook");
            entity.Property(e => e.ViTriUngTuyen)
                .HasMaxLength(150)
                .HasColumnName("vi_tri_ung_tuyen");

            entity.HasOne(d => d.IdTaikhoanNavigation).WithOne(p => p.UngVien)
                .HasForeignKey<UngVien>(d => d.IdTaikhoan)
                .HasConstraintName("FK_UngVien_TaiKhoan");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
