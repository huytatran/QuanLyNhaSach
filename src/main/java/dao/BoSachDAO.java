package dao;

import entity.BoSach;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BoSachDAO {

    public List<BoSach> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM BoSach ORDER BY tenBoSach", BoSach.class)
                    .getResultList();
        }
    }

    public long countAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long c = session.createQuery("SELECT COUNT(b) FROM BoSach b", Long.class).uniqueResult();
            return c == null ? 0 : c;
        }
    }

    public BoSach getById(Integer maBoSach) {
        if (maBoSach == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(BoSach.class, maBoSach);
        }
    }

    public Map<Integer, Long> demSachTheoBoSach() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<Object[]> rows = session.createQuery(
                    "SELECT s.boSach.maBoSach, COUNT(s) FROM Sach s GROUP BY s.boSach.maBoSach",
                    Object[].class)
                    .getResultList();

            Map<Integer, Long> map = new HashMap<>();
            for (Object[] row : rows) {
                map.put((Integer) row[0], (Long) row[1]);
            }
            return map;
        }
    }

    public boolean insert(String tenBoSach, String moTa) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            Long trung = session.createQuery(
                    "SELECT COUNT(b) FROM BoSach b WHERE LOWER(b.tenBoSach)=:ten",
                    Long.class)
                    .setParameter("ten", tenBoSach.trim().toLowerCase())
                    .uniqueResult();

            if (trung != null && trung > 0) return false;

            tx = session.beginTransaction();

            BoSach bs = new BoSach();
            bs.setTenBoSach(tenBoSach.trim());
            bs.setMoTa(moTa);

            session.persist(bs);

            tx.commit();
            return true;

        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public boolean update(Integer maBoSach, String tenBoSach, String moTa) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            Long trung = session.createQuery(
                    "SELECT COUNT(b) FROM BoSach b WHERE LOWER(b.tenBoSach)=:ten AND b.maBoSach<>:ma",
                    Long.class)
                    .setParameter("ten", tenBoSach.trim().toLowerCase())
                    .setParameter("ma", maBoSach)
                    .uniqueResult();

            if (trung != null && trung > 0) return false;

            tx = session.beginTransaction();

            BoSach bs = session.get(BoSach.class, maBoSach);

            if (bs == null)
                throw new IllegalArgumentException("Không tìm thấy bộ sách.");

            bs.setTenBoSach(tenBoSach.trim());
            bs.setMoTa(moTa);

            session.merge(bs);

            tx.commit();

            return true;

        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public boolean delete(Integer maBoSach) {
        Transaction tx = null;

        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            Long soSach = session.createQuery(
                    "SELECT COUNT(s) FROM Sach s WHERE s.boSach.maBoSach=:ma",
                    Long.class)
                    .setParameter("ma", maBoSach)
                    .uniqueResult();

            if (soSach != null && soSach > 0) return false;

            BoSach bs = session.get(BoSach.class, maBoSach);

            if (bs == null) return false;

            tx = session.beginTransaction();

            session.remove(bs);

            tx.commit();

            return true;

        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}