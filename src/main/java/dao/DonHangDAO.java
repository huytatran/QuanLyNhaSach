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
     * @return maDH vua tao
     */
    public int taoDonHang(Integer maKH, Integer maNV, String phuongThuc,
                          Map<String, Integer> gioHang) {
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
            dh.setSoTienGiam(BigDecimal.ZERO);
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

    /** Hoàn trả toàn bộ đơn: hoàn tồn kho và loại đơn khỏi doanh thu. */
    public void traDonHang(Integer maDH) {
        if (maDH == null) {
            throw new IllegalArgumentException("Mã đơn hàng không hợp lệ.");
        }

        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            DonHang donHang = session.get(DonHang.class, maDH);
            if (donHang == null) {
                throw new IllegalArgumentException("Không tìm thấy đơn hàng.");
            }
            if (Integer.valueOf(TRANG_THAI_DA_TRA).equals(donHang.getTrangThai())) {
                throw new IllegalStateException("Đơn hàng này đã được trả trước đó.");
            }

            List<SachVatLy> sachDaBan = session.createQuery(
                            "FROM SachVatLy sv WHERE sv.chiTietDonHang.donHang.maDH = :ma " +
                                    "AND sv.trangThai = :trangThai",
                            SachVatLy.class)
                    .setParameter("ma", maDH)
                    .setParameter("trangThai", DA_BAN)
                    .getResultList();
            for (SachVatLy sach : sachDaBan) {
                sach.setTrangThai(CO_SAN);
            }
            donHang.setTrangThai(TRANG_THAI_DA_TRA);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) {
                tx.rollback();
            }
            throw e;
        }
    }
}
