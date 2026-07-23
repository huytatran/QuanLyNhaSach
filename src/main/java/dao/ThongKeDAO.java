package dao;

import org.hibernate.Session;
import utils.HibernateConfig;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ThongKeDAO {

    public long demDonHomNay() {
        LocalDateTime start = LocalDate.now().atStartOfDay();
        LocalDateTime end = start.plusDays(1);
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long count = session.createQuery(
                            "SELECT COUNT(dh) FROM DonHang dh "
                                    + "WHERE dh.ngayLap >= :start AND dh.ngayLap < :end",
                            Long.class)
                    .setParameter("start", start)
                    .setParameter("end", end)
                    .uniqueResult();
            return count == null ? 0 : count;
        }
    }

    public long demTonKho() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long count = session.createQuery(
                            "SELECT COUNT(sv) FROM SachVatLy sv WHERE sv.trangThai = :tt",
                            Long.class)
                    .setParameter("tt", "Có sẵn")
                    .uniqueResult();
            return count == null ? 0 : count;
        }
    }

    public long demDauSach() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long count = session.createQuery("SELECT COUNT(s) FROM Sach s", Long.class)
                    .uniqueResult();
            return count == null ? 0 : count;
        }
    }

    public List<Object[]> getDonHangGanDay(int limit) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                            "SELECT dh.maDH, dh.ngayLap, dh.tongTien, dh.trangThai, kh.tenKH "
                                    + "FROM DonHang dh JOIN dh.khachHang kh "
                                    + "ORDER BY dh.ngayLap DESC",
                            Object[].class)
                    .setMaxResults(limit)
                    .getResultList();
        }
    }

    public Map<String, Object> tongHopDoanhThu(LocalDate from, LocalDate to) {
        LocalDateTime start = from.atStartOfDay();
        LocalDateTime end = to.plusDays(1).atStartOfDay();
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Object[] row = session.createQuery(
                            "SELECT COUNT(dh), COALESCE(SUM(dh.tongTien), 0) "
                                    + "FROM DonHang dh "
                                    + "WHERE dh.trangThai <> 2 AND dh.ngayLap >= :start AND dh.ngayLap < :end",
                            Object[].class)
                    .setParameter("start", start)
                    .setParameter("end", end)
                    .uniqueResult();

            Map<String, Object> map = new HashMap<>();
            map.put("soDon", row == null || row[0] == null ? 0L : row[0]);
            map.put("doanhThu", row == null || row[1] == null ? BigDecimal.ZERO : row[1]);
            return map;
        }
    }

    /** Doanh thu theo ngay trong khoang. */
    public List<Object[]> doanhThuTheoNgay(LocalDate from, LocalDate to) {
        LocalDateTime start = from.atStartOfDay();
        LocalDateTime end = to.plusDays(1).atStartOfDay();
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createNativeQuery(
                            "SELECT CAST(NgayLap AS date) AS Ngay, COUNT(*) AS SoDon, "
                                    + "COALESCE(SUM(TongTien), 0) AS DoanhThu "
                                    + "FROM DonHang "
                                    + "WHERE TrangThai <> 2 AND NgayLap >= :start AND NgayLap < :end "
                                    + "GROUP BY CAST(NgayLap AS date) "
                                    + "ORDER BY CAST(NgayLap AS date)",
                            Object[].class)
                    .setParameter("start", start)
                    .setParameter("end", end)
                    .getResultList();
        }
    }

    /** Top sach ban chay theo so luong trong khoang ngay. */
    public List<Object[]> topSachBanChay(LocalDate from, LocalDate to, int limit) {
        LocalDateTime start = from.atStartOfDay();
        LocalDateTime end = to.plusDays(1).atStartOfDay();
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                            "SELECT s.maSach, s.tenSach, SUM(ct.soLuong), SUM(ct.soLuong * ct.donGia) "
                                    + "FROM ChiTietDonHang ct JOIN ct.sach s JOIN ct.donHang dh "
                                    + "WHERE dh.trangThai <> 2 AND dh.ngayLap >= :start AND dh.ngayLap < :end "
                                    + "GROUP BY s.maSach, s.tenSach "
                                    + "ORDER BY SUM(ct.soLuong) DESC",
                            Object[].class)
                    .setParameter("start", start)
                    .setParameter("end", end)
                    .setMaxResults(limit)
                    .getResultList();
        }
    }
}
