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

    private static final String CO_SAN = "Có sẵn";
    private static final String DA_BAN = "Đã bán";

    /**
     * Tao don ban hang POS: DonHang + ChiTiet + gan SachVatLy 'Có sẵn' -> 'Đã bán'.
     * @param gioHang map maSach -> soLuong
     * @return maDH neu thanh cong
     */
    public int taoDonHang(Integer maKH, Integer maNV, String phuongThuc,
                          Map<String, Integer> gioHang) {
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
            dh.setTongTien(BigDecimal.ZERO); // trigger se cap nhat sau khi chen chi tiet
            dh.setTrangThai(1); // Da giao (ban tai quay)
            dh.setPhuongThucThanhToan(phuongThuc);
            dh.setKhachHang(kh);
            dh.setNhanVien(nv);
            dh.setSoTienGiam(BigDecimal.ZERO);
            session.persist(dh);
            session.flush();

            for (Map.Entry<String, Integer> entry : gioHang.entrySet()) {
                String maSach = entry.getKey();
                int soLuong = entry.getValue();
                if (soLuong <= 0) continue;

                Sach sach = session.get(Sach.class, maSach);
                if (sach == null) {
                    throw new IllegalArgumentException("Không tìm thấy sách " + maSach);
                }

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

                ChiTietDonHang ct = new ChiTietDonHang();
                ct.setDonHang(dh);
                ct.setSach(sach);
                ct.setSoLuong(soLuong);
                ct.setDonGia(sach.getGiaBan() != null ? sach.getGiaBan() : BigDecimal.ZERO);
                session.persist(ct);
                session.flush(); // co MaCTDH

                for (SachVatLy sv : cuonCoSan) {
                    sv.setTrangThai(DA_BAN);
                    sv.setChiTietDonHang(ct);
                    session.merge(sv);
                }
            }

            tx.commit();
            return dh.getMaDH();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}
