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
-- 4. NHẬP DỮ LIỆU MẪU CHUẨN TIẾNG VIỆT UNICODE (N'...')
-- ============================================================

-- Thể loại
SET IDENTITY_INSERT TheLoai ON;
INSERT INTO TheLoai (MaTL, TenTL) VALUES 
(1, N'Tiểu Thuyết'),
(2, N'Truyện Ngắn'),
(3, N'Văn Học Việt Nam'),
(4, N'Thiếu Nhi'),
(5, N'Kỹ Năng Sống'),
(6, N'Kinh Tế');
SET IDENTITY_INSERT TheLoai OFF;

-- Tác giả
SET IDENTITY_INSERT TacGia ON;
INSERT INTO TacGia (MaTG, TenTG, TieuSu) VALUES
(1, N'Nguyễn Nhật Ánh', N'Nhà văn nổi tiếng với các tác phẩm dành cho tuổi mới lớn.'),
(2, N'Tô Hoài', N'Nhà văn lớn của văn học hiện đại Việt Nam.'),
(3, N'Nam Cao', N'Nhà văn thực dụng nổi tiếng trước 1945.'),
(4, N'Vũ Trọng Phụng', N'Ông vua hiện thực trào phúng.'),
(5, N'Nguyễn Du', N'Đại thi hào dân tộc Việt Nam.');
SET IDENTITY_INSERT TacGia OFF;

-- Nhà xuất bản
SET IDENTITY_INSERT NhaXuatBan ON;
INSERT INTO NhaXuatBan (MaNXB, TenNXB, Sdt, DiaChi) VALUES
(1, N'NXB Trẻ', '02839316289', N'161 Lý Chính Thắng, Q.3, TP.HCM'),
(2, N'NXB Kim Đồng', '02439434730', N'55 Quang Trung, Q. Hai Bà Trưng, Hà Nội'),
(3, N'NXB Văn Học', '02438257253', N'18 Nguyễn Trường Tộ, Hà Nội'),
(4, N'NXB Hội Nhà Văn', '02438222135', N'65 Nguyễn Du, Hà Nội');
SET IDENTITY_INSERT NhaXuatBan OFF;

-- Nhân viên
INSERT INTO NhanVien (TenNV, Sdt, Email, DiaChi, TaiKhoan, MatKhau, VaiTroNV, TrangThai) VALUES
(N'Quản Trị Viên', '0900000000', 'admin@bookstore.com', N'TP. Hồ Chí Minh', 'admin', '123456', 1, 1),
(N'Nhân Viên Demo', '0911111111', 'nv@bookstore.com', N'TP. Hồ Chí Minh', 'nhanvien', '123456', 0, 1);

-- Khách hàng
INSERT INTO KhachHang (TenKH, Sdt, Email, DiemTichLuy, TrangThai) VALUES
(N'Khách Hàng Vãng Lai', '0000000000', 'guest@bookstore.com', 0, 1),
(N'Nguyễn Văn A', '0988888888', 'anguyen@gmail.com', 120, 1),
(N'Trần Thị B', '0977777777', 'btran@gmail.com', 50, 1);

-- Voucher
INSERT INTO Voucher (MaCode, LoaiGiam, GiaTri, GiaTriDonToiThieu, GiaGiamToiDa, NgayBatDau, NgayKetThuc, SoLuongToiDa, DaSuDung) VALUES
(N'WELCOME10', 1, 10.00, 100000.00, 50000.00, '2026-01-01', '2026-12-31', 200, 0),
(N'GIAM50K', 2, 50000.00, 200000.00, 50000.00, '2026-01-01', '2026-12-31', 100, 0),
(N'MEMBER15', 1, 15.00, 300000.00, 100000.00, '2026-01-01', '2026-12-31', 50, 0);

-- Sách
INSERT INTO Sach (MaSach, TenSach, NamXB, GiaBan, MaTL, MaNXB, TrangThai, AnhBia) VALUES
('S001', N'Cho Tôi Xin Một Vé Đi Tuổi Thơ', 2008, 85000.00, 1, 2, 1, 'book-images/S001.webp'),
('S002', N'Mắt Biếc', 1990, 98000.00, 1, 2, 1, NULL),
('S003', N'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', 2010, 110000.00, 1, 2, 1, NULL),
('S004', N'Cô Gái Đến Từ Hôm Qua', 1989, 75000.00, 1, 2, 1, NULL),
('S005', N'Kính Vạn Hoa - Tập 1', 1995, 65000.00, 4, 2, 1, NULL),
('S006', N'Dế Mèn Phiêu Lưu Ký', 1941, 55000.00, 4, 2, 1, NULL),
('S007', N'Sống Mòn', 1944, 82000.00, 3, 3, 1, NULL),
('S008', N'Số Đỏ', 1936, 78000.00, 3, 3, 1, NULL),
('S009', N'Truyện Kiều', 1820, 120000.00, 3, 4, 1, NULL);

-- Sách tác giả
INSERT INTO Sach_TacGia (MaSach, MaTG, VaiTroTG) VALUES
('S001', 1, N'Tác giả'),
('S002', 1, N'Tác giả'),
('S003', 1, N'Tác giả'),
('S004', 1, N'Tác giả'),
('S005', 1, N'Tác giả'),
('S006', 2, N'Tác giả'),
('S007', 3, N'Tác giả'),
('S008', 4, N'Tác giả'),
('S009', 5, N'Tác giả');

-- Sách biến thể (SachBienThe)
INSERT INTO SachBienThe (MaSach, MaBienTheCode, BiaSach, NgonNgu, GiaBienThe, TrangThai) VALUES
('S001', 'S001-BM-VI', N'Bìa mềm', N'Tiếng Việt', 85000.00, 1),
('S001', 'S001-BC-VI', N'Bìa cứng', N'Tiếng Việt', 120000.00, 1),
('S002', 'S002-BM-VI', N'Bìa mềm', N'Tiếng Việt', 98000.00, 1),
('S003', 'S003-BM-VI', N'Bìa mềm', N'Tiếng Việt', 110000.00, 1),
('S004', 'S004-BM-VI', N'Bìa mềm', N'Tiếng Việt', 75000.00, 1),
('S005', 'S005-BM-VI', N'Bìa mềm', N'Tiếng Việt', 65000.00, 1),
('S006', 'S006-BM-VI', N'Bìa mềm', N'Tiếng Việt', 55000.00, 1),
('S007', 'S007-BM-VI', N'Bìa mềm', N'Tiếng Việt', 82000.00, 1),
('S008', 'S008-BM-VI', N'Bìa mềm', N'Tiếng Việt', 78000.00, 1),
('S009', 'S009-BM-VI', N'Bìa mềm', N'Tiếng Việt', 120000.00, 1);

-- Sách vật lý (Kho tồn)
INSERT INTO SachVatLy (MaSerial, MaSach, TrangThai) VALUES
('SER-S001-001', 'S001', N'Có sẵn'),
('SER-S001-002', 'S001', N'Có sẵn'),
('SER-S001-003', 'S001', N'Có sẵn'),
('SER-S001-004', 'S001', N'Có sẵn'),
('SER-S001-005', 'S001', N'Có sẵn'),
('SER-S002-001', 'S002', N'Có sẵn'),
('SER-S002-002', 'S002', N'Có sẵn'),
('SER-S002-003', 'S002', N'Có sẵn'),
('SER-S003-001', 'S003', N'Có sẵn'),
('SER-S003-002', 'S003', N'Có sẵn'),
('SER-S004-001', 'S004', N'Có sẵn'),
('SER-S005-001', 'S005', N'Có sẵn'),
('SER-S006-001', 'S006', N'Có sẵn'),
('SER-S007-001', 'S007', N'Có sẵn'),
('SER-S008-001', 'S008', N'Có sẵn'),
('SER-S009-001', 'S009', N'Có sẵn');
GO

PRINT N'=== Tạo database QuanLyNhaSach và dữ liệu mẫu chuẩn UTF-8 thành công! ===';
PRINT N'Tài khoản admin: admin / 123456';
PRINT N'Tài khoản nhân viên: nhanvien / 123456';
GO

