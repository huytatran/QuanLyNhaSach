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

### 4. Tạo thư mục lưu ảnh bìa
```
D:\DoAn_NhomDuAn1\uploads\books\
```
> Ảnh bìa sách upload từ máy sẽ được lưu vào đây. Nếu dùng URL ảnh internet thì không cần.

### 5. Chạy với IntelliJ
- Mở project → cấu hình **Tomcat Run Configuration**
- Deployment: `QuanLyNhaSach:war exploded`
- Application context: `/`
- Nhấn **Run** → truy cập `http://localhost:8080/`

---

## 🔑 Tài khoản mặc định

| Tài khoản | Mật khẩu | Vai trò |
|-----------|----------|---------|
| `admin` | `123456` | Quản trị viên (toàn quyền) |
| `nhanvien` | `123456` | Nhân viên thường |

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
| Thuộc tính sách | ✅ | ✅ |
| Quản lý Nhân viên | ✅ | ❌ |
| Báo cáo doanh thu | ✅ | ❌ |

> Phân quyền được xử lý bởi `AuthorizationFilter.java` — chặn `/nhanvien` và `/baocao` với nhân viên thường.

---

## ✅ Chức năng đã hoàn chỉnh

### 1. Đăng nhập & Bảo mật
- **File:** `LoginServlet.java`, `AuthorizationFilter.java`
- Login bằng tài khoản/mật khẩu nhân viên
- Lưu thông tin vào Session sau đăng nhập
- Auto-logout sau **15 phút** không hoạt động
- Filter kiểm tra session mọi request, redirect về `/login` nếu chưa đăng nhập

### 2. Dashboard
- **File:** `DashboardServlet.java`, `ThongKeDAO.java`, `dashboard.jsp`
- Hiển thị 4 KPI: đơn hôm nay, tồn kho, đầu sách, số nhân viên
- Bảng 8 đơn hàng gần nhất

### 3. Bán hàng (POS)
- **File:** `PosServlet.java`, `DonHangDAO.java`, `pos.jsp`
- Tìm kiếm sách đang kinh doanh
- Thêm/xóa/cập nhật số lượng trong giỏ hàng (lưu trong Session)
- Hiển thị ảnh bìa trong giỏ hàng
- Áp dụng voucher giảm giá
- Thêm khách hàng mới nhanh không rời trang (AJAX)
- Thanh toán: Tiền mặt / Chuyển khoản / Thẻ
- Khi thanh toán: tạo DonHang → tạo ChiTietDonHang → cập nhật SachVatLy "Có sẵn" → "Đã bán"

### 4. Quản lý Sách
- **File:** `SachServlet.java`, `SachDAO.java`, `sach.jsp`, `sach-form.jsp`
- CRUD đầy đủ: thêm, sửa, ngừng kinh doanh (xóa mềm)
- Toggle trạng thái kinh doanh bằng switch
- Tìm kiếm theo mã/tên sách + phân trang
- Sắp xếp: sách còn hàng lên trên, hết hàng xuống dưới
- Upload ảnh bìa từ máy hoặc dán URL ảnh internet
- Gán: Tác giả, Thể loại, NXB, Bộ sách

### 5. Nhập kho
- **File:** `NhapKhoServlet.java`, `SachVatLyDAO.java`, `nhap-kho.jsp`
- Nhập modal ngay trên trang Quản lý Sách
- Nhập danh sách mã serial (mỗi dòng 1 serial, hoặc cách nhau bằng dấu phẩy)
- Mỗi serial = 1 bản ghi `SachVatLy` với trạng thái "Có sẵn"
- Bỏ qua serial trùng, không báo lỗi

### 6. Thuộc tính sách (Danh mục)
- **File:** `DanhMucServlet.java`, `danhmuc.jsp`
- 4 tab: **Thể loại**, **Tác giả**, **Nhà xuất bản**, **Bộ sách/Series**
- Mỗi tab: xem danh sách + số sách đang dùng + thêm/sửa (modal inline) + xóa (chặn nếu có sách đang dùng)

### 7. Đơn hàng
- **File:** `DonHangServlet.java`, `DonHangDAO.java`, `don-hang.jsp`, `don-hang-chi-tiet.jsp`
- Xem danh sách tất cả đơn hàng
- Xem chi tiết từng đơn: sách, số lượng, giá
- Đổi/trả đơn: cập nhật trạng thái → hoàn lại tồn kho SachVatLy

### 8. Quản lý Khách hàng
- **File:** `KhachHangServlet.java`, `KhachHangDAO.java`, `khachhang.jsp`, `khachhang-form.jsp`
- CRUD: thêm, sửa, ngừng hoạt động (xóa mềm)
- Quản lý nhiều địa chỉ cho 1 khách, đặt địa chỉ mặc định
- Toggle trạng thái hoạt động

### 9. Quản lý Nhân viên *(Admin only)*
- **File:** `NhanVienServlet.java`, `NhanVienDAO.java`, `nhanvien.jsp`, `nhanvien-form.jsp`
- CRUD: thêm, sửa, xóa (chặn nếu đã có đơn hàng)
- Phân vai trò: Admin (1) / Nhân viên (0)
- Không thể xóa tài khoản đang đăng nhập

### 10. Voucher giảm giá
- **File:** `VoucherServlet.java`, `VoucherRepo.java`, `voucher.jsp`
- Tạo voucher: giảm % hoặc giảm tiền mặt, điều kiện đơn tối thiểu, giảm tối đa, thời hạn, số lượt
- Xóa mềm: chuyển trạng thái hết hạn
- Tích hợp vào POS: chọn voucher → tính tiền giảm → tăng lượt sử dụng khi thanh toán

### 11. Phản hồi khách hàng
- **File:** `DanhGiaServlet.java`, `DanhGiaRepo.java`, `danhgia.jsp`
- Xem danh sách phản hồi
- Thêm phản hồi mới: chọn khách, chọn sách, số sao, nội dung

### 12. Báo cáo doanh thu *(Admin only)*
- **File:** `BaoCaoServlet.java`, `ThongKeDAO.java`, `baocao.jsp`
- Chọn khoảng ngày tùy chỉnh
- Tổng số đơn + tổng doanh thu
- Bảng doanh thu theo từng ngày
- Top 10 sách bán chạy nhất

---

## 🔧 Chức năng có nhưng chưa hoàn chỉnh

| Vấn đề | File liên quan | Cách fix |
|--------|---------------|----------|
| **Phản hồi KH — lỗi field name** | `danhgia.jsp` gửi `binhLuan`/`diem`, `DanhGiaServlet` đọc `noiDung`/`soSao` | Sửa tên `name=""` trong JSP cho khớp |
| **Đơn hàng — thiếu tìm kiếm/lọc** | `DonHangServlet.java`, `don-hang.jsp` | Thêm filter theo ngày/KH/trạng thái |
| **Báo cáo — chỉ có bảng số** | `baocao.jsp` | Thêm Chart.js để vẽ biểu đồ |
| **Dashboard — thiếu doanh thu** | `ThongKeDAO.java`, `dashboard.jsp` | Thêm method `doanhThuHomNay()` |

---

## 💡 Chức năng có thể bổ sung thêm

| Chức năng | Độ ưu tiên | File cần tạo/sửa |
|-----------|:----------:|------------------|
| Fix lỗi Phản hồi KH | 🔴 Cao | `danhgia.jsp` |
| Biểu đồ doanh thu (Chart.js) | 🟡 Trung bình | `baocao.jsp` |
| Tìm kiếm/lọc đơn hàng | 🟡 Trung bình | `DonHangServlet`, `DonHangDAO`, `don-hang.jsp` |
| In hóa đơn bán hàng | 🟡 Trung bình | `don-hang-chi-tiet.jsp` (thêm nút print) |
| Hủy đơn hàng | 🟡 Trung bình | `DonHangServlet`, `DonHangDAO` |
| Doanh thu hôm nay trên Dashboard | 🟡 Trung bình | `ThongKeDAO`, `DashboardServlet`, `dashboard.jsp` |
| Sửa voucher | 🟢 Thấp | `VoucherServlet`, `VoucherRepo`, `voucher.jsp` |
| Export báo cáo Excel/PDF | 🟢 Thấp | `BaoCaoServlet` + thư viện Apache POI |
| Biến thể sách (Loại bìa, Số trang, Ngôn ngữ) | 🟢 Thấp | Thêm cột `Sach` + sửa `Sach.java` + `sach-form.jsp` |
| Kiểm kê kho | 🟢 Thấp | Servlet + DAO + JSP mới |

---

## 🔄 Luồng hoạt động chi tiết

### Đăng nhập
```
Truy cập http://localhost:8080/
    ↓ (index.jsp redirect)
/login → LoginServlet.doGet() → login.jsp
    ↓ (submit form)
LoginServlet.doPost()
    → NhanVienDAO.checkLogin(taiKhoan, matKhau)
    → Thành công: lưu NhanVien vào Session → redirect /dashboard
    → Thất bại: hiển thị lỗi trên login.jsp
```

### Phân quyền (mọi request)
```
Browser gửi request
    ↓
AuthorizationFilter.doFilter()
    → Chưa đăng nhập: redirect /login
    → Đã đăng nhập + là Admin: cho qua tất cả
    → Đã đăng nhập + là NV thường + truy cập /nhanvien hoặc /baocao:
        → redirect /dashboard?error=permission-denied
    → Còn lại: cho qua
```

### Bán hàng (POS)
```
/pos → PosServlet.doGet()
    → SachDAO.getAllDangBan() (chỉ sách TrangThai=true)
    → SachDAO.getTonKhoMap() (đếm SachVatLy còn "Có sẵn")
    → VoucherRepo.getVouchersHopLe() (voucher còn hiệu lực)
    → pos.jsp

[Thêm vào giỏ] POST action=add
    → Kiểm tra tồn kho → gioHang trong Session += 1

[Áp voucher] POST action=applyVoucher
    → Lưu maVoucherApDung vào Session
    → Tính soTienGiam = VoucherRepo.tinhTienGiamGia()

[Thanh toán] POST action=checkout
    → DonHangDAO.taoDonHang():
        1. INSERT DonHang
        2. Với mỗi sách: INSERT ChiTietDonHang
        3. UPDATE SachVatLy SET TrangThai='Đã bán' WHERE MaSach=? LIMIT soLuong
        4. UPDATE DonHang SET TongTien=sum
    → VoucherRepo.tangLuotSuDung() nếu có voucher
    → Xóa gioHang + maVoucherApDung khỏi Session
```

### Quản lý sách
```
GET /sach → SachServlet.doGet()
    → SachDAO.getAll(trang, size) — native SQL ORDER BY tồn kho DESC
    → SachDAO.getTonKhoMap()
    → sach.jsp (bảng danh sách)

GET /sach?action=new → sach-form.jsp (form trống)
GET /sach?action=edit&ma=X → sach-form.jsp (form có dữ liệu)

POST /sach (action=save)
    → SachServlet.xuLyLuu()
    → xuLyUploadAnhBia(): lưu file vào D:/uploads/books/ HOẶC lấy URL từ hidden field
    → SachDAO.insert() hoặc SachDAO.update()

POST /sach (action=toggleTrangThai)
    → SachDAO.doiTrangThai() — đảo Boolean TrangThai
```

### Upload ảnh bìa
```
Form sach-form.jsp:
    ① Choose File → input[name=anhBiaFile] (multipart)
    ② Dán URL    → input[name=anhBia] (text/hidden)

Submit → SachServlet.xuLyUploadAnhBia():
    - Nếu có file: lưu vào D:/DoAn_NhomDuAn1/uploads/books/{MaSach}.jpg
                   return "book-images/{MaSach}.jpg" → lưu vào DB
    - Nếu không có file: đọc request.getParameter("anhBia") → lưu URL vào DB

Hiển thị ảnh:
    <img src="${s.anhBia}">
    → Nếu là "book-images/S001.jpg": ImageServlet đọc file từ D:/uploads/books/
    → Nếu là "https://...": browser tải thẳng từ internet
```

### Nhập kho
```
Trang sach.jsp → nhấn nút 📦 → modal nhập serial
    ↓
POST /nhap-kho
    → NhapKhoServlet.doPost()
    → Tách chuỗi serial theo dòng/dấu phẩy
    → SachVatLyDAO.insertBatch(list):
        - session.get(SachVatLy, serial) != null → bỏ qua (trùng)
        - session.persist(SachVatLy{serial, sach, "Có sẵn"})
```

### Đổi/trả đơn hàng
```
Trang don-hang-chi-tiet.jsp → nhấn "Đổi/Trả"
    ↓
POST /don-hang (action=return)
    → DonHangDAO.traDonHang(maDH):
        1. UPDATE DonHang SET TrangThai=2 (đã trả)
        2. UPDATE SachVatLy SET TrangThai='Có sẵn', MaCTDH=null
           WHERE MaCTDH IN (SELECT MaCTDH FROM ChiTietDonHang WHERE MaDH=?)
```

---

## 📁 Cấu trúc project

```
src/main/java/
├── controller/       Servlet xử lý HTTP request
│   ├── LoginServlet           /login
│   ├── DashboardServlet       /dashboard
│   ├── SachServlet            /sach
│   ├── PosServlet             /pos
│   ├── DonHangServlet         /don-hang
│   ├── KhachHangServlet       /khachhang
│   ├── NhanVienServlet        /nhanvien
│   ├── NhapKhoServlet         /nhap-kho
│   ├── DanhMucServlet         /danhmuc
│   ├── VoucherServlet         /voucher/*
│   ├── BaoCaoServlet          /baocao
│   ├── DanhGiaServlet         /danhgia/*
│   ├── FeaturePreviewServlet  /donhang (placeholder)
│   └── ImageServlet           /book-images/* (serve ảnh bìa)
├── dao/              Truy vấn DB qua Hibernate Session
├── entity/           14 class ánh xạ sang bảng SQL
├── filter/           AuthorizationFilter
├── repository/       VoucherRepo, DanhGiaRepo
└── utils/            HibernateConfig (cấu hình kết nối DB)

src/main/webapp/
├── view/
│   ├── common/sidebar.jsp, topbar.jsp
│   ├── dashboard.jsp, login.jsp
│   ├── pos.jsp
│   ├── sach.jsp, sach-form.jsp, nhap-kho.jsp
│   ├── don-hang.jsp, don-hang-chi-tiet.jsp
│   ├── khachhang.jsp, khachhang-form.jsp
│   ├── nhanvien.jsp, nhanvien-form.jsp
│   ├── voucher.jsp, danhgia.jsp
│   ├── baocao.jsp, danhmuc.jsp
│   └── feature-preview.jsp
├── assets/images/    Logo SVG
└── META-INF/context.xml   Map /book-images/ → D:/uploads/books/

docs/
└── database_setup.sql
```

---

## 🗃️ Sơ đồ quan hệ bảng

```
TheLoai ──┐
TacGia ────┤
NhaXuatBan─┤
BoSach ────┴──► Sach ◄──── Sach_TacGia (MaSach + MaTG)
                 │
                 ▼
            SachVatLy (từng cuốn vật lý có serial)
                 │ MaCTDH (FK, nullable)
                 ▼
            ChiTietDonHang ◄──── DonHang
                                    │
                         KhachHang + NhanVien + Voucher

KhachHang ──► DiaChiKhachHang (nhiều địa chỉ)
KhachHang ──► DanhGia (phản hồi sách)
```
