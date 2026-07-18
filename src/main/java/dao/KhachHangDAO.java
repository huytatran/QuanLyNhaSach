package dao;

import entity.KhachHang;
import org.hibernate.Session;
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
}
