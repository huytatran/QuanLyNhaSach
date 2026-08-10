package dao;

import entity.Sach;
import entity.SachBienThe;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.math.BigDecimal;
import java.util.List;

public class SachBienTheDAO {

    /** Tất cả biến thể của một đầu sách (kể cả ngừng bán) — dùng ở form sửa sách. */
    public List<SachBienThe> getByMaSach(String maSach) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "FROM SachBienThe bt WHERE bt.sach.maSach = :ma ORDER BY bt.maBienThe",
                    SachBienThe.class)
                    .setParameter("ma", maSach)
                    .getResultList();
        }
    }

    /**
     * Alias dùng cho SachServlet (gọi bienTheDAO.getBySach()).
     * Trả về tất cả biến thể kể cả ngừng bán để hiển thị đầy đủ trong form.
     */
    public List<SachBienThe> getBySach(String maSach) {
        return getByMaSach(maSach);
    }

    /** Chỉ biến thể đang bán (trangThai = true) — dùng cho POS. */
    public List<SachBienThe> getByMaSachDangBan(String maSach) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "FROM SachBienThe bt WHERE bt.sach.maSach = :ma AND bt.trangThai = true ORDER BY bt.maBienThe",
                    SachBienThe.class)
                    .setParameter("ma", maSach)
                    .getResultList();
        }
    }

    public SachBienThe getById(Integer maBienThe) {
        if (maBienThe == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(SachBienThe.class, maBienThe);
        }
    }

    /**
     * Thêm mới một biến thể.
     * @param maBienTheCode mã định danh ngắn do người dùng nhập (VD: S001-BC-VI),
     *                      lưu vào cột BiaSach tạm thời ghép với ngôn ngữ.
     *                      Thực tế entity dùng biaSach = loaiBia, ngonNgu = ngonNgu.
     * @return false nếu maBienTheCode đã tồn tại trong cùng đầu sách
     */
    public boolean insert(String maSach, String loaiBia, String ngonNgu,
                          String maBienTheCode, BigDecimal giaBan) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            // Kiểm tra trùng maBienTheCode trong cùng sách
            Long trung = session.createQuery(
                    "SELECT COUNT(bt) FROM SachBienThe bt WHERE bt.sach.maSach = :ma AND bt.maBienTheCode = :code",
                    Long.class)
                    .setParameter("ma", maSach)
                    .setParameter("code", maBienTheCode.trim())
                    .uniqueResult();
            if (trung != null && trung > 0) return false;

            tx = session.beginTransaction();
            Sach sach = session.get(Sach.class, maSach);
            if (sach == null) throw new IllegalArgumentException("Không tìm thấy sách.");

            SachBienThe bt = new SachBienThe();
            bt.setSach(sach);
            bt.setMaBienTheCode(maBienTheCode.trim());
            bt.setBiaSach(loaiBia == null || loaiBia.isBlank() ? null : loaiBia.trim());
            bt.setNgonNgu(ngonNgu == null || ngonNgu.isBlank() ? null : ngonNgu.trim());
            bt.setGiaBienThe(giaBan != null ? giaBan : BigDecimal.ZERO);
            bt.setTrangThai(true);
            session.persist(bt);
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Cập nhật biến thể đã tồn tại.
     * @return false nếu maBienTheCode trùng với biến thể khác trong cùng sách
     */
    public boolean update(Integer maBienThe, String loaiBia, String ngonNgu,
                          String maBienTheCode, BigDecimal giaBan) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            SachBienThe bt = session.get(SachBienThe.class, maBienThe);
            if (bt == null) throw new IllegalArgumentException("Không tìm thấy biến thể.");

            // Kiểm tra trùng code với biến thể khác cùng sách
            Long trung = session.createQuery(
                    "SELECT COUNT(b) FROM SachBienThe b WHERE b.sach.maSach = :ma AND b.maBienTheCode = :code AND b.maBienThe <> :id",
                    Long.class)
                    .setParameter("ma", bt.getSach().getMaSach())
                    .setParameter("code", maBienTheCode.trim())
                    .setParameter("id", maBienThe)
                    .uniqueResult();
            if (trung != null && trung > 0) return false;

            tx = session.beginTransaction();
            bt.setMaBienTheCode(maBienTheCode.trim());
            bt.setBiaSach(loaiBia == null || loaiBia.isBlank() ? null : loaiBia.trim());
            bt.setNgonNgu(ngonNgu == null || ngonNgu.isBlank() ? null : ngonNgu.trim());
            bt.setGiaBienThe(giaBan != null ? giaBan : BigDecimal.ZERO);
            session.merge(bt);
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Xóa biến thể — chỉ xóa được nếu chưa có ChiTietDonHang nào gán biến thể này.
     * (SachVatLy không có field sachBienThe nên không kiểm tra qua đó được)
     * @return false nếu không xóa được
     */
    public boolean delete(Integer maBienThe) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            SachBienThe bt = session.get(SachBienThe.class, maBienThe);
            if (bt == null) return false;

            // Kiểm tra có ChiTietDonHang nào đã dùng biến thể này không
            Long soCTDH = session.createQuery(
                    "SELECT COUNT(ct) FROM ChiTietDonHang ct WHERE ct.sachBienThe.maBienThe = :ma",
                    Long.class)
                    .setParameter("ma", maBienThe)
                    .uniqueResult();
            if (soCTDH != null && soCTDH > 0) return false;

            tx = session.beginTransaction();
            session.remove(bt);
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /** Bật/tắt trạng thái bán của biến thể. */
    public void doiTrangThai(Integer maBienThe) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            SachBienThe bt = session.get(SachBienThe.class, maBienThe);
            if (bt == null) throw new IllegalArgumentException("Không tìm thấy biến thể.");
            bt.setTrangThai(!Boolean.TRUE.equals(bt.getTrangThai()));
            session.merge(bt);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}
