package dao;

import entity.NhaXuatBan;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NhaXuatBanDAO {

    public List<NhaXuatBan> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "FROM NhaXuatBan ORDER BY tenNXB",
                    NhaXuatBan.class
            ).getResultList();
        }
    }

    public long countAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long c = session.createQuery(
                    "SELECT COUNT(n) FROM NhaXuatBan n",
                    Long.class
            ).uniqueResult();
            return c == null ? 0 : c;
        }
    }

    public NhaXuatBan getById(Integer maNXB) {
        if (maNXB == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(NhaXuatBan.class, maNXB);
        }
    }

    public Map<Integer, Long> demSachTheoNXB() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<Object[]> rows = session.createQuery(
                    "SELECT s.nhaXuatBan.maNXB, COUNT(s) FROM Sach s GROUP BY s.nhaXuatBan.maNXB",
                    Object[].class
            ).getResultList();

            Map<Integer, Long> map = new HashMap<>();
            for (Object[] row : rows) {
                map.put((Integer) row[0], (Long) row[1]);
            }
            return map;
        }
    }

    public boolean insert(String tenNXB, String sdt, String diaChi) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            Long trung = session.createQuery(
                    "SELECT COUNT(n) FROM NhaXuatBan n WHERE LOWER(n.tenNXB)=:ten",
                    Long.class)
                    .setParameter("ten", tenNXB.trim().toLowerCase())
                    .uniqueResult();

            if (trung != null && trung > 0) return false;

            tx = session.beginTransaction();

            NhaXuatBan n = new NhaXuatBan();
            n.setTenNXB(tenNXB.trim());
            n.setSdt(sdt);
            n.setDiaChi(diaChi);

            session.persist(n);

            tx.commit();
            return true;

        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public boolean update(Integer maNXB,
                          String tenNXB,
                          String sdt,
                          String diaChi) {

        Transaction tx = null;

        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            Long trung = session.createQuery(
                    "SELECT COUNT(n) FROM NhaXuatBan n WHERE LOWER(n.tenNXB)=:ten AND n.maNXB<>:ma",
                    Long.class)
                    .setParameter("ten", tenNXB.trim().toLowerCase())
                    .setParameter("ma", maNXB)
                    .uniqueResult();

            if (trung != null && trung > 0) return false;

            tx = session.beginTransaction();

            NhaXuatBan n = session.get(NhaXuatBan.class, maNXB);

            if (n == null)
                throw new IllegalArgumentException("Không tìm thấy nhà xuất bản.");

            n.setTenNXB(tenNXB.trim());
            n.setSdt(sdt);
            n.setDiaChi(diaChi);

            session.merge(n);

            tx.commit();

            return true;

        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public boolean delete(Integer maNXB) {

        Transaction tx = null;

        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            Long soSach = session.createQuery(
                    "SELECT COUNT(s) FROM Sach s WHERE s.nhaXuatBan.maNXB=:ma",
                    Long.class)
                    .setParameter("ma", maNXB)
                    .uniqueResult();

            if (soSach != null && soSach > 0) return false;

            NhaXuatBan n = session.get(NhaXuatBan.class, maNXB);

            if (n == null) return false;

            tx = session.beginTransaction();

            session.remove(n);

            tx.commit();

            return true;

        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}