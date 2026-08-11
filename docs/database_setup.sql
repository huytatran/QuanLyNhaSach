-- ============================================================
-- SCRIPT TẠO DATABASE: QuanLyNhaSach
-- Chạy toàn bộ script này trong SQL Server Management Studio
-- ============================================================

-- 1. Tạo database (nếu chưa có)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'QuanLyNhaSach')
    CREATE DATABASE QuanLyNhaSach;
GO

USE QuanLyNhaSach;
GO

-- ============================================================
-- 2. XÓA BẢNG CŨ (theo thứ tự phụ thuộc FK)
-- ============================================================
IF OBJECT_ID('DanhGia',          'U') IS NOT NULL DROP TABLE DanhGia;
IF OBJECT_ID('SachBienThe',      'U') IS NOT NULL DROP TABLE SachBienThe;
IF OBJECT_ID('SachVatLy',        'U') IS NOT NULL DROP TABLE SachVatLy;
IF OBJECT_ID('ChiTietDonHang',   'U') IS NOT NULL DROP TABLE ChiTietDonHang;
IF OBJECT_ID('DonHang',          'U') IS NOT NULL DROP TABLE DonHang;
IF OBJECT_ID('DiaChiKhachHang',  'U') IS NOT NULL DROP TABLE DiaChiKhachHang;
IF OBJECT_ID('Sach_TacGia',      'U') IS NOT NULL DROP TABLE Sach_TacGia;
IF OBJECT_ID('Sach',             'U') IS NOT NULL DROP TABLE Sach;
IF OBJECT_ID('KhachHang',        'U') IS NOT NULL DROP TABLE KhachHang;
IF OBJECT_ID('NhanVien',         'U') IS NOT NULL DROP TABLE NhanVien;
IF OBJECT_ID('Voucher',          'U') IS NOT NULL DROP TABLE Voucher;
IF OBJECT_ID('TacGia',           'U') IS NOT NULL DROP TABLE TacGia;
IF OBJECT_ID('NhaXuatBan',       'U') IS NOT NULL DROP TABLE NhaXuatBan;
IF OBJECT_ID('BoSach',           'U') IS NOT NULL DROP TABLE BoSach;
IF OBJECT_ID('TheLoai',          'U') IS NOT NULL DROP TABLE TheLoai;
GO

-- ============================================================
-- 3. TẠO BẢNG
-- ============================================================

-- Thể loại sách
CREATE TABLE TheLoai (
    MaTL    INT           IDENTITY(1,1) PRIMARY KEY,
    TenTL   NVARCHAR(100) NOT NULL
);

-- Tác giả
CREATE TABLE TacGia (
    MaTG    INT           IDENTITY(1,1) PRIMARY KEY,
    TenTG   NVARCHAR(200) NOT NULL,
    TieuSu  NVARCHAR(MAX) NULL
);

-- Nhà xuất bản
CREATE TABLE NhaXuatBan (
    MaNXB   INT           IDENTITY(1,1) PRIMARY KEY,
    TenNXB  NVARCHAR(200) NOT NULL,
    Sdt     NVARCHAR(20)  NULL,
    DiaChi  NVARCHAR(300) NULL
);

-- Bộ sách / series
CREATE TABLE BoSach (
    MaBoSach    INT           IDENTITY(1,1) PRIMARY KEY,
    TenBoSach   NVARCHAR(200) NOT NULL,
    MoTa        NVARCHAR(MAX) NULL
);

-- Nhân viên
CREATE TABLE NhanVien (
    MaNV        INT           IDENTITY(1,1) PRIMARY KEY,
    TenNV       NVARCHAR(200) NOT NULL,
    Sdt         NVARCHAR(20)  NULL,
    Email       NVARCHAR(200) NULL,
    DiaChi      NVARCHAR(300) NULL,
    TaiKhoan    NVARCHAR(100) NOT NULL UNIQUE,
    MatKhau     NVARCHAR(255) NOT NULL,
    VaiTroNV    INT           NOT NULL DEFAULT 0,  -- 0: NV thường, 1: Admin
    TrangThai   BIT           NULL DEFAULT 1
);

-- Khách hàng
CREATE TABLE KhachHang (
    MaKH        INT           IDENTITY(1,1) PRIMARY KEY,
    TenKH       NVARCHAR(200) NOT NULL,
    Sdt         NVARCHAR(20)  NULL,
    Email       NVARCHAR(200) NULL,
    DiemTichLuy INT           NOT NULL DEFAULT 0,
    TrangThai   BIT           NULL DEFAULT 1
);

-- Địa chỉ khách hàng
CREATE TABLE DiaChiKhachHang (
    MaDiaChi        INT           IDENTITY(1,1) PRIMARY KEY,
    MaKH            INT           NOT NULL,
    DiaChiChiTiet   NVARCHAR(500) NOT NULL,
    LaMacDinh       BIT           NULL DEFAULT 0,
    CONSTRAINT FK_DiaChi_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);

-- Voucher giảm giá
CREATE TABLE Voucher (
    MaVoucher           INT             IDENTITY(1,1) PRIMARY KEY,
    MaCode              NVARCHAR(50)    NOT NULL UNIQUE,
    LoaiGiam            INT             NOT NULL,  -- 1: %, 2: tiền mặt
    GiaTri              DECIMAL(18,2)   NOT NULL,
    GiaTriDonToiThieu   DECIMAL(18,2)   NOT NULL DEFAULT 0,
    GiaGiamToiDa        DECIMAL(18,2)   NULL,
    NgayBatDau          DATETIME2       NOT NULL,
    NgayKetThuc         DATETIME2       NOT NULL,
    SoLuongToiDa        INT             NOT NULL DEFAULT 1,
    DaSuDung            INT             NOT NULL DEFAULT 0
);

-- Sách (đầu sách)
CREATE TABLE Sach (
    MaSach      NVARCHAR(20)    NOT NULL PRIMARY KEY,
    TenSach     NVARCHAR(500)   NOT NULL,
    NamXB       INT             NULL,
    GiaBan      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    MaTL        INT             NOT NULL,
    MaNXB       INT             NOT NULL,
    MaBoSach    INT             NULL,
    SoPhan      INT             NULL,
    TrangThai   BIT             NULL DEFAULT 1,  -- 1: đang KD, 0: ngừng KD
    AnhBia      NVARCHAR(500)   NULL,
    CONSTRAINT FK_Sach_TheLoai    FOREIGN KEY (MaTL)     REFERENCES TheLoai(MaTL),
    CONSTRAINT FK_Sach_NhaXuatBan FOREIGN KEY (MaNXB)    REFERENCES NhaXuatBan(MaNXB),
    CONSTRAINT FK_Sach_BoSach     FOREIGN KEY (MaBoSach) REFERENCES BoSach(MaBoSach)
);

-- Bảng trung gian Sách - Tác giả
CREATE TABLE Sach_TacGia (
    MaSach      NVARCHAR(20)    NOT NULL,
    MaTG        INT             NOT NULL,
    VaiTroTG    NVARCHAR(100)   NULL,
    PRIMARY KEY (MaSach, MaTG),
    CONSTRAINT FK_SachTacGia_Sach   FOREIGN KEY (MaSach) REFERENCES Sach(MaSach),
    CONSTRAINT FK_SachTacGia_TacGia FOREIGN KEY (MaTG)   REFERENCES TacGia(MaTG)
);

-- Sách vật lý (từng cuốn có serial)
CREATE TABLE SachVatLy (
    MaSerial    NVARCHAR(100)   NOT NULL PRIMARY KEY,
    MaSach      NVARCHAR(20)    NOT NULL,
    TrangThai   NVARCHAR(50)    NOT NULL DEFAULT N'Có sẵn',  -- 'Có sẵn' | 'Đã bán'
    MaCTDH      INT             NULL,
    CONSTRAINT FK_SachVatLy_Sach FOREIGN KEY (MaSach) REFERENCES Sach(MaSach)
);

-- Đơn hàng
CREATE TABLE DonHang (
    MaDH                INT             IDENTITY(1,1) PRIMARY KEY,
    NgayLap             DATETIME2       NOT NULL DEFAULT GETDATE(),
    TongTien            DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TrangThai           INT             NOT NULL DEFAULT 1,  -- 0: chờ, 1: đã giao, 2: hủy
    PhuongThucThanhToan NVARCHAR(100)   NULL,
    MaKH                INT             NOT NULL,
    MaNV                INT             NOT NULL,
    MaVoucher           INT             NULL,
    SoTienGiam          DECIMAL(18,2)   NULL DEFAULT 0,
    CONSTRAINT FK_DonHang_KhachHang FOREIGN KEY (MaKH)      REFERENCES KhachHang(MaKH),
    CONSTRAINT FK_DonHang_NhanVien  FOREIGN KEY (MaNV)      REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_DonHang_Voucher   FOREIGN KEY (MaVoucher) REFERENCES Voucher(MaVoucher)
);

-- Chi tiết đơn hàng
CREATE TABLE ChiTietDonHang (
    MaCTDH      INT             IDENTITY(1,1) PRIMARY KEY,
    MaDH        INT             NOT NULL,
    MaSach      NVARCHAR(20)    NOT NULL,
    SoLuong     INT             NOT NULL DEFAULT 1,
    DonGia      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    ThanhTien   AS (SoLuong * DonGia),   -- cột tính toán tự động
    CONSTRAINT FK_CTDH_DonHang FOREIGN KEY (MaDH)   REFERENCES DonHang(MaDH),
    CONSTRAINT FK_CTDH_Sach    FOREIGN KEY (MaSach) REFERENCES Sach(MaSach)
);

-- Thêm FK từ SachVatLy → ChiTietDonHang (sau khi tạo ChiTietDonHang)
ALTER TABLE SachVatLy
    ADD CONSTRAINT FK_SachVatLy_CTDH FOREIGN KEY (MaCTDH) REFERENCES ChiTietDonHang(MaCTDH);

-- Đánh giá / phản hồi khách hàng
CREATE TABLE DanhGia (
    MaDanhGia   INT             IDENTITY(1,1) PRIMARY KEY,
    MaKH        INT             NOT NULL,
    MaSach      NVARCHAR(20)    NOT NULL,
    SoSao       INT             NULL CHECK (SoSao BETWEEN 1 AND 5),
    NoiDung     NVARCHAR(MAX)   NULL,
    NgayDanhGia DATETIME2       NULL DEFAULT GETDATE(),
    CONSTRAINT FK_DanhGia_KhachHang FOREIGN KEY (MaKH)   REFERENCES KhachHang(MaKH),
    CONSTRAINT FK_DanhGia_Sach      FOREIGN KEY (MaSach) REFERENCES Sach(MaSach)
);

-- Biến thể sách (1 đầu sách có nhiều biến thể, mỗi biến thể có giá riêng)
-- VD: Harry Potter bìa cứng tiếng Việt 250k, bìa mềm tiếng Việt 180k, bìa cứng tiếng Anh 320k
CREATE TABLE SachBienThe (
    MaBienThe       INT             IDENTITY(1,1) PRIMARY KEY,
    MaSach          NVARCHAR(20)    NOT NULL,
    MaBienTheCode   NVARCHAR(50)    NULL,         -- Mã ngắn do người dùng đặt, VD: S001-BC-VI
    BiaSach         NVARCHAR(50)    NULL,         -- 'Bìa mềm' | 'Bìa cứng' | 'Bìa đặc biệt' | 'Bìa da'
    NgonNgu         NVARCHAR(100)   NULL,         -- 'Tiếng Việt' | 'Tiếng Anh' | 'Song ngữ Anh-Việt'
    GiaBienThe      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TrangThai       BIT             NOT NULL DEFAULT 1,   -- 1: đang bán, 0: ngừng bán
    CONSTRAINT FK_BienThe_Sach  FOREIGN KEY (MaSach) REFERENCES Sach(MaSach),
    CONSTRAINT UQ_BienThe_Code  UNIQUE (MaSach, MaBienTheCode)  -- mã duy nhất trong mỗi sách
);
GO

-- ============================================================
-- 4. DỮ LIỆU MẪU — tài khoản admin mặc định
-- ============================================================
INSERT INTO NhanVien (TenNV, Sdt, Email, DiaChi, TaiKhoan, MatKhau, VaiTroNV, TrangThai)
VALUES (N'Admin', '0900000000', 'admin@bookstore.com', N'TP. HCM', 'admin', '123456', 1, 1);

INSERT INTO NhanVien (TenNV, Sdt, Email, DiaChi, TaiKhoan, MatKhau, VaiTroNV, TrangThai)
VALUES (N'Nhân Viên Demo', '0911111111', 'nv@bookstore.com', N'TP. HCM', 'nhanvien', '123456', 0, 1);
GO

PRINT N'=== Tạo database QuanLyNhaSach thành công! ===';
PRINT N'Tài khoản admin: admin / 123456';
PRINT N'Tài khoản nhân viên: nhanvien / 123456';
GO
