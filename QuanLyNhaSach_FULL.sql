/* ============================================================
   DATABASE: QuanLyNhaSach  —  BẢN ĐẦY ĐỦ ĐỒNG BỘ VỚI JAVA CODE
   Gốc: QuanLyNhaSach.sql (file nguyên thủy)
   Bổ sung trong quá trình code (migration):
     [1] Sach        : + TrangThai BIT, AnhBia, BiaSach, NgonNgu
     [2] NhanVien    : + TrangThai BIT, CaLamViec NVARCHAR(100)
     [3] KhachHang   : + TrangThai BIT
     [4] ChiTietDonHang: + MaBienThe INT NULL, bỏ UNIQUE(MaDH,MaSach)
     [5] SachBienThe : bảng MỚI hoàn toàn (entity SachBienThe.java)
     [6] LichSuDoiTra: bảng MỚI hoàn toàn (entity LichSuDoiTra.java)
     [7] SachVatLy   : bỏ constraint DaBan_PhaiCoCTDH (lỗi Hibernate flush)
     [8] Voucher     : bỏ CK_DaSuDung (lỗi khi INSERT data mẫu > 1)
     [9] DonHang     : bỏ CK_TrangThai (Java dùng 1=DA_GIAO mặc định)

   Cách chạy: Mở trong SSMS → chọn master → F5
   Tài khoản: admin/123456  |  nhanvien/123456
   ============================================================ */

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLyNhaSach')
BEGIN
    ALTER DATABASE QuanLyNhaSach SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyNhaSach;
END;
GO

CREATE DATABASE QuanLyNhaSach COLLATE Vietnamese_CI_AS;
GO

USE QuanLyNhaSach;
GO

-- ============================================================
-- 1. NHA XUAT BAN  (giữ nguyên file gốc)
-- ============================================================
CREATE TABLE NhaXuatBan (
    MaNXB   INT IDENTITY(1,1) PRIMARY KEY,
    TenNXB  NVARCHAR(100) NOT NULL,
    Sdt     VARCHAR(15)   NULL,
    DiaChi  NVARCHAR(200) NULL
);
GO

-- ============================================================
-- 2. THE LOAI  (giữ nguyên)
-- ============================================================
CREATE TABLE TheLoai (
    MaTL  INT IDENTITY(1,1) PRIMARY KEY,
    TenTL NVARCHAR(100) NOT NULL
);
GO

-- ============================================================
-- 3. TAC GIA  (giữ nguyên)
-- ============================================================
CREATE TABLE TacGia (
    MaTG   INT IDENTITY(1,1) PRIMARY KEY,
    TenTG  NVARCHAR(100) NOT NULL,
    TieuSu NVARCHAR(MAX) NULL
);
GO

-- ============================================================
-- 4. BO SACH  (giữ nguyên)
-- ============================================================
CREATE TABLE BoSach (
    MaBoSach  INT IDENTITY(1,1) PRIMARY KEY,
    TenBoSach NVARCHAR(150) NOT NULL,
    MoTa      NVARCHAR(500) NULL
);
GO

-- ============================================================
-- 5. SACH
--   [1] THÊM: TrangThai BIT DEFAULT 1  (entity Sach.java: trangThai)
--             AnhBia NVARCHAR(500)      (entity Sach.java: anhBia)
--             BiaSach NVARCHAR(50)      (migration-bien-the-sach.sql)
--             NgonNgu NVARCHAR(100)     (migration-bien-the-sach.sql)
-- ============================================================
CREATE TABLE Sach (
    MaSach    VARCHAR(20)   NOT NULL PRIMARY KEY,
    TenSach   NVARCHAR(200) NOT NULL,
    NamXB     INT           NULL,
    GiaBan    DECIMAL(12,2) NOT NULL DEFAULT 0,
    MaTL      INT           NOT NULL,
    MaNXB     INT           NOT NULL,
    MaBoSach  INT           NULL,
    SoPhan    INT           NULL,
    TrangThai BIT           NOT NULL DEFAULT 1,   -- [1] MỚI: 1=đang KD, 0=ngừng
    AnhBia    NVARCHAR(500) NULL,                 -- [1] MỚI
    BiaSach   NVARCHAR(50)  NULL,                 -- [1] MỚI (migration)
    NgonNgu   NVARCHAR(100) NULL,                 -- [1] MỚI (migration)
    CONSTRAINT FK_Sach_TheLoai    FOREIGN KEY (MaTL)     REFERENCES TheLoai(MaTL),
    CONSTRAINT FK_Sach_NhaXuatBan FOREIGN KEY (MaNXB)    REFERENCES NhaXuatBan(MaNXB),
    CONSTRAINT FK_Sach_BoSach     FOREIGN KEY (MaBoSach) REFERENCES BoSach(MaBoSach)
);
GO

-- ============================================================
-- 6. SACH_TACGIA  (giữ nguyên)
-- ============================================================
CREATE TABLE Sach_TacGia (
    MaSach   VARCHAR(20)  NOT NULL,
    MaTG     INT          NOT NULL,
    VaiTroTG NVARCHAR(50) NULL,
    CONSTRAINT PK_Sach_TacGia       PRIMARY KEY (MaSach, MaTG),
    CONSTRAINT FK_SachTacGia_Sach   FOREIGN KEY (MaSach) REFERENCES Sach(MaSach),
    CONSTRAINT FK_SachTacGia_TacGia FOREIGN KEY (MaTG)   REFERENCES TacGia(MaTG)
);
GO

-- ============================================================
-- 7. NHAN VIEN
--   [2] THÊM: TrangThai BIT DEFAULT 1  (entity NhanVien.java)
--             CaLamViec NVARCHAR(100)   (entity NhanVien.java)
-- ============================================================
CREATE TABLE NhanVien (
    MaNV      INT IDENTITY(1,1) PRIMARY KEY,
    TenNV     NVARCHAR(100) NOT NULL,
    Sdt       VARCHAR(15)   NULL,
    Email     VARCHAR(100)  NULL,
    DiaChi    NVARCHAR(200) NULL,
    TaiKhoan  VARCHAR(50)   NOT NULL UNIQUE,
    MatKhau   VARCHAR(255)  NOT NULL,
    VaiTroNV  TINYINT       NOT NULL DEFAULT 0,  -- 0=NV thường, 1=Admin
    TrangThai BIT           NOT NULL DEFAULT 1,  -- [2] MỚI: 1=đang làm, 0=nghỉ
    CaLamViec NVARCHAR(100) NULL                 -- [2] MỚI
);
GO

-- ============================================================
-- 8. KHACH HANG
--   [3] THÊM: TrangThai BIT DEFAULT 1  (entity KhachHang.java)
-- ============================================================
CREATE TABLE KhachHang (
    MaKH        INT IDENTITY(1,1) PRIMARY KEY,
    TenKH       NVARCHAR(100) NOT NULL,
    Sdt         VARCHAR(15)   NULL,
    Email       VARCHAR(100)  NULL,
    DiemTichLuy INT           NOT NULL DEFAULT 0,
    TrangThai   BIT           NOT NULL DEFAULT 1  -- [3] MỚI
);
GO

-- ============================================================
-- 9. DIA CHI KHACH HANG  (giữ nguyên)
-- ============================================================
CREATE TABLE DiaChiKhachHang (
    MaDiaChi      INT IDENTITY(1,1) PRIMARY KEY,
    MaKH          INT           NOT NULL,
    DiaChiChiTiet NVARCHAR(200) NOT NULL,
    LaMacDinh     BIT           NOT NULL DEFAULT 0,
    CONSTRAINT FK_DiaChiKhachHang_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);
GO

-- ============================================================
-- 10. VOUCHER
--   [8] BỎ: CK_Voucher_DaSuDung — lỗi khi INSERT voucher DaSuDung>1
--   Giữ nguyên mọi thứ khác từ file gốc
-- ============================================================
CREATE TABLE Voucher (
    MaVoucher         INT IDENTITY(1,1) PRIMARY KEY,
    MaCode            VARCHAR(20)   NOT NULL UNIQUE,
    LoaiGiam          TINYINT       NOT NULL,           -- 0=%, 1=tiền cố định
    GiaTri            DECIMAL(12,2) NOT NULL,
    GiaTriDonToiThieu DECIMAL(12,2) NOT NULL DEFAULT 0,
    GiaGiamToiDa      DECIMAL(12,2) NULL,
    NgayBatDau        DATETIME      NOT NULL,
    NgayKetThuc       DATETIME      NOT NULL,
    SoLuongToiDa      INT           NOT NULL DEFAULT 1,
    DaSuDung          INT           NOT NULL DEFAULT 0,
    CONSTRAINT CK_Voucher_LoaiGiam  CHECK (LoaiGiam IN (0, 1)),
    CONSTRAINT CK_Voucher_NgayHopLe CHECK (NgayKetThuc > NgayBatDau)
    -- [8] BỎ CK_Voucher_DaSuDung: gây lỗi khi insert data mẫu có DaSuDung > 1
);
GO

-- ============================================================
-- 11. DON HANG
--   [9] BỎ: CK_DonHang_TrangThai — Java dùng TrangThai=1 làm mặc định
--   DEFAULT đổi thành 1 (DA_GIAO) khớp với DonHangDAO.TRANG_THAI_DA_GIAO
-- ============================================================
CREATE TABLE DonHang (
    MaDH                INT IDENTITY(1,1) PRIMARY KEY,
    NgayLap             DATETIME      NOT NULL DEFAULT GETDATE(),
    TongTien            DECIMAL(12,2) NOT NULL DEFAULT 0,
    TrangThai           TINYINT       NOT NULL DEFAULT 1,  -- [9] 1=Đã giao (mặc định Java)
    PhuongThucThanhToan NVARCHAR(50)  NULL,
    MaKH                INT           NOT NULL,
    MaNV                INT           NOT NULL,
    MaVoucher           INT           NULL,
    SoTienGiam          DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_DonHang_KhachHang FOREIGN KEY (MaKH)      REFERENCES KhachHang(MaKH),
    CONSTRAINT FK_DonHang_NhanVien  FOREIGN KEY (MaNV)      REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_DonHang_Voucher   FOREIGN KEY (MaVoucher) REFERENCES Voucher(MaVoucher)
);
GO

-- ============================================================
-- 12. SACH BIEN THE  [5] BẢNG MỚI HOÀN TOÀN
--   Entity: SachBienThe.java
--   Dùng trong: POS (CartItem.maBienThe), DonHangDAO.taoDonHangBienThe
-- ============================================================
CREATE TABLE SachBienThe (
    MaBienThe     INT IDENTITY(1,1) PRIMARY KEY,
    MaSach        VARCHAR(20)   NOT NULL,
    MaBienTheCode NVARCHAR(50)  NULL,         -- VD: S001-BC-VI, unique per sách
    BiaSach       NVARCHAR(50)  NULL,         -- 'Bìa mềm' | 'Bìa cứng' | 'Bìa da'
    NgonNgu       NVARCHAR(100) NULL,         -- 'Tiếng Việt' | 'Tiếng Anh'
    GiaBienThe    DECIMAL(12,2) NOT NULL DEFAULT 0,
    TrangThai     BIT           NOT NULL DEFAULT 1,   -- 1=đang bán
    CONSTRAINT FK_BienThe_Sach FOREIGN KEY (MaSach) REFERENCES Sach(MaSach),
    CONSTRAINT UQ_BienThe_Code UNIQUE (MaSach, MaBienTheCode)
);
GO

-- ============================================================
-- 13. CHI TIET DON HANG
--   [4] THÊM:  MaBienThe INT NULL FK→SachBienThe (entity ChiTietDonHang.java)
--   [4] BỎ:   UNIQUE(MaDH, MaSach) — DonHangDAO.doiMon() tạo nhiều dòng
--             cùng sách trong 1 đơn khi đổi hàng nhiều lần
-- ============================================================
CREATE TABLE ChiTietDonHang (
    MaCTDH    INT IDENTITY(1,1) PRIMARY KEY,
    MaDH      INT           NOT NULL,
    MaSach    VARCHAR(20)   NOT NULL,
    MaBienThe INT           NULL,  -- [4] MỚI: NULL=giá gốc, có giá trị=biến thể
    SoLuong   INT           NOT NULL DEFAULT 1,
    DonGia    DECIMAL(12,2) NOT NULL,
    ThanhTien AS (SoLuong * DonGia) PERSISTED,
    -- [4] BỎ UNIQUE(MaDH, MaSach)
    CONSTRAINT FK_CTDH_DonHang FOREIGN KEY (MaDH)       REFERENCES DonHang(MaDH),
    CONSTRAINT FK_CTDH_Sach    FOREIGN KEY (MaSach)     REFERENCES Sach(MaSach),
    CONSTRAINT FK_CTDH_BienThe FOREIGN KEY (MaBienThe)  REFERENCES SachBienThe(MaBienThe),
    CONSTRAINT CK_CTDH_SoLuong CHECK (SoLuong > 0)
);
GO

-- ============================================================
-- 14. SACH VAT LY
--   [7] BỎ: CK_SachVatLy_DaBan_PhaiCoCTDH — gây lỗi Hibernate flush order
--   Giữ nguyên 3 giá trị TrangThai hợp lệ từ file gốc
-- ============================================================
CREATE TABLE SachVatLy (
    MaSerial  VARCHAR(30)  NOT NULL PRIMARY KEY,
    MaSach    VARCHAR(20)  NOT NULL,
    TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Có sẵn',
    MaCTDH    INT          NULL,
    CONSTRAINT FK_SachVatLy_Sach      FOREIGN KEY (MaSach) REFERENCES Sach(MaSach),
    CONSTRAINT FK_SachVatLy_CTDH      FOREIGN KEY (MaCTDH) REFERENCES ChiTietDonHang(MaCTDH),
    CONSTRAINT CK_SachVatLy_TrangThai CHECK (TrangThai IN (N'Có sẵn', N'Đã bán', N'Hư hỏng'))
    -- [7] BỎ CK_SachVatLy_DaBan_PhaiCoCTDH — gây lỗi Hibernate merge order
);
GO

-- ============================================================
-- 15. DANH GIA  (giữ nguyên file gốc)
-- ============================================================
CREATE TABLE DanhGia (
    MaDanhGia   INT IDENTITY(1,1) PRIMARY KEY,
    MaKH        INT           NOT NULL,
    MaSach      VARCHAR(20)   NOT NULL,
    SoSao       TINYINT       NOT NULL,
    NoiDung     NVARCHAR(500) NULL,
    NgayDanhGia DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_DanhGia_KhachHang FOREIGN KEY (MaKH)   REFERENCES KhachHang(MaKH),
    CONSTRAINT FK_DanhGia_Sach      FOREIGN KEY (MaSach) REFERENCES Sach(MaSach),
    CONSTRAINT CK_DanhGia_SoSao     CHECK (SoSao BETWEEN 1 AND 5),
    CONSTRAINT UQ_DanhGia_KhachSach UNIQUE (MaKH, MaSach)
);
GO

-- ============================================================
-- 16. LICH SU DOI TRA  [6] BẢNG MỚI HOÀN TOÀN
--   Entity: LichSuDoiTra.java
--   Dùng trong: DonHangDAO.traMon(), DonHangDAO.doiMon()
--   Thay thế 2 stored procedure sp_TraSach/sp_DoiSach về mặt lưu log
-- ============================================================
CREATE TABLE LichSuDoiTra (
    MaDoiTra      INT IDENTITY(1,1) PRIMARY KEY,
    MaDH          INT            NOT NULL,
    LoaiGiaoDich  NVARCHAR(10)   NOT NULL CHECK (LoaiGiaoDich IN (N'TRA', N'DOI')),
    NgayThucHien  DATETIME       NOT NULL DEFAULT GETDATE(),
    MaCTDHCu      INT            NOT NULL,
    SoLuongTra    INT            NOT NULL,
    MaSachMoi     VARCHAR(20)    NULL,
    SoLuongMoi    INT            NULL,
    ChenhLechTien DECIMAL(12,2)  NOT NULL DEFAULT 0,
    LyDo          NVARCHAR(255)  NULL,
    CONSTRAINT FK_DoiTra_DonHang FOREIGN KEY (MaDH)      REFERENCES DonHang(MaDH),
    CONSTRAINT FK_DoiTra_CTDHCu  FOREIGN KEY (MaCTDHCu)  REFERENCES ChiTietDonHang(MaCTDH),
    CONSTRAINT FK_DoiTra_SachMoi FOREIGN KEY (MaSachMoi) REFERENCES Sach(MaSach)
);
GO

-- ============================================================
-- TRIGGER  (giữ nguyên từ file gốc)
-- ============================================================
CREATE TRIGGER trg_CapNhatTongTien
ON ChiTietDonHang
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DanhSachMaDH TABLE (MaDH INT);
    INSERT INTO @DanhSachMaDH (MaDH)
        SELECT MaDH FROM inserted
        UNION
        SELECT MaDH FROM deleted;
    UPDATE dh
    SET TongTien = ISNULL((
        SELECT SUM(ct.ThanhTien)
        FROM ChiTietDonHang ct
        WHERE ct.MaDH = dh.MaDH
    ), 0) - dh.SoTienGiam
    FROM DonHang dh
    INNER JOIN @DanhSachMaDH d ON dh.MaDH = d.MaDH;
END;
GO

-- ============================================================
-- STORED PROCEDURE  (giữ nguyên từ file gốc)
-- ============================================================
CREATE PROCEDURE sp_TraSachBinhThuong
    @MaSerial VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE SachVatLy
    SET TrangThai = N'Có sẵn', MaCTDH = NULL
    WHERE MaSerial = @MaSerial AND TrangThai = N'Đã bán';
END;
GO

CREATE PROCEDURE sp_DoiSachHong
    @MaSerialCu  VARCHAR(30),
    @MaSerialMoi VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaCTDH INT;
    SELECT @MaCTDH = MaCTDH FROM SachVatLy WHERE MaSerial = @MaSerialCu;
    IF @MaCTDH IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy cuốn sách này trong đơn hàng nào.', 16, 1);
        RETURN;
    END
    UPDATE SachVatLy SET TrangThai = N'Hư hỏng', MaCTDH = NULL
    WHERE MaSerial = @MaSerialCu;
    UPDATE SachVatLy SET TrangThai = N'Đã bán', MaCTDH = @MaCTDH
    WHERE MaSerial = @MaSerialMoi AND TrangThai = N'Có sẵn';
END;
GO

PRINT N'>>> Schema 16 bảng + trigger + 2 SP hoàn tất.';
GO

-- ============================================================
-- DỮ LIỆU MẪU — giữ nguyên 100% từ file gốc QuanLyNhaSach.sql
-- ============================================================

-- NHÀ XUẤT BẢN (15)
INSERT INTO NhaXuatBan (TenNXB, Sdt, DiaChi) VALUES
(N'Nhà xuất bản Kim Đồng',                 '02438228645', N'55 Quang Trung, Hai Bà Trưng, Hà Nội'),
(N'Nhà xuất bản Trẻ',                       '02839316289', N'161B Lý Chính Thắng, Quận 3, TP. Hồ Chí Minh'),
(N'Nhà xuất bản Giáo dục Việt Nam',         '02438220801', N'81 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội'),
(N'Nhà xuất bản Văn học',                   '02439433490', N'18 Nguyễn Trường Tộ, Ba Đình, Hà Nội'),
(N'Nhà xuất bản Thế Giới',                  '02438253841', N'46 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội'),
(N'Nhà xuất bản Hội Nhà văn',               '02439443736', N'65 Nguyễn Du, Hai Bà Trưng, Hà Nội'),
(N'Nhà xuất bản Lao động',                  '02438515380', N'175 Giảng Võ, Đống Đa, Hà Nội'),
(N'Nhà xuất bản Phụ nữ Việt Nam',           '02439716717', N'39 Hàng Chuối, Hai Bà Trưng, Hà Nội'),
(N'Nhà xuất bản Tổng hợp TP. Hồ Chí Minh', '02838296764', N'62 Nguyễn Thị Minh Khai, Quận 1, TP. Hồ Chí Minh'),
(N'Nhà xuất bản Chính trị Quốc gia Sự thật','02437477458', N'6/86 Duy Tân, Cầu Giấy, Hà Nội'),
(N'Nhà xuất bản Dân Trí',                   '02435141362', N'119 Tây Sơn, Đống Đa, Hà Nội'),
(N'Nhà xuất bản Thanh Niên',                '02439434044', N'64 Bà Triệu, Hoàn Kiếm, Hà Nội'),
(N'Nhà xuất bản Hồng Đức',                  '02439260024', N'65 Tràng Thi, Hoàn Kiếm, Hà Nội'),
(N'Nhà xuất bản Đại học Quốc gia Hà Nội',   '02437547450', N'144 Xuân Thủy, Cầu Giấy, Hà Nội'),
(N'Nhà xuất bản Khoa học và Kỹ thuật',      '02439423172', N'70 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội');
GO

-- THỂ LOẠI (20)
INSERT INTO TheLoai (TenTL) VALUES
(N'Văn học Việt Nam'),(N'Văn học nước ngoài'),(N'Thiếu nhi'),
(N'Truyện tranh'),(N'Manga'),(N'Light Novel'),
(N'Trinh thám'),(N'Kinh tế'),(N'Quản trị'),
(N'Khởi nghiệp'),(N'Tâm lý học'),(N'Kỹ năng sống'),
(N'Công nghệ thông tin'),(N'Lập trình'),(N'Trí tuệ nhân tạo'),
(N'Khoa học'),(N'Lịch sử'),(N'Ngoại ngữ'),
(N'Tiểu thuyết'),(N'Tự truyện');
GO

-- TÁC GIẢ (30)
INSERT INTO TacGia (TenTG, TieuSu) VALUES
(N'Nguyễn Nhật Ánh',        N'Nhà văn nổi tiếng của Việt Nam.'),
(N'Tô Hoài',                 N'Tác giả của Dế Mèn Phiêu Lưu Ký.'),
(N'Nam Cao',                  N'Nhà văn hiện thực Việt Nam.'),
(N'Vũ Trọng Phụng',          N'Tác giả Số Đỏ.'),
(N'Nguyễn Du',                N'Đại thi hào dân tộc.'),
(N'J. K. Rowling',            N'Tác giả Harry Potter.'),
(N'Agatha Christie',          N'Nữ hoàng truyện trinh thám.'),
(N'Dale Carnegie',            N'Tác giả Đắc Nhân Tâm.'),
(N'Paulo Coelho',             N'Tác giả Nhà Giả Kim.'),
(N'Haruki Murakami',          N'Nhà văn Nhật Bản.'),
(N'Dan Brown',                N'Tác giả Mật Mã Da Vinci.'),
(N'Yuval Noah Harari',        N'Tác giả Sapiens.'),
(N'James Clear',              N'Tác giả Atomic Habits.'),
(N'Robert C. Martin',         N'Tác giả Clean Code.'),
(N'Kathy Sierra',             N'Đồng tác giả Head First Java.'),
(N'Joshua Bloch',             N'Tác giả Effective Java.'),
(N'Fujiko F. Fujio',          N'Tác giả Doraemon.'),
(N'Gosho Aoyama',             N'Tác giả Thám tử lừng danh Conan.'),
(N'Akira Toriyama',           N'Tác giả Dragon Ball.'),
(N'Eiichiro Oda',             N'Tác giả One Piece.'),
(N'George Orwell',            N'Tác giả 1984.'),
(N'Antoine de Saint-Exupéry',N'Tác giả Hoàng tử bé.'),
(N'Victor Hugo',              N'Tác giả Những người khốn khổ.'),
(N'Ernest Hemingway',         N'Nhà văn Mỹ.'),
(N'Nguyễn Ngọc Tư',          N'Nhà văn Việt Nam.'),
(N'Phùng Quán',               N'Tác giả Tuổi thơ dữ dội.'),
(N'Nguyễn Huy Thiệp',        N'Nhà văn Việt Nam.'),
(N'Xuân Quỳnh',               N'Nhà thơ Việt Nam.'),
(N'Nguyễn Ngọc Ký',          N'Nhà giáo Việt Nam.'),
(N'Stephen King',             N'Nhà văn Mỹ.');
GO

-- BỘ SÁCH (15)
INSERT INTO BoSach (TenBoSach, MoTa) VALUES
(N'Harry Potter',             N'Bộ tiểu thuyết giả tưởng nổi tiếng.'),
(N'Doraemon',                 N'Bộ truyện tranh thiếu nhi Nhật Bản.'),
(N'Thám tử lừng danh Conan', N'Bộ truyện tranh trinh thám.'),
(N'Dragon Ball',              N'Bộ truyện tranh nổi tiếng của Akira Toriyama.'),
(N'One Piece',                N'Bộ truyện tranh hải tặc.'),
(N'Kính Vạn Hoa',             N'Bộ truyện tuổi học trò của Nguyễn Nhật Ánh.'),
(N'Chuyện xứ Lang Biang',     N'Bộ truyện giả tưởng của Nguyễn Nhật Ánh.'),
(N'Sherlock Holmes',          N'Bộ truyện trinh thám kinh điển.'),
(N'Percy Jackson',            N'Bộ tiểu thuyết thần thoại Hy Lạp.'),
(N'Atomic Habits Series',     N'Bộ sách phát triển bản thân.'),
(N'Head First',               N'Bộ sách lập trình.'),
(N'Clean Code Series',        N'Bộ sách lập trình chuyên nghiệp.'),
(N'Sapiens Series',           N'Bộ sách lịch sử loài người.'),
(N'Nhóc Nicolas',             N'Bộ truyện thiếu nhi Pháp.'),
(N'Tuổi Thơ Dữ Dội',          N'Bộ truyện lịch sử Việt Nam.');
GO

-- SÁCH (50) — giữ nguyên file gốc + thêm TrangThai=1, AnhBia=NULL
INSERT INTO Sach (MaSach, TenSach, NamXB, GiaBan, MaTL, MaNXB, MaBoSach, SoPhan, TrangThai, AnhBia) VALUES
('S001',N'Cho Tôi Xin Một Vé Đi Tuổi Thơ',           2008, 85000, 1, 2,NULL,NULL,1,'book-images/S001.webp'),
('S002',N'Mắt Biếc',                                   1990, 98000, 1, 2,NULL,NULL,1,NULL),
('S003',N'Tôi Thấy Hoa Vàng Trên Cỏ Xanh',            2010,110000, 1, 2,NULL,NULL,1,NULL),
('S004',N'Cô Gái Đến Từ Hôm Qua',                     1995, 89000, 1, 2,NULL,NULL,1,NULL),
('S005',N'Kính Vạn Hoa - Tập 1',                      1995, 65000, 3, 1, 6,  1,  1,NULL),
('S006',N'Dế Mèn Phiêu Lưu Ký',                       1941, 75000, 3, 1,NULL,NULL,1,NULL),
('S007',N'Sống Mòn',                                   1944, 92000, 1, 4,NULL,NULL,1,NULL),
('S008',N'Số Đỏ',                                      1936, 90000, 1, 4,NULL,NULL,1,NULL),
('S009',N'Truyện Kiều',                                1820,120000, 1, 4,NULL,NULL,1,NULL),
('S010',N'Harry Potter và Hòn Đá Phù Thủy',            1997,180000,19, 1, 1,  1,  1,NULL),
('S011',N'Harry Potter và Phòng Chứa Bí Mật',          1998,180000,19, 1, 1,  2,  1,NULL),
('S012',N'Harry Potter và Tên Tù Nhân Ngục Azkaban',   1999,180000,19, 1, 1,  3,  1,NULL),
('S013',N'Harry Potter và Chiếc Cốc Lửa',              2000,195000,19, 1, 1,  4,  1,NULL),
('S014',N'Harry Potter và Hội Phượng Hoàng',           2003,205000,19, 1, 1,  5,  1,NULL),
('S015',N'Harry Potter và Hoàng Tử Lai',               2005,205000,19, 1, 1,  6,  1,NULL),
('S016',N'Harry Potter và Bảo Bối Tử Thần',            2007,220000,19, 1, 1,  7,  1,NULL),
('S017',N'Án Mạng Trên Sông Nile',                     1937,150000, 7, 5,NULL,NULL,1,NULL),
('S018',N'Vụ Án Bí Ẩn Ở Styles',                      1920,145000, 7, 5,NULL,NULL,1,NULL),
('S019',N'Đắc Nhân Tâm',                               1936,120000,12, 5,NULL,NULL,1,NULL),
('S020',N'Nhà Giả Kim',                                1988, 98000,19, 5,NULL,NULL,1,NULL),
('S021',N'Rừng Na Uy',                                 1987,135000,19, 5,NULL,NULL,1,NULL),
('S022',N'Mật Mã Da Vinci',                            2003,160000, 7, 5,NULL,NULL,1,NULL),
('S023',N'Thiên Thần và Ác Quỷ',                       2000,155000, 7, 5,NULL,NULL,1,NULL),
('S024',N'Sapiens: Lược Sử Loài Người',                2011,210000,16, 5,13,  1,  1,NULL),
('S025',N'Homo Deus',                                  2015,220000,16, 5,13,  2,  1,NULL),
('S026',N'Atomic Habits',                              2018,185000,12, 5,10,  1,  1,NULL),
('S027',N'Clean Code',                                 2008,320000,14,15,12,  1,  1,NULL),
('S028',N'Head First Java',                            2022,350000,14,15,11,  1,  1,NULL),
('S029',N'Effective Java',                             2018,420000,14,15,NULL,NULL,1,NULL),
('S030',N'Doraemon - Tập 1',                           1974, 28000, 5, 1, 2,  1,  1,NULL),
('S031',N'Doraemon - Tập 2',                           1974, 28000, 5, 1, 2,  2,  1,NULL),
('S032',N'Doraemon - Tập 3',                           1974, 28000, 5, 1, 2,  3,  1,NULL),
('S033',N'Doraemon - Tập 4',                           1974, 28000, 5, 1, 2,  4,  1,NULL),
('S034',N'Doraemon - Tập 5',                           1974, 28000, 5, 1, 2,  5,  1,NULL),
('S035',N'Thám tử lừng danh Conan - Tập 1',            1994, 32000, 5, 1, 3,  1,  1,NULL),
('S036',N'Thám tử lừng danh Conan - Tập 2',            1994, 32000, 5, 1, 3,  2,  1,NULL),
('S037',N'Thám tử lừng danh Conan - Tập 3',            1994, 32000, 5, 1, 3,  3,  1,NULL),
('S038',N'Thám tử lừng danh Conan - Tập 4',            1994, 32000, 5, 1, 3,  4,  1,NULL),
('S039',N'Thám tử lừng danh Conan - Tập 5',            1994, 32000, 5, 1, 3,  5,  1,NULL),
('S040',N'Dragon Ball - Tập 1',                        1984, 35000, 5, 1, 4,  1,  1,NULL),
('S041',N'Dragon Ball - Tập 2',                        1984, 35000, 5, 1, 4,  2,  1,NULL),
('S042',N'Dragon Ball - Tập 3',                        1984, 35000, 5, 1, 4,  3,  1,NULL),
('S043',N'One Piece - Tập 1',                          1997, 35000, 5, 1, 5,  1,  1,NULL),
('S044',N'One Piece - Tập 2',                          1997, 35000, 5, 1, 5,  2,  1,NULL),
('S045',N'One Piece - Tập 3',                          1997, 35000, 5, 1, 5,  3,  1,NULL),
('S046',N'1984',                                        1949,135000,19, 5,NULL,NULL,1,NULL),
('S047',N'Hoàng Tử Bé',                                1943, 98000, 3, 5,NULL,NULL,1,NULL),
('S048',N'Những Người Khốn Khổ',                       1862,180000,19, 4,NULL,NULL,1,NULL),
('S049',N'Ông Già Và Biển Cả',                         1952,125000,19, 4,NULL,NULL,1,NULL),
('S050',N'Carrie',                                      1974,145000,19, 5,NULL,NULL,1,NULL);
GO

-- SÁCH - TÁC GIẢ (50 dòng — giữ nguyên file gốc)
INSERT INTO Sach_TacGia (MaSach, MaTG, VaiTroTG) VALUES
('S001',1,N'Tác giả'),('S002',1,N'Tác giả'),('S003',1,N'Tác giả'),
('S004',1,N'Tác giả'),('S005',1,N'Tác giả'),('S006',2,N'Tác giả'),
('S007',3,N'Tác giả'),('S008',4,N'Tác giả'),('S009',5,N'Tác giả'),
('S010',6,N'Tác giả'),('S011',6,N'Tác giả'),('S012',6,N'Tác giả'),
('S013',6,N'Tác giả'),('S014',6,N'Tác giả'),('S015',6,N'Tác giả'),
('S016',6,N'Tác giả'),('S017',7,N'Tác giả'),('S018',7,N'Tác giả'),
('S019',8,N'Tác giả'),('S020',9,N'Tác giả'),('S021',10,N'Tác giả'),
('S022',11,N'Tác giả'),('S023',11,N'Tác giả'),('S024',12,N'Tác giả'),
('S025',12,N'Tác giả'),('S026',13,N'Tác giả'),('S027',14,N'Tác giả'),
('S028',15,N'Tác giả'),('S029',16,N'Tác giả'),
('S030',17,N'Tác giả'),('S031',17,N'Tác giả'),('S032',17,N'Tác giả'),
('S033',17,N'Tác giả'),('S034',17,N'Tác giả'),
('S035',18,N'Tác giả'),('S036',18,N'Tác giả'),('S037',18,N'Tác giả'),
('S038',18,N'Tác giả'),('S039',18,N'Tác giả'),
('S040',19,N'Tác giả'),('S041',19,N'Tác giả'),('S042',19,N'Tác giả'),
('S043',20,N'Tác giả'),('S044',20,N'Tác giả'),('S045',20,N'Tác giả'),
('S046',21,N'Tác giả'),('S047',22,N'Tác giả'),('S048',23,N'Tác giả'),
('S049',24,N'Tác giả'),('S050',30,N'Tác giả');
GO

-- NHÂN VIÊN (20) — giữ nguyên file gốc + thêm TrangThai=1, CaLamViec
INSERT INTO NhanVien (TenNV, Sdt, Email, DiaChi, TaiKhoan, MatKhau, VaiTroNV, TrangThai, CaLamViec) VALUES
(N'Nguyễn Văn Admin','0901111111','admin1@bookstore.vn', N'Hà Nội','admin',   '123456',1,1,NULL),
(N'Trần Thị Admin',  '0901111112','admin2@bookstore.vn', N'Hà Nội','admin2',  '123456',1,1,NULL),
(N'Nguyễn Văn An',   '0902000001','an@gmail.com',        N'Hà Nội','nhanvien','123456',0,1,N'Ca sáng'),
(N'Trần Thị Bình',   '0902000002','binh@gmail.com',      N'Hà Nội','binh',   '123456',0,1,N'Ca chiều'),
(N'Lê Văn Cường',    '0902000003','cuong@gmail.com',     N'Hải Phòng','cuong','123456',0,1,N'Ca sáng'),
(N'Phạm Thị Dung',   '0902000004','dung@gmail.com',      N'Nam Định','dung',  '123456',0,1,N'Ca tối'),
(N'Hoàng Văn Đức',   '0902000005','duc@gmail.com',       N'Hà Nội','duc',     '123456',0,1,N'Ca sáng'),
(N'Vũ Thị Hạnh',     '0902000006','hanh@gmail.com',      N'Hải Dương','hanh', '123456',0,1,N'Ca chiều'),
(N'Đặng Văn Hùng',   '0902000007','hung@gmail.com',      N'Hà Nội','hung',    '123456',0,1,N'Ca sáng'),
(N'Nguyễn Thu Hà',   '0902000008','ha@gmail.com',        N'Hà Nội','ha',      '123456',0,1,N'Ca tối'),
(N'Lý Văn Long',     '0902000009','long@gmail.com',      N'Hà Nội','long',    '123456',0,1,N'Ca sáng'),
(N'Bùi Minh Quân',   '0902000010','quan@gmail.com',      N'Hà Nội','quan',    '123456',0,1,N'Ca chiều'),
(N'Đỗ Thị Mai',      '0902000011','mai@gmail.com',       N'Hà Nội','mai',     '123456',0,1,N'Ca sáng'),
(N'Ngô Văn Phúc',    '0902000012','phuc@gmail.com',      N'Hà Nội','phuc',    '123456',0,1,N'Ca tối'),
(N'Phan Văn Sơn',    '0902000013','son@gmail.com',       N'Hà Nội','son',     '123456',0,1,N'Ca sáng'),
(N'Trịnh Thị Lan',   '0902000014','lan@gmail.com',       N'Hà Nội','lan',     '123456',0,1,N'Ca chiều'),
(N'Cao Văn Nam',     '0902000015','nam@gmail.com',       N'Hà Nội','nam',     '123456',0,1,N'Ca sáng'),
(N'Đinh Thị Yến',    '0902000016','yen@gmail.com',       N'Hà Nội','yen',     '123456',0,1,N'Ca tối'),
(N'Nguyễn Văn Hải',  '0902000017','hai@gmail.com',       N'Hà Nội','hai',     '123456',0,1,N'Ca sáng'),
(N'Trần Quốc Bảo',   '0902000018','bao@gmail.com',       N'Hà Nội','bao',     '123456',0,1,N'Ca chiều');
GO

-- KHÁCH HÀNG (50) — giữ nguyên file gốc + thêm TrangThai=1
INSERT INTO KhachHang (TenKH, Sdt, Email, DiemTichLuy, TrangThai) VALUES
(N'Nguyễn Văn A',      '0903000001','a@gmail.com',          120,1),
(N'Trần Thị B',        '0903000002','b@gmail.com',           80,1),
(N'Lê Văn C',          '0903000003','c@gmail.com',           30,1),
(N'Phạm Thị D',        '0903000004','d@gmail.com',           50,1),
(N'Hoàng Văn E',       '0903000005','e@gmail.com',            0,1),
(N'Vũ Thị F',          '0903000006','f@gmail.com',           60,1),
(N'Đặng Văn G',        '0903000007','g@gmail.com',           90,1),
(N'Ngô Thị H',         '0903000008','h@gmail.com',           20,1),
(N'Đỗ Văn I',          '0903000009','i@gmail.com',          100,1),
(N'Bùi Thị K',         '0903000010','k@gmail.com',          150,1),
(N'Nguyễn Văn L',      '0903000011','l@gmail.com',            0,1),
(N'Trần Thị M',        '0903000012','m@gmail.com',           10,1),
(N'Lê Văn N',          '0903000013','n@gmail.com',           70,1),
(N'Phạm Thị O',        '0903000014','o@gmail.com',           90,1),
(N'Hoàng Văn P',       '0903000015','p@gmail.com',          120,1),
(N'Vũ Thị Q',          '0903000016','q@gmail.com',           55,1),
(N'Đặng Văn R',        '0903000017','r@gmail.com',           40,1),
(N'Ngô Thị S',         '0903000018','s@gmail.com',           65,1),
(N'Đỗ Văn T',          '0903000019','t@gmail.com',           85,1),
(N'Bùi Thị U',         '0903000020','u@gmail.com',           95,1),
(N'Nguyễn Văn V',      '0903000021','v@gmail.com',           30,1),
(N'Trần Thị W',        '0903000022','w@gmail.com',           15,1),
(N'Lê Văn X',          '0903000023','x@gmail.com',           25,1),
(N'Phạm Thị Y',        '0903000024','y@gmail.com',           75,1),
(N'Hoàng Văn Z',       '0903000025','z@gmail.com',          100,1),
(N'Nguyễn Minh Anh',   '0903000026','anh@gmail.com',         20,1),
(N'Trần Quốc Bảo',     '0903000027','bao@gmail.com',         50,1),
(N'Lê Hải Đăng',       '0903000028','dang@gmail.com',        80,1),
(N'Phạm Gia Huy',      '0903000029','huy@gmail.com',         45,1),
(N'Hoàng Khánh Linh',  '0903000030','linh@gmail.com',        70,1),
(N'Nguyễn Đức Mạnh',   '0903000031','manh@gmail.com',         0,1),
(N'Trần Quỳnh Như',    '0903000032','nhu@gmail.com',         20,1),
(N'Lê Tuấn Kiệt',      '0903000033','kiet@gmail.com',        40,1),
(N'Phạm Nhật Nam',     '0903000034','nam@gmail.com',         60,1),
(N'Hoàng Thu Trang',   '0903000035','trang@gmail.com',      110,1),
(N'Vũ Thanh Tùng',     '0903000036','tung@gmail.com',        35,1),
(N'Đặng Phương Anh',   '0903000037','phuonganh@gmail.com',   55,1),
(N'Ngô Minh Quân',     '0903000038','minhquan@gmail.com',    95,1),
(N'Đỗ Quốc Việt',      '0903000039','viet@gmail.com',       125,1),
(N'Bùi Thị Hương',     '0903000040','huong@gmail.com',        0,1),
(N'Nguyễn Tiến Đạt',   '0903000041','dat@gmail.com',         30,1),
(N'Trần Văn Phong',    '0903000042','phong@gmail.com',       80,1),
(N'Lê Thị Mai',        '0903000043','mai@gmail.com',         15,1),
(N'Phạm Minh Tuấn',    '0903000044','tuan@gmail.com',        60,1),
(N'Hoàng Anh Tuấn',    '0903000045','anhtuan@gmail.com',     95,1),
(N'Vũ Bảo Ngọc',       '0903000046','ngoc@gmail.com',       100,1),
(N'Đặng Quốc Huy',     '0903000047','quochuy@gmail.com',     10,1),
(N'Ngô Thành Công',    '0903000048','cong@gmail.com',        40,1),
(N'Đỗ Văn Sơn',        '0903000049','son@gmail.com',         75,1),
(N'Bùi Nhật Minh',     '0903000050','nhatminh@gmail.com',   120,1);
GO

-- ĐỊA CHỈ KHÁCH HÀNG (50) — giữ nguyên file gốc
INSERT INTO DiaChiKhachHang (MaKH, DiaChiChiTiet, LaMacDinh) VALUES
(1, N'12 Cầu Giấy, Hà Nội',1),
(2, N'25 Hai Bà Trưng, Hà Nội',1),
(3, N'15 Lê Lợi, Đà Nẵng',1),
(4, N'45 Nguyễn Huệ, TP. Hồ Chí Minh',1),
(5, N'10 Trần Hưng Đạo, Hải Phòng',1),
(6, N'18 Võ Văn Tần, TP. Hồ Chí Minh',1),
(7, N'30 Lý Thường Kiệt, Hà Nội',1),
(8, N'28 Điện Biên Phủ, Đà Nẵng',1),
(9, N'65 Phan Đình Phùng, Huế',1),
(10,N'90 Nguyễn Trãi, Hà Nội',1),
(11,N'22 Hoàng Hoa Thám, Hà Nội',1),
(12,N'17 Nguyễn Văn Linh, Đà Nẵng',1),
(13,N'11 Nguyễn Huệ, TP. Hồ Chí Minh',1),
(14,N'40 Trần Phú, Hải Phòng',1),
(15,N'78 Lý Tự Trọng, Cần Thơ',1),
(16,N'29 Quang Trung, Hà Nội',1),
(17,N'56 Bạch Đằng, Đà Nẵng',1),
(18,N'88 Hùng Vương, Huế',1),
(19,N'44 Nguyễn Thị Minh Khai, TP.HCM',1),
(20,N'33 Hai Bà Trưng, Hà Nội',1),
(21,N'99 Trần Hưng Đạo, Nam Định',1),
(22,N'100 Phạm Văn Đồng, Hà Nội',1),
(23,N'20 Nguyễn Chí Thanh, Hà Nội',1),
(24,N'70 Nguyễn Văn Cừ, Hải Phòng',1),
(25,N'88 Trần Cao Vân, Đà Nẵng',1),
(26,N'15 Hùng Vương, Hà Nội',1),
(27,N'66 Nguyễn Trãi, Hà Nội',1),
(28,N'45 Lê Duẩn, TP.HCM',1),
(29,N'72 Võ Nguyên Giáp, Đà Nẵng',1),
(30,N'18 Trần Quốc Toản, Hà Nội',1),
(31,N'102 Nguyễn Huệ, Huế',1),
(32,N'89 Bạch Mai, Hà Nội',1),
(33,N'30 Nguyễn Công Trứ, Hà Nội',1),
(34,N'65 Lê Hồng Phong, Hải Phòng',1),
(35,N'20 Lê Duẩn, Đà Nẵng',1),
(36,N'50 Hoàng Diệu, Hà Nội',1),
(37,N'18 Nguyễn Đình Chiểu, TP.HCM',1),
(38,N'66 Trần Hưng Đạo, Cần Thơ',1),
(39,N'32 Điện Biên Phủ, Hà Nội',1),
(40,N'45 Nguyễn Tất Thành, Đà Nẵng',1),
(41,N'12 Nguyễn Văn Linh, Hải Phòng',1),
(42,N'36 Lý Nam Đế, Hà Nội',1),
(43,N'77 Hai Bà Trưng, Huế',1),
(44,N'19 Nguyễn Tri Phương, Đà Nẵng',1),
(45,N'61 Trần Phú, Hà Nội',1),
(46,N'99 Phan Chu Trinh, Đà Nẵng',1),
(47,N'41 Lê Lợi, Huế',1),
(48,N'24 Trần Hưng Đạo, Hà Nội',1),
(49,N'88 Nguyễn Trãi, TP.HCM',1),
(50,N'55 Nguyễn Văn Cừ, Cần Thơ',1);
GO

-- VOUCHER (30) — giữ nguyên file gốc
INSERT INTO Voucher (MaCode,LoaiGiam,GiaTri,GiaTriDonToiThieu,GiaGiamToiDa,NgayBatDau,NgayKetThuc,SoLuongToiDa,DaSuDung) VALUES
('WELCOME10',0,10000, 100000,NULL,   '2026-01-01','2026-12-31',500, 25),
('WELCOME20',0,20000, 200000,NULL,   '2026-01-01','2026-12-31',500, 12),
('WELCOME30',0,30000, 300000,NULL,   '2026-01-01','2026-12-31',300,  6),
('VIP05',    1,5,     100000,50000,  '2026-01-01','2026-12-31',500,120),
('VIP10',    1,10,    200000,100000, '2026-01-01','2026-12-31',500, 75),
('VIP15',    1,15,    300000,150000, '2026-01-01','2026-12-31',300, 42),
('VIP20',    1,20,    500000,200000, '2026-01-01','2026-12-31',200, 20),
('BOOK10',   1,10,    150000,40000,  '2026-01-01','2026-12-31',300, 18),
('BOOK15',   1,15,    250000,60000,  '2026-01-01','2026-12-31',300, 30),
('BOOK20',   1,20,    350000,80000,  '2026-01-01','2026-12-31',300, 14),
('SUMMER10', 1,10,    100000,50000,  '2026-06-01','2026-08-31',500, 10),
('SUMMER20', 1,20,    300000,120000, '2026-06-01','2026-08-31',500,  8),
('NEWYEAR',  0,50000, 500000,NULL,   '2026-01-01','2026-02-28',200, 35),
('STUDENT5', 1,5,      50000,20000,  '2026-01-01','2026-12-31',500, 60),
('STUDENT10',1,10,    150000,50000,  '2026-01-01','2026-12-31',300, 15),
('SALE50K',  0,50000, 500000,NULL,   '2026-01-01','2026-12-31',200, 12),
('SALE100K', 0,100000,1000000,NULL,  '2026-01-01','2026-12-31',100,  5),
('FREESHIP15',0,15000,100000,NULL,   '2026-01-01','2026-12-31',1000,150),
('FREESHIP30',0,30000,300000,NULL,   '2026-01-01','2026-12-31',800, 98),
('FLASH5',   1,5,     100000,30000,  '2026-03-01','2026-03-31',200, 19),
('FLASH10',  1,10,    200000,50000,  '2026-03-01','2026-03-31',200, 10),
('BLACKFRIDAY',1,25,  500000,300000, '2026-11-20','2026-11-30',300,  0),
('CYBERDAY', 1,20,    300000,200000, '2026-11-25','2026-12-05',300,  0),
('BOOKFAIR', 0,20000, 150000,NULL,   '2026-04-01','2026-04-30',500, 11),
('KHAITRUONG',0,50000,300000,NULL,   '2026-01-01','2026-01-31',500,300),
('MEMBER5',  1,5,     100000,30000,  '2026-01-01','2026-12-31',1000,200),
('MEMBER8',  1,8,     150000,50000,  '2026-01-01','2026-12-31',1000,150),
('MEMBER12', 1,12,    250000,70000,  '2026-01-01','2026-12-31',800, 90),
('BOOKSTORE10',1,10,  200000,80000,  '2026-01-01','2026-12-31',500, 44),
('BOOKSTORE15',1,15,  400000,120000, '2026-01-01','2026-12-31',300, 18);
GO

-- ĐƠN HÀNG (20) — giữ nguyên file gốc
-- Trigger sẽ tự tính TongTien sau khi insert ChiTietDonHang
INSERT INTO DonHang (NgayLap,TongTien,TrangThai,PhuongThucThanhToan,MaKH,MaNV,MaVoucher,SoTienGiam) VALUES
('2026-07-01',0,1,N'Tiền mặt',     1, 3,1, 10000),
('2026-07-01',0,1,N'Chuyển khoản', 2, 4,NULL,0),
('2026-07-02',0,1,N'Ví MoMo',      3, 5,4, 25000),
('2026-07-02',0,1,N'Tiền mặt',     4, 6,NULL,0),
('2026-07-03',0,1,N'Chuyển khoản', 5, 7,2, 20000),
('2026-07-03',0,1,N'Tiền mặt',     6, 8,NULL,0),
('2026-07-04',0,1,N'Ví ZaloPay',   7, 9,5, 35000),
('2026-07-04',0,1,N'Tiền mặt',     8,10,NULL,0),
('2026-07-05',0,1,N'Chuyển khoản', 9,11,8, 50000),
('2026-07-05',0,1,N'Tiền mặt',    10,12,NULL,0),
('2026-07-06',0,1,N'Tiền mặt',    11,13,10,25000),
('2026-07-06',0,1,N'Chuyển khoản',12,14,NULL,0),
('2026-07-07',0,1,N'Ví MoMo',     13,15,12,45000),
('2026-07-07',0,1,N'Tiền mặt',    14,16,NULL,0),
('2026-07-08',0,1,N'Chuyển khoản',15,17,15,30000),
('2026-07-08',0,1,N'Tiền mặt',    16,18,NULL,0),
('2026-07-09',0,1,N'Ví MoMo',     17,19,18,15000),
('2026-07-09',0,1,N'Tiền mặt',    18,20,NULL,0),
('2026-07-10',0,1,N'Chuyển khoản',19, 3,20,50000),
('2026-07-10',0,1,N'Tiền mặt',    20, 4,NULL,0);
GO

-- CHI TIẾT ĐƠN HÀNG (40 dòng) — giữ nguyên file gốc
-- Trigger trg_CapNhatTongTien sẽ cập nhật TongTien tự động
INSERT INTO ChiTietDonHang (MaDH,MaSach,SoLuong,DonGia) VALUES
(1,'S001',1,85000),(1,'S019',1,120000),
(2,'S010',1,180000),(2,'S030',2,28000),
(3,'S020',1,98000),(3,'S026',1,185000),
(4,'S006',2,75000),(4,'S047',1,98000),
(5,'S024',1,210000),(5,'S025',1,220000),
(6,'S027',1,320000),(6,'S028',1,350000),
(7,'S035',2,32000),(7,'S036',2,32000),
(8,'S043',2,35000),(8,'S044',2,35000),
(9,'S017',1,150000),(9,'S018',1,145000),
(10,'S003',1,110000),(10,'S004',1,89000),
(11,'S002',1,98000),(11,'S005',2,65000),
(12,'S029',1,420000),(12,'S026',1,185000),
(13,'S046',1,135000),(13,'S049',1,125000),
(14,'S048',1,180000),(14,'S050',1,145000),
(15,'S030',3,28000),(15,'S031',3,28000),
(16,'S032',2,28000),(16,'S033',2,28000),
(17,'S034',3,28000),(17,'S040',2,35000),
(18,'S041',2,35000),(18,'S042',2,35000),
(19,'S011',1,180000),(19,'S012',1,180000),
(20,'S013',1,195000),(20,'S014',1,205000);
GO

-- SÁCH VẬT LÝ (100 cuốn S001-S010, mỗi sách 10 cuốn) — giữ nguyên file gốc
INSERT INTO SachVatLy (MaSerial,MaSach,TrangThai,MaCTDH) VALUES
('S001001','S001',N'Có sẵn',NULL),('S001002','S001',N'Có sẵn',NULL),
('S001003','S001',N'Có sẵn',NULL),('S001004','S001',N'Có sẵn',NULL),
('S001005','S001',N'Có sẵn',NULL),('S001006','S001',N'Có sẵn',NULL),
('S001007','S001',N'Có sẵn',NULL),('S001008','S001',N'Có sẵn',NULL),
('S001009','S001',N'Có sẵn',NULL),('S001010','S001',N'Có sẵn',NULL),

('S002001','S002',N'Có sẵn',NULL),('S002002','S002',N'Có sẵn',NULL),
('S002003','S002',N'Có sẵn',NULL),('S002004','S002',N'Có sẵn',NULL),
('S002005','S002',N'Có sẵn',NULL),('S002006','S002',N'Có sẵn',NULL),
('S002007','S002',N'Có sẵn',NULL),('S002008','S002',N'Có sẵn',NULL),
('S002009','S002',N'Có sẵn',NULL),('S002010','S002',N'Có sẵn',NULL),

('S003001','S003',N'Có sẵn',NULL),('S003002','S003',N'Có sẵn',NULL),
('S003003','S003',N'Có sẵn',NULL),('S003004','S003',N'Có sẵn',NULL),
('S003005','S003',N'Có sẵn',NULL),('S003006','S003',N'Có sẵn',NULL),
('S003007','S003',N'Có sẵn',NULL),('S003008','S003',N'Có sẵn',NULL),
('S003009','S003',N'Có sẵn',NULL),('S003010','S003',N'Có sẵn',NULL),

('S004001','S004',N'Có sẵn',NULL),('S004002','S004',N'Có sẵn',NULL),
('S004003','S004',N'Có sẵn',NULL),('S004004','S004',N'Có sẵn',NULL),
('S004005','S004',N'Có sẵn',NULL),('S004006','S004',N'Có sẵn',NULL),
('S004007','S004',N'Có sẵn',NULL),('S004008','S004',N'Có sẵn',NULL),
('S004009','S004',N'Có sẵn',NULL),('S004010','S004',N'Có sẵn',NULL),

('S005001','S005',N'Có sẵn',NULL),('S005002','S005',N'Có sẵn',NULL),
('S005003','S005',N'Có sẵn',NULL),('S005004','S005',N'Có sẵn',NULL),
('S005005','S005',N'Có sẵn',NULL),('S005006','S005',N'Có sẵn',NULL),
('S005007','S005',N'Có sẵn',NULL),('S005008','S005',N'Có sẵn',NULL),
('S005009','S005',N'Có sẵn',NULL),('S005010','S005',N'Có sẵn',NULL),

('S006001','S006',N'Có sẵn',NULL),('S006002','S006',N'Có sẵn',NULL),
('S006003','S006',N'Có sẵn',NULL),('S006004','S006',N'Có sẵn',NULL),
('S006005','S006',N'Có sẵn',NULL),('S006006','S006',N'Có sẵn',NULL),
('S006007','S006',N'Có sẵn',NULL),('S006008','S006',N'Có sẵn',NULL),
('S006009','S006',N'Có sẵn',NULL),('S006010','S006',N'Có sẵn',NULL),

('S007001','S007',N'Có sẵn',NULL),('S007002','S007',N'Có sẵn',NULL),
('S007003','S007',N'Có sẵn',NULL),('S007004','S007',N'Có sẵn',NULL),
('S007005','S007',N'Có sẵn',NULL),('S007006','S007',N'Có sẵn',NULL),
('S007007','S007',N'Có sẵn',NULL),('S007008','S007',N'Có sẵn',NULL),
('S007009','S007',N'Có sẵn',NULL),('S007010','S007',N'Có sẵn',NULL),

('S008001','S008',N'Có sẵn',NULL),('S008002','S008',N'Có sẵn',NULL),
('S008003','S008',N'Có sẵn',NULL),('S008004','S008',N'Có sẵn',NULL),
('S008005','S008',N'Có sẵn',NULL),('S008006','S008',N'Có sẵn',NULL),
('S008007','S008',N'Có sẵn',NULL),('S008008','S008',N'Có sẵn',NULL),
('S008009','S008',N'Có sẵn',NULL),('S008010','S008',N'Có sẵn',NULL),

('S009001','S009',N'Có sẵn',NULL),('S009002','S009',N'Có sẵn',NULL),
('S009003','S009',N'Có sẵn',NULL),('S009004','S009',N'Có sẵn',NULL),
('S009005','S009',N'Có sẵn',NULL),('S009006','S009',N'Có sẵn',NULL),
('S009007','S009',N'Có sẵn',NULL),('S009008','S009',N'Có sẵn',NULL),
('S009009','S009',N'Có sẵn',NULL),('S009010','S009',N'Có sẵn',NULL),

('S010001','S010',N'Có sẵn',NULL),('S010002','S010',N'Có sẵn',NULL),
('S010003','S010',N'Có sẵn',NULL),('S010004','S010',N'Có sẵn',NULL),
('S010005','S010',N'Có sẵn',NULL),('S010006','S010',N'Có sẵn',NULL),
('S010007','S010',N'Có sẵn',NULL),('S010008','S010',N'Có sẵn',NULL),
('S010009','S010',N'Có sẵn',NULL),('S010010','S010',N'Có sẵn',NULL);
GO

-- SÁCH VẬT LÝ — S011-S050, mỗi sách 5 cuốn (bổ sung để test đầy đủ)
INSERT INTO SachVatLy (MaSerial,MaSach,TrangThai,MaCTDH) VALUES
('S011001','S011',N'Có sẵn',NULL),('S011002','S011',N'Có sẵn',NULL),('S011003','S011',N'Có sẵn',NULL),('S011004','S011',N'Có sẵn',NULL),('S011005','S011',N'Có sẵn',NULL),
('S012001','S012',N'Có sẵn',NULL),('S012002','S012',N'Có sẵn',NULL),('S012003','S012',N'Có sẵn',NULL),('S012004','S012',N'Có sẵn',NULL),('S012005','S012',N'Có sẵn',NULL),
('S013001','S013',N'Có sẵn',NULL),('S013002','S013',N'Có sẵn',NULL),('S013003','S013',N'Có sẵn',NULL),('S013004','S013',N'Có sẵn',NULL),('S013005','S013',N'Có sẵn',NULL),
('S014001','S014',N'Có sẵn',NULL),('S014002','S014',N'Có sẵn',NULL),('S014003','S014',N'Có sẵn',NULL),('S014004','S014',N'Có sẵn',NULL),('S014005','S014',N'Có sẵn',NULL),
('S015001','S015',N'Có sẵn',NULL),('S015002','S015',N'Có sẵn',NULL),('S015003','S015',N'Có sẵn',NULL),('S015004','S015',N'Có sẵn',NULL),('S015005','S015',N'Có sẵn',NULL),
('S016001','S016',N'Có sẵn',NULL),('S016002','S016',N'Có sẵn',NULL),('S016003','S016',N'Có sẵn',NULL),('S016004','S016',N'Có sẵn',NULL),('S016005','S016',N'Có sẵn',NULL),
('S017001','S017',N'Có sẵn',NULL),('S017002','S017',N'Có sẵn',NULL),('S017003','S017',N'Có sẵn',NULL),('S017004','S017',N'Có sẵn',NULL),('S017005','S017',N'Có sẵn',NULL),
('S018001','S018',N'Có sẵn',NULL),('S018002','S018',N'Có sẵn',NULL),('S018003','S018',N'Có sẵn',NULL),('S018004','S018',N'Có sẵn',NULL),('S018005','S018',N'Có sẵn',NULL),
('S019001','S019',N'Có sẵn',NULL),('S019002','S019',N'Có sẵn',NULL),('S019003','S019',N'Có sẵn',NULL),('S019004','S019',N'Có sẵn',NULL),('S019005','S019',N'Có sẵn',NULL),
('S020001','S020',N'Có sẵn',NULL),('S020002','S020',N'Có sẵn',NULL),('S020003','S020',N'Có sẵn',NULL),('S020004','S020',N'Có sẵn',NULL),('S020005','S020',N'Có sẵn',NULL),
('S021001','S021',N'Có sẵn',NULL),('S021002','S021',N'Có sẵn',NULL),('S021003','S021',N'Có sẵn',NULL),('S021004','S021',N'Có sẵn',NULL),('S021005','S021',N'Có sẵn',NULL),
('S022001','S022',N'Có sẵn',NULL),('S022002','S022',N'Có sẵn',NULL),('S022003','S022',N'Có sẵn',NULL),('S022004','S022',N'Có sẵn',NULL),('S022005','S022',N'Có sẵn',NULL),
('S023001','S023',N'Có sẵn',NULL),('S023002','S023',N'Có sẵn',NULL),('S023003','S023',N'Có sẵn',NULL),('S023004','S023',N'Có sẵn',NULL),('S023005','S023',N'Có sẵn',NULL),
('S024001','S024',N'Có sẵn',NULL),('S024002','S024',N'Có sẵn',NULL),('S024003','S024',N'Có sẵn',NULL),('S024004','S024',N'Có sẵn',NULL),('S024005','S024',N'Có sẵn',NULL),
('S025001','S025',N'Có sẵn',NULL),('S025002','S025',N'Có sẵn',NULL),('S025003','S025',N'Có sẵn',NULL),('S025004','S025',N'Có sẵn',NULL),('S025005','S025',N'Có sẵn',NULL),
('S026001','S026',N'Có sẵn',NULL),('S026002','S026',N'Có sẵn',NULL),('S026003','S026',N'Có sẵn',NULL),('S026004','S026',N'Có sẵn',NULL),('S026005','S026',N'Có sẵn',NULL),
('S027001','S027',N'Có sẵn',NULL),('S027002','S027',N'Có sẵn',NULL),('S027003','S027',N'Có sẵn',NULL),('S027004','S027',N'Có sẵn',NULL),('S027005','S027',N'Có sẵn',NULL),
('S028001','S028',N'Có sẵn',NULL),('S028002','S028',N'Có sẵn',NULL),('S028003','S028',N'Có sẵn',NULL),('S028004','S028',N'Có sẵn',NULL),('S028005','S028',N'Có sẵn',NULL),
('S029001','S029',N'Có sẵn',NULL),('S029002','S029',N'Có sẵn',NULL),('S029003','S029',N'Có sẵn',NULL),('S029004','S029',N'Có sẵn',NULL),('S029005','S029',N'Có sẵn',NULL),
('S030001','S030',N'Có sẵn',NULL),('S030002','S030',N'Có sẵn',NULL),('S030003','S030',N'Có sẵn',NULL),('S030004','S030',N'Có sẵn',NULL),('S030005','S030',N'Có sẵn',NULL),
('S031001','S031',N'Có sẵn',NULL),('S031002','S031',N'Có sẵn',NULL),('S031003','S031',N'Có sẵn',NULL),('S031004','S031',N'Có sẵn',NULL),('S031005','S031',N'Có sẵn',NULL),
('S032001','S032',N'Có sẵn',NULL),('S032002','S032',N'Có sẵn',NULL),('S032003','S032',N'Có sẵn',NULL),('S032004','S032',N'Có sẵn',NULL),('S032005','S032',N'Có sẵn',NULL),
('S033001','S033',N'Có sẵn',NULL),('S033002','S033',N'Có sẵn',NULL),('S033003','S033',N'Có sẵn',NULL),('S033004','S033',N'Có sẵn',NULL),('S033005','S033',N'Có sẵn',NULL),
('S034001','S034',N'Có sẵn',NULL),('S034002','S034',N'Có sẵn',NULL),('S034003','S034',N'Có sẵn',NULL),('S034004','S034',N'Có sẵn',NULL),('S034005','S034',N'Có sẵn',NULL),
('S035001','S035',N'Có sẵn',NULL),('S035002','S035',N'Có sẵn',NULL),('S035003','S035',N'Có sẵn',NULL),('S035004','S035',N'Có sẵn',NULL),('S035005','S035',N'Có sẵn',NULL),
('S036001','S036',N'Có sẵn',NULL),('S036002','S036',N'Có sẵn',NULL),('S036003','S036',N'Có sẵn',NULL),('S036004','S036',N'Có sẵn',NULL),('S036005','S036',N'Có sẵn',NULL),
('S037001','S037',N'Có sẵn',NULL),('S037002','S037',N'Có sẵn',NULL),('S037003','S037',N'Có sẵn',NULL),('S037004','S037',N'Có sẵn',NULL),('S037005','S037',N'Có sẵn',NULL),
('S038001','S038',N'Có sẵn',NULL),('S038002','S038',N'Có sẵn',NULL),('S038003','S038',N'Có sẵn',NULL),('S038004','S038',N'Có sẵn',NULL),('S038005','S038',N'Có sẵn',NULL),
('S039001','S039',N'Có sẵn',NULL),('S039002','S039',N'Có sẵn',NULL),('S039003','S039',N'Có sẵn',NULL),('S039004','S039',N'Có sẵn',NULL),('S039005','S039',N'Có sẵn',NULL),
('S040001','S040',N'Có sẵn',NULL),('S040002','S040',N'Có sẵn',NULL),('S040003','S040',N'Có sẵn',NULL),('S040004','S040',N'Có sẵn',NULL),('S040005','S040',N'Có sẵn',NULL),
('S041001','S041',N'Có sẵn',NULL),('S041002','S041',N'Có sẵn',NULL),('S041003','S041',N'Có sẵn',NULL),('S041004','S041',N'Có sẵn',NULL),('S041005','S041',N'Có sẵn',NULL),
('S042001','S042',N'Có sẵn',NULL),('S042002','S042',N'Có sẵn',NULL),('S042003','S042',N'Có sẵn',NULL),('S042004','S042',N'Có sẵn',NULL),('S042005','S042',N'Có sẵn',NULL),
('S043001','S043',N'Có sẵn',NULL),('S043002','S043',N'Có sẵn',NULL),('S043003','S043',N'Có sẵn',NULL),('S043004','S043',N'Có sẵn',NULL),('S043005','S043',N'Có sẵn',NULL),
('S044001','S044',N'Có sẵn',NULL),('S044002','S044',N'Có sẵn',NULL),('S044003','S044',N'Có sẵn',NULL),('S044004','S044',N'Có sẵn',NULL),('S044005','S044',N'Có sẵn',NULL),
('S045001','S045',N'Có sẵn',NULL),('S045002','S045',N'Có sẵn',NULL),('S045003','S045',N'Có sẵn',NULL),('S045004','S045',N'Có sẵn',NULL),('S045005','S045',N'Có sẵn',NULL),
('S046001','S046',N'Có sẵn',NULL),('S046002','S046',N'Có sẵn',NULL),('S046003','S046',N'Có sẵn',NULL),('S046004','S046',N'Có sẵn',NULL),('S046005','S046',N'Có sẵn',NULL),
('S047001','S047',N'Có sẵn',NULL),('S047002','S047',N'Có sẵn',NULL),('S047003','S047',N'Có sẵn',NULL),('S047004','S047',N'Có sẵn',NULL),('S047005','S047',N'Có sẵn',NULL),
('S048001','S048',N'Có sẵn',NULL),('S048002','S048',N'Có sẵn',NULL),('S048003','S048',N'Có sẵn',NULL),('S048004','S048',N'Có sẵn',NULL),('S048005','S048',N'Có sẵn',NULL),
('S049001','S049',N'Có sẵn',NULL),('S049002','S049',N'Có sẵn',NULL),('S049003','S049',N'Có sẵn',NULL),('S049004','S049',N'Có sẵn',NULL),('S049005','S049',N'Có sẵn',NULL),
('S050001','S050',N'Có sẵn',NULL),('S050002','S050',N'Có sẵn',NULL),('S050003','S050',N'Có sẵn',NULL),('S050004','S050',N'Có sẵn',NULL),('S050005','S050',N'Có sẵn',NULL);
GO

-- SÁCH BIẾN THỂ [5] — bảng mới, data mẫu cho POS
-- Các sách phổ biến nhất có biến thể bìa/ngôn ngữ
INSERT INTO SachBienThe (MaSach,MaBienTheCode,BiaSach,NgonNgu,GiaBienThe,TrangThai) VALUES
('S001','S001-BM-VI', N'Bìa mềm',  N'Tiếng Việt',  85000,1),
('S001','S001-BC-VI', N'Bìa cứng', N'Tiếng Việt', 120000,1),
('S002','S002-BM-VI', N'Bìa mềm',  N'Tiếng Việt',  98000,1),
('S003','S003-BM-VI', N'Bìa mềm',  N'Tiếng Việt', 110000,1),
('S004','S004-BM-VI', N'Bìa mềm',  N'Tiếng Việt',  89000,1),
('S006','S006-BM-VI', N'Bìa mềm',  N'Tiếng Việt',  75000,1),
('S009','S009-BM-VI', N'Bìa mềm',  N'Tiếng Việt', 120000,1),
('S010','S010-BM-VI', N'Bìa mềm',  N'Tiếng Việt', 180000,1),
('S010','S010-BC-VI', N'Bìa cứng', N'Tiếng Việt', 250000,1),
('S010','S010-BM-EN', N'Bìa mềm',  N'Tiếng Anh',  280000,1),
('S016','S016-BM-VI', N'Bìa mềm',  N'Tiếng Việt', 220000,1),
('S016','S016-BC-VI', N'Bìa cứng', N'Tiếng Việt', 320000,1),
('S019','S019-BM-VI', N'Bìa mềm',  N'Tiếng Việt', 120000,1),
('S020','S020-BM-VI', N'Bìa mềm',  N'Tiếng Việt',  98000,1),
('S021','S021-BM-VI', N'Bìa mềm',  N'Tiếng Việt', 135000,1),
('S022','S022-BM-VI', N'Bìa mềm',  N'Tiếng Việt', 160000,1),
('S024','S024-BM-VI', N'Bìa mềm',  N'Tiếng Việt', 210000,1),
('S024','S024-BC-VI', N'Bìa cứng', N'Tiếng Việt', 280000,1),
('S026','S026-BM-VI', N'Bìa mềm',  N'Tiếng Việt', 185000,1),
('S026','S026-BC-VI', N'Bìa cứng', N'Tiếng Việt', 250000,1),
('S027','S027-BM-EN', N'Bìa mềm',  N'Tiếng Anh',  320000,1),
('S028','S028-BM-EN', N'Bìa mềm',  N'Tiếng Anh',  350000,1),
('S029','S029-BM-EN', N'Bìa mềm',  N'Tiếng Anh',  420000,1),
('S046','S046-BM-VI', N'Bìa mềm',  N'Tiếng Việt', 135000,1),
('S047','S047-BM-VI', N'Bìa mềm',  N'Tiếng Việt',  98000,1),
('S047','S047-BC-VI', N'Bìa cứng', N'Tiếng Việt', 140000,1);
GO

-- ĐÁNH GIÁ (50) — giữ nguyên file gốc
INSERT INTO DanhGia (MaKH,MaSach,SoSao,NoiDung) VALUES
(1,'S001',5,N'Cuốn sách rất hay và ý nghĩa.'),
(2,'S002',5,N'Đọc rất cảm động.'),
(3,'S003',5,N'Tác phẩm tuyệt vời.'),
(4,'S004',4,N'Nội dung hấp dẫn.'),
(5,'S005',5,N'Rất phù hợp thiếu nhi.'),
(6,'S006',5,N'Tác phẩm kinh điển.'),
(7,'S007',4,N'Đáng đọc.'),
(8,'S008',5,N'Hài hước và sâu sắc.'),
(9,'S009',5,N'Kiệt tác văn học.'),
(10,'S010',5,N'Harry Potter quá hay.'),
(11,'S011',5,N'Đọc không thể dừng.'),
(12,'S012',5,N'Rất cuốn hút.'),
(13,'S013',5,N'Phần hay nhất.'),
(14,'S014',4,N'Nội dung hấp dẫn.'),
(15,'S015',5,N'Rất đáng tiền.'),
(16,'S016',5,N'Kết thúc tuyệt vời.'),
(17,'S017',4,N'Trinh thám rất hay.'),
(18,'S018',4,N'Logic chặt chẽ.'),
(19,'S019',5,N'Nên đọc một lần trong đời.'),
(20,'S020',5,N'Truyền cảm hứng.'),
(21,'S021',4,N'Phong cách Murakami rất đặc biệt.'),
(22,'S022',5,N'Cực kỳ hấp dẫn.'),
(23,'S023',5,N'Hay hơn mong đợi.'),
(24,'S024',5,N'Kiến thức bổ ích.'),
(25,'S025',5,N'Rất đáng đọc.'),
(26,'S026',5,N'Thay đổi thói quen rất tốt.'),
(27,'S027',5,N'Lập trình viên nên đọc.'),
(28,'S028',5,N'Học Java rất dễ hiểu.'),
(29,'S029',5,N'Cuốn Java hay nhất.'),
(30,'S030',5,N'Tuổi thơ của tôi.'),
(31,'S031',5,N'Doraemon rất hay.'),
(32,'S032',4,N'Con thích lắm.'),
(33,'S033',5,N'Truyện rất vui.'),
(34,'S034',5,N'Đọc mãi không chán.'),
(35,'S035',5,N'Conan quá đỉnh.'),
(36,'S036',5,N'Rất cuốn hút.'),
(37,'S037',5,N'Trinh thám hấp dẫn.'),
(38,'S038',4,N'Đọc rất hay.'),
(39,'S039',5,N'Rất thích.'),
(40,'S040',5,N'Dragon Ball tuổi thơ.'),
(41,'S041',5,N'Hay tuyệt.'),
(42,'S042',5,N'Goku rất ngầu.'),
(43,'S043',5,N'One Piece quá hay.'),
(44,'S044',5,N'Luffy tuyệt vời.'),
(45,'S045',4,N'Rất đáng xem.'),
(46,'S046',5,N'Một kiệt tác.'),
(47,'S047',5,N'Hoàng tử bé rất ý nghĩa.'),
(48,'S048',5,N'Không thể bỏ qua.'),
(49,'S049',5,N'Rất xúc động.'),
(50,'S050',4,N'Truyện kinh dị khá hay.');
GO

-- LỊCH SỬ ĐỔI TRẢ — data mẫu để test chức năng đổi/trả (entity LichSuDoiTra.java)
-- Ghi chú: trong thực tế Java tự điền bảng này qua DonHangDAO.traMon()/doiMon()
-- Data mẫu dưới đây giả lập 3 lần trả hàng và 2 lần đổi hàng từ các đơn đã có
INSERT INTO LichSuDoiTra (MaDH, LoaiGiaoDich, NgayThucHien, MaCTDHCu, SoLuongTra, MaSachMoi, SoLuongMoi, ChenhLechTien, LyDo) VALUES
-- Khách hàng 1 trả 1 cuốn S001 từ đơn 1 (MaCTDH=1: S001 x1 giá 85000)
(1, N'TRA', '2026-07-05 10:00:00', 1, 1, NULL, NULL, -85000.00, N'Sách bị lỗi trang'),
-- Khách hàng 3 đổi 1 cuốn S020 từ đơn 3 (MaCTDH=5: S020 x1 giá 98000) sang S021 (giá 135000)
(3, N'DOI', '2026-07-06 14:30:00', 5, 1, 'S021', 1, 37000.00, N'Muốn đổi sang sách khác'),
-- Khách hàng 9 trả 1 cuốn S017 từ đơn 9 (MaCTDH=17: S017 x1 giá 150000)
(9, N'TRA', '2026-07-08 09:15:00', 17, 1, NULL, NULL, -150000.00, N'Đọc rồi không thích'),
-- Khách hàng 6 đổi 1 cuốn S027 từ đơn 6 (MaCTDH=11: S027 x1 giá 320000) sang S029 (giá 420000)
(6, N'DOI', '2026-07-10 16:00:00', 11, 1, 'S029', 1, 100000.00, N'Muốn đọc bản nâng cao hơn'),
-- Khách hàng 2 trả 1 cuốn S010 từ đơn 2 (MaCTDH=3: S010 x1 giá 180000)
(2, N'TRA', '2026-07-12 11:30:00', 3, 1, NULL, NULL, -180000.00, N'Mua nhầm phiên bản');
GO

-- ============================================================
-- QUERY SAMPLE (giữ nguyên từ file gốc, dạng comment)
-- ============================================================
-- Tồn kho: SELECT s.MaSach,s.TenSach,COUNT(sv.MaSerial) AS TonKho
--          FROM Sach s LEFT JOIN SachVatLy sv ON sv.MaSach=s.MaSach AND sv.TrangThai=N'Có sẵn'
--          GROUP BY s.MaSach,s.TenSach;

-- Tra cứu serial: SELECT sv.MaSerial,s.TenSach,kh.TenKH,dh.MaDH,dh.NgayLap
--                 FROM SachVatLy sv JOIN Sach s ON s.MaSach=sv.MaSach
--                 JOIN ChiTietDonHang ct ON ct.MaCTDH=sv.MaCTDH
--                 JOIN DonHang dh ON dh.MaDH=ct.MaDH
--                 JOIN KhachHang kh ON kh.MaKH=dh.MaKH
--                 WHERE sv.MaSerial='S001001';

-- Doanh thu theo tháng: SELECT YEAR(NgayLap) Nam,MONTH(NgayLap) Thang,SUM(TongTien) DoanhThu
--                       FROM DonHang WHERE TrangThai=1
--                       GROUP BY YEAR(NgayLap),MONTH(NgayLap) ORDER BY Nam,Thang;

-- Top 5 bán chạy: SELECT TOP 5 s.TenSach,COUNT(sv.MaSerial) SoLuongBan
--                 FROM Sach s JOIN SachVatLy sv ON sv.MaSach=s.MaSach
--                 WHERE sv.TrangThai=N'Đã bán'
--                 GROUP BY s.TenSach ORDER BY SoLuongBan DESC;

-- Voucher hợp lệ: SELECT * FROM Voucher WHERE MaCode='VIP10'
--                 AND GETDATE() BETWEEN NgayBatDau AND NgayKetThuc
--                 AND DaSuDung < SoLuongToiDa;

-- EXEC sp_TraSachBinhThuong @MaSerial = 'S001001';
-- EXEC sp_DoiSachHong @MaSerialCu = 'S001002', @MaSerialMoi = 'S002001';

-- ============================================================
-- KIỂM TRA NHANH
-- ============================================================
SELECT 'NhaXuatBan'    AS Bang, COUNT(*) AS SoBanGhi FROM NhaXuatBan    UNION ALL
SELECT 'TheLoai',               COUNT(*) FROM TheLoai                    UNION ALL
SELECT 'TacGia',                COUNT(*) FROM TacGia                     UNION ALL
SELECT 'BoSach',                COUNT(*) FROM BoSach                     UNION ALL
SELECT 'Sach',                  COUNT(*) FROM Sach                       UNION ALL
SELECT 'Sach_TacGia',           COUNT(*) FROM Sach_TacGia                UNION ALL
SELECT 'NhanVien',              COUNT(*) FROM NhanVien                   UNION ALL
SELECT 'KhachHang',             COUNT(*) FROM KhachHang                  UNION ALL
SELECT 'DiaChiKhachHang',       COUNT(*) FROM DiaChiKhachHang            UNION ALL
SELECT 'Voucher',               COUNT(*) FROM Voucher                    UNION ALL
SELECT 'DonHang',               COUNT(*) FROM DonHang                    UNION ALL
SELECT 'ChiTietDonHang',        COUNT(*) FROM ChiTietDonHang             UNION ALL
SELECT 'SachBienThe',           COUNT(*) FROM SachBienThe                UNION ALL
SELECT 'SachVatLy',             COUNT(*) FROM SachVatLy                  UNION ALL
SELECT 'DanhGia',               COUNT(*) FROM DanhGia                    UNION ALL
SELECT 'LichSuDoiTra',          COUNT(*) FROM LichSuDoiTra;
GO

PRINT N'';
PRINT N'==========================================================';
PRINT N' QuanLyNhaSach khởi tạo thành công!';
PRINT N' Tài khoản: admin/123456  |  nhanvien/123456';
PRINT N' 16 bảng | Trigger | 2 SP | 300+ serial kho';
PRINT N'==========================================================';
GO
