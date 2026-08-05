-- Migration: Thêm biến thể bìa sách và ngôn ngữ vào bảng Sach
-- Ngày: 2026-08-05

ALTER TABLE Sach
    ADD BiaSach  NVARCHAR(50)  NULL,  -- 'Bìa mềm' | 'Bìa cứng' | 'Bìa đặc biệt'
        NgonNgu  NVARCHAR(100) NULL;  -- VD: 'Tiếng Việt', 'Tiếng Anh', 'Song ngữ Anh-Việt'
