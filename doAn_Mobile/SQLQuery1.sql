CREATE DATABASE mobile_app;
GO

USE mobile_app;
GO

-- =========================
-- BẢNG TÀI KHOẢN
-- =========================
CREATE TABLE TaiKhoan (
    id_taikhoan INT PRIMARY KEY IDENTITY(1,1),
    email NVARCHAR(100) UNIQUE NOT NULL,
    mat_khau NVARCHAR(255) NOT NULL,
    so_dien_thoai NVARCHAR(15),
    vai_tro NVARCHAR(20) NOT NULL DEFAULT 'ung_vien',
    trang_thai BIT DEFAULT 1,
    ngay_tao DATETIME DEFAULT GETDATE(),

    CONSTRAINT CK_TaiKhoan_VaiTro
    CHECK (vai_tro IN ('admin', 'ung_vien', 'nha_tuyen_dung'))
);
GO

-- =========================
-- BẢNG ỨNG VIÊN
-- =========================
CREATE TABLE UngVien (
    id_ungvien INT PRIMARY KEY IDENTITY(1,1),
    id_taikhoan INT NOT NULL,

    ho_ten NVARCHAR(100),
    anh_dai_dien NVARCHAR(MAX),
    ngay_sinh DATE,
    gioi_tinh NVARCHAR(10),
    dia_chi NVARCHAR(255),

    vi_tri_ung_tuyen NVARCHAR(150),
    profile_facebook NVARCHAR(255),
    nguoi_gioi_thieu NVARCHAR(MAX),

    CONSTRAINT FK_UngVien_TaiKhoan
    FOREIGN KEY (id_taikhoan)
    REFERENCES TaiKhoan(id_taikhoan)
    ON DELETE CASCADE,

    CONSTRAINT UQ_UngVien_TaiKhoan
    UNIQUE (id_taikhoan)
);
GO

-- =========================
-- BẢNG NHÀ TUYỂN DỤNG
-- =========================
CREATE TABLE NhaTuyenDung (
    id_ntd INT PRIMARY KEY IDENTITY(1,1),
    id_taikhoan INT NOT NULL,

    ten_cong_ty NVARCHAR(150) NOT NULL,
    logo NVARCHAR(MAX),
    dia_chi NVARCHAR(255),
    mo_ta NVARCHAR(MAX),
    linh_vuc NVARCHAR(100),
    website NVARCHAR(255),

    CONSTRAINT FK_NhaTuyenDung_TaiKhoan
    FOREIGN KEY (id_taikhoan)
    REFERENCES TaiKhoan(id_taikhoan)
    ON DELETE CASCADE,

    CONSTRAINT UQ_NhaTuyenDung_TaiKhoan
    UNIQUE (id_taikhoan)
);
GO

-- =========================
-- BẢNG HỒ SƠ CV
-- =========================
CREATE TABLE HoSoCV (
    id_cv INT PRIMARY KEY IDENTITY(1,1),
    id_ungvien INT NOT NULL,

    -- Loại mẫu CV: simple / pro
    loai_mau_cv NVARCHAR(50) NOT NULL DEFAULT 'simple',

    -- Thông tin CV
    tieu_de_cv NVARCHAR(150),
    anh_cv NVARCHAR(MAX),
    muc_tieu NVARCHAR(MAX),

    -- Học vấn
    hoc_van NVARCHAR(MAX),
    mo_ta_hoc_van NVARCHAR(MAX),

    -- Nội dung chính
    kinh_nghiem NVARCHAR(MAX),
    ky_nang NVARCHAR(MAX),
    so_thich NVARCHAR(MAX),
    chung_chi NVARCHAR(MAX),
    danh_hieu NVARCHAR(MAX),
    hoat_dong NVARCHAR(MAX),
    nganh_nghe NVARCHAR(MAX),

    -- Trạng thái CV
    trang_thai_tim_viec BIT DEFAULT 1,
    trang_thai BIT DEFAULT 1,

    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME NULL,

    CONSTRAINT FK_HoSoCV_UngVien
    FOREIGN KEY (id_ungvien)
    REFERENCES UngVien(id_ungvien)
    ON DELETE CASCADE,

    CONSTRAINT CK_HoSoCV_LoaiMau
    CHECK (loai_mau_cv IN ('simple', 'pro'))
);
GO

-- =========================
-- BẢNG TIN TUYỂN DỤNG
-- =========================
CREATE TABLE TinTuyenDung (
    id_tin INT PRIMARY KEY IDENTITY(1,1),
    id_ntd INT NOT NULL,

    tieu_de NVARCHAR(200) NOT NULL,
    mo_ta_cong_viec NVARCHAR(MAX),
    yeu_cau NVARCHAR(MAX),
    quyen_loi NVARCHAR(MAX),
    dia_diem NVARCHAR(255),
    muc_luong NVARCHAR(100),
    kinh_nghiem NVARCHAR(100),
    hinh_thuc NVARCHAR(50),
    nganh_nghe NVARCHAR(100),
    han_nop DATE,
    trang_thai NVARCHAR(50) DEFAULT N'Đang tuyển',
    ngay_dang DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_TinTuyenDung_NhaTuyenDung
    FOREIGN KEY (id_ntd)
    REFERENCES NhaTuyenDung(id_ntd)
    ON DELETE CASCADE
);
GO

-- =========================
-- BẢNG ỨNG TUYỂN
-- =========================
CREATE TABLE UngTuyen (
    id_ungtuyen INT PRIMARY KEY IDENTITY(1,1),
    id_tin INT NOT NULL,
    id_cv INT NOT NULL,

    ngay_ung_tuyen DATETIME DEFAULT GETDATE(),
    trang_thai NVARCHAR(50) DEFAULT N'Chờ duyệt',

    CONSTRAINT FK_UngTuyen_TinTuyenDung
    FOREIGN KEY (id_tin)
    REFERENCES TinTuyenDung(id_tin)
    ON DELETE CASCADE,

    CONSTRAINT FK_UngTuyen_HoSoCV
    FOREIGN KEY (id_cv)
    REFERENCES HoSoCV(id_cv)
);
GO

-- =========================
-- BẢNG LƯU TIN
-- =========================
CREATE TABLE LuuTin (
    id_luu INT PRIMARY KEY IDENTITY(1,1),
    id_ungvien INT NOT NULL,
    id_tin INT NOT NULL,

    ngay_luu DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_LuuTin_UngVien
    FOREIGN KEY (id_ungvien)
    REFERENCES UngVien(id_ungvien)
    ON DELETE CASCADE,

    CONSTRAINT FK_LuuTin_TinTuyenDung
    FOREIGN KEY (id_tin)
    REFERENCES TinTuyenDung(id_tin)
);
GO

-- =========================
-- UNIQUE CONSTRAINTS
-- =========================

-- Tránh ứng viên lưu trùng một tin nhiều lần
ALTER TABLE LuuTin
ADD CONSTRAINT UQ_LuuTin_UngVien_Tin
UNIQUE (id_ungvien, id_tin);
GO

-- Tránh một CV ứng tuyển trùng một tin nhiều lần
ALTER TABLE UngTuyen
ADD CONSTRAINT UQ_UngTuyen_Tin_CV
UNIQUE (id_tin, id_cv);
GO

-- =========================
-- INDEXES
-- =========================

CREATE INDEX IX_UngVien_IdTaiKhoan
ON UngVien(id_taikhoan);
GO

CREATE INDEX IX_NhaTuyenDung_IdTaiKhoan
ON NhaTuyenDung(id_taikhoan);
GO

CREATE INDEX IX_HoSoCV_IdUngVien
ON HoSoCV(id_ungvien);
GO

CREATE INDEX IX_HoSoCV_LoaiMauCv
ON HoSoCV(loai_mau_cv);
GO

CREATE INDEX IX_TinTuyenDung_IdNtd
ON TinTuyenDung(id_ntd);
GO

CREATE INDEX IX_UngTuyen_IdTin
ON UngTuyen(id_tin);
GO

CREATE INDEX IX_UngTuyen_IdCv
ON UngTuyen(id_cv);
GO

CREATE INDEX IX_LuuTin_IdUngVien
ON LuuTin(id_ungvien);
GO

CREATE INDEX IX_LuuTin_IdTin
ON LuuTin(id_tin);
GO

-- =========================
-- DATA MẪU ADMIN
-- =========================

INSERT INTO TaiKhoan (
    email,
    mat_khau,
    so_dien_thoai,
    vai_tro,
    trang_thai
)
VALUES (
    'admin@gmail.com',
    '123456',
    '0123456789',
    'admin',
    1
);
GO