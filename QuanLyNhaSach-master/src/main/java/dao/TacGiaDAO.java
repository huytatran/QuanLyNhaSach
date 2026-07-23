package dao;

import entity.TacGia;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.List;

public class TacGiaDAO {

    public List<TacGia> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM TacGia ORDER BY tenTG", TacGia.class).getResultList();
        }
    }

    public TacGia getById(Integer maTG) {
        if (maTG == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(TacGia.class, maTG);
        }
    }

    public boolean tenTonTai(String tenTG, Integer excludeMaTG) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(t) FROM TacGia t WHERE LOWER(t.tenTG) = :ten";
            if (excludeMaTG != null) hql += " AND t.maTG <> :ma";
            var q = session.createQuery(hql, Long.class).setParameter("ten", tenTG.trim().toLowerCase());
            if (excludeMaTG != null) q.setParameter("ma", excludeMaTG);
            Long c = q.uniqueResult();
            return c != null && c > 0;
        }
    }

    public void insert(TacGia tg) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.persist(tg);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public void update(TacGia tg) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.merge(tg);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /** @return false nếu đang có sách liên kết với tác giả này */
    public boolean delete(Integer maTG) {
        if (maTG == null) return false;
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long soSach = session.createQuery(
                    "SELECT COUNT(st) FROM SachTacGia st WHERE st.tacGia.maTG = :ma", Long.class)
                    .setParameter("ma", maTG).uniqueResult();
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
