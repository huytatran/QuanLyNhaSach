package dao;

import entity.NhaXuatBan;
import org.hibernate.Session;
import utils.HibernateConfig;

import java.util.List;

public class NhaXuatBanDAO {

    public List<NhaXuatBan> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM NhaXuatBan ORDER BY tenNXB", NhaXuatBan.class)
                    .getResultList();
        }
    }
}
