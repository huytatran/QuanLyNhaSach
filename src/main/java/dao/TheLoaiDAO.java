package dao;

import entity.TheLoai;
import org.hibernate.Session;
import utils.HibernateConfig;

import java.util.List;

public class TheLoaiDAO {

    public List<TheLoai> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM TheLoai ORDER BY tenTL", TheLoai.class)
                    .getResultList();
        }
    }
}
