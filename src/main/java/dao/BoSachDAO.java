package dao;

import entity.BoSach;
import org.hibernate.Session;
import utils.HibernateConfig;

import java.util.List;

public class BoSachDAO {

    public List<BoSach> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM BoSach ORDER BY tenBoSach", BoSach.class)
                    .getResultList();
        }
    }
}
