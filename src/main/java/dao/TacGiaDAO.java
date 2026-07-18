package dao;

import entity.TacGia;
import org.hibernate.Session;
import utils.HibernateConfig;

import java.util.List;

public class TacGiaDAO {

    public List<TacGia> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM TacGia ORDER BY tenTG", TacGia.class)
                    .getResultList();
        }
    }
}
