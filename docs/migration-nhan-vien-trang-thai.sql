/*
  Bo sung trang thai lam viec cho nhan vien.
  Cac ban ghi cu mac dinh dang hoat dong (1).
*/
IF COL_LENGTH('dbo.NhanVien', 'TrangThai') IS NULL
BEGIN
    ALTER TABLE dbo.NhanVien
        ADD TrangThai BIT NOT NULL
            CONSTRAINT DF_NhanVien_TrangThai DEFAULT (1);
END;
