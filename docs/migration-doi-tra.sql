SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO

/*
    Migration cho tinh nang "Doi hang / Tra hang theo tung dong san pham".
    Chay script nay tren database QuanLyNhaSach TRUOC KHI test tinh nang moi.
    Nho bao cac thanh vien khac trong nhom vi day la thay doi schema dung chung.

    Luu y: cot Sach.TrangThai (danh dau sach con kinh doanh hay khong) DA CO SAN
    trong project (dung boi SachServlet/SachDAO.doiTrangThai), nen KHONG can them lai.
    Migration nay chi bo sung phan doi/tra.
*/

-- 1) Theo doi so luong da tra tren tung dong chi tiet don hang,
--    de khong cho tra vuot qua so luong da mua trong dong do.
ALTER TABLE ChiTietDonHang ADD SoLuongDaTra INT NOT NULL DEFAULT 0;

-- 2) Bang luu lich su tra hang / doi hang.
CREATE TABLE LichSuDoiTra (
    MaDoiTra        INT IDENTITY(1,1) PRIMARY KEY,
    MaDH            INT NOT NULL REFERENCES DonHang(MaDH),
    LoaiGiaoDich    NVARCHAR(10) NOT NULL CHECK (LoaiGiaoDich IN (N'TRA', N'DOI')),
    NgayThucHien    DATETIME2 NOT NULL DEFAULT GETDATE(),
    MaCTDHCu        INT NOT NULL REFERENCES ChiTietDonHang(MaCTDH),
    SoLuongTra      INT NOT NULL,
    MaSachMoi       VARCHAR(20) NULL REFERENCES Sach(MaSach),
    SoLuongMoi      INT NULL,
    ChenhLechTien   DECIMAL(18,2) NOT NULL DEFAULT 0,
    LyDo            NVARCHAR(255) NULL
);

-- Ghi chu: neu MaSach trong bang Sach cua ban khong phai VARCHAR(20),
-- sua kieu du lieu cot MaSachMoi o tren cho khop truoc khi chay.
