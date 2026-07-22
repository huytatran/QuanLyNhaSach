package repository;

import entity.Voucher;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import utils.HibernateConfig;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class VoucherRepo {

    // 1. Lấy toàn bộ danh sách Voucher (Không phân trang - Giữ lại để dự phòng)
    public List<Voucher> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM Voucher", Voucher.class).getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 2. Thêm mới Voucher (Phục vụ form Thêm mới của NV4)
    public boolean add(Voucher obj) {
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
    // CHỨC NĂNG MỚI BỔ SUNG: PHÂN TRANG VÀ XÓA MỀM (CẬP NHẬT TRẠNG THÁI)
    // =========================================================================

    // Hàm lấy danh sách Voucher có phân trang (Sắp xếp mới nhất lên đầu)
    public List<Voucher> getVouchersByPage(int page, int pageSize) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            // Sắp xếp giảm dần theo mã hoặc ngày tạo tùy bạn, ở đây mình xếp theo mã giảm dần (mới nhất)
            Query<Voucher> query = session.createQuery("FROM Voucher ORDER BY maVoucher DESC", Voucher.class);
            // setFirstResult: Vị trí bắt đầu lấy
            query.setFirstResult((page - 1) * pageSize);
            // setMaxResults: Số lượng bản ghi cần lấy trên 1 trang
            query.setMaxResults(pageSize);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Hàm đếm tổng số lượng Voucher để tính số trang
    public int getTotalCount() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Query<Long> query = session.createQuery("SELECT COUNT(v) FROM Voucher v", Long.class);
            Long count = query.uniqueResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // Hàm Xóa mềm: Chuyển voucher thành Hết hạn (Set NgayKetThuc = thời gian hiện tại)
    public boolean updateTrangThaiHetHan(Integer maVoucher) {
        Transaction tran = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tran = session.beginTransaction();
            // Lấy voucher hiện tại ra
            Voucher v = session.get(Voucher.class, maVoucher);
            if (v != null) {
                // Cập nhật ngày kết thúc thành ngay lúc bấm nút
                v.setNgayKetThuc(LocalDateTime.now());
                session.merge(v);
            }
            tran.commit();
            return true;
        } catch (Exception e) {
            if (tran != null) tran.rollback();
            e.printStackTrace();
            return false;
        }
    }


    // =========================================================================
    // PHẦN CODE TÍCH HỢP HỖ TRỢ NV3 (BÁN HÀNG - POS)
    // =========================================================================

    // 3. Hàm kiểm tra xem Voucher có tồn tại và còn điều kiện áp dụng không
    public Voucher checkVoucherHopLe(String maCode) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT v FROM Voucher v WHERE v.maCode = :maCode";
            Query<Voucher> query = session.createQuery(hql, Voucher.class);
            query.setParameter("maCode", maCode);
            Voucher v = query.uniqueResult();

            if (v != null) {
                LocalDateTime now = LocalDateTime.now();
                // Điều kiện hợp lệ: Đang trong thời gian áp dụng VÀ số lượt dùng vẫn còn
                if (!now.isBefore(v.getNgayBatDau()) && !now.isAfter(v.getNgayKetThuc()) && v.getDaSuDung() < v.getSoLuongToiDa()) {
                    return v;
                }
            }
            return null; // Không hợp lệ, quá hạn hoặc hết lượt
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 4. Hàm tính chính xác số tiền khách được giảm (NV3 sẽ gọi hàm này)
    public BigDecimal tinhTienGiamGia(String maCode, BigDecimal tongTienDonHang) {
        // 4.1 Check xem mã có hợp lệ không
        Voucher v = this.checkVoucherHopLe(maCode);

        if (v == null) {
            return BigDecimal.ZERO;
        }

        // 4.2 Check xem đơn hàng có đủ giá trị tối thiểu không
        if (tongTienDonHang.compareTo(v.getGiaTriDonToiThieu()) < 0) {
            return BigDecimal.ZERO;
        }

        BigDecimal soTienGiam = BigDecimal.ZERO;

        // 4.3 Xử lý tính toán dựa theo loại giảm giá (1: %, 2: Tiền mặt)
        if (v.getLoaiGiam() == 1) {
            // Tính số tiền giảm theo %
            BigDecimal phanTram = v.getGiaTri().divide(new BigDecimal("100"));
            soTienGiam = tongTienDonHang.multiply(phanTram);

            // Giới hạn số tiền giảm tối đa (Nếu có cấu hình và vượt quá mức cho phép)
            if (v.getGiaGiamToiDa() != null && soTienGiam.compareTo(v.getGiaGiamToiDa()) > 0) {
                soTienGiam = v.getGiaGiamToiDa();
            }

        } else if (v.getLoaiGiam() == 2) {
            // Giảm tiền mặt trực tiếp
            soTienGiam = v.getGiaTri();

            // Đảm bảo không giảm âm tiền của hóa đơn
            if (soTienGiam.compareTo(tongTienDonHang) > 0) {
                soTienGiam = tongTienDonHang;
            }
        }

        return soTienGiam;
    }
}