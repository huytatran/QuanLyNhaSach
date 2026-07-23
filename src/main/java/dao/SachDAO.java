package dao;

import entity.Sach;
import entity.SachTacGia;
import entity.TacGia;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SachDAO {

    private static final String TRANG_THAI_CO_SAN = "Có sẵn";
    private static final String VAI_TRO_TAC_GIA = "Tác giả";

    public List<Sach> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT DISTINCT s FROM Sach s "
                            + "LEFT JOIN FETCH s.theLoai "
                            + "LEFT JOIN FETCH s.nhaXuatBan "
                            + "LEFT JOIN FETCH s.boSach "
                            + "ORDER BY s.maSach",
                    Sach.class)
                    .getResultList();
        }
    }

    /** Ban co phan trang: trang bat dau tu 1. */
    public List<Sach> getAll(int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT DISTINCT s FROM Sach s "
                            + "LEFT JOIN FETCH s.theLoai "
                            + "LEFT JOIN FETCH s.nhaXuatBan "
                            + "LEFT JOIN FETCH s.boSach "
                            + "ORDER BY s.maSach",
                    Sach.class)
                    .setFirstResult((trang - 1) * soDongMoiTrang)
                    .setMaxResults(soDongMoiTrang)
                    .getResultList();
        }
    }

    public long countAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long c = session.createQuery("SELECT COUNT(s) FROM Sach s", Long.class).uniqueResult();
            return c == null ? 0 : c;
        }
    }

    public List<Sach> search(String tuKhoa) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            return session.createQuery(
                    "SELECT DISTINCT s FROM Sach s "
                            + "LEFT JOIN FETCH s.theLoai "
                            + "LEFT JOIN FETCH s.nhaXuatBan "
                            + "LEFT JOIN FETCH s.boSach "
                            + "WHERE LOWER(s.maSach) LIKE :q OR LOWER(s.tenSach) LIKE :q "
                            + "ORDER BY s.maSach",
                    Sach.class)
                    .setParameter("q", like)
                    .getResultList();
        }
    }

    /** Ban co phan trang: trang bat dau tu 1. */
    public List<Sach> search(String tuKhoa, int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            return session.createQuery(
                    "SELECT DISTINCT s FROM Sach s "
                            + "LEFT JOIN FETCH s.theLoai "
                            + "LEFT JOIN FETCH s.nhaXuatBan "
                            + "LEFT JOIN FETCH s.boSach "
                            + "WHERE LOWER(s.maSach) LIKE :q OR LOWER(s.tenSach) LIKE :q "
                            + "ORDER BY s.maSach",
                    Sach.class)
                    .setParameter("q", like)
                    .setFirstResult((trang - 1) * soDongMoiTrang)
                    .setMaxResults(soDongMoiTrang)
                    .getResultList();
        }
    }

    public long countSearch(String tuKhoa) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            Long c = session.createQuery(
                    "SELECT COUNT(DISTINCT s) FROM Sach s WHERE LOWER(s.maSach) LIKE :q OR LOWER(s.tenSach) LIKE :q",
                    Long.class)
                    .setParameter("q", like)
                    .uniqueResult();
            return c == null ? 0 : c;
        }
    }

    public Sach getById(String maSach) {
        if (maSach == null || maSach.isBlank()) {
            return null;
        }
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT s FROM Sach s "
                            + "LEFT JOIN FETCH s.theLoai "
                            + "LEFT JOIN FETCH s.nhaXuatBan "
                            + "LEFT JOIN FETCH s.boSach "
                            + "WHERE s.maSach = :ma",
                    Sach.class)
                    .setParameter("ma", maSach.trim())
                    .uniqueResult();
        }
    }

    /**
     * Dem so cuon SachVatLy trang thai "Có sẵn" theo tung MaSach.
     */
    public Map<String, Long> getTonKhoMap() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<Object[]> rows = session.createQuery(
                    "SELECT sv.sach.maSach, COUNT(sv.maSerial) "
                            + "FROM SachVatLy sv "
                            + "WHERE sv.trangThai = :tt "
                            + "GROUP BY sv.sach.maSach",
                    Object[].class)
                    .setParameter("tt", TRANG_THAI_CO_SAN)
                    .getResultList();

            Map<String, Long> map = new HashMap<>();
            for (Object[] row : rows) {
                map.put((String) row[0], (Long) row[1]);
            }
            return map;
        }
    }

    public TacGia getTacGiaChinh(String maSach) {
        if (maSach == null || maSach.isBlank()) {
            return null;
        }
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<TacGia> list = session.createQuery(
                    "SELECT st.tacGia FROM SachTacGia st "
                            + "WHERE st.sach.maSach = :ma "
                            + "ORDER BY st.vaiTroTG",
                    TacGia.class)
                    .setParameter("ma", maSach.trim())
                    .setMaxResults(1)
                    .getResultList();
            return list.isEmpty() ? null : list.get(0);
        }
    }

    /**
     * @return false neu ma sach da ton tai
     */
    public boolean insert(Sach sach, Integer maTacGia) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            if (session.get(Sach.class, sach.getMaSach()) != null) {
                return false;
            }
            tx = session.beginTransaction();
            session.persist(sach);
            if (maTacGia != null) {
                luuTacGiaChinh(session, sach.getMaSach(), maTacGia);
            }
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) {
                tx.rollback();
            }
            throw e;
        }
    }

    public void update(Sach sach, Integer maTacGia) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.merge(sach);

            // Xoa lien ket tac gia cu roi gan lai (1 tac gia chinh tren form)
            session.createMutationQuery("DELETE FROM SachTacGia st WHERE st.sach.maSach = :ma")
                    .setParameter("ma", sach.getMaSach())
                    .executeUpdate();
            if (maTacGia != null) {
                luuTacGiaChinh(session, sach.getMaSach(), maTacGia);
            }
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) {
                tx.rollback();
            }
            throw e;
        }
    }

    /**
     * Chi xoa khi chua co ban ghi SachVatLy nao (theo nghiep vu SachServlet).
     * @return false neu khong xoa duoc
     */
    public boolean delete(String maSach) {
        if (maSach == null || maSach.isBlank()) {
            return false;
        }
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long soVatLy = session.createQuery(
                    "SELECT COUNT(sv) FROM SachVatLy sv WHERE sv.sach.maSach = :ma",
                    Long.class)
                    .setParameter("ma", maSach.trim())
                    .uniqueResult();
            if (soVatLy != null && soVatLy > 0) {
                return false;
            }

            Sach sach = session.get(Sach.class, maSach.trim());
            if (sach == null) {
                return false;
            }

            tx = session.beginTransaction();
            session.createMutationQuery("DELETE FROM SachTacGia st WHERE st.sach.maSach = :ma")
                    .setParameter("ma", maSach.trim())
                    .executeUpdate();
            session.createMutationQuery("DELETE FROM DanhGia dg WHERE dg.sach.maSach = :ma")
                    .setParameter("ma", maSach.trim())
                    .executeUpdate();
            session.remove(sach);
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) {
                tx.rollback();
            }
            throw e;
        }
    }

    private void luuTacGiaChinh(Session session, String maSach, Integer maTacGia) {
        Sach sachRef = session.getReference(Sach.class, maSach);
        TacGia tacGiaRef = session.getReference(TacGia.class, maTacGia);
        SachTacGia st = new SachTacGia();
        st.setSach(sachRef);
        st.setTacGia(tacGiaRef);
        st.setVaiTroTG(VAI_TRO_TAC_GIA);
        session.persist(st);
    }
}
