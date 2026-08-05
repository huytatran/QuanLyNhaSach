package repository;

import entity.DanhGia;
import entity.KhachHang;
import entity.Sach;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import utils.HibernateConfig;

import java.util.List;

public class DanhGiaRepo {

    // 1. Lấy danh sách Đánh giá (Mới nhất lên đầu - Không phân trang, giữ lại dự phòng)
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

    // =========================================================================
    // CHỨC NĂNG MỚI BỔ SUNG: PHÂN TRANG ĐÁNH GIÁ
    // =========================================================================

    // Hàm lấy danh sách Đánh giá có phân trang (Sắp xếp mới nhất lên đầu)
    public List<DanhGia> getDanhGiaByPage(int page, int pageSize) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Query<DanhGia> query = session.createQuery("FROM DanhGia ORDER BY maDanhGia DESC", DanhGia.class);
            query.setFirstResult((page - 1) * pageSize);
            query.setMaxResults(pageSize);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Hàm đếm tổng số lượng Đánh giá để tính số trang
    public int getTotalCount() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Query<Long> query = session.createQuery("SELECT COUNT(d) FROM DanhGia d", Long.class);
            Long count = query.uniqueResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // =========================================================================
    // CÁC HÀM HỖ TRỢ DROPDOWN
    // =========================================================================

    // 3. Hàm hỗ trợ lấy danh sách Sách cho Dropdown form
    public List<Sach> getListSach() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM Sach", Sach.class).getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 4. Hàm hỗ trợ lấy danh sách Khách Hàng cho Dropdown form
    public List<KhachHang> getListKhachHang() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM KhachHang", KhachHang.class).getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}