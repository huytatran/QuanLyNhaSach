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

    /** Đơn đã giao (trangThai=1) còn cuốn chưa trả — dùng cho tab Đổi/Trả. */
    public List<DonHang> getAllCoTheDoiTra(int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            // Lấy maDH của các đơn còn SachVatLy trạng thái 'Đã bán'
            List<Integer> maDHList = session.createQuery(
                    "SELECT DISTINCT sv.chiTietDonHang.donHang.maDH FROM SachVatLy sv " +
                    "WHERE sv.trangThai = :tt",
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
                    "WHERE sv.trangThai = :tt AND sv.chiTietDonHang.donHang.trangThai = :trangThai",
                    Long.class)
                    .setParameter("tt", DA_BAN)
                    .setParameter("trangThai", TRANG_THAI_DA_GIAO)
                    .uniqueResult();
            return c == null ? 0 : c;
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
                                "FROM SachVatLy sv WHERE sv.sach.maSach = :ma AND sv.trangThai = :tt",
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
                            "FROM SachVatLy sv WHERE sv.chiTietDonHang.maCTDH = :ma AND sv.trangThai = :tt",
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
            dh.setTongTien(dh.getTongTien().subtract(ct.getDonGia().multiply(BigDecimal.valueOf(soLuongTra))));

            capNhatTrangThaiNeuDaTraHet(session, dh);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Moi: Doi mot phan (hoac toan bo) so luong cua MOT dong chi tiet don hang sang sach khac.
     * Chi cho phep doi sang sach co gia BANG hoac CAO HON gia dong hien tai (khach tra them
     * phan chenh lech neu co, khong doi sang gia thap hon). Khong dung bang/cot moi:
     * tao them 1 dong ChiTietDonHang MOI cho sach da doi toi (dong ChiTietDonHang la du lieu
     * bth cua bang co san, khong phai thay doi cau truc). "Con lai" cua dong moi nay lai
     * duoc suy ra dung nhu tren, tu SachVatLy.
     */
    public void doiMon(Integer maCTDH, int soLuongDoi, String maSachMoi) {
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
            if (giaMoi.compareTo(giaCu) < 0) {
                throw new IllegalArgumentException(
                        "Chỉ được đổi sang sách có giá bằng hoặc cao hơn sách cũ (" +
                                giaCu.toPlainString() + " đ).");
            }

            // Sach moi phai con du hang trong kho
            List<SachVatLy> cuonSachMoi = session.createQuery(
                            "FROM SachVatLy sv WHERE sv.sach.maSach = :ma AND sv.trangThai = :tt",
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
                            "FROM SachVatLy sv WHERE sv.chiTietDonHang.maCTDH = :ma AND sv.trangThai = :tt",
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

            // Tao dong chi tiet don hang MOI cho sach da doi toi (du lieu binh thuong, khong doi cau truc bang)
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
            dh.setTongTien(dh.getTongTien().add(giaMoi.subtract(giaCu).multiply(BigDecimal.valueOf(soLuongDoi))));

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
                                    "WHERE sv.chiTietDonHang.donHang.maDH = :ma AND sv.trangThai = :tt " +
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

    // Neu tat ca cac dong cua don khong con cuon nao o trang thai 'Đã bán' (da tra/doi het)
    // thi chuyen trang thai don sang "da tra" (tai su dung TRANG_THAI_DA_TRA co san).
    private void capNhatTrangThaiNeuDaTraHet(Session session, DonHang dh) {
        Long conLai = session.createQuery(
                        "SELECT COUNT(sv) FROM SachVatLy sv WHERE sv.chiTietDonHang.donHang.maDH = :ma " +
                                "AND sv.trangThai = :tt", Long.class)
                .setParameter("ma", dh.getMaDH())
                .setParameter("tt", DA_BAN)
                .uniqueResult();
        dh.setTrangThai((conLai == null || conLai == 0) ? TRANG_THAI_DA_TRA : TRANG_THAI_DA_GIAO);
    }
}
