package controller;

import entity.Voucher;
import repository.VoucherRepo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

// Đã bổ sung thêm đường dẫn /voucher/het-han vào đây
@WebServlet({"/voucher/hien-thi", "/voucher/them", "/voucher/het-han"})
public class VoucherServlet extends HttpServlet {

    private VoucherRepo voucherRepo = new VoucherRepo();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();

        // 1. CHỨC NĂNG XÓA MỀM (CHUYỂN TRẠNG THÁI HẾT HẠN)
        if (uri.contains("/het-han")) {
            try {
                // Lấy mã voucher từ URL (nút thùng rác gửi lên)
                Integer maVoucher = Integer.parseInt(request.getParameter("ma"));
                // Gọi repo để cập nhật ngày kết thúc về hiện tại
                voucherRepo.updateTrangThaiHetHan(maVoucher);
            } catch (Exception e) {
                e.printStackTrace();
            }
            // Xong việc thì quay lại trang hiển thị
            response.sendRedirect(request.getContextPath() + "/voucher/hien-thi");
            return; // Phải có return để dừng xử lý code bên dưới
        }

        // 2. CHỨC NĂNG HIỂN THỊ VÀ PHÂN TRANG
        if (uri.contains("/hien-thi")) {
            int page = 1; // Mặc định ở trang 1
            int pageSize = 5; // Số lượng voucher trên 1 trang (bạn có thể đổi số này)

            // Nếu có tham số page trên URL thì lấy giá trị đó
            if (request.getParameter("page") != null) {
                try {
                    page = Integer.parseInt(request.getParameter("page"));
                } catch (NumberFormatException e) {
                    page = 1; // Tránh lỗi nếu người dùng nhập linh tinh
                }
            }

            // Gọi hàm lấy danh sách theo phân trang
            List<Voucher> listVoucher = voucherRepo.getVouchersByPage(page, pageSize);

            // Tính toán tổng số trang
            int totalVouchers = voucherRepo.getTotalCount();
            int totalPages = (int) Math.ceil((double) totalVouchers / pageSize);

            // Gửi dữ liệu sang JSP
            request.setAttribute("listVoucher", listVoucher);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);

            request.getRequestDispatcher("/view/voucher.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String uri = request.getRequestURI();

        if (uri.contains("/them")) {
            try {
                String maCode = request.getParameter("maCode");
                String loaiGiam = request.getParameter("loaiGiam");
                String giaTri = request.getParameter("giaTri");
                String giaTriDonToiThieu = request.getParameter("giaTriDonToiThieu");
                String giaGiamToiDa = request.getParameter("giaGiamToiDa");
                String soLuongToiDa = request.getParameter("soLuongToiDa");
                String strNgayBatDau = request.getParameter("ngayBatDau");
                String strNgayKetThuc = request.getParameter("ngayKetThuc");

                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
                Voucher v = new Voucher();
                v.setMaCode(maCode);
                v.setLoaiGiam(Integer.parseInt(loaiGiam));
                v.setGiaTri(new BigDecimal(giaTri));
                v.setGiaTriDonToiThieu(new BigDecimal(giaTriDonToiThieu));
                v.setGiaGiamToiDa(new BigDecimal(giaGiamToiDa));
                v.setNgayBatDau(LocalDateTime.parse(strNgayBatDau, formatter));
                v.setNgayKetThuc(LocalDateTime.parse(strNgayKetThuc, formatter));
                v.setSoLuongToiDa(Integer.parseInt(soLuongToiDa));
                v.setDaSuDung(0);

                voucherRepo.add(v);
                response.sendRedirect(request.getContextPath() + "/voucher/hien-thi");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}