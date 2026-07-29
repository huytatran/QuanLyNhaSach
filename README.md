# 📚 Portal.BookStore — Quản Lý Nhà Sách

Hệ thống quản lý nhà sách offline, xây dựng bằng **Java Servlet + Hibernate + SQL Server**.

---

## 🛠️ Công nghệ sử dụng

| Thành phần | Công nghệ |
|-----------|-----------|
| Backend | Java 21, Jakarta Servlet 6.1 |
| ORM | Hibernate 6.6 |
| Database | Microsoft SQL Server |
| Frontend | JSP + JSTL + Bootstrap 5.3 |
| Build tool | Maven |
| Server | Apache Tomcat 10.1 |

---

## ⚙️ Cài đặt và chạy

### 1. Yêu cầu
- JDK 21
- Apache Tomcat 10.1
- SQL Server (local, port 1433)
- IntelliJ IDEA

### 2. Tạo database
Chạy file `docs/database_setup.sql` trong **SQL Server Management Studio**:
```sql
-- Tự động tạo database QuanLyNhaSach và toàn bộ 14 bảng
-- Tài khoản mặc định: admin/123456 và nhanvien/123456
```

### 3. Cấu hình kết nối
Chỉnh thông tin DB trong `src/main/java/utils/HibernateConfig.java`:
```java
properties.put("hibernate.connection.url",      "jdbc:sqlserver://localhost:1433;databaseName=QuanLyNhaSach;...");
properties.put("hibernate.connection.username", "sa");
properties.put("hibernate.connection.password", "123456");
```

### 4. Tạo thư mục lưu ảnh
```
D:\DoAn_NhomDuAn1\uploads\books\
```
> Ảnh bìa sách sẽ được lưu vào thư mục này khi upload.

### 5. Chạy với IntelliJ
- Mở project, cấu hình **Tomcat Run Configuration**
- Deployment: `QuanLyNhaSach:war exploded`
- Application context: `/`
- Nhấn **Run**

---

## 🔄 Luồng hoạt động

### Đăng nhập
```
Truy cập http://localhost:8080/
    ↓
Redirect → /login
    ↓
Nhập tài khoản / mật khẩu
    ↓
LoginServlet → NhanVienDAO.checkLogin()
    ↓
Thành công → lưu NhanVien vào Session → redirect /dashboard
Thất bại   → hiển thị lỗi
```

### Phân quyền
```
Mọi request đều đi qua AuthorizationFilter
    ↓
Chưa đăng nhập → redirect /login
    ↓
Đã đăng nhập:
  - VaiTroNV = 1 (Admin)   → truy cập được tất cả
  - VaiTroNV = 0 (NV)      → bị chặn /nhanvien và /baocao
```

### Bán hàng (POS)
```
Nhân viên vào /pos
    ↓
Xem danh sách sách (có ảnh bìa, giá, tồn kho)
    ↓
Nhấn 🛒 thêm vào giỏ → lưu vào Session (gioHang)
    ↓
Giỏ hàng hiện bên phải (có ảnh bìa từng cuốn)
    ↓
Chọn khách hàng + phương thức thanh toán
    ↓
Nhấn "Thanh toán" → DonHangDAO.taoDonHang()
    ↓
  1. Tạo bản ghi DonHang
  2. Tạo ChiTietDonHang cho từng đầu sách
  3. Cập nhật SachVatLy: "Có sẵn" → "Đã bán"
  4. Tính tổng tiền
    ↓
Xóa giỏ hàng → thông báo thành công
```

### Quản lý sách
```
GET  /sach              → danh sách (phân trang, tìm kiếm)
GET  /sach?action=new   → form thêm mới
GET  /sach?action=edit  → form sửa (kèm ảnh bìa hiện tại)
POST /sach (save)       → lưu vào DB + upload ảnh bìa
POST /sach (delete)     → ngừng kinh doanh (TrangThai = false)
POST /sach (toggleTrangThai) → bật/tắt trạng thái kinh doanh
```

### Upload ảnh bìa
```
Chọn file ảnh trong form sửa sách
    ↓
JavaScript preview ảnh ngay lập tức (FileReader)
    ↓
Submit form (multipart/form-data)
    ↓
SachServlet.xuLyUploadAnhBia()
    ↓
Lưu file → D:/DoAn_NhomDuAn1/uploads/books/{MaSach}.jpg
Lưu path → cột AnhBia trong DB: "book-images/{MaSach}.jpg"
    ↓
Hiển thị ảnh qua ImageServlet (@WebServlet("/book-images/*"))
    → Đọc file từ D:/DoAn_NhomDuAn1/uploads/books/
    → Trả về bytes ảnh cho browser
```

### Nhập kho
```
Từ trang Quản lý Sách → nhấn nút Nhập kho
    ↓
Nhập danh sách mã serial (mỗi dòng 1 serial)
    ↓
NhapKhoServlet → SachVatLyDAO.insertBatch()
    ↓
Mỗi serial = 1 bản ghi SachVatLy (TrangThai = "Có sẵn")
```

### Báo cáo doanh thu (Admin)
```
Chọn khoảng ngày from/to
    ↓
ThongKeDAO:
  - Tổng số đơn + tổng doanh thu
  - Doanh thu theo từng ngày (biểu đồ)
  - Top 10 sách bán chạy nhất
```

---

## 📁 Cấu trúc project

```
src/main/java/
├── controller/       Servlet xử lý request
│   ├── LoginServlet
│   ├── DashboardServlet
│   ├── SachServlet
│   ├── PosServlet
│   ├── DonHangServlet
│   ├── KhachHangServlet
│   ├── NhanVienServlet
│   ├── NhapKhoServlet
│   ├── VoucherServlet
│   ├── BaoCaoServlet
│   ├── DanhGiaServlet
│   ├── FeaturePreviewServlet
│   └── ImageServlet  ← serve ảnh bìa
├── dao/              Truy vấn database qua Hibernate
├── entity/           Mapping Java ↔ SQL (14 bảng)
├── filter/           AuthorizationFilter (phân quyền)
├── repository/       VoucherRepo, DanhGiaRepo
└── utils/            HibernateConfig

src/main/webapp/
├── view/             JSP pages
│   ├── common/       sidebar.jsp, topbar.jsp
│   ├── dashboard.jsp
│   ├── pos.jsp
│   ├── sach.jsp / sach-form.jsp
│   ├── don-hang.jsp / don-hang-chi-tiet.jsp
│   ├── khachhang.jsp / khachhang-form.jsp
│   ├── nhanvien.jsp / nhanvien-form.jsp
│   ├── voucher.jsp
│   ├── danhgia.jsp
│   ├── baocao.jsp
│   └── nhap-kho.jsp
├── assets/images/    Logo
└── META-INF/
    └── context.xml   Cấu hình serve ảnh bìa

docs/
└── database_setup.sql  Script tạo database
```

---

## ✅ Chức năng đã hoàn chỉnh

| Module | Chức năng |
|--------|-----------|
| **Đăng nhập** | Login, logout, auto-logout sau 15 phút |
| **Phân quyền** | Admin/Nhân viên, filter theo role |
| **Dashboard** | Thống kê 4 chỉ số, đơn hàng gần đây |
| **Bán hàng (POS)** | Giỏ hàng, checkout, áp voucher, thêm KH nhanh |
| **Quản lý Sách** | CRUD, ảnh bìa, phân trang, tìm kiếm, toggle trạng thái, sắp xếp theo tồn kho |
| **Nhập kho** | Nhập serial hàng loạt |
| **Khách hàng** | CRUD, địa chỉ, toggle trạng thái |
| **Nhân viên** | CRUD (Admin only) |
| **Đơn hàng** | Xem danh sách, chi tiết, đổi/trả |
| **Voucher** | Tạo mới, phân trang, kết thúc sớm |
| **Phản hồi KH** | Xem danh sách, thêm mới |
| **Báo cáo** | Doanh thu, top sách bán chạy (Admin only) |
| **Thuộc tính sách** | CRUD Thể loại, Tác giả, NXB, Bộ sách |

---

## 🔧 Chức năng có nhưng chưa hoàn chỉnh

| Vấn đề | Mô tả |
|--------|-------|
| **Phản hồi KH — lỗi field** | Form gửi `binhLuan`/`diem` nhưng Servlet đọc `noiDung`/`soSao` → không lưu được |
| **Đơn hàng — thiếu tìm kiếm** | Không có lọc theo ngày/khách/trạng thái |
| **Báo cáo — chỉ có bảng số** | Chưa có biểu đồ doanh thu theo ngày |
| **Dashboard — thiếu doanh thu** | Chưa hiển thị doanh thu hôm nay |

---

## 💡 Chức năng có thể bổ sung

| Chức năng | Độ ưu tiên |
|-----------|-----------|
| Fix lỗi Phản hồi KH | 🔴 Cao |
| Tìm kiếm/lọc đơn hàng | 🟡 Trung bình |
| Biểu đồ doanh thu (Chart.js) | 🟡 Trung bình |
| In hóa đơn bán hàng | 🟡 Trung bình |
| Hủy đơn hàng | 🟡 Trung bình |
| Sửa voucher | 🟢 Thấp |
| Export báo cáo Excel | 🟢 Thấp |
| Kiểm kê kho (xem toàn bộ serial) | 🟢 Thấp |

---

## 🗃️ Sơ đồ bảng chính

```
TheLoai ──┐
TacGia ────┤
NhaXuatBan─┤
BoSach ────┴──► Sach ◄──── Sach_TacGia
                 │
                 ▼
            SachVatLy ◄──── ChiTietDonHang ◄──── DonHang
                                                     │
                                              KhachHang + NhanVien + Voucher
```

---

## 🔑 Tài khoản mặc định

| Tài khoản | Mật khẩu | Vai trò |
|-----------|----------|---------|
| `admin` | `123456` | Quản trị viên |
| `nhanvien` | `123456` | Nhân viên |

---

## 👤 Phân quyền

| Tính năng | Admin | Nhân viên |
|-----------|:-----:|:---------:|
| Dashboard | ✅ | ✅ |
| Bán hàng (POS) | ✅ | ✅ |
| Quản lý Sách | ✅ | ✅ |
| Đơn hàng | ✅ | ✅ |
| Khách hàng | ✅ | ✅ |
| Voucher | ✅ | ✅ |
| Phản hồi KH | ✅ | ✅ |
| Quản lý Nhân viên | ✅ | ❌ |
| Báo cáo doanh thu | ✅ | ❌ |

---

## 🔑 Tài khoản mặc định

| Tài khoản | Mật khẩu | Vai trò |
|-----------|----------|---------|
| `admin` | `123456` | Quản trị viên |
| `nhanvien` | `123456` | Nhân viên |
