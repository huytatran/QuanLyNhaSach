package dao;

import entity.NhanVien;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.List;

public class NhanVienDAO {

    public NhanVien checkLogin(String taiKhoan, String matKhau) {
        if (taiKhoan == null || matKhau == null) {
            return null;
        }
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                            "FROM NhanVien nv WHERE nv.taiKhoan = :tk AND nv.matKhau = :mk",
                            NhanVien.class)
                    .setParameter("tk", taiKhoan.trim())
                    .setParameter("mk", matKhau)
                    .uniqueResult();
        }
    }

    public long demTatCa() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long count = session.createQuery("SELECT COUNT(nv) FROM NhanVien nv", Long.class)
                    .uniqueResult();
            return count == null ? 0 : count;
        }
    }

    public List<NhanVien> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM NhanVien ORDER BY maNV", NhanVien.class)
                    .getResultList();
        }
    }

    public List<NhanVien> search(String tuKhoa) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            return session.createQuery(
                            "FROM NhanVien nv WHERE LOWER(nv.tenNV) LIKE :q "
                                    + "OR LOWER(nv.taiKhoan) LIKE :q OR LOWER(nv.sdt) LIKE :q "
                                    + "ORDER BY nv.maNV",
                            NhanVien.class)
                    .setParameter("q", like)
                    .getResultList();
        }
    }

    public NhanVien getById(Integer maNV) {
        if (maNV == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(NhanVien.class, maNV);
        }
    }

    public boolean taiKhoanTonTai(String taiKhoan, Integer excludeMaNV) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(nv) FROM NhanVien nv WHERE nv.taiKhoan = :tk";
            if (excludeMaNV != null) {
                hql += " AND nv.maNV <> :ma";
            }
            var q = session.createQuery(hql, Long.class).setParameter("tk", taiKhoan.trim());
            if (excludeMaNV != null) q.setParameter("ma", excludeMaNV);
            Long c = q.uniqueResult();
            return c != null && c > 0;
        }
    }

    public void insert(NhanVien nv) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.persist(nv);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public void update(NhanVien nv) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            NhanVien old = session.get(NhanVien.class, nv.getMaNV());
            if (old == null) throw new IllegalArgumentException("Không tìm thấy nhân viên.");
            old.setTenNV(nv.getTenNV());
            old.setSdt(nv.getSdt());
            old.setEmail(nv.getEmail());
            old.setDiaChi(nv.getDiaChi());
            old.setTaiKhoan(nv.getTaiKhoan());
            old.setVaiTroNV(nv.getVaiTroNV());
            if (nv.getMatKhau() != null && !nv.getMatKhau().isBlank()) {
                old.setMatKhau(nv.getMatKhau());
            }
            session.merge(old);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /** @return false neu dang co don hang hoac khong ton tai */
    public boolean delete(Integer maNV) {
        if (maNV == null) return false;
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long soDon = session.createQuery(
                            "SELECT COUNT(dh) FROM DonHang dh WHERE dh.nhanVien.maNV = :ma",
                            Long.class)
                    .setParameter("ma", maNV)
                    .uniqueResult();
            if (soDon != null && soDon > 0) return false;

            NhanVien nv = session.get(NhanVien.class, maNV);
            if (nv == null) return false;

            tx = session.beginTransaction();
            session.remove(nv);
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}
