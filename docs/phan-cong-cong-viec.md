# Phan cong cong viec du an QuanLyNhaSach

Tai lieu nay dung de team biet ro moi nguoi can lam module nao, nhanh Git nao can dung, va tieu chi de mot task duoc xem la hoan thanh.

## 1. Tong quan

- Du an: He thong Quan ly Nha Sach
- Cong nghe: Java Servlet/JSP, Hibernate, SQL Server, Maven
- Mo hinh: Presentation (JSP) -> Controller (Servlet) -> DAO (Hibernate)
- Hinh thuc ban hang: offline tai quay
- Nhanh chinh hien tai: `master`

Luu y: Khong them luong dat hang online, giao hang, van chuyen neu khong nam trong yeu cau do an. He thong tap trung vao ban hang tai quay.

## 2. Nguyen tac lam viec

- Khong code truc tiep tren `master`.
- Moi module tao nhanh rieng theo mau `feature/<ten-module>`.
- Truoc khi code, luon cap nhat code moi nhat:

```bash
git pull origin master
```

- Commit nho, ro noi dung, khong don ca tuan vao mot commit.
- Khi lam xong mot phan, tao Pull Request hoac bao lead review truoc khi merge.
- Khong goi DAO truc tiep tu JSP.
- Khong viet SQL hoac logic database trong Servlet neu da co DAO.

## 3. Bang phan cong

| Thanh vien | Module phu trach | Viec can lam | San pham ban giao | Nhanh Git |
|---|---|---|---|---|
| NV1 - [Dien ten] | Nhap kho sach | Tao `NhapKhoServlet`; tao form nhap so luong theo ma sach; moi lan nhap sinh ban ghi `SachVatLy` trang thai co san; luu lich su phieu nhap gom ngay nhap, nguoi nhap, so luong | Man hinh nhap kho hoat dong; POS ban duoc sach vua nhap | `feature/nhapkho` |
| NV2 - [Dien ten] | Khach hang | Tao `KhachHangServlet`; CRUD khach hang; quan ly `DiaChiKhachHang`; tim kiem khach theo ten hoac so dien thoai; tich hop chon khach trong POS | Man hinh quan ly khach hang; POS chon duoc khach that tu database | `feature/khachhang` |
| NV3 - [Dien ten] | Ban hang va don hang | Hoan thien `PosServlet`; xem lich su don hang theo khach/ngay; huy don hoac doi tra; khi huy don phai hoan trang thai `SachVatLy` ve co san; in hoa don tu `DonHang` va `ChiTietDonHang` neu kip | POS day du vong doi: tao don, xem don, huy/doi tra, in hoa don | `feature/donhang` |
| NV4 - [Dien ten] | Voucher va danh gia | Tao `VoucherServlet`; CRUD ma giam gia; xu ly dieu kien ap dung voucher; tich hop chon voucher trong POS; tao `DanhGiaServlet` neu con thoi gian | POS tinh dung so tien giam khi ap voucher; quan ly voucher dung tren database | `feature/voucher` |
| NV5 - [Dien ten] | Bao cao, nhan vien, ha tang chung | Hoan thien `BaoCaoServlet`; hoan thien `NhanVienServlet`; them doi mat khau tu phuc vu neu can; giu thong nhat `sidebar.jsp`, `topbar.jsp`; kiem tra `AuthorizationFilter` khi them route moi; ho tro review code | Bao cao doanh thu dung; phan quyen khong bi vo; layout thong nhat | `feature/baocao` |

## 4. Tien do de xuat

| Giai doan | Noi dung | Moc kiem tra |
|---|---|---|
| Tuan 1 | Moi nguoi tao khung Servlet, DAO, JSP cho module cua minh | Route moi truy cap duoc, chua can day du chuc nang |
| Tuan 2 | Hoan thien CRUD chinh: nhap kho, khach hang, voucher | Nhap kho xong thi POS ban duoc sach moi nhap |
| Tuan 3 | Tich hop module: khach hang vao POS, voucher vao POS, huy don hoan kho | Chay tron kich ban ban hang tu dau den cuoi |
| Tuan 4 | Test cheo, sua loi, viet bao cao, chuan bi slide va demo | Ban giao source code, bao cao, video demo |

## 5. Definition of Done

Mot task chi duoc xem la xong khi dat du cac muc sau:

- Chuc nang chay duoc tren du lieu that trong SQL Server.
- Khong lam hong cac module dang chay.
- Khong vang loi 500 khi nhap sai hoac bo trong du lieu co ban.
- Co commit ro rang tren Git.
- Co nguoi khac review truoc khi merge vao `master`.
- Giao dien co menu/duong dan phu hop voi layout chung.
- Ten class, ten servlet, ten nhanh Git dung theo quy uoc cua team.

## 6. Mau commit message

```text
feat: them man hinh nhap kho
fix: sua loi huy don khong hoan kho
refactor: tach logic tinh tong tien don hang
docs: cap nhat phan cong cong viec
```

## 7. Viec can cap nhat sau

- Dien ten that cua tung thanh vien.
- Cap nhat trang thai tung module: chua lam, dang lam, da xong, can sua.
- Bo sung deadline cu the neu giang vien yeu cau.
- Cap nhat lai tai lieu nay moi khi team thay doi phan cong.
