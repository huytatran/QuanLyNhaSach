-- Migration: Tạo bảng SachBienThe (biến thể sách có giá riêng)
-- Ngày: 2026-08-05
-- Mô tả: Mỗi đầu sách (Sach) có thể có nhiều biến thể (bìa mềm/cứng/đặc biệt, ngôn ngữ)
--        mỗi biến thể mang mã riêng và giá bán riêng.
--        Xóa 2 cột BiaSach/NgonNgu cũ trên bảng Sach (đã chuyển xuống bảng này).

-- Bước 1: Tạo bảng SachBienThe
CREATE TABLE SachBienThe (
    MaBienThe       INT             IDENTITY(1,1) PRIMARY KEY,
    MaSach          VARCHAR(20)     NOT NULL,            -- VARCHAR khớp với Sach.MaSach
    MaBienTheCode   NVARCHAR(50)    NULL,            -- Mã ngắn do người dùng đặt, VD: S001-BC-VI
    BiaSach         NVARCHAR(50)    NULL,            -- 'Bìa mềm' | 'Bìa cứng' | 'Bìa da'
    NgonNgu         NVARCHAR(100)   NULL,            -- 'Tiếng Việt' | 'Tiếng Anh' | ...
    GiaBienThe      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TrangThai       BIT             NOT NULL DEFAULT 1,  -- 1: đang bán, 0: ngừng bán
    CONSTRAINT FK_BienThe_Sach      FOREIGN KEY (MaSach) REFERENCES Sach(MaSach),
    CONSTRAINT UQ_BienThe_Code      UNIQUE (MaSach, MaBienTheCode)  -- mã duy nhất trong mỗi sách
);

-- Bước 2: Xóa 2 cột BiaSach/NgonNgu cũ ra khỏi bảng Sach
--         (Chạy sau khi đã migrate dữ liệu nếu cần giữ)
ALTER TABLE Sach DROP COLUMN BiaSach;
ALTER TABLE Sach DROP COLUMN NgonNgu;
