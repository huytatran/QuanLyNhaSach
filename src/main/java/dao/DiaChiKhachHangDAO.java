package dao;

import entity.DiaChiKhachHang;
import entity.KhachHang;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.List;

/**
 * DAO cho DiaChiKhachHang. 1 khach hang co the co nhieu dia chi
 * lien he (dung de xuat hoa don hoac cham soc khach than thiet -
 * KHONG phai dia chi giao hang vi day la ban offline tai quay).
 * LaMacDinh danh dau dia chi duoc chon san khi lap hoa don.
 */
public class DiaChiKhachHangDAO {

    public List<DiaChiKhachHang> getByKhachHang(Integer maKH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "FROM DiaChiKhachHang dc WHERE dc.khachHang.maKH = :ma "
                            + "ORDER BY dc.laMacDinh DESC, dc.maDiaChi",
                    DiaChiKhachHang.class)
                    .setParameter("ma", maKH)
                    .getResultList();
        }
    }

    public DiaChiKhachHang getById(Integer maDiaChi) {
        if (maDiaChi == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(DiaChiKhachHang.class, maDiaChi);
        }
    }

    /** Them dia chi moi. Neu la dia chi dau tien cua khach, tu dong dat lam mac dinh. */
    public void insert(Integer maKH, String diaChiChiTiet, boolean laMacDinh) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            KhachHang kh = session.get(KhachHang.class, maKH);
            if (kh == null) throw new IllegalArgumentException("Không tìm thấy khách hàng.");

            Long soDiaChiHienCo = session.createQuery(
                    "SELECT COUNT(dc) FROM DiaChiKhachHang dc WHERE dc.khachHang.maKH = :ma", Long.class)
                    .setParameter("ma", maKH)
                    .uniqueResult();
            boolean macDinh = laMacDinh || soDiaChiHienCo == null || soDiaChiHienCo == 0;

            tx = session.beginTransaction();
            if (macDinh) {
                boThamDinhCacDiaChiKhac(session, maKH);
            }
            DiaChiKhachHang dc = new DiaChiKhachHang();
            dc.setKhachHang(kh);
            dc.setDiaChiChiTiet(diaChiChiTiet);
            dc.setLaMacDinh(macDinh);
            session.persist(dc);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    public void update(Integer maDiaChi, String diaChiChiTiet) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            DiaChiKhachHang dc = session.get(DiaChiKhachHang.class, maDiaChi);
            if (dc == null) throw new IllegalArgumentException("Không tìm thấy địa chỉ.");
            dc.setDiaChiChiTiet(diaChiChiTiet);
            session.merge(dc);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /** Dat 1 dia chi lam mac dinh - tu dong bo mac dinh cac dia chi khac cua cung khach. */
    public void datMacDinh(Integer maDiaChi) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            DiaChiKhachHang dc = session.get(DiaChiKhachHang.class, maDiaChi);
            if (dc == null) throw new IllegalArgumentException("Không tìm thấy địa chỉ.");

            tx = session.beginTransaction();
            boThamDinhCacDiaChiKhac(session, dc.getKhachHang().getMaKH());
            dc.setLaMacDinh(true);
            session.merge(dc);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    private void boThamDinhCacDiaChiKhac(Session session, Integer maKH) {
        session.createMutationQuery("UPDATE DiaChiKhachHang dc SET dc.laMacDinh = false WHERE dc.khachHang.maKH = :ma")
                .setParameter("ma", maKH)
                .executeUpdate();
    }

    /** Xoa 1 dia chi. Neu dia chi vua xoa la mac dinh, tu dong gan mac dinh cho dia chi con lai dau tien (neu co). */
    public void delete(Integer maDiaChi) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            DiaChiKhachHang dc = session.get(DiaChiKhachHang.class, maDiaChi);
            if (dc == null) return;
            Integer maKH = dc.getKhachHang().getMaKH();
            boolean laMacDinh = Boolean.TRUE.equals(dc.getLaMacDinh());

            tx = session.beginTransaction();
            session.remove(dc);

            if (laMacDinh) {
                List<DiaChiKhachHang> conLai = session.createQuery(
                        "FROM DiaChiKhachHang dc WHERE dc.khachHang.maKH = :ma ORDER BY dc.maDiaChi",
                        DiaChiKhachHang.class)
                        .setParameter("ma", maKH)
                        .setMaxResults(1)
                        .getResultList();
                if (!conLai.isEmpty()) {
                    DiaChiKhachHang moi = conLai.get(0);
                    moi.setLaMacDinh(true);
                    session.merge(moi);
                }
            }
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}
