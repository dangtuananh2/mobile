using System;
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

    public virtual DbSet<TaiKhoan> TaiKhoans { get; set; }

    public virtual DbSet<UngVien> UngViens { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseSqlServer(
                "Data Source=DESKTOP-RHOOB01\\SQLEXPRESS03;Initial Catalog=mobile_app;Integrated Security=True;TrustServerCertificate=True"
            );
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<HoSoCv>(entity =>
        {
            entity.HasKey(e => e.IdCv).HasName("PK__HoSoCV__00B7DEE59B9DE6C2");

            entity.ToTable("HoSoCV");

            entity.Property(e => e.IdCv)
                .HasColumnName("id_cv");

            entity.Property(e => e.IdUngvien)
                .HasColumnName("id_ungvien");

            entity.Property(e => e.LoaiMauCv)
                .HasMaxLength(50)
                .HasDefaultValue("simple")
                .HasColumnName("loai_mau_cv");

            entity.Property(e => e.TieuDeCv)
                .HasMaxLength(150)
                .HasColumnName("tieu_de_cv");

            entity.Property(e => e.AnhCv)
                .HasColumnName("anh_cv");

            entity.Property(e => e.MucTieu)
                .HasColumnName("muc_tieu");

            entity.Property(e => e.HocVan)
                .HasColumnName("hoc_van");

            entity.Property(e => e.MoTaHocVan)
                .HasColumnName("mo_ta_hoc_van");

            entity.Property(e => e.KinhNghiem)
                .HasColumnName("kinh_nghiem");

            entity.Property(e => e.KyNang)
                .HasColumnName("ky_nang");

            entity.Property(e => e.SoThich)
                .HasColumnName("so_thich");

            entity.Property(e => e.ChungChi)
                .HasColumnName("chung_chi");

            entity.Property(e => e.DanhHieu)
                .HasColumnName("danh_hieu");

            entity.Property(e => e.HoatDong)
                .HasColumnName("hoat_dong");

            entity.Property(e => e.NganhNghe)
                .HasColumnName("nganh_nghe");

            entity.Property(e => e.TrangThaiTimViec)
                .HasDefaultValue(true)
                .HasColumnName("trang_thai_tim_viec");

            entity.Property(e => e.TrangThai)
                .HasDefaultValue(true)
                .HasColumnName("trang_thai");

            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("ngay_tao");

            entity.Property(e => e.NgayCapNhat)
                .HasColumnType("datetime")
                .HasColumnName("ngay_cap_nhat");

            entity.HasOne(d => d.IdUngvienNavigation)
                .WithMany(p => p.HoSoCvs)
                .HasForeignKey(d => d.IdUngvien)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_CV_UngVien");
        });

        modelBuilder.Entity<TaiKhoan>(entity =>
        {
            entity.HasKey(e => e.IdTaikhoan).HasName("PK__TaiKhoan__353EB507F4300A6E");

            entity.ToTable("TaiKhoan");

            entity.HasIndex(e => e.Email, "UQ__TaiKhoan__AB6E6164ED0704AF").IsUnique();

            entity.Property(e => e.IdTaikhoan)
                .HasColumnName("id_taikhoan");

            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .HasColumnName("email");

            entity.Property(e => e.MatKhau)
                .HasMaxLength(255)
                .HasColumnName("mat_khau");

            entity.Property(e => e.SoDienThoai)
                .HasMaxLength(15)
                .HasColumnName("so_dien_thoai");

            entity.Property(e => e.VaiTro)
                .HasMaxLength(20)
                .HasDefaultValue("ung_vien")
                .HasColumnName("vai_tro");

            entity.Property(e => e.TrangThai)
                .HasDefaultValue(true)
                .HasColumnName("trang_thai");

            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("ngay_tao");
        });

        modelBuilder.Entity<UngVien>(entity =>
        {
            entity.HasKey(e => e.IdUngvien).HasName("PK__UngVien__D132BE7A1E9B51AB");

            entity.ToTable("UngVien");

            entity.Property(e => e.IdUngvien)
                .HasColumnName("id_ungvien");

            entity.Property(e => e.IdTaikhoan)
                .HasColumnName("id_taikhoan");

            entity.Property(e => e.HoTen)
                .HasMaxLength(100)
                .HasColumnName("ho_ten");

            entity.Property(e => e.AnhDaiDien)
                .HasColumnName("anh_dai_dien");

            entity.Property(e => e.NgaySinh)
                .HasColumnName("ngay_sinh");

            entity.Property(e => e.GioiTinh)
                .HasMaxLength(10)
                .HasColumnName("gioi_tinh");

            entity.Property(e => e.DiaChi)
                .HasMaxLength(255)
                .HasColumnName("dia_chi");

            entity.Property(e => e.ViTriUngTuyen)
                .HasMaxLength(150)
                .HasColumnName("vi_tri_ung_tuyen");

            entity.Property(e => e.ProfileFacebook)
                .HasMaxLength(255)
                .HasColumnName("profile_facebook");

            entity.Property(e => e.NguoiGioiThieu)
                .HasColumnName("nguoi_gioi_thieu");

            entity.HasOne(d => d.IdTaikhoanNavigation)
                .WithMany(p => p.UngViens)
                .HasForeignKey(d => d.IdTaikhoan)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UngVien_TaiKhoan");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}