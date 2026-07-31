package controller;

import dao.DonHangDAO;
import dao.KhachHangDAO;
import dao.SachDAO;
import entity.KhachHang;
import entity.NhanVien;
import entity.Sach;
import entity.Voucher;
import repository.VoucherRepo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/pos")
public class PosServlet extends HttpServlet {

    private final SachDAO sachDAO = new SachDAO();
    private final KhachHangDAO khachHangDAO = new KhachHangDAO();
    private final DonHangDAO donHangDAO = new DonHangDAO();
    private final VoucherRepo voucherRepo = new VoucherRepo();

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String q = request.getParameter("q");
        // Chi lay nhung sach dang con kinh doanh (trangThai = true) de ban tai quay POS
        List<Sach> danhSach = (q != null && !q.isBlank()) ? sachDAO.searchDangBan(q.trim()) : sachDAO.getAllDangBan();
        Map<String, Long> tonKho = sachDAO.getTonKhoMap();

        HttpSession session = request.getSession();
        Map<String, Integer> gioHang = (Map<String, Integer>) session.getAttribute("gioHang");
        if (gioHang == null) {
            gioHang = new LinkedHashMap<>();
            session.setAttribute("gioHang", gioHang);
        }

        request.setAttribute("danhSachSach", danhSach);
        request.setAttribute("tonKhoMap", tonKho);
        request.setAttribute("dsKhachHang", khachHangDAO.getAll());

        // Lấy danh sách voucher hợp lệ
        List<Voucher> dsVoucher = voucherRepo.getVouchersHopLe();

        // Lọc voucher theo loại khách (mới/cũ) nếu có khách được chọn
        Integer maKHSelected = (Integer) session.getAttribute("maKHSelected");
        boolean isNewCustomer = false;
        if (maKHSelected != null) {
            isNewCustomer = !khachHangDAO.hasOrder(maKHSelected);
            dsVoucher = filterVouchersForCustomerType(dsVoucher, isNewCustomer);
        }

        request.setAttribute("dsVoucher", dsVoucher);
        request.setAttribute("isNewCustomer", isNewCustomer);
        request.setAttribute("maKHSelected", maKHSelected);
        request.setAttribute("chiTietGio", buildChiTietGio(gioHang, tonKho));

        // ------------------ LOGIC TÍNH TIỀN CÓ VOUCHER ------------------
        BigDecimal tongTienGio = tinhTong(gioHang);
        BigDecimal soTienGiam = BigDecimal.ZERO;

        // Lấy danh sách vouchers đã áp từ session
        @SuppressWarnings("unchecked")
        List<String> appliedVouchers = (List<String>) session.getAttribute("appliedVouchers");
        if (appliedVouchers == null) {
            appliedVouchers = new ArrayList<>();
            session.setAttribute("appliedVouchers", appliedVouchers);
        }
        
        // Tính tổng tiền giảm từ tất cả vouchers áp dụng (mỗi % tính trên tổng gốc)
        for (String maCode : appliedVouchers) {
            if (maCode != null && !maCode.isBlank()) {
                BigDecimal discount = voucherRepo.tinhTienGiamGia(maCode, tongTienGio);
                soTienGiam = soTienGiam.add(discount);
            }
        }

        BigDecimal tongTienPhaiTra = tongTienGio.subtract(soTienGiam);
        if (tongTienPhaiTra.compareTo(BigDecimal.ZERO) < 0) {
            tongTienPhaiTra = BigDecimal.ZERO;
        }

        // Tính cap dựa trên loại khách
        BigDecimal capPercent = isNewCustomer ? new BigDecimal("0.4") : new BigDecimal("0.2");
        BigDecimal capAmount = tongTienGio.multiply(capPercent);
        BigDecimal currentDiscountPercent = tongTienGio.compareTo(BigDecimal.ZERO) > 0
            ? soTienGiam.divide(tongTienGio, 2, java.math.RoundingMode.HALF_UP)
            : BigDecimal.ZERO;

        request.setAttribute("tongTienGio", tongTienGio);
        request.setAttribute("soTienGiam", soTienGiam);
        request.setAttribute("tongTienPhaiTra", tongTienPhaiTra);
        request.setAttribute("appliedVouchers", appliedVouchers);
        request.setAttribute("capPercent", capPercent.multiply(new BigDecimal("100")).intValue());
        request.setAttribute("capAmount", capAmount);
        request.setAttribute("currentDiscountPercent", currentDiscountPercent.multiply(new BigDecimal("100")).intValue());
        // ----------------------------------------------------------------

        request.setAttribute("tuKhoa", q);
        request.setAttribute("activeMenu", "pos");
        request.getRequestDispatcher("/view/pos.jsp").forward(request, response);
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        Map<String, Integer> gioHang = (Map<String, Integer>) session.getAttribute("gioHang");

        // Lưu maKH được chọn vào session (nếu form gửi kèm) để giữ selection across redirects
        String maKHParam = request.getParameter("maKH");
        if (maKHParam != null && !maKHParam.isBlank()) {
            try {
                session.setAttribute("maKHSelected", Integer.valueOf(maKHParam));
            } catch (NumberFormatException ignored) { }
        }

        if ("addKH".equals(action)) {
            String ten = request.getParameter("tenKH");
            String sdt = request.getParameter("sdt");
            if (ten != null && !ten.isBlank()) {
                KhachHang kh = new KhachHang();
                kh.setTenKH(ten.trim());
                kh.setSdt(sdt != null ? sdt.trim() : "");
                KhachHang saved = khachHangDAO.insert(kh);

                response.setContentType("application/json");
                response.getWriter().write(String.format("{\"maKH\": %d, \"tenKH\": \"%s\"}",
                        saved.getMaKH(), saved.getTenKH()));
            }
            return;
        }

        if (gioHang == null) {
            gioHang = new LinkedHashMap<>();
            session.setAttribute("gioHang", gioHang);
        }

        if ("add".equals(action)) {
            String ma = request.getParameter("ma");
            Map<String, Long> ton = sachDAO.getTonKhoMap();
            long coSan = ton.getOrDefault(ma, 0L);
            int hienTai = gioHang.getOrDefault(ma, 0);
            if (hienTai + 1 > coSan) {
                response.sendRedirect(request.getContextPath() + "/pos?loi=" +
                        java.net.URLEncoder.encode("Không đủ tồn kho cho mã " + ma, "UTF-8"));
                return;
            }
            gioHang.put(ma, hienTai + 1);
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        if ("update".equals(action)) {
            String ma = request.getParameter("ma");
            int sl = parseInt(request.getParameter("soLuong"), 1);
            Map<String, Long> ton = sachDAO.getTonKhoMap();
            long coSan = ton.getOrDefault(ma, 0L);
            if (sl <= 0) {
                gioHang.remove(ma);
            } else if (sl > coSan) {
                response.sendRedirect(request.getContextPath() + "/pos?loi=" +
                        java.net.URLEncoder.encode("Chỉ còn " + coSan + " cuốn cho mã " + ma, "UTF-8"));
                return;
            } else {
                gioHang.put(ma, sl);
            }
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        if ("remove".equals(action)) {
            gioHang.remove(request.getParameter("ma"));
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        if ("clear".equals(action)) {
            gioHang.clear();
            session.removeAttribute("appliedVouchers");
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        if ("applyVoucherSingle".equals(action)) {
            String maCode = request.getParameter("maCode");

            if (maCode != null && !maCode.isBlank()) {
                @SuppressWarnings("unchecked")
                List<String> appliedVouchers = (List<String>) session.getAttribute("appliedVouchers");
                if (appliedVouchers == null) {
                    appliedVouchers = new ArrayList<>();
                    session.setAttribute("appliedVouchers", appliedVouchers);
                }

                // Kiểm tra tối đa 2 vouchers
                if (appliedVouchers.size() >= 2) {
                    response.sendRedirect(request.getContextPath() + "/pos?loi=" +
                            java.net.URLEncoder.encode("Tối đa chỉ được áp 2 vouchers cùng lúc", "UTF-8"));
                    return;
                }

                // Kiểm tra voucher đã được áp hay chưa
                if (appliedVouchers.contains(maCode.trim())) {
                    response.sendRedirect(request.getContextPath() + "/pos?loi=" +
                            java.net.URLEncoder.encode("Voucher này đã được áp dụng rồi", "UTF-8"));
                    return;
                }

                // Kiểm tra cap trước khi áp
                BigDecimal tongTien = tinhTong(gioHang);
                if (tongTien.compareTo(BigDecimal.ZERO) <= 0) {
                    response.sendRedirect(request.getContextPath() + "/pos?loi=" +
                            java.net.URLEncoder.encode("Giỏ hàng rỗng, không thể áp voucher", "UTF-8"));
                    return;
                }

                BigDecimal currentTotal = BigDecimal.ZERO;
                for (String ma : appliedVouchers) {
                    currentTotal = currentTotal.add(voucherRepo.tinhTienGiamGia(ma, tongTien));
                }

                BigDecimal newDiscount = voucherRepo.tinhTienGiamGia(maCode.trim(), tongTien);

                // Kiểm tra voucher hợp lệ
                if (newDiscount.compareTo(BigDecimal.ZERO) <= 0) {
                    response.sendRedirect(request.getContextPath() + "/pos?loi=" +
                            java.net.URLEncoder.encode("Voucher này không áp dụng được (có thể hết lượt hoặc không đạt điều kiện)", "UTF-8"));
                    return;
                }

                BigDecimal totalWithNew = currentTotal.add(newDiscount);

                Integer maKHSelected = (Integer) session.getAttribute("maKHSelected");
                boolean isNewCustomer = (maKHSelected != null) && !khachHangDAO.hasOrder(maKHSelected);
                BigDecimal capPercent = isNewCustomer ? new BigDecimal("0.4") : new BigDecimal("0.2");
                BigDecimal capAmount = tongTien.multiply(capPercent);

                if (totalWithNew.compareTo(capAmount) > 0) {
                    response.sendRedirect(request.getContextPath() + "/pos?loi=" +
                            java.net.URLEncoder.encode("Áp voucher này sẽ vượt ngưỡng giảm giá (" + capPercent.multiply(new BigDecimal("100")).intValue() + "%)", "UTF-8"));
                    return;
                }

                appliedVouchers.add(maCode.trim());
            }

            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        if ("removeAppliedVoucher".equals(action)) {
            String maCode = request.getParameter("maCode");
            if (maCode != null && !maCode.isBlank()) {
                @SuppressWarnings("unchecked")
                List<String> appliedVouchers = (List<String>) session.getAttribute("appliedVouchers");
                if (appliedVouchers != null) {
                    appliedVouchers.remove(maCode.trim());
                }
            }
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        if ("cancelAllVouchers".equals(action)) {
            session.removeAttribute("appliedVouchers");
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        if ("applyVoucher".equals(action)) {
            String maCode = request.getParameter("maCode");
            String maCode2 = request.getParameter("maCode2");

            if (maCode != null && !maCode.isBlank()) {
                session.setAttribute("maVoucherApDung", maCode);
            } else {
                session.removeAttribute("maVoucherApDung");
            }

            if (maCode2 != null && !maCode2.isBlank()) {
                session.setAttribute("maVoucherApDung2", maCode2);
            } else {
                session.removeAttribute("maVoucherApDung2");
            }

            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        if ("checkout".equals(action)) {
            String maKHStr = request.getParameter("maKH");
            String pttt = request.getParameter("phuongThuc");

            if (maKHStr == null || maKHStr.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/pos?loi=" +
                        java.net.URLEncoder.encode("Vui lòng chọn khách hàng.", "UTF-8"));
                return;
            }
            if (gioHang.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/pos?loi=" +
                        java.net.URLEncoder.encode("Giỏ hàng trống.", "UTF-8"));
                return;
            }

            NhanVien nv = (NhanVien) session.getAttribute("currentUser");
            try {
                BigDecimal tongTien = tinhTong(gioHang);
                BigDecimal soTienGiam = BigDecimal.ZERO;

                // Tính giảm từ tất cả vouchers áp dụng (% trên tổng gốc)
                @SuppressWarnings("unchecked")
                List<String> appliedVouchers = (List<String>) session.getAttribute("appliedVouchers");
                if (appliedVouchers != null) {
                    for (String maCode : appliedVouchers) {
                        if (maCode != null && !maCode.isBlank()) {
                            BigDecimal discount = voucherRepo.tinhTienGiamGia(maCode.trim(), tongTien);
                            if (discount.compareTo(BigDecimal.ZERO) > 0) {
                                soTienGiam = soTienGiam.add(discount);
                                voucherRepo.tangLuotSuDung(maCode.trim());
                            }
                        }
                    }
                }

                int maDH = donHangDAO.taoDonHang(
                        Integer.valueOf(maKHStr),
                        nv.getMaNV(),
                        (pttt == null || pttt.isBlank()) ? "Tiền mặt" : pttt,
                        new LinkedHashMap<>(gioHang),
                        soTienGiam);

                gioHang.clear();
                session.removeAttribute("appliedVouchers");

                response.sendRedirect(request.getContextPath() + "/pos?thanhCong=" + maDH);
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/pos?loi=" +
                        java.net.URLEncoder.encode(e.getMessage() == null ? "Không tạo được đơn" : e.getMessage(), "UTF-8"));
            }
            return;
        }

        response.sendRedirect(request.getContextPath() + "/pos");
    }

    private List<Map<String, Object>> buildChiTietGio(Map<String, Integer> gioHang, Map<String, Long> tonKho) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map.Entry<String, Integer> e : gioHang.entrySet()) {
            Sach s = sachDAO.getById(e.getKey());
            if (s == null) continue;
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("maSach", s.getMaSach());
            row.put("tenSach", s.getTenSach());
            row.put("anhBia", s.getAnhBia());   // thêm ảnh bìa vào giỏ
            row.put("donGia", s.getGiaBan());
            row.put("soLuong", e.getValue());
            row.put("thanhTien", s.getGiaBan().multiply(BigDecimal.valueOf(e.getValue())));
            row.put("ton", tonKho.getOrDefault(s.getMaSach(), 0L));
            list.add(row);
        }
        return list;
    }

    private BigDecimal tinhTong(Map<String, Integer> gioHang) {
        BigDecimal tong = BigDecimal.ZERO;
        for (Map.Entry<String, Integer> e : gioHang.entrySet()) {
            Sach s = sachDAO.getById(e.getKey());
            if (s != null && s.getGiaBan() != null) {
                tong = tong.add(s.getGiaBan().multiply(BigDecimal.valueOf(e.getValue())));
            }
        }
        return tong;
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s.trim()); }
        catch (Exception e) { return def; }
    }

    /**
     * Lọc danh sách voucher theo loại khách hàng
     * - Khách mới: loại bỏ voucher chứa từ "MEMBER"
     * - Khách cũ: loại bỏ voucher chứa từ "WELCOME"
     */
    private List<Voucher> filterVouchersForCustomerType(List<Voucher> vouchers, boolean isNewCustomer) {
        if (vouchers == null) return vouchers;
        return vouchers.stream()
                .filter(v -> {
                    String code = v.getMaCode().toUpperCase();
                    if (isNewCustomer) {
                        // Khách mới: không hiển thị voucher chứa "MEMBER"
                        return !code.contains("MEMBER");
                    } else {
                        // Khách cũ: không hiển thị voucher chứa "WELCOME"
                        return !code.contains("WELCOME");
                    }
                })
                .collect(Collectors.toList());
    }
}