package dao;

import entity.TacGia;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TacGiaDAO {

    public List<TacGia> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM TacGia ORDER BY tenTG", TacGia.class)
                    .getResultList();
        }
    }

    public long countAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long c = session.createQuery("SELECT COUNT(t) FROM TacGia t", Long.class).uniqueResult();
            return c == null ? 0 : c;
        }
    }

    public TacGia getById(Integer maTG) {
        if (maTG == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(TacGia.class, maTG);
        }
    }

    public Map<Integer, Long> demSachTheoTacGia() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<Object[]> rows = session.createQuery(
                    "SELECT tg.maTG, COUNT(s) " +
                            "FROM Sach s JOIN s.danhSachTacGia st JOIN st.tacGia tg " +
                            "GROUP BY tg.maTG",
                    Object[].class)
                    .getResultList();

            Map<Integer, Long> map = new HashMap<>();
            for (Object[] row : rows) {
                map.put((Integer) row[0], (Long) row[1]);
            }
            return map;
        }
    }

    public boolean insert(String tenTG, String tieuSu) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            Long trung = session.createQuery(
                    "SELECT COUNT(t) FROM TacGia t WHERE LOWER(t.tenTG)=:ten",
                    Long.class)
                    .setParameter("ten", tenTG.trim().toLowerCase())
                    .uniqueResult();

            if (trung != null && trung > 0) return false;

            tx = session.beginTransaction();

            TacGia tg = new TacGia();
            tg.setTenTG(tenTG.trim());
            tg.setTieuSu(tieuSu);

            session.persist(tg);

            tx.commit();
            return true;

        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public boolean update(Integer maTG, String tenTG, String tieuSu) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            Long trung = session.createQuery(
                    "SELECT COUNT(t) FROM TacGia t WHERE LOWER(t.tenTG)=:ten AND t.maTG<>:ma",
                    Long.class)
                    .setParameter("ten", tenTG.trim().toLowerCase())
                    .setParameter("ma", maTG)
                    .uniqueResult();

            if (trung != null && trung > 0) return false;

            tx = session.beginTransaction();

            TacGia tg = session.get(TacGia.class, maTG);

            if (tg == null)
                throw new IllegalArgumentException("Không tìm thấy tác giả.");

            tg.setTenTG(tenTG.trim());
            tg.setTieuSu(tieuSu);

            session.merge(tg);

            tx.commit();

            return true;

        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public boolean delete(Integer maTG) {
        Transaction tx = null;

        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            Long soSach = session.createQuery(
                    "SELECT COUNT(st) FROM SachTacGia st WHERE st.tacGia.maTG=:ma",
                    Long.class)
                    .setParameter("ma", maTG)
                    .uniqueResult();

            if (soSach != null && soSach > 0) return false;

            TacGia tg = session.get(TacGia.class, maTG);

            if (tg == null) return false;

            tx = session.beginTransaction();

            session.remove(tg);

            tx.commit();

            return true;

        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}