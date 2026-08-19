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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet({"/voucher/hien-thi", "/voucher/them", "/voucher/het-han"})
public class VoucherServlet extends HttpServlet {

    private VoucherRepo voucherRepo = new VoucherRepo();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();

        // 1. CHỨC NĂNG XÓA MỀM (CHUYỂN TRẠNG THÁI HẾT HẠN)
        if (uri.contains("/het-han")) {
            try {
                Integer maVoucher = Integer.parseInt(request.getParameter("ma"));
                voucherRepo.updateTrangThaiHetHan(maVoucher);
            } catch (Exception e) {
                e.printStackTrace();
            }
            response.sendRedirect(request.getContextPath() + "/voucher/hien-thi");
            return;
        }

        // 2. CHỨC NĂNG HIỂN THỊ, LỌC VÀ PHÂN TRANG (ĐÃ TỐI ƯU BẰNG JAVA STREAM)
        if (uri.contains("/hien-thi")) {
            int page = 1;
            int pageSize = 5;

            if (request.getParameter("page") != null) {
                try {
                    page = Integer.parseInt(request.getParameter("page"));
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            // Lấy TẤT CẢ dữ liệu từ Database lên (Truyền số trang lớn để lấy hết)
            // Trick này giúp bạn không cần viết thêm hàm SQL phức tạp trong DAO
            List<Voucher> listAll = voucherRepo.getVouchersByPage(1, 999999);

            // BẮT CÁC THAM SỐ TỪ FORM BỘ LỌC BÊN JSP GỬI LÊN
            String searchCode = request.getParameter("searchCode");
            String filterCodeDropdown = request.getParameter("filterCodeDropdown");
            String filterStatus = request.getParameter("filterStatus");
            String filterDate = request.getParameter("filterDate");

            LocalDateTime now = LocalDateTime.now();

            // SỬ DỤNG JAVA STREAM ĐỂ LỌC DỮ LIỆU
            List<Voucher> filteredList = listAll.stream().filter(v -> {
                // Lọc theo ô gõ tìm kiếm
                boolean matchSearch = (searchCode == null || searchCode.trim().isEmpty())
                        || v.getMaCode().toLowerCase().contains(searchCode.trim().toLowerCase());

                // Lọc theo Dropdown chọn mã
                boolean matchDropdown = (filterCodeDropdown == null || filterCodeDropdown.trim().isEmpty())
                        || v.getMaCode().equalsIgnoreCase(filterCodeDropdown.trim());

                // Lọc theo Trạng thái (Tính toán trạng thái động y hệt bên giao diện)
                boolean matchStatus = true;
                if (filterStatus != null && !filterStatus.trim().isEmpty()) {
                    String currentStatus = "Đang chạy";
                    if (v.getDaSuDung() >= v.getSoLuongToiDa()) { currentStatus = "Hết lượt"; }
                    else if (now.isAfter(v.getNgayKetThuc())) { currentStatus = "Đã kết thúc"; }
                    else if (now.isBefore(v.getNgayBatDau())) { currentStatus = "Sắp diễn ra"; }

                    if (filterStatus.equals("Đã kết thúc")) {
                        matchStatus = currentStatus.equals("Đã kết thúc") || currentStatus.equals("Hết lượt");
                    } else {
                        matchStatus = currentStatus.equals(filterStatus);
                    }
                }

                // Lọc theo Ngày (Kiểm tra xem ngày chọn có rơi vào thời gian hiệu lực không)
                boolean matchDate = true;
                if (filterDate != null && !filterDate.trim().isEmpty()) {
                    try {
                        LocalDate selectedDate = LocalDate.parse(filterDate);
                        LocalDate startDate = v.getNgayBatDau().toLocalDate();
                        LocalDate endDate = v.getNgayKetThuc().toLocalDate();
                        matchDate = !selectedDate.isBefore(startDate) && !selectedDate.isAfter(endDate);
                    } catch (Exception e) {
                        matchDate = true; // Bỏ qua nếu lỗi format ngày
                    }
                }

                // Phải thỏa mãn TẤT CẢ các bộ lọc thì mới giữ lại
                return matchSearch && matchDropdown && matchStatus && matchDate;

            }).collect(Collectors.toList());

            // TÍNH TOÁN LẠI PHÂN TRANG DỰA TRÊN DANH SÁCH ĐÃ LỌC
            int totalVouchers = filteredList.size();
            int totalPages = (int) Math.ceil((double) totalVouchers / pageSize);

            if (page > totalPages && totalPages > 0) { page = totalPages; }
            if (page < 1) { page = 1; }

            int fromIndex = (page - 1) * pageSize;
            int toIndex = Math.min(fromIndex + pageSize, totalVouchers);

            // Cắt danh sách lấy đúng 5 phần tử của trang hiện tại
            List<Voucher> pagedList = filteredList.subList(fromIndex, toIndex);

            // Gửi dữ liệu sang JSP
            request.setAttribute("listAllVoucher", listAll); // Truyền toàn bộ sang để Dropdown chọn mã hiển thị đủ
            request.setAttribute("listVoucher", pagedList);  // Truyền phần đã lọc và cắt trang sang bảng
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
                v.setLoaiGiam(Short.parseShort(loaiGiam));
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