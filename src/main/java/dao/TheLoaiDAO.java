package dao;

import entity.TheLoai;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TheLoaiDAO {

    public List<TheLoai> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM TheLoai ORDER BY tenTL", TheLoai.class)
                    .getResultList();
        }
    }

    public long countAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long c = session.createQuery("SELECT COUNT(t) FROM TheLoai t", Long.class).uniqueResult();
            return c == null ? 0 : c;
        }
    }

    public TheLoai getById(Integer maTL) {
        if (maTL == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(TheLoai.class, maTL);
        }
    }

    /** Dem so dau sach dang dung tung the loai - dung de hien trong bang va chan xoa khi dang su dung. */
    public Map<Integer, Long> demSachTheoTheLoai() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<Object[]> rows = session.createQuery(
                    "SELECT s.theLoai.maTL, COUNT(s) FROM Sach s GROUP BY s.theLoai.maTL",
                    Object[].class)
                    .getResultList();
            Map<Integer, Long> map = new HashMap<>();
            for (Object[] row : rows) {
                map.put((Integer) row[0], (Long) row[1]);
            }
            return map;
        }
    }

    /** @return false neu ten the loai da ton tai (khong phan biet hoa/thuong) */
    public boolean insert(String tenTL) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long trung = session.createQuery(
                    "SELECT COUNT(t) FROM TheLoai t WHERE LOWER(t.tenTL) = :ten", Long.class)
                    .setParameter("ten", tenTL.trim().toLowerCase())
                    .uniqueResult();
            if (trung != null && trung > 0) return false;

            tx = session.beginTransaction();
            TheLoai t = new TheLoai();
            t.setTenTL(tenTL.trim());
            session.persist(t);
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /** @return false neu ten trung voi the loai khac */
    public boolean update(Integer maTL, String tenTL) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long trung = session.createQuery(
                    "SELECT COUNT(t) FROM TheLoai t WHERE LOWER(t.tenTL) = :ten AND t.maTL <> :ma", Long.class)
                    .setParameter("ten", tenTL.trim().toLowerCase())
                    .setParameter("ma", maTL)
                    .uniqueResult();
            if (trung != null && trung > 0) return false;

            tx = session.beginTransaction();
            TheLoai t = session.get(TheLoai.class, maTL);
            if (t == null) throw new IllegalArgumentException("Không tìm thấy thể loại.");
            t.setTenTL(tenTL.trim());
            session.merge(t);
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Chi xoa duoc neu chua co dau sach nao dung the loai nay
     * (Sach.MaTL la NOT NULL trong schema goc nen bat buoc phai chan truoc).
     * @return false neu dang duoc su dung, khong xoa duoc
     */
    public boolean delete(Integer maTL) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long soSach = session.createQuery(
                    "SELECT COUNT(s) FROM Sach s WHERE s.theLoai.maTL = :ma", Long.class)
                    .setParameter("ma", maTL)
                    .uniqueResult();
            if (soSach != null && soSach > 0) return false;

            TheLoai t = session.get(TheLoai.class, maTL);
            if (t == null) return false;

            tx = session.beginTransaction();
            session.remove(t);
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}
