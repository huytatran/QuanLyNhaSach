package repository;

import entity.NhanVien;
import org.hibernate.Session;
import org.hibernate.query.Query;
import utils.HibernateConfig; // Đã import chuẩn theo cấu trúc nhóm bạn

public class NhanVienRepo {

    // Hàm kiểm tra Đăng nhập bằng Hibernate
    public NhanVien dangNhap(String taiKhoan, String matKhau) {

        // Đã sử dụng đúng lệnh getFACTORY() giống hệt trong VoucherRepo của bạn
        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            // Câu lệnh HQL: Tìm nhân viên khớp tài khoản và mật khẩu
            String hql = "SELECT nv FROM NhanVien nv WHERE nv.taiKhoan = :tk AND nv.matKhau = :mk";

            Query<NhanVien> query = session.createQuery(hql, NhanVien.class);

            // Truyền tham số tài khoản, mật khẩu vào câu truy vấn
            query.setParameter("tk", taiKhoan);
            query.setParameter("mk", matKhau);

            // Lấy ra duy nhất 1 nhân viên khớp mật khẩu (Nếu sai thì tự động trả về null)
            return query.uniqueResult();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}