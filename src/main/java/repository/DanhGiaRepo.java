package repository;

import entity.DanhGia;
import entity.KhachHang;
import entity.Sach;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.List;

public class DanhGiaRepo {

    // 1. Lấy danh sách Đánh giá (Mới nhất lên đầu)
    public List<DanhGia> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM DanhGia ORDER BY maDanhGia DESC", DanhGia.class).getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 2. Thêm đánh giá mới
    public boolean add(DanhGia obj) {
        Transaction tran = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tran = session.beginTransaction();
            session.persist(obj);
            tran.commit();
            return true;
        } catch (Exception e) {
            if (tran != null) tran.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // 3. Hàm hỗ trợ lấy danh sách Sách cho Dropdown form
    public List<Sach> getListSach() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM Sach", Sach.class).getResultList();
        } catch (Exception e) {
            return null;
        }
    }

    // 4. Hàm hỗ trợ lấy danh sách Khách Hàng cho Dropdown form
    public List<KhachHang> getListKhachHang() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM KhachHang", KhachHang.class).getResultList();
        } catch (Exception e) {
            return null;
        }
    }
}