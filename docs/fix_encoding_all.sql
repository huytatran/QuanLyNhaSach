-- ============================================================
-- SCRIPT SỬA LỖI TIẾNG VIỆT TOÀN BỘ DATABASE: QuanLyNhaSach
-- Hướng dẫn: Mở SSMS -> Chọn DB QuanLyNhaSach -> Dán toàn bộ script và nhấn F5 (Execute)
-- ============================================================

USE QuanLyNhaSach;
GO

-- 1. Cập nhật Thể Loại (TheLoai)
IF OBJECT_ID('TheLoai', 'U') IS NOT NULL
BEGIN
    UPDATE TheLoai SET TenTL = N'Tiểu Thuyết' WHERE MaTL = 1;
    UPDATE TheLoai SET TenTL = N'Truyện Ngắn' WHERE MaTL = 2;
    UPDATE TheLoai SET TenTL = N'Văn Học Việt Nam' WHERE MaTL = 3;
    UPDATE TheLoai SET TenTL = N'Thiếu Nhi' WHERE MaTL = 4;
    UPDATE TheLoai SET TenTL = N'Kỹ Năng Sống' WHERE MaTL = 5;
    UPDATE TheLoai SET TenTL = N'Kinh Tế' WHERE MaTL = 6;
END;
GO

-- 2. Cập nhật Tác Giả (TacGia)
IF OBJECT_ID('TacGia', 'U') IS NOT NULL
BEGIN
    UPDATE TacGia SET TenTG = N'Nguyễn Nhật Ánh' WHERE MaTG = 1;
    UPDATE TacGia SET TenTG = N'Tô Hoài' WHERE MaTG = 2;
    UPDATE TacGia SET TenTG = N'Nam Cao' WHERE MaTG = 3;
    UPDATE TacGia SET TenTG = N'Vũ Trọng Phụng' WHERE MaTG = 4;
    UPDATE TacGia SET TenTG = N'Nguyễn Du' WHERE MaTG = 5;
END;
GO

-- 3. Cập nhật Nhà Xuất Bản (NhaXuatBan)
IF OBJECT_ID('NhaXuatBan', 'U') IS NOT NULL
BEGIN
    UPDATE NhaXuatBan SET TenNXB = N'NXB Trẻ', DiaChi = N'161 Lý Chính Thắng, Q.3, TP.HCM' WHERE MaNXB = 1;
    UPDATE NhaXuatBan SET TenNXB = N'NXB Kim Đồng', DiaChi = N'55 Quang Trung, Q. Hai Bà Trưng, Hà Nội' WHERE MaNXB = 2;
    UPDATE NhaXuatBan SET TenNXB = N'NXB Văn Học', DiaChi = N'18 Nguyễn Trường Tộ, Hà Nội' WHERE MaNXB = 3;
    UPDATE NhaXuatBan SET TenNXB = N'NXB Hội Nhà Văn', DiaChi = N'65 Nguyễn Du, Hà Nội' WHERE MaNXB = 4;
END;
GO

-- 4. Cập nhật Sách (Sach)
IF OBJECT_ID('Sach', 'U') IS NOT NULL
BEGIN
    UPDATE Sach SET TenSach = N'Cho Tôi Xin Một Vé Đi Tuổi Thơ' WHERE MaSach = 'S001';
    UPDATE Sach SET TenSach = N'Mắt Biếc' WHERE MaSach = 'S002';
    UPDATE Sach SET TenSach = N'Tôi Thấy Hoa Vàng Trên Cỏ Xanh' WHERE MaSach = 'S003';
    UPDATE Sach SET TenSach = N'Cô Gái Đến Từ Hôm Qua' WHERE MaSach = 'S004';
    UPDATE Sach SET TenSach = N'Kính Vạn Hoa - Tập 1' WHERE MaSach = 'S005';
    UPDATE Sach SET TenSach = N'Dế Mèn Phiêu Lưu Ký' WHERE MaSach = 'S006';
    UPDATE Sach SET TenSach = N'Sống Mòn' WHERE MaSach = 'S007';
    UPDATE Sach SET TenSach = N'Số Đỏ' WHERE MaSach = 'S008';
    UPDATE Sach SET TenSach = N'Truyện Kiều' WHERE MaSach = 'S009';
END;
GO

-- 5. Cập nhật Sách Biến Thể (SachBienThe)
IF OBJECT_ID('SachBienThe', 'U') IS NOT NULL
BEGIN
    UPDATE SachBienThe SET BiaSach = N'Bìa mềm' WHERE BiaSach IS NULL OR BiaSach LIKE '%b%m%';
    UPDATE SachBienThe SET NgonNgu = N'Tiếng Việt' WHERE NgonNgu IS NULL OR NgonNgu LIKE '%Vi%t%';
END;
GO

-- 6. Cập nhật Nhân Viên (NhanVien)
IF OBJECT_ID('NhanVien', 'U') IS NOT NULL
BEGIN
    UPDATE NhanVien SET TenNV = N'Quản Trị Viên', DiaChi = N'TP. Hồ Chí Minh' WHERE TaiKhoan = 'admin';
    UPDATE NhanVien SET TenNV = N'Nhân Viên Demo', DiaChi = N'TP. Hồ Chí Minh' WHERE TaiKhoan = 'nhanvien';
END;
GO

-- 7. Cập nhật Khách Hàng (KhachHang)
IF OBJECT_ID('KhachHang', 'U') IS NOT NULL
BEGIN
    UPDATE KhachHang SET TenKH = N'Khách Hàng Vãng Lai' WHERE MaKH = 1 OR TenKH LIKE '%V%ng%';
    UPDATE KhachHang SET TenKH = N'Nguyễn Văn A' WHERE MaKH = 2;
    UPDATE KhachHang SET TenKH = N'Trần Thị B' WHERE MaKH = 3;
END;
GO

PRINT N'=== Đã sửa toàn bộ lỗi Tiếng Việt cho Database QuanLyNhaSach thành công! ===';
