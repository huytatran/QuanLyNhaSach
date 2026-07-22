package dao;

import entity.KhachHang;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.List;

public class KhachHangDAO {

    public List<KhachHang> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM KhachHang ORDER BY tenKH", KhachHang.class)
                    .getResultList();
        }
    }

    public KhachHang getById(Integer maKH) {
        if (maKH == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(KhachHang.class, maKH);
        }
    }

    public KhachHang insert(KhachHang kh) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.persist(kh);
            tx.commit();
            return kh; // Sau khi persist, maKH tu tang se duoc gan vao doi tuong kh
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}
