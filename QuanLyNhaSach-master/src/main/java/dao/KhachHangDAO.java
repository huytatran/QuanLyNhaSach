package dao;

import entity.KhachHang;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO cho KhachHang. Ban hang offline tai quay (khong giao hang) nen
 * form khach hang chi can thong tin lien he co ban (Ten/Sdt/Email).
 * Dia chi (dung de xuat hoa don hoac cham soc khach than thiet) duoc
 * quan ly rieng trong DiaChiKhachHangDAO vi 1 khach co the co nhieu
 * dia chi (quan he N-1).
 */
public class KhachHangDAO {

    public List<KhachHang> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM KhachHang ORDER BY tenKH", KhachHang.class)
                    .getResultList();
        }
    }

    /** Ban co phan trang: trang bat dau tu 1. */
    public List<KhachHang> getAll(int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM KhachHang ORDER BY tenKH", KhachHang.class)
                    .setFirstResult((trang - 1) * soDongMoiTrang)
                    .setMaxResults(soDongMoiTrang)
                    .getResultList();
        }
    }

    public long countAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long c = session.createQuery("SELECT COUNT(kh) FROM KhachHang kh", Long.class).uniqueResult();
            return c == null ? 0 : c;
        }
    }

    /** Tim theo ten hoac so dien thoai - dung ca cho man Quan ly khach hang lan o POS. */
    public List<KhachHang> search(String tuKhoa) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            return session.createQuery(
                    "FROM KhachHang kh WHERE LOWER(kh.tenKH) LIKE :q OR LOWER(kh.sdt) LIKE :q "
                            + "ORDER BY kh.tenKH",
                    KhachHang.class)
                    .setParameter("q", like)
                    .getResultList();
        }
    }

    /** Ban co phan trang: trang bat dau tu 1. */
    public List<KhachHang> search(String tuKhoa, int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            return session.createQuery(
                    "FROM KhachHang kh WHERE LOWER(kh.tenKH) LIKE :q OR LOWER(kh.sdt) LIKE :q "
                            + "ORDER BY kh.tenKH",
                    KhachHang.class)
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
                    "SELECT COUNT(kh) FROM KhachHang kh WHERE LOWER(kh.tenKH) LIKE :q OR LOWER(kh.sdt) LIKE :q",
                    Long.class)
                    .setParameter("q", like)
                    .uniqueResult();
            return c == null ? 0 : c;
        }
    }

    public KhachHang getById(Integer maKH) {
        if (maKH == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(KhachHang.class, maKH);
        }
    }

    /**
     * Lay dia chi mac dinh (LaMacDinh = true) cua tung khach hang, dung
     * de hien nhanh trong bang danh sach ma khong can vao tung khach.
     * @return Map<MaKH, DiaChiChiTiet>
     */
    public Map<Integer, String> getDiaChiMacDinhMap() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT dc.khachHang.maKH, dc.diaChiChiTiet FROM DiaChiKhachHang dc "
                    + "WHERE dc.laMacDinh = true";
            List<Object[]> rows = session.createQuery(hql, Object[].class).getResultList();
            Map<Integer, String> map = new HashMap<>();
            for (Object[] row : rows) {
                map.put((Integer) row[0], (String) row[1]);
            }
            return map;
        }
    }

    public KhachHang insert(KhachHang kh) {          // đổi void -> KhachHang
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            if (kh.getDiemTichLuy() == null) kh.setDiemTichLuy(0);
            if (kh.getTrangThai() == null) kh.setTrangThai(true); // mac dinh: dang hoat dong
            session.persist(kh);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
        return kh;                                    // thêm dòng này
    }

    /**
     * Dung cho nut "Xoa" tren giao dien: KHONG xoa cung ban ghi (se loi
     * vi lien quan bang phu DiaChiKhachHang / DonHang), ma chi cap nhat
     * TrangThai = false (ngung hoat dong). Du lieu va lich su don hang
     * cua khach van con nguyen, chi khong con hien la khach dang hoat dong.
     */
    public void ngungHoatDong(Integer maKH) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            KhachHang kh = session.get(KhachHang.class, maKH);
            if (kh == null) throw new IllegalArgumentException("Không tìm thấy khách hàng.");
            kh.setTrangThai(false);
            session.merge(kh);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /** Bat/tat hoat dong (dung cho cong tac Trang thai) - dao nguoc gia tri hien tai. */
    public void doiTrangThai(Integer maKH) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            KhachHang kh = session.get(KhachHang.class, maKH);
            if (kh == null) throw new IllegalArgumentException("Không tìm thấy khách hàng.");
            kh.setTrangThai(!Boolean.TRUE.equals(kh.getTrangThai()));
            session.merge(kh);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public void update(KhachHang kh) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            KhachHang old = session.get(KhachHang.class, kh.getMaKH());
            if (old == null) throw new IllegalArgumentException("Không tìm thấy khách hàng.");
            old.setTenKH(kh.getTenKH());
            old.setSdt(kh.getSdt());
            old.setEmail(kh.getEmail());
            if (kh.getDiemTichLuy() != null) old.setDiemTichLuy(kh.getDiemTichLuy());
            session.merge(old);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Xoa khach hang - CHI cho xoa neu khach chua tung co don hang nao
     * (kiem tra bang DonHang truoc, tranh vi pham FK). Neu chua co don
     * hang thi xoa luon dia chi cua khach (bang phu, khong con y nghia
     * gi khi khach da bi xoa).
     * @return true neu xoa thanh cong, false neu khach da tung mua hang.
     */
    public boolean delete(Integer maKH) {
        if (maKH == null) return false;
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long soDon = session.createQuery(
                    "SELECT COUNT(dh) FROM DonHang dh WHERE dh.khachHang.maKH = :ma", Long.class)
                    .setParameter("ma", maKH)
                    .uniqueResult();
            if (soDon != null && soDon > 0) return false;

            KhachHang kh = session.get(KhachHang.class, maKH);
            if (kh == null) return false;

            tx = session.beginTransaction();
            session.createMutationQuery("DELETE FROM DiaChiKhachHang dc WHERE dc.khachHang.maKH = :ma")
                    .setParameter("ma", maKH)
                    .executeUpdate();
            session.remove(kh);
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}
