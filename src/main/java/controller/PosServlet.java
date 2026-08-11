package controller;

import dao.DonHangDAO;
import dao.KhachHangDAO;
import dao.SachBienTheDAO;
import dao.SachDAO;
import entity.*;
import repository.VoucherRepo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/pos")
public class PosServlet extends HttpServlet {

    private final SachDAO sachDAO             = new SachDAO();
    private final SachBienTheDAO bienTheDAO   = new SachBienTheDAO();
    private final KhachHangDAO khachHangDAO   = new KhachHangDAO();
    private final DonHangDAO donHangDAO       = new DonHangDAO();
    private final VoucherRepo voucherRepo     = new VoucherRepo();

    // ----------------------------------------------------------------
    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String q = request.getParameter("q");
        List<Sach> danhSach = (q != null && !q.isBlank())
                ? sachDAO.searchDangBan(q.trim())
                : sachDAO.getAllDangBan();

        Map<String, Long> tonKho = sachDAO.getTonKhoMap();

        HttpSession session = request.getSession();
        Map<String, CartItem> gioHang = layGioHang(session);

        // Trừ số lượng đang trong giỏ khỏi tồn kho hiển thị
        // → nhân viên thấy ngay tồn kho "còn lại thực tế" khi đang chọn hàng
        Map<String, Long> tonKhoHienThi = new java.util.HashMap<>(tonKho);
        for (CartItem item : gioHang.values()) {
            String maSach = item.getMaSach();
            long tonHienTai = tonKhoHienThi.getOrDefault(maSach, 0L);
            long conLai = Math.max(0L, tonHienTai - item.getSoLuong());
            tonKhoHienThi.put(maSach, conLai);
        }

        // Gắn danh sách biến thể đang bán cho từng đầu sách (dùng trong POS để chọn)
        Map<String, List<SachBienThe>> bienTheMap = new LinkedHashMap<>();
        for (Sach s : danhSach) {
            List<SachBienThe> ds = bienTheDAO.getByMaSachDangBan(s.getMaSach());
            bienTheMap.put(s.getMaSach(), ds);
        }
        request.setAttribute("bienTheMap", bienTheMap);

        request.setAttribute("danhSachSach", danhSach);
        request.setAttribute("tonKhoMap", tonKhoHienThi);
        request.setAttribute("dsKhachHang", khachHangDAO.getAll());

        // Voucher
        List<Voucher> dsVoucher = voucherRepo.getVouchersHopLe();
        Integer maKHSelected = (Integer) session.getAttribute("maKHSelected");
        boolean isNewCustomer = false;
        if (maKHSelected != null) {
            isNewCustomer = !khachHangDAO.hasOrder(maKHSelected);
            dsVoucher = filterVouchersForCustomerType(dsVoucher, isNewCustomer);
        }
        request.setAttribute("dsVoucher", dsVoucher);
        request.setAttribute("isNewCustomer", isNewCustomer);
        request.setAttribute("maKHSelected", maKHSelected);

        // Giỏ hàng chi tiết
        request.setAttribute("chiTietGio", new ArrayList<>(gioHang.values()));

        // Tính tiền
        BigDecimal tongTienGio  = tinhTong(gioHang);
        BigDecimal soTienGiam   = BigDecimal.ZERO;

        List<String> appliedVouchers = layAppliedVouchers(session);
        for (String maCode : appliedVouchers) {
            if (maCode != null && !maCode.isBlank()) {
                soTienGiam = soTienGiam.add(voucherRepo.tinhTienGiamGia(maCode, tongTienGio));
            }
        }
        BigDecimal tongTienPhaiTra = tongTienGio.subtract(soTienGiam).max(BigDecimal.ZERO);

        BigDecimal capPercent   = isNewCustomer ? new BigDecimal("0.4") : new BigDecimal("0.2");
        BigDecimal capAmount    = tongTienGio.multiply(capPercent);
        BigDecimal curDiscPct   = tongTienGio.compareTo(BigDecimal.ZERO) > 0
                ? soTienGiam.divide(tongTienGio, 2, java.math.RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        request.setAttribute("tongTienGio",            tongTienGio);
        request.setAttribute("soTienGiam",             soTienGiam);
        request.setAttribute("tongTienPhaiTra",        tongTienPhaiTra);
        request.setAttribute("appliedVouchers",        appliedVouchers);
        request.setAttribute("capPercent",             capPercent.multiply(new BigDecimal("100")).intValue());
        request.setAttribute("capAmount",              capAmount);
        request.setAttribute("currentDiscountPercent", curDiscPct.multiply(new BigDecimal("100")).intValue());
        request.setAttribute("tuKhoa",                 q);
        request.setAttribute("activeMenu",             "pos");
        request.getRequestDispatcher("/view/pos.jsp").forward(request, response);
    }

    // ----------------------------------------------------------------
    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        Map<String, CartItem> gioHang = layGioHang(session);

        // Giữ lại khách hàng đã chọn
        String maKHParam = request.getParameter("maKH");
        if (maKHParam != null && !maKHParam.isBlank()) {
            try { session.setAttribute("maKHSelected", Integer.valueOf(maKHParam)); }
            catch (NumberFormatException ignored) {}
        }

        // ---- Thêm khách hàng nhanh (AJAX) ----
        if ("addKH".equals(action)) {
            String ten = request.getParameter("tenKH");
            String sdt = request.getParameter("sdt");
            if (ten != null && !ten.isBlank()) {
                KhachHang kh = new KhachHang();
                kh.setTenKH(ten.trim());
                kh.setSdt(sdt != null ? sdt.trim() : "");
                KhachHang saved = khachHangDAO.insert(kh);
                response.setContentType("application/json");
                response.getWriter().write(String.format("{\"maKH\":%d,\"tenKH\":\"%s\"}",
                        saved.getMaKH(), saved.getTenKH()));
            }
            return;
        }

        // ---- Thêm sách vào giỏ (có thể kèm biến thể) ----
        if ("add".equals(action)) {
            String maSach      = request.getParameter("ma");
            String maBienTheStr = request.getParameter("maBienThe");   // có thể null/rỗng
            Integer maBienThe  = parseIntOrNull(maBienTheStr);

            // Xác định giá và tên hiển thị
            BigDecimal donGia;
            String tenBienThe = "";
            if (maBienThe != null && maBienThe > 0) {
                SachBienThe bt = bienTheDAO.getById(maBienThe);
                if (bt == null) {
                    chuyenVePOSVoiLoi(response, request, "Biến thể không tồn tại.");
                    return;
                }
                donGia    = bt.getGiaBienThe();
                tenBienThe = bt.getTenHienThi();
            } else {
                Sach s = sachDAO.getById(maSach);
                if (s == null) { chuyenVePOSVoiLoi(response, request, "Sách không tồn tại."); return; }
                donGia    = s.getGiaBan() != null ? s.getGiaBan() : BigDecimal.ZERO;
                maBienThe  = 0;  // không có biến thể
            }

            // Kiểm tra tồn kho
            Map<String, Long> ton = sachDAO.getTonKhoMap();
            String key = CartItem.buildKey(maSach, maBienThe);
            int hienTai = gioHang.containsKey(key) ? gioHang.get(key).getSoLuong() : 0;
            long coSan  = ton.getOrDefault(maSach, 0L);
            if (hienTai + 1 > coSan) {
                chuyenVePOSVoiLoi(response, request, "Không đủ tồn kho cho sách " + maSach);
                return;
            }

            Sach s = sachDAO.getById(maSach);
            if (gioHang.containsKey(key)) {
                gioHang.get(key).setSoLuong(hienTai + 1);
            } else {
                gioHang.put(key, new CartItem(maSach, maBienThe == 0 ? null : maBienThe,
                        1, donGia,
                        s != null ? s.getTenSach() : maSach,
                        tenBienThe,
                        s != null ? s.getAnhBia() : null));
            }
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        // ---- Cập nhật số lượng ----
        if ("update".equals(action)) {
            String key  = request.getParameter("key");
            int sl      = parseInt(request.getParameter("soLuong"), 1);
            if (sl <= 0) {
                gioHang.remove(key);
            } else {
                CartItem item = gioHang.get(key);
                if (item != null) {
                    String maSach = item.getMaSach();
                    long coSan    = sachDAO.getTonKhoMap().getOrDefault(maSach, 0L);
                    if (sl > coSan) {
                        chuyenVePOSVoiLoi(response, request, "Chỉ còn " + coSan + " cuốn cho " + maSach);
                        return;
                    }
                    item.setSoLuong(sl);
                }
            }
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        // ---- Xóa 1 dòng ----
        if ("remove".equals(action)) {
            gioHang.remove(request.getParameter("key"));
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        // ---- Xóa toàn bộ ----
        if ("clear".equals(action)) {
            gioHang.clear();
            session.removeAttribute("appliedVouchers");
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        // ---- Áp voucher đơn ----
        if ("applyVoucherSingle".equals(action)) {
            String maCode = request.getParameter("maCode");
            if (maCode != null && !maCode.isBlank()) {
                List<String> applied = layAppliedVouchers(session);
                if (applied.size() >= 2) {
                    chuyenVePOSVoiLoi(response, request, "Tối đa chỉ được áp 2 vouchers cùng lúc");
                    return;
                }
                if (applied.contains(maCode.trim())) {
                    chuyenVePOSVoiLoi(response, request, "Voucher này đã được áp dụng rồi");
                    return;
                }
                BigDecimal tongTien = tinhTong(gioHang);
                if (tongTien.compareTo(BigDecimal.ZERO) <= 0) {
                    chuyenVePOSVoiLoi(response, request, "Giỏ hàng rỗng, không thể áp voucher");
                    return;
                }
                BigDecimal currentTotal = BigDecimal.ZERO;
                for (String ma : applied) currentTotal = currentTotal.add(voucherRepo.tinhTienGiamGia(ma, tongTien));
                BigDecimal newDiscount  = voucherRepo.tinhTienGiamGia(maCode.trim(), tongTien);
                if (newDiscount.compareTo(BigDecimal.ZERO) <= 0) {
                    chuyenVePOSVoiLoi(response, request, "Voucher này không áp dụng được (hết lượt hoặc không đạt điều kiện)");
                    return;
                }
                Integer maKHSel = (Integer) session.getAttribute("maKHSelected");
                boolean isNew   = (maKHSel != null) && !khachHangDAO.hasOrder(maKHSel);
                BigDecimal cap  = tongTien.multiply(isNew ? new BigDecimal("0.4") : new BigDecimal("0.2"));
                if (currentTotal.add(newDiscount).compareTo(cap) > 0) {
                    chuyenVePOSVoiLoi(response, request, "Áp voucher này sẽ vượt ngưỡng giảm giá (" + (isNew ? 40 : 20) + "%)");
                    return;
                }
                applied.add(maCode.trim());
            }
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        // ---- Gỡ 1 voucher ----
        if ("removeAppliedVoucher".equals(action)) {
            String maCode = request.getParameter("maCode");
            if (maCode != null) layAppliedVouchers(session).remove(maCode.trim());
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        // ---- Hủy tất cả voucher ----
        if ("cancelAllVouchers".equals(action)) {
            session.removeAttribute("appliedVouchers");
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        // ---- Thanh toán ----
        if ("checkout".equals(action)) {
            String maKHStr  = request.getParameter("maKH");
            String pttt     = request.getParameter("phuongThuc");
            if (maKHStr == null || maKHStr.isBlank()) {
                chuyenVePOSVoiLoi(response, request, "Vui lòng chọn khách hàng.");
                return;
            }
            if (gioHang.isEmpty()) {
                chuyenVePOSVoiLoi(response, request, "Giỏ hàng trống.");
                return;
            }
            NhanVien nv = (NhanVien) session.getAttribute("currentUser");
            try {
                BigDecimal tongTien  = tinhTong(gioHang);
                BigDecimal soTienGiam = BigDecimal.ZERO;
                List<String> applied  = layAppliedVouchers(session);
                for (String maCode : applied) {
                    if (maCode != null && !maCode.isBlank()) {
                        BigDecimal d = voucherRepo.tinhTienGiamGia(maCode.trim(), tongTien);
                        if (d.compareTo(BigDecimal.ZERO) > 0) {
                            soTienGiam = soTienGiam.add(d);
                            voucherRepo.tangLuotSuDung(maCode.trim());
                        }
                    }
                }
                // Chuyển giỏ hàng CartItem sang Map<maSach, soLuong> + Map giá theo key
                // DonHangDAO.taoDonHang cần biết giá của từng dòng — truyền qua overload mới
                int maDH = donHangDAO.taoDonHangBienThe(
                        Integer.valueOf(maKHStr),
                        nv.getMaNV(),
                        (pttt == null || pttt.isBlank()) ? "Tiền mặt" : pttt,
                        new ArrayList<>(gioHang.values()),
                        soTienGiam);

                gioHang.clear();
                session.removeAttribute("appliedVouchers");
                response.sendRedirect(request.getContextPath() + "/pos?thanhCong=" + maDH);
            } catch (Exception e) {
                chuyenVePOSVoiLoi(response, request,
                        e.getMessage() == null ? "Không tạo được đơn" : e.getMessage());
            }
            return;
        }

        response.sendRedirect(request.getContextPath() + "/pos");
    }

    // ---- Helpers ----
    @SuppressWarnings("unchecked")
    private Map<String, CartItem> layGioHang(HttpSession session) {
        Map<String, CartItem> gh = (Map<String, CartItem>) session.getAttribute("gioHangV2");
        if (gh == null) {
            gh = new LinkedHashMap<>();
            session.setAttribute("gioHangV2", gh);
        }
        return gh;
    }

    @SuppressWarnings("unchecked")
    private List<String> layAppliedVouchers(HttpSession session) {
        List<String> list = (List<String>) session.getAttribute("appliedVouchers");
        if (list == null) {
            list = new ArrayList<>();
            session.setAttribute("appliedVouchers", list);
        }
        return list;
    }

    private BigDecimal tinhTong(Map<String, CartItem> gioHang) {
        return gioHang.values().stream()
                .map(CartItem::getThanhTien)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return def; }
    }

    private Integer parseIntOrNull(String s) {
        try { return (s == null || s.isBlank()) ? null : Integer.parseInt(s.trim()); }
        catch (Exception e) { return null; }
    }

    private void chuyenVePOSVoiLoi(HttpServletResponse resp, HttpServletRequest req, String loi)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/pos?loi="
                + java.net.URLEncoder.encode(loi, "UTF-8"));
    }

    private List<Voucher> filterVouchersForCustomerType(List<Voucher> vouchers, boolean isNewCustomer) {
        if (vouchers == null) return vouchers;
        return vouchers.stream().filter(v -> {
            String code = v.getMaCode().toUpperCase();
            return isNewCustomer ? !code.contains("MEMBER") : !code.contains("WELCOME");
        }).collect(Collectors.toList());
    }
}
