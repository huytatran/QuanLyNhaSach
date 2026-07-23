package dao;

import entity.SachVatLy;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.List;

public class SachVatLyDAO {

    /**
     * Luu hang loat cac cuon sach vat ly vao co so du lieu.
     * Thuong dung khi nhap mot lo hang lon.
     */
    public void insertBatch(List<SachVatLy> list) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            for (SachVatLy sv : list) {
                // Kiem tra ton tai truoc khi insert de tranh loi duplicate primary key (MaSerial)
                // Neu ma serial da ton tai thi bo qua khong chen nua
                if (session.get(SachVatLy.class, sv.getMaSerial()) == null) {
                    session.persist(sv);
                }
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
     * Lay danh sach cac cuon sach vat ly thuoc ve mot dau sach cu the.
     */
    public List<SachVatLy> getByMaSach(String maSach) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM SachVatLy sv WHERE sv.sach.maSach = :ma", SachVatLy.class)
                    .setParameter("ma", maSach)
                    .getResultList();
        }
    }
}
