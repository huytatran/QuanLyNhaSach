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

    public static final short TRANG_THAI_DA_GIAO = 1;
    public static final short TRANG_THAI_DA_TRA = 2;

    private static final String CO_SAN = "Có sẵn";
    private static final String DA_BAN = "Đã bán";

    private long demSoLuongConLaiToanDon(Session session, Integer maDH) {
        Long c = session.createQuery(
                "SELECT COUNT(sv) FROM SachVatLy sv WHERE sv.chiTietDonHang.donHang.maDH = :maDH " +
                        "AND UPPER(TRIM(sv.trangThai)) = UPPER(TRIM(:tt))", Long.class)
                .setParameter("maDH", maDH)
                .setParameter("tt", DA_BAN)
                .uniqueResult();
        return c == null ? 0 : c;
    }

    private BigDecimal tinhGiamMoiCuon(DonHang dh, long soLuongConLaiToanDon) {
        BigDecimal soTienGiam = dh.getSoTienGiam() == null ? BigDecimal.ZERO : dh.getSoTienGiam();
        if (soLuongConLaiToanDon <= 0 || soTienGiam.compareTo(BigDecimal.ZERO) <= 0) return BigDecimal.ZERO;
        return soTienGiam.divide(BigDecimal.valueOf(soLuongConLaiToanDon), 2, java.math.RoundingMode.HALF_UP);
    }

    private void capNhatTienSauKhiTraHang(DonHang dh, BigDecimal giaTriHangGiam, BigDecimal soTienGiamTruDi) {
        BigDecimal soTienGiamCu = dh.getSoTienGiam() == null ? BigDecimal.ZERO : dh.getSoTienGiam();
        BigDecimal truoc = dh.getTongTien().add(soTienGiamCu);
        BigDecimal sau = truoc.subtract(giaTriHangGiam);
        if (sau.compareTo(BigDecimal.ZERO) < 0) sau = BigDecimal.ZERO;

        BigDecimal soTienGiamMoi = soTienGiamCu.subtract(soTienGiamTruDi == null ? BigDecimal.ZERO : soTienGiamTruDi);
        if (soTienGiamMoi.compareTo(BigDecimal.ZERO) < 0) soTienGiamMoi = BigDecimal.ZERO;

        BigDecimal tongTienMoi = sau.subtract(soTienGiamMoi);
        if (tongTienMoi.compareTo(BigDecimal.ZERO) < 0) tongTienMoi = BigDecimal.ZERO;

        dh.setSoTienGiam(soTienGiamMoi);
        dh.setTongTien(tongTienMoi);
    }

    private void capNhatTienSauKhiDoiSangSachRe(DonHang dh, BigDecimal giaTriHangGiam) {
        BigDecimal soTienGiamCu = dh.getSoTienGiam() == null ? BigDecimal.ZERO : dh.getSoTienGiam();
        BigDecimal truoc = dh.getTongTien().add(soTienGiamCu);
        BigDecimal sau = truoc.subtract(giaTriHangGiam);
        if (sau.compareTo(BigDecimal.ZERO) < 0) sau = BigDecimal.ZERO;

        Voucher vc = dh.getVoucher();
        boolean conDuDieuKienVoucher = vc == null || vc.getGiaTriDonToiThieu() == null
                || sau.compareTo(vc.getGiaTriDonToiThieu()) >= 0;

        BigDecimal soTienGiamMoi = conDuDieuKienVoucher ? soTienGiamCu : BigDecimal.ZERO;

        BigDecimal tongTienMoi = sau.subtract(soTienGiamMoi);
        if (tongTienMoi.compareTo(BigDecimal.ZERO) < 0) tongTienMoi = BigDecimal.ZERO;

        dh.setSoTienGiam(soTienGiamMoi);
        dh.setTongTien(tongTienMoi);
    }

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

    public long countAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long c = session.createQuery("SELECT COUNT(dh) FROM DonHang dh", Long.class).uniqueResult();
            return c == null ? 0 : c;
        }
    }

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

    public long countAll(java.time.LocalDate tuNgay, java.time.LocalDate denNgay, Integer maDon, String tenKH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            var q = session.createQuery(buildHqlDonHang(tuNgay, denNgay, maDon, tenKH, true), Long.class);
            ganThamSoLoc(q, tuNgay, denNgay, maDon, tenKH);
            Long c = q.uniqueResult();
            return c == null ? 0 : c;
        }
    }

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

    public List<DonHang> getAllCoTheDoiTra(int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
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

    public int taoDonHangBienThe(Integer maKH, Integer maNV, String phuongThuc,
                                 java.util.List<entity.CartItem> items,
                                 java.math.BigDecimal soTienGiam, String maCodeVoucher) {
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
            if (maCodeVoucher != null && !maCodeVoucher.isBlank()) {
                Voucher vc = session.createQuery(
                        "FROM Voucher v WHERE v.maCode = :c", Voucher.class)
                        .setParameter("c", maCodeVoucher.trim())
                        .uniqueResult();
                dh.setVoucher(vc);
            }
            session.persist(dh);
            session.flush();

            BigDecimal tong = BigDecimal.ZERO;

            for (entity.CartItem item : items) {
                int soLuong = item.getSoLuong();
                if (soLuong <= 0) continue;

                Sach sach = session.get(Sach.class, item.getMaSach());
                if (sach == null) throw new IllegalArgumentException("Không tìm thấy sách " + item.getMaSach());

                BigDecimal donGia = item.getDonGia() != null ? item.getDonGia() : BigDecimal.ZERO;

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

    public int taoDonHang(Integer maKH, Integer maNV, String phuongThuc,
                          Map<String, Integer> gioHang, java.math.BigDecimal soTienGiam) {
        if (gioHang == null || gioHang.isEmpty()) {
            throw new IllegalArgumentException("Giỏ hàng trống.");
        }

        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();

            KhachHang kh = session.get(KhachHang.class, maKH);
            NhanVien nv = session.get(NhanVien.class, maNV);
            if (kh == null) throw new IllegalArgumentException("Không tìm thấy khách hàng.");
            if (nv == null) throw new IllegalArgumentException("Không tìm thấy nhân viên.");

            DonHang dh = new DonHang();
            dh.setNgayLap(LocalDateTime.now());
            dh.setTongTien(BigDecimal.ZERO);
            dh.setTrangThai(TRANG_THAI_DA_GIAO);
            dh.setPhuongThucThanhToan(phuongThuc);
            dh.setKhachHang(kh);
            dh.setNhanVien(nv);
            dh.setSoTienGiam(soTienGiam == null ? BigDecimal.ZERO : soTienGiam);
            session.persist(dh);
            session.flush();

            BigDecimal tong = BigDecimal.ZERO;

            for (Map.Entry<String, Integer> entry : gioHang.entrySet()) {
                String maSach = entry.getKey();
                int soLuong = entry.getValue();
                if (soLuong <= 0) continue;

                Sach sach = session.get(Sach.class, maSach);
                if (sach == null) {
                    throw new IllegalArgumentException("Không tìm thấy sách " + maSach);
                }

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

                ChiTietDonHang ct = new ChiTietDonHang();
                ct.setDonHang(dh);
                ct.setSach(sach);
                ct.setSoLuong(soLuong);
                ct.setDonGia(sach.getGiaBan() != null ? sach.getGiaBan() : BigDecimal.ZERO);
                session.persist(ct);
                session.flush();

                tong = tong.add(ct.getDonGia().multiply(BigDecimal.valueOf(soLuong)));

                for (SachVatLy sv : cuonCoSan) {
                    sv.setTrangThai(DA_BAN);
                    sv.setChiTietDonHang(ct);
                    session.merge(sv);
                }
            }

            dh.setTongTien(tong);
            session.merge(dh);

            tx.commit();
            return dh.getMaDH();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public void traMon(Integer maCTDH, int soLuongTra) {
        traMon(maCTDH, soLuongTra, null);
    }

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

            DonHang dh = ct.getDonHang();

            long soLuongConLaiToanDon = demSoLuongConLaiToanDon(session, dh.getMaDH());
            BigDecimal giamMoiCuon = tinhGiamMoiCuon(dh, soLuongConLaiToanDon);

            BigDecimal donGia = ct.getDonGia();
            BigDecimal giaHoanMoiCuon = donGia.subtract(giamMoiCuon);
            if (giaHoanMoiCuon.compareTo(BigDecimal.ZERO) < 0) giaHoanMoiCuon = BigDecimal.ZERO;
            BigDecimal soTienHoan = giaHoanMoiCuon.multiply(BigDecimal.valueOf(soLuongTra));
            BigDecimal giaTriHangGiam = donGia.multiply(BigDecimal.valueOf(soLuongTra));
            BigDecimal soTienGiamTruDi = giamMoiCuon.multiply(BigDecimal.valueOf(soLuongTra));

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

            capNhatTienSauKhiTraHang(dh, giaTriHangGiam, soTienGiamTruDi);

            LichSuDoiTra ls = new LichSuDoiTra();
            ls.setDonHang(dh);
            ls.setLoaiGiaoDich("TRA");
            ls.setNgayThucHien(LocalDateTime.now());
            ls.setChiTietCu(ct);
            ls.setSoLuongTra(soLuongTra);
            ls.setChenhLechTien(soTienHoan.negate());
            ls.setLyDo(chuanHoaLyDo(lyDo));
            session.persist(ls);

            capNhatTrangThaiNeuDaTraHet(session, dh);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public void doiMon(Integer maCTDH, int soLuongDoi, String maSachMoi) {
        doiMon(maCTDH, soLuongDoi, maSachMoi, null);
    }

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
            BigDecimal giaMoi = sachMoi.getGiaBan() != null ? sachMoi.getGiaBan() : BigDecimal.ZERO;

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

            BigDecimal chenhLech = giaMoi.subtract(giaCu).multiply(BigDecimal.valueOf(soLuongDoi));
            if (chenhLech.compareTo(BigDecimal.ZERO) < 0) {
                capNhatTienSauKhiDoiSangSachRe(dh, chenhLech.negate());
            } else {
                dh.setTongTien(dh.getTongTien().add(chenhLech));
            }

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