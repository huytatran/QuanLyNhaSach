package dao;

import entity.*;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class DonHangDAO {

    public static final int TRANG_THAI_DA_GIAO = 1;
    public static final int TRANG_THAI_DA_TRA = 2;

    private static final String CO_SAN = "Có sẵn";
    private static final String DA_BAN = "Đã bán";

    // Lay danh sach tat ca don hang de hien thi o trang quan ly
    public List<DonHang> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                            "SELECT DISTINCT dh FROM DonHang dh " +
                                    "LEFT JOIN FETCH dh.khachHang " +
                                    "LEFT JOIN FETCH dh.nhanVien " +
                                    "ORDER BY dh.ngayLap DESC", DonHang.class)
                    .getResultList();
        }
    }

    /** Moi: ban co phan trang cho trang danh sach don hang. Trang bat dau tu 1. */
    public List<DonHang> getAll(int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                            "SELECT DISTINCT dh FROM DonHang dh " +
                                    "LEFT JOIN FETCH dh.khachHang " +
                                    "LEFT JOIN FETCH dh.nhanVien " +
                                    "ORDER BY dh.ngayLap DESC", DonHang.class)
                    .setFirstResult((trang - 1) * soDongMoiTrang)
                    .setMaxResults(soDongMoiTrang)
                    .getResultList();
        }
    }

    /** Moi: tong so don hang, dung de tinh so trang. */
    public long countAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long c = session.createQuery("SELECT COUNT(dh) FROM DonHang dh", Long.class).uniqueResult();
            return c == null ? 0 : c;
        }
    }

    /** Moi: danh sach don hang co loc theo khoang ngay lap, ma don va ten khach hang, thay cho o tim kiem khong hoat dong. */
    public List<DonHang> getAll(int trang, int soDongMoiTrang, java.time.LocalDate tuNgay,
                                java.time.LocalDate denNgay, Integer maDon, String tenKH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            var q = session.createQuery(buildHqlDonHang(tuNgay, denNgay, maDon, tenKH, false), DonHang.class);
            ganThamSoLoc(q, tuNgay, denNgay, maDon, tenKH);
            return q.setFirstResult((trang - 1) * soDongMoiTrang)
                    .setMaxResults(soDongMoiTrang)
                    .getResultList();
        }
    }

    /** Moi: dem so don hang theo bo loc - dung de tinh phan trang khi loc. */
    public long countAll(java.time.LocalDate tuNgay, java.time.LocalDate denNgay, Integer maDon, String tenKH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            var q = session.createQuery(buildHqlDonHang(tuNgay, denNgay, maDon, tenKH, true), Long.class);
            ganThamSoLoc(q, tuNgay, denNgay, maDon, tenKH);
            Long c = q.uniqueResult();
            return c == null ? 0 : c;
        }
    }

    /** Moi: toan bo danh sach don hang theo bo loc, khong phan trang - dung de xuat Excel. */
    public List<DonHang> getAllKhongPhanTrang(java.time.LocalDate tuNgay, java.time.LocalDate denNgay, Integer maDon, String tenKH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            var q = session.createQuery(buildHqlDonHang(tuNgay, denNgay, maDon, tenKH, false), DonHang.class);
            ganThamSoLoc(q, tuNgay, denNgay, maDon, tenKH);
            return q.getResultList();
        }
    }

    private String buildHqlDonHang(java.time.LocalDate tuNgay, java.time.LocalDate denNgay, Integer maDon, String tenKH, boolean dem) {
        StringBuilder hql = new StringBuilder(dem
                ? "SELECT COUNT(dh) FROM DonHang dh LEFT JOIN dh.khachHang kh "
                : "SELECT DISTINCT dh FROM DonHang dh LEFT JOIN FETCH dh.khachHang kh LEFT JOIN FETCH dh.nhanVien ");
        hql.append("WHERE 1=1 ");
        if (tuNgay != null) hql.append("AND dh.ngayLap >= :tuNgay ");
        if (denNgay != null) hql.append("AND dh.ngayLap < :denNgay ");
        if (maDon != null) hql.append("AND dh.maDH = :maDon ");
        if (tenKH != null && !tenKH.isBlank()) hql.append("AND LOWER(kh.tenKH) LIKE :tenKH ");
        if (!dem) hql.append("ORDER BY dh.ngayLap DESC");
        return hql.toString();
    }

    /** Đơn đã giao (trangThai=1) còn cuốn chưa trả — dùng cho tab Đổi/Trả. */
    public List<DonHang> getAllCoTheDoiTra(int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            // Lấy maDH của các đơn còn SachVatLy trạng thái 'Đã bán'
            List<Integer> maDHList = session.createQuery(
                            "SELECT DISTINCT sv.chiTietDonHang.donHang.maDH FROM SachVatLy sv " +
                                    "WHERE UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))",
                            Integer.class)
                    .setParameter("tt", DA_BAN)
                    .getResultList();

            if (maDHList.isEmpty()) return java.util.Collections.emptyList();

            return session.createQuery(
                            "SELECT DISTINCT dh FROM DonHang dh " +
                                    "LEFT JOIN FETCH dh.khachHang " +
                                    "LEFT JOIN FETCH dh.nhanVien " +
                                    "WHERE dh.maDH IN :ids AND dh.trangThai = :tt " +
                                    "ORDER BY dh.ngayLap DESC", DonHang.class)
                    .setParameter("ids", maDHList)
                    .setParameter("tt", TRANG_THAI_DA_GIAO)
                    .setFirstResult((trang - 1) * soDongMoiTrang)
                    .setMaxResults(soDongMoiTrang)
                    .getResultList();
        }
    }

    /** Đếm số đơn có thể đổi/trả — dùng để tính phân trang. */
    public long countCoTheDoiTra() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long c = session.createQuery(
                            "SELECT COUNT(DISTINCT sv.chiTietDonHang.donHang.maDH) FROM SachVatLy sv " +
                                    "WHERE UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt)) AND sv.chiTietDonHang.donHang.trangThai = :trangThai",
                            Long.class)
                    .setParameter("tt", DA_BAN)
                    .setParameter("trangThai", TRANG_THAI_DA_GIAO)
                    .uniqueResult();
            return c == null ? 0 : c;
        }
    }

    /** Moi: ban co loc theo ngay lap, ma don va ten khach hang, dung cho tab Doi/Tra. */
    public List<DonHang> getAllCoTheDoiTra(int trang, int soDongMoiTrang, java.time.LocalDate tuNgay,
                                           java.time.LocalDate denNgay, Integer maDon, String tenKH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<Integer> maDHList = session.createQuery(
                            "SELECT DISTINCT sv.chiTietDonHang.donHang.maDH FROM SachVatLy sv " +
                                    "WHERE UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))",
                            Integer.class)
                    .setParameter("tt", DA_BAN)
                    .getResultList();
            if (maDHList.isEmpty()) return java.util.Collections.emptyList();

            var q = session.createQuery(buildHqlCoTheDoiTra(tuNgay, denNgay, maDon, tenKH, false), DonHang.class)
                    .setParameter("ids", maDHList)
                    .setParameter("tt", TRANG_THAI_DA_GIAO);
            ganThamSoLoc(q, tuNgay, denNgay, maDon, tenKH);
            return q.setFirstResult((trang - 1) * soDongMoiTrang)
                    .setMaxResults(soDongMoiTrang)
                    .getResultList();
        }
    }

    /** Moi: dem so don co the doi/tra co ap dung loc - dung de tinh phan trang khi loc. */
    public long countCoTheDoiTra(java.time.LocalDate tuNgay, java.time.LocalDate denNgay, Integer maDon, String tenKH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<Integer> maDHList = session.createQuery(
                            "SELECT DISTINCT sv.chiTietDonHang.donHang.maDH FROM SachVatLy sv " +
                                    "WHERE UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))",
                            Integer.class)
                    .setParameter("tt", DA_BAN)
                    .getResultList();
            if (maDHList.isEmpty()) return 0;

            var q = session.createQuery(
                            buildHqlCoTheDoiTra(tuNgay, denNgay, maDon, tenKH, true), Long.class)
                    .setParameter("ids", maDHList)
                    .setParameter("tt", TRANG_THAI_DA_GIAO);
            ganThamSoLoc(q, tuNgay, denNgay, maDon, tenKH);
            Long c = q.uniqueResult();
            return c == null ? 0 : c;
        }
    }

    /** Moi: toan bo danh sach don co the doi/tra theo bo loc, khong phan trang - dung de xuat Excel. */
    public List<DonHang> getAllCoTheDoiTraKhongPhanTrang(java.time.LocalDate tuNgay, java.time.LocalDate denNgay, Integer maDon, String tenKH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<Integer> maDHList = session.createQuery(
                            "SELECT DISTINCT sv.chiTietDonHang.donHang.maDH FROM SachVatLy sv " +
                                    "WHERE UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))",
                            Integer.class)
                    .setParameter("tt", DA_BAN)
                    .getResultList();
            if (maDHList.isEmpty()) return java.util.Collections.emptyList();

            var q = session.createQuery(buildHqlCoTheDoiTra(tuNgay, denNgay, maDon, tenKH, false), DonHang.class)
                    .setParameter("ids", maDHList)
                    .setParameter("tt", TRANG_THAI_DA_GIAO);
            ganThamSoLoc(q, tuNgay, denNgay, maDon, tenKH);
            return q.getResultList();
        }
    }

    private String buildHqlCoTheDoiTra(java.time.LocalDate tuNgay, java.time.LocalDate denNgay, Integer maDon, String tenKH, boolean dem) {
        StringBuilder hql = new StringBuilder(dem
                ? "SELECT COUNT(DISTINCT dh) FROM DonHang dh LEFT JOIN dh.khachHang kh "
                : "SELECT DISTINCT dh FROM DonHang dh LEFT JOIN FETCH dh.khachHang kh LEFT JOIN FETCH dh.nhanVien ");
        hql.append("WHERE dh.maDH IN :ids AND dh.trangThai = :tt ");
        if (tuNgay != null) hql.append("AND dh.ngayLap >= :tuNgay ");
        if (denNgay != null) hql.append("AND dh.ngayLap < :denNgay ");
        if (maDon != null) hql.append("AND dh.maDH = :maDon ");
        if (tenKH != null && !tenKH.isBlank()) hql.append("AND LOWER(kh.tenKH) LIKE :tenKH ");
        if (!dem) hql.append("ORDER BY dh.ngayLap DESC");
        return hql.toString();
    }

    private void ganThamSoLoc(org.hibernate.query.Query<?> q, java.time.LocalDate tuNgay,
                              java.time.LocalDate denNgay, Integer maDon, String tenKH) {
        if (tuNgay != null) q.setParameter("tuNgay", tuNgay.atStartOfDay());
        if (denNgay != null) q.setParameter("denNgay", denNgay.plusDays(1).atStartOfDay());
        if (maDon != null) q.setParameter("maDon", maDon);
        if (tenKH != null && !tenKH.isBlank()) q.setParameter("tenKH", "%" + tenKH.trim().toLowerCase() + "%");
    }

    /** Lấy các đơn đã đổi/trả hoàn tất (trangThai = 2). */
    public List<DonHang> getAllDaDoiTra() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                            "SELECT DISTINCT dh FROM DonHang dh " +
                                    "LEFT JOIN FETCH dh.khachHang " +
                                    "LEFT JOIN FETCH dh.nhanVien " +
                                    "WHERE dh.trangThai = :tt " +
                                    "ORDER BY dh.ngayLap DESC", DonHang.class)
                    .setParameter("tt", TRANG_THAI_DA_TRA)
                    .getResultList();
        }
    }

    // Lay chi tiet mot don hang kem theo danh sach cac san pham (chi tiet don hang)
    public DonHang getById(Integer maDH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                            "SELECT dh FROM DonHang dh " +
                                    "LEFT JOIN FETCH dh.khachHang " +
                                    "LEFT JOIN FETCH dh.nhanVien " +
                                    "LEFT JOIN FETCH dh.chiTietDonHangs ct " +
                                    "LEFT JOIN FETCH ct.sach " +
                                    "WHERE dh.maDH = :ma", DonHang.class)
                    .setParameter("ma", maDH)
                    .uniqueResult();
        }
    }

    /**
     * Tạo đơn hàng từ giỏ hàng có biến thể (CartItem).
     * Mỗi CartItem mang maBienThe (null/0 = không có biến thể, dùng giá sach.giaBan).
     * @return maDH vừa tạo
     */
    public int taoDonHangBienThe(Integer maKH, Integer maNV, String phuongThuc,
                                 java.util.List<entity.CartItem> items,
                                 java.math.BigDecimal soTienGiam) {
        if (items == null || items.isEmpty()) {
            throw new IllegalArgumentException("Giỏ hàng trống.");
        }
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();

            KhachHang kh = session.get(KhachHang.class, maKH);
            NhanVien  nv = session.get(NhanVien.class, maNV);
            if (kh == null) throw new IllegalArgumentException("Không tìm thấy khách hàng.");
            if (nv == null) throw new IllegalArgumentException("Không tìm thấy nhân viên.");

            DonHang dh = new DonHang();
            dh.setNgayLap(java.time.LocalDateTime.now());
            dh.setTongTien(BigDecimal.ZERO);
            dh.setTrangThai(TRANG_THAI_DA_GIAO);
            dh.setPhuongThucThanhToan(phuongThuc);
            dh.setKhachHang(kh);
            dh.setNhanVien(nv);
            dh.setSoTienGiam(soTienGiam == null ? BigDecimal.ZERO : soTienGiam);
            session.persist(dh);
            session.flush();

            BigDecimal tong = BigDecimal.ZERO;

            for (entity.CartItem item : items) {
                int soLuong = item.getSoLuong();
                if (soLuong <= 0) continue;

                Sach sach = session.get(Sach.class, item.getMaSach());
                if (sach == null) throw new IllegalArgumentException("Không tìm thấy sách " + item.getMaSach());

                // Giá lấy từ CartItem (snapshot lúc thêm vào giỏ)
                BigDecimal donGia = item.getDonGia() != null ? item.getDonGia() : BigDecimal.ZERO;

                // Lấy SachVatLy còn trong kho
                java.util.List<SachVatLy> cuonCoSan = session.createQuery(
                                "FROM SachVatLy sv WHERE sv.sach.maSach = :ma AND UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))",
                                SachVatLy.class)
                        .setParameter("ma", item.getMaSach())
                        .setParameter("tt", CO_SAN)
                        .setMaxResults(soLuong)
                        .getResultList();

                if (cuonCoSan.size() < soLuong) {
                    throw new IllegalArgumentException(
                            "Sách \"" + sach.getTenSach() + "\" chỉ còn " + cuonCoSan.size() + " cuốn.");
                }

                ChiTietDonHang ct = new ChiTietDonHang();
                ct.setDonHang(dh);
                ct.setSach(sach);
                ct.setSoLuong(soLuong);
                ct.setDonGia(donGia);
                // Ghi lại biến thể đã bán để xem lại lịch sử đơn hàng
                if (item.getMaBienThe() != null && item.getMaBienThe() > 0) {
                    SachBienThe bt = session.get(entity.SachBienThe.class, item.getMaBienThe());
                    ct.setSachBienThe(bt);
                }
                session.persist(ct);
                session.flush();

                tong = tong.add(donGia.multiply(BigDecimal.valueOf(soLuong)));

                for (SachVatLy sv : cuonCoSan) {
                    sv.setTrangThai(DA_BAN);
                    sv.setChiTietDonHang(ct);
                    session.merge(sv);
                }
            }

            /*dh.setTongTien(tong);
            session.merge(dh);*/
            // Cap nhat tong tien thuc thu (Tong - Giam gia, khong am)
            BigDecimal tongThucThu = tong.subtract(soTienGiam == null ? BigDecimal.ZERO : soTienGiam).max(BigDecimal.ZERO);
            dh.setTongTien(tongThucThu);
            session.merge(dh);


            tx.commit();
            return dh.getMaDH();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Tao don ban hang POS:
     * 1. Tao ban ghi DonHang
     * 2. Voi moi mon hang: Tao ChiTietDonHang + Cap nhat tung cuon SachVatLy tu 'Có sẵn' sang 'Đã bán'
     * @param gioHang map maSach -> soLuong
     * @param soTienGiam tien giam tren don hang (co the = 0)
     * @return maDH vua tao
     */
    public int taoDonHang(Integer maKH, Integer maNV, String phuongThuc,
                          Map<String, Integer> gioHang, java.math.BigDecimal soTienGiam) {
        if (gioHang == null || gioHang.isEmpty()) {
            throw new IllegalArgumentException("Giỏ hàng trống.");
        }

        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();

            // Lay thong tin Khach hang va Nhan vien tu DB
            KhachHang kh = session.get(KhachHang.class, maKH);
            NhanVien nv = session.get(NhanVien.class, maNV);
            if (kh == null) throw new IllegalArgumentException("Không tìm thấy khách hàng.");
            if (nv == null) throw new IllegalArgumentException("Không tìm thấy nhân viên.");

            // Khoi tao doi tuong DonHang moi
            DonHang dh = new DonHang();
            dh.setNgayLap(LocalDateTime.now());
            dh.setTongTien(BigDecimal.ZERO);
            dh.setTrangThai(TRANG_THAI_DA_GIAO); // Mac dinh 1 la Da giao
            dh.setPhuongThucThanhToan(phuongThuc);
            dh.setKhachHang(kh);
            dh.setNhanVien(nv);
            // Lưu số tiền giảm được áp cho đơn (không để null)
            dh.setSoTienGiam(soTienGiam == null ? BigDecimal.ZERO : soTienGiam);
            session.persist(dh);
            session.flush(); // Day xuong DB de lay MaDH tu dong tang

            BigDecimal tong = BigDecimal.ZERO;

            // Duyet qua tung mat hang trong gio hang
            for (Map.Entry<String, Integer> entry : gioHang.entrySet()) {
                String maSach = entry.getKey();
                int soLuong = entry.getValue();
                if (soLuong <= 0) continue;

                Sach sach = session.get(Sach.class, maSach);
                if (sach == null) {
                    throw new IllegalArgumentException("Không tìm thấy sách " + maSach);
                }

                // Tim cac cuon sach vat ly con trong kho de ban
                List<SachVatLy> cuonCoSan = session.createQuery(
                                "FROM SachVatLy sv WHERE sv.sach.maSach = :ma AND UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))",
                                SachVatLy.class)
                        .setParameter("ma", maSach)
                        .setParameter("tt", CO_SAN)
                        .setMaxResults(soLuong)
                        .getResultList();

                if (cuonCoSan.size() < soLuong) {
                    throw new IllegalArgumentException(
                            "Sách \"" + sach.getTenSach() + "\" chỉ còn " + cuonCoSan.size() + " cuốn.");
                }

                // Tao chi tiet don hang cho dau sach nay
                ChiTietDonHang ct = new ChiTietDonHang();
                ct.setDonHang(dh);
                ct.setSach(sach);
                ct.setSoLuong(soLuong);
                ct.setDonGia(sach.getGiaBan() != null ? sach.getGiaBan() : BigDecimal.ZERO);
                session.persist(ct);
                session.flush();

                // Tinh luy ke tong tien don hang
                tong = tong.add(ct.getDonGia().multiply(BigDecimal.valueOf(soLuong)));

                // Gan tung cuon sach vat ly cu the vao chi tiet don hang va doi trang thai thanh 'Đã bán'
                for (SachVatLy sv : cuonCoSan) {
                    sv.setTrangThai(DA_BAN);
                    sv.setChiTietDonHang(ct);
                    session.merge(sv);
                }
            }

            // Cap nhat tong tien cuoi cung cho don hang
            dh.setTongTien(tong);
            session.merge(dh);

            tx.commit();
            return dh.getMaDH();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Moi: Tra mot phan (hoac toan bo) so luong cua MOT dong chi tiet don hang.
     * Khong dung cot/bang moi: "con lai co the tra" duoc suy ra bang cach dem
     * so cuon SachVatLy dang gan voi dong nay va con o trang thai 'Đã bán'
     * (ban dau, so cuon nay luon bang dung ct.soLuong tu luc tao don).
     */
    public void traMon(Integer maCTDH, int soLuongTra) {
        traMon(maCTDH, soLuongTra, null);
    }

    /** @param lyDo Không bắt buộc — có thể null/rỗng. */
    public void traMon(Integer maCTDH, int soLuongTra, String lyDo) {
        if (maCTDH == null || soLuongTra <= 0) {
            throw new IllegalArgumentException("Yêu cầu trả hàng không hợp lệ.");
        }

        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();

            ChiTietDonHang ct = session.get(ChiTietDonHang.class, maCTDH);
            if (ct == null) {
                throw new IllegalArgumentException("Không tìm thấy sản phẩm trong đơn hàng.");
            }

            List<SachVatLy> cuonDaBan = session.createQuery(
                            "FROM SachVatLy sv WHERE sv.chiTietDonHang.maCTDH = :ma AND UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))",
                            SachVatLy.class)
                    .setParameter("ma", maCTDH)
                    .setParameter("tt", DA_BAN)
                    .setMaxResults(soLuongTra)
                    .getResultList();
            if (cuonDaBan.size() < soLuongTra) {
                throw new IllegalArgumentException("Chỉ còn " + cuonDaBan.size() + " cuốn có thể trả cho món này.");
            }
            for (SachVatLy sv : cuonDaBan) {
                sv.setTrangThai(CO_SAN);
            }

            DonHang dh = ct.getDonHang();
            BigDecimal soTienHoan = ct.getDonGia().multiply(BigDecimal.valueOf(soLuongTra));
            dh.setTongTien(dh.getTongTien().subtract(soTienHoan));

            // Ghi lịch sử trả hàng
            LichSuDoiTra ls = new LichSuDoiTra();
            ls.setDonHang(dh);
            ls.setLoaiGiaoDich("TRA");
            ls.setNgayThucHien(LocalDateTime.now());
            ls.setChiTietCu(ct);
            ls.setSoLuongTra(soLuongTra);
            ls.setChenhLechTien(soTienHoan.negate()); // am = cua hang hoan lai cho khach
            ls.setLyDo(chuanHoaLyDo(lyDo));
            session.persist(ls);

            capNhatTrangThaiNeuDaTraHet(session, dh);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Moi: Doi mot phan (hoac toan bo) so luong cua MOT dong chi tiet don hang sang sach khac.
     * Cho phep doi sang sach co gia BANG, CAO HON hoac THAP HON gia dong hien tai (khach tra
     * them phan chenh lech neu gia cao hon, duoc hoan lai neu gia thap hon). Khong dung bang/cot moi:
     * tao them 1 dong ChiTietDonHang MOI cho sach da doi toi (dong ChiTietDonHang la du lieu
     * bth cua bang co san, khong phai thay doi cau truc). "Con lai" cua dong moi nay lai
     * duoc suy ra dung nhu tren, tu SachVatLy.
     */
    public void doiMon(Integer maCTDH, int soLuongDoi, String maSachMoi) {
        doiMon(maCTDH, soLuongDoi, maSachMoi, null);
    }

    /** @param lyDo Không bắt buộc — có thể null/rỗng. */
    public void doiMon(Integer maCTDH, int soLuongDoi, String maSachMoi, String lyDo) {
        if (maCTDH == null || soLuongDoi <= 0 || maSachMoi == null || maSachMoi.isBlank()) {
            throw new IllegalArgumentException("Yêu cầu đổi hàng không hợp lệ.");
        }

        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();

            ChiTietDonHang ct = session.get(ChiTietDonHang.class, maCTDH);
            if (ct == null) {
                throw new IllegalArgumentException("Không tìm thấy sản phẩm trong đơn hàng.");
            }
            if (maSachMoi.equals(ct.getSach().getMaSach())) {
                throw new IllegalArgumentException("Vui lòng chọn một cuốn sách khác để đổi.");
            }

            Sach sachMoi = session.get(Sach.class, maSachMoi);
            if (sachMoi == null) {
                throw new IllegalArgumentException("Không tìm thấy sách muốn đổi tới.");
            }

            BigDecimal giaCu = ct.getDonGia();
            // Gia moi >= gia cu: khach tra them chenh lech. Gia moi < gia cu: cua hang hoan
            // lai chenh lech cho khach (chenhLech tinh ben duoi se am, van dung DECIMAL(12,2)
            // nhu schema QuanLyNhaSach.sql khai bao cho DonGia/GiaBan/TongTien/ChenhLechTien).
            BigDecimal giaMoi = sachMoi.getGiaBan() != null ? sachMoi.getGiaBan() : BigDecimal.ZERO;

            // Sach moi phai con du hang trong kho
            List<SachVatLy> cuonSachMoi = session.createQuery(
                            "FROM SachVatLy sv WHERE sv.sach.maSach = :ma AND UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))",
                            SachVatLy.class)
                    .setParameter("ma", maSachMoi)
                    .setParameter("tt", CO_SAN)
                    .setMaxResults(soLuongDoi)
                    .getResultList();
            if (cuonSachMoi.size() < soLuongDoi) {
                throw new IllegalArgumentException(
                        "Sách \"" + sachMoi.getTenSach() + "\" chỉ còn " + cuonSachMoi.size() + " cuốn.");
            }

            // Hoan lai sach cu ve kho
            List<SachVatLy> cuonSachCu = session.createQuery(
                            "FROM SachVatLy sv WHERE sv.chiTietDonHang.maCTDH = :ma AND UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))",
                            SachVatLy.class)
                    .setParameter("ma", maCTDH)
                    .setParameter("tt", DA_BAN)
                    .setMaxResults(soLuongDoi)
                    .getResultList();
            if (cuonSachCu.size() < soLuongDoi) {
                throw new IllegalArgumentException("Chỉ còn " + cuonSachCu.size() + " cuốn có thể đổi cho món này.");
            }
            for (SachVatLy sv : cuonSachCu) {
                sv.setTrangThai(CO_SAN);
            }

            DonHang dh = ct.getDonHang();

            // Sua loi: doan code truoc day gia dinh bang ChiTietDonHang co UNIQUE(MaDH, MaSach)
            // roi dung uniqueResultOptional() de tim dong trung va GOP so luong vao - nhung
            // bang nay KHONG he co rang buoc UNIQUE do (kiem tra lai database_setup.sql va
            // migration-doi-tra.sql). Neu don hang co san >= 2 dong cung mot sach (hoan toan
            // hop le, vd khach mua/doi sach do nhieu lan truoc), uniqueResultOptional() nem
            // NonUniqueResultException -> bi catch chung thanh "Khong the thuc hien thao tac."
            // -> day chinh la nguyen nhan chinh khien nut "Doi" bi loi. Sua: luon tao dong
            // ChiTietDonHang MOI cho lan doi nay, khong gop vao dong co san nua.
            ChiTietDonHang ctMoi = new ChiTietDonHang();
            ctMoi.setDonHang(dh);
            ctMoi.setSach(sachMoi);
            ctMoi.setSoLuong(soLuongDoi);
            ctMoi.setDonGia(giaMoi);
            session.persist(ctMoi);
            session.flush();

            for (SachVatLy sv : cuonSachMoi) {
                sv.setTrangThai(DA_BAN);
                sv.setChiTietDonHang(ctMoi);
            }

            // Khach chi tra phan chenh lech (>= 0) vi da rang buoc gia moi >= gia cu
            BigDecimal chenhLech = giaMoi.subtract(giaCu).multiply(BigDecimal.valueOf(soLuongDoi));
            dh.setTongTien(dh.getTongTien().add(chenhLech));

            // Ghi lich su doi hang
            LichSuDoiTra ls = new LichSuDoiTra();
            ls.setDonHang(dh);
            ls.setLoaiGiaoDich("DOI");
            ls.setNgayThucHien(LocalDateTime.now());
            ls.setChiTietCu(ct);
            ls.setSoLuongTra(soLuongDoi);
            ls.setSachMoi(sachMoi);
            ls.setSoLuongMoi(soLuongDoi);
            ls.setChenhLechTien(chenhLech);
            ls.setLyDo(chuanHoaLyDo(lyDo));
            session.persist(ls);

            capNhatTrangThaiNeuDaTraHet(session, dh);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Moi: so luong CON LAI co the tra/doi cho tung dong ChiTietDonHang cua 1 don hang.
     * Suy ra tu du lieu SachVatLy hien co (dem so cuon dang gan voi dong do va con
     * trang thai 'Đã bán'), khong can them cot luu rieng.
     */
    public Map<Integer, Long> getSoLuongConLaiTheoDon(Integer maDH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<Object[]> rows = session.createQuery(
                            "SELECT sv.chiTietDonHang.maCTDH, COUNT(sv) FROM SachVatLy sv " +
                                    "WHERE sv.chiTietDonHang.donHang.maDH = :ma AND UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt)) " +
                                    "GROUP BY sv.chiTietDonHang.maCTDH",
                            Object[].class)
                    .setParameter("ma", maDH)
                    .setParameter("tt", DA_BAN)
                    .getResultList();
            java.util.Map<Integer, Long> map = new java.util.HashMap<>();
            for (Object[] row : rows) {
                map.put((Integer) row[0], (Long) row[1]);
            }
            return map;
        }
    }

    /** Lich su doi/tra cua MOT don hang cu the - dung cho trang chi tiet don hang. */
    public List<LichSuDoiTra> getLichSuDoiTraTheoDon(Integer maDH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                            "SELECT ls FROM LichSuDoiTra ls " +
                                    "LEFT JOIN FETCH ls.chiTietCu ct " +
                                    "LEFT JOIN FETCH ct.sach " +
                                    "LEFT JOIN FETCH ls.sachMoi " +
                                    "WHERE ls.donHang.maDH = :maDH " +
                                    "ORDER BY ls.ngayThucHien DESC", LichSuDoiTra.class)
                    .setParameter("maDH", maDH)
                    .getResultList();
        }
    }

    private String chuanHoaLyDo(String lyDo) {
        return (lyDo == null || lyDo.isBlank()) ? null : lyDo.trim();
    }

    // Neu tat ca cac dong cua don khong con cuon nao o trang thai 'Đã bán' (da tra/doi het)
    // thi chuyen trang thai don sang "da tra" (tai su dung TRANG_THAI_DA_TRA co san).
    private void capNhatTrangThaiNeuDaTraHet(Session session, DonHang dh) {
        Long conLai = session.createQuery(
                        "SELECT COUNT(sv) FROM SachVatLy sv WHERE sv.chiTietDonHang.donHang.maDH = :ma " +
                                "AND UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))", Long.class)
                .setParameter("ma", dh.getMaDH())
                .setParameter("tt", DA_BAN)
                .uniqueResult();
        dh.setTrangThai((conLai == null || conLai == 0) ? TRANG_THAI_DA_TRA : TRANG_THAI_DA_GIAO);
    }
}
