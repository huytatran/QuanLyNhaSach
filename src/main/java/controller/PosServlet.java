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
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/pos")
public class PosServlet extends HttpServlet {
    private final SachDAO sachDAO           = new SachDAO();
    private final SachBienTheDAO bienTheDAO = new SachBienTheDAO();
    private final KhachHangDAO khachHangDAO = new KhachHangDAO();
    private final DonHangDAO donHangDAO     = new DonHangDAO();
    private final VoucherRepo voucherRepo   = new VoucherRepo();

    // ----------------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String q = request.getParameter("q");

        // AJAX search: trả JSON danh sách sách
        if (isAjax(request) && q != null) {
            List<Sach> danhSach = q.isBlank()
                    ? sachDAO.getAllDangBan()
                    : sachDAO.searchDangBan(q.trim());
            Map<String, Long> tonKho = sachDAO.getTonKhoMap();
            HttpSession session = request.getSession();
            Map<String, CartItem> gioHang = layGioHang(session);
            Map<String, Long> tonKhoHienThi = new HashMap<>(tonKho);
            for (CartItem item : gioHang.values()) {
                String ms = item.getMaSach();
                long cur = tonKhoHienThi.getOrDefault(ms, 0L);
                tonKhoHienThi.put(ms, Math.max(0L, cur - item.getSoLuong()));
            }
            danhSach.sort((a, b) -> {
                long tA = tonKhoHienThi.getOrDefault(a.getMaSach(), 0L);
                long tB = tonKhoHienThi.getOrDefault(b.getMaSach(), 0L);
                if (tA > 0 && tB == 0) return -1;
                if (tA == 0 && tB > 0) return 1;
                return a.getMaSach().compareTo(b.getMaSach());
            });
            Map<String, List<SachBienThe>> bienTheMap = new LinkedHashMap<>();
            for (Sach s : danhSach) {
                bienTheMap.put(s.getMaSach(), bienTheDAO.getByMaSachDangBan(s.getMaSach()));
            }
            StringBuilder sb = new StringBuilder("{\"ok\":true,\"sachs\":[");
            for (int i = 0; i < danhSach.size(); i++) {
                Sach s = danhSach.get(i);
                long ton = tonKhoHienThi.getOrDefault(s.getMaSach(), 0L);
                List<SachBienThe> bts = bienTheMap.get(s.getMaSach());
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"maSach\":").append(jsonStr(s.getMaSach())).append(",");
                sb.append("\"tenSach\":").append(jsonStr(s.getTenSach())).append(",");
                sb.append("\"anhBia\":").append(jsonStr(s.getAnhBia())).append(",");
                sb.append("\"giaBan\":").append(s.getGiaBan() != null ? s.getGiaBan().toPlainString() : "0").append(",");
                sb.append("\"ton\":").append(ton).append(",");
                sb.append("\"bienThes\":[");
                if (bts != null) {
                    for (int j = 0; j < bts.size(); j++) {
                        SachBienThe bt = bts.get(j);
                        if (j > 0) sb.append(",");
                        sb.append("{\"maBienThe\":").append(bt.getMaBienThe()).append(",");
                        sb.append("\"tenHienThi\":").append(jsonStr(bt.getTenHienThi())).append(",");
                        sb.append("\"giaBienThe\":").append(bt.getGiaBienThe() != null ? bt.getGiaBienThe().toPlainString() : "0").append("}");
                    }
                }
                sb.append("]}");
            }
            sb.append("]}");
            sendJson(response, sb.toString());
            return;
        }

        // Normal GET: render trang lần đầu
        List<Sach> danhSach = (q != null && !q.isBlank())
                ? sachDAO.searchDangBan(q.trim())
                : sachDAO.getAllDangBan();
        Map<String, Long> tonKho = sachDAO.getTonKhoMap();
        HttpSession session = request.getSession();
        Map<String, CartItem> gioHang = layGioHang(session);

        Map<String, Long> tonKhoHienThi = new HashMap<>(tonKho);
        for (CartItem item : gioHang.values()) {
            String ms = item.getMaSach();
            long cur = tonKhoHienThi.getOrDefault(ms, 0L);
            tonKhoHienThi.put(ms, Math.max(0L, cur - item.getSoLuong()));
        }

        danhSach.sort((a, b) -> {
            long tA = tonKhoHienThi.getOrDefault(a.getMaSach(), 0L);
            long tB = tonKhoHienThi.getOrDefault(b.getMaSach(), 0L);
            if (tA > 0 && tB == 0) return -1;
            if (tA == 0 && tB > 0) return 1;
            return a.getMaSach().compareTo(b.getMaSach());
        });
        Map<String, List<SachBienThe>> bienTheMap = new LinkedHashMap<>();
        for (Sach s : danhSach) {
            bienTheMap.put(s.getMaSach(), bienTheDAO.getByMaSachDangBan(s.getMaSach()));
        }

        // 1. Kiểm tra loại khách hàng (Mới/Cũ)
        Integer maKHSelected = (Integer) session.getAttribute("maKHSelected");
        boolean isNewCustomer = false;
        if (maKHSelected != null) {
            isNewCustomer = !khachHangDAO.hasOrder(maKHSelected);
        }

        // 2. Tự động chọn/kiểm tra voucher tốt nhất (Best Voucher)
        capNhatAutoVoucher(session, gioHang, isNewCustomer);

        // 3. Lọc danh sách Voucher theo loại khách hàng
        List<Voucher> dsVoucher = filterVouchersForCustomerType(voucherRepo.getVouchersHopLe(), isNewCustomer);

        request.setAttribute("bienTheMap", bienTheMap);
        request.setAttribute("danhSachSach", danhSach);
        request.setAttribute("tonKhoMap", tonKhoHienThi);
        request.setAttribute("dsKhachHang", khachHangDAO.getAll());
        request.setAttribute("dsVoucher", dsVoucher);
        request.setAttribute("isNewCustomer", isNewCustomer);
        request.setAttribute("maKHSelected", maKHSelected);
        request.setAttribute("chiTietGio", new ArrayList<>(gioHang.values()));

        // 4. Tính toán tiền giảm cho 1 Voucher duy nhất
        BigDecimal tongTienGio = tinhTong(gioHang);
        String appliedVoucher  = (String) session.getAttribute("appliedVoucher");
        BigDecimal soTienGiam  = BigDecimal.ZERO;
        if (appliedVoucher != null && !appliedVoucher.isBlank()) {
            soTienGiam = voucherRepo.tinhTienGiamGia(appliedVoucher, tongTienGio);
        }
        BigDecimal tongTienPhaiTra = tongTienGio.subtract(soTienGiam).max(BigDecimal.ZERO);

        request.setAttribute("tongTienGio",     tongTienGio);
        request.setAttribute("soTienGiam",      soTienGiam);
        request.setAttribute("tongTienPhaiTra", tongTienPhaiTra);
        request.setAttribute("appliedVoucher",  appliedVoucher != null ? appliedVoucher : "");
        request.setAttribute("tuKhoa",          q);
        request.setAttribute("activeMenu",      "pos");
        request.getRequestDispatcher("/view/pos.jsp").forward(request, response);
    }

    // ----------------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        Map<String, CartItem> gioHang = layGioHang(session);

        // Cập nhật khách hàng được chọn & Reset cờ thủ công nếu chọn khách mới
        String maKHParam = request.getParameter("maKH");
        if (maKHParam != null) {
            Integer oldKH = (Integer) session.getAttribute("maKHSelected");
            Integer newKH = parseIntOrNull(maKHParam);
            if ((oldKH == null && newKH != null) || (oldKH != null && !oldKH.equals(newKH))) {
                session.setAttribute("maKHSelected", newKH);
                session.removeAttribute("manualVoucher"); // Reset để tự động chọn lại voucher phù hợp cho KH mới
            }
        }

        // ---- Nếu client chỉ muốn refresh summary/cart (ví dụ khi thay đổi khách) ----
        if ("refreshSummary".equals(action) || "refresh".equals(action)) {
            // Trả về JSON hiện trạng giỏ hàng + summary (gồm isNewCustomer)
            sendJsonCartResponse(response, session, gioHang);
            return;
        }

        // ---- Thêm khách hàng nhanh ----
        if ("addKH".equals(action)) {
            String ten = request.getParameter("tenKH");
            String sdt = request.getParameter("sdt");
            if (ten != null && !ten.isBlank()) {
                KhachHang kh = new KhachHang();
                kh.setTenKH(ten.trim());
                kh.setSdt(sdt != null ? sdt.trim() : "");
                KhachHang saved = khachHangDAO.insert(kh);
                session.setAttribute("maKHSelected", saved.getMaKH());
                session.removeAttribute("manualVoucher");
                sendJson(response, String.format("{\"ok\":true,\"maKH\":%d,\"tenKH\":%s,\"sdt\":%s}",
                        saved.getMaKH(), jsonStr(saved.getTenKH()), jsonStr(saved.getSdt())));
            } else {
                sendJson(response, "{\"ok\":false,\"message\":\"Tên không được trống\"}");
            }
            return;
        }

        // ---- Thêm sách vào giỏ ----
        if ("add".equals(action)) {
            String maSach      = request.getParameter("ma");
            String maBienTheStr = request.getParameter("maBienThe");
            Integer maBienThe  = parseIntOrNull(maBienTheStr);
            BigDecimal donGia;
            String tenBienThe = "";
            if (maBienThe != null && maBienThe > 0) {
                SachBienThe bt = bienTheDAO.getById(maBienThe);
                if (bt == null) { sendJsonError(response, "Biến thể không tồn tại."); return; }
                donGia     = bt.getGiaBienThe();
                tenBienThe = bt.getTenHienThi();
            } else {
                Sach s = sachDAO.getById(maSach);
                if (s == null) { sendJsonError(response, "Sách không tồn tại."); return; }
                donGia    = s.getGiaBan() != null ? s.getGiaBan() : BigDecimal.ZERO;
                maBienThe = 0;
            }
            Map<String, Long> ton = sachDAO.getTonKhoMap();
            String key   = CartItem.buildKey(maSach, maBienThe);
            int hienTai  = gioHang.containsKey(key) ? gioHang.get(key).getSoLuong() : 0;
            long coSan   = ton.getOrDefault(maSach, 0L);
            if (hienTai + 1 > coSan) {
                sendJsonError(response, "Không đủ tồn kho cho sách " + maSach);
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
            sendJsonCartResponse(response, session, gioHang);
            return;
        }

        // ---- Cập nhật số lượng ----
        if ("update".equals(action)) {
            String key = request.getParameter("key");
            int sl     = parseInt(request.getParameter("soLuong"), 1);
            if (sl <= 0) {
                gioHang.remove(key);
            } else {
                CartItem item = gioHang.get(key);
                if (item != null) {
                    long coSan = sachDAO.getTonKhoMap().getOrDefault(item.getMaSach(), 0L);
                    if (sl > coSan) { sendJsonError(response, "Chỉ còn " + coSan + " cuốn cho " + item.getMaSach()); return; }
                    item.setSoLuong(sl);
                }
            }
            sendJsonCartResponse(response, session, gioHang);
            return;
        }

        // ---- Xóa 1 dòng ----
        if ("remove".equals(action)) {
            gioHang.remove(request.getParameter("key"));
            sendJsonCartResponse(response, session, gioHang);
            return;
        }

        // ---- Xóa toàn bộ giỏ ----
        if ("clear".equals(action)) {
            gioHang.clear();
            session.removeAttribute("appliedVoucher");
            session.removeAttribute("manualVoucher");
            sendJsonCartResponse(response, session, gioHang);
            return;
        }

        // ---- Áp dụng Voucher (Thủ công) ----
        if ("applyVoucherSingle".equals(action)) {
            String maCode = request.getParameter("maCode");
            if (maCode == null || maCode.isBlank()) { sendJsonError(response, "Vui lòng chọn voucher"); return; }
            BigDecimal tongTien = tinhTong(gioHang);
            if (tongTien.compareTo(BigDecimal.ZERO) <= 0) { sendJsonError(response, "Giỏ hàng rỗng, không thể áp voucher"); return; }

            BigDecimal giam = voucherRepo.tinhTienGiamGia(maCode.trim(), tongTien);
            if (giam.compareTo(BigDecimal.ZERO) <= 0) {
                sendJsonError(response, "Voucher không đủ điều kiện áp dụng");
                return;
            }
            session.setAttribute("appliedVoucher", maCode.trim());
            session.setAttribute("manualVoucher", true); // Đánh dấu thu ngân chủ động chọn
            sendJsonCartResponse(response, session, gioHang);
            return;
        }

        // ---- Hủy Voucher (Thủ công) ----
        if ("cancelAllVouchers".equals(action)) {
            session.removeAttribute("appliedVoucher");
            session.setAttribute("manualVoucher", true); // Đánh dấu thu ngân chủ động gỡ
            sendJsonCartResponse(response, session, gioHang);
            return;
        }

        // ---- Thanh toán ----
        if ("checkout".equals(action)) {
            String maKHStr = request.getParameter("maKH");
            String pttt    = request.getParameter("phuongThuc");
            if (maKHStr == null || maKHStr.isBlank()) { sendJsonError(response, "Vui lòng chọn khách hàng."); return; }
            if (gioHang.isEmpty()) { sendJsonError(response, "Giỏ hàng trống."); return; }
            NhanVien nv = (NhanVien) session.getAttribute("currentUser");
            if (nv == null) { sendJsonError(response, "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại."); return; }
            try {
                BigDecimal tongTien   = tinhTong(gioHang);
                BigDecimal soTienGiam = BigDecimal.ZERO;
                String appliedCode    = (String) session.getAttribute("appliedVoucher");

                if (appliedCode != null && !appliedCode.isBlank()) {
                    soTienGiam = voucherRepo.tinhTienGiamGia(appliedCode, tongTien);
                    if (soTienGiam.compareTo(BigDecimal.ZERO) > 0) {
                        voucherRepo.tangLuotSuDung(appliedCode);
                    }
                }

                int maDH = donHangDAO.taoDonHangBienThe(
                        Integer.valueOf(maKHStr),
                        nv.getMaNV(),
                        (pttt == null || pttt.isBlank()) ? "Tiền mặt" : pttt,
                        new ArrayList<>(gioHang.values()),
                        soTienGiam);
                gioHang.clear();
                session.removeAttribute("appliedVoucher");
                session.removeAttribute("manualVoucher");
                session.removeAttribute("maKHSelected");
                sendJson(response, "{\"ok\":true,\"maDH\":" + maDH + ",\"message\":\"Tạo đơn hàng #" + maDH + " thành công.\",\"cart\":[],\"summary\":{\"tongTienGio\":0,\"soTienGiam\":0,\"tongTienPhaiTra\":0,\"appliedVoucher\":\"\"}}");
            } catch (Exception e) {
                sendJsonError(response, e.getMessage() == null ? "Không tạo được đơn" : e.getMessage());
            }
            return;
        }

        sendJson(response, "{\"ok\":false,\"message\":\"Hành động không hợp lệ\"}");
    }

    // ----------------------------------------------------------------
    // HAM HO TRO RENDER DỮ LIỆU VA CHECK AUTOMATIC VOUCHER
    // ----------------------------------------------------------------

    // Tự động chọn voucher tốt nhất nếu chưa bị chọn thủ công
    private void capNhatAutoVoucher(HttpSession session, Map<String, CartItem> gioHang, boolean isNewCustomer) {
        Boolean manual = (Boolean) session.getAttribute("manualVoucher");
        if (manual != null && manual) {
            // Nếu user đã can thiệp thủ công: Kiểm tra xem voucher hiện tại có còn hợp lệ với giá trị giỏ hàng mới không
            String curCode = (String) session.getAttribute("appliedVoucher");
            if (curCode != null && !curCode.isBlank()) {
                BigDecimal giam = voucherRepo.tinhTienGiamGia(curCode, tinhTong(gioHang));
                if (giam.compareTo(BigDecimal.ZERO) <= 0) {
                    session.removeAttribute("appliedVoucher"); // Hết điều kiện thì gỡ
                }
            }
            return;
        }

        // Tự động tìm Best Voucher
        BigDecimal tong = tinhTong(gioHang);
        Voucher best = voucherRepo.findBestVoucher(tong, isNewCustomer);
        if (best != null) {
            session.setAttribute("appliedVoucher", best.getMaCode());
        } else {
            session.removeAttribute("appliedVoucher");
        }
    }

    // Build & send JSON cart + summary
    private void sendJsonCartResponse(HttpServletResponse response, HttpSession session,
                                      Map<String, CartItem> gioHang) throws IOException {
        Integer maKHSel = (Integer) session.getAttribute("maKHSelected");
        boolean isNew   = (maKHSel != null) && !khachHangDAO.hasOrder(maKHSel);

        // Tự động kiểm tra/chọn Best Voucher trước khi trả JSON
        capNhatAutoVoucher(session, gioHang, isNew);

        BigDecimal tongTienGio = tinhTong(gioHang);
        String appliedCode     = (String) session.getAttribute("appliedVoucher");
        BigDecimal soTienGiam  = BigDecimal.ZERO;
        if (appliedCode != null && !appliedCode.isBlank()) {
            soTienGiam = voucherRepo.tinhTienGiamGia(appliedCode, tongTienGio);
        }
        BigDecimal tongPhaiTra = tongTienGio.subtract(soTienGiam).max(BigDecimal.ZERO);

        StringBuilder sb = new StringBuilder("{\"ok\":true,\"cart\":[");
        boolean first = true;
        for (Map.Entry<String, CartItem> e : gioHang.entrySet()) {
            CartItem item = e.getValue();
            if (!first) sb.append(",");
            first = false;
            sb.append("{");
            sb.append("\"key\":").append(jsonStr(e.getKey())).append(",");
            sb.append("\"maSach\":").append(jsonStr(item.getMaSach())).append(",");
            sb.append("\"tenSach\":").append(jsonStr(item.getTenSach())).append(",");
            sb.append("\"anhBia\":").append(jsonStr(item.getAnhBia())).append(",");
            sb.append("\"tenBienThe\":").append(jsonStr(item.getTenBienThe())).append(",");
            sb.append("\"soLuong\":").append(item.getSoLuong()).append(",");
            sb.append("\"donGia\":").append(item.getDonGia() != null ? item.getDonGia().toPlainString() : "0").append(",");
            sb.append("\"thanhTien\":").append(item.getThanhTien().toPlainString());
            sb.append("}");
        }
        sb.append("],\"summary\":{");
        sb.append("\"tongTienGio\":").append(tongTienGio.toPlainString()).append(",");
        sb.append("\"soTienGiam\":").append(soTienGiam.toPlainString()).append(",");
        sb.append("\"tongTienPhaiTra\":").append(tongPhaiTra.toPlainString()).append(",");
        sb.append("\"isNewCustomer\":").append(isNew).append(",");
        sb.append("\"appliedVoucher\":").append(jsonStr(appliedCode != null ? appliedCode : "")).append("");
        sb.append("}}");
        sendJson(response, sb.toString());
    }

    // ---- Helpers ----
    private boolean isAjax(HttpServletRequest req) {
        return "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
    }

    private void sendJson(HttpServletResponse response, String json) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter pw = response.getWriter();
        pw.write(json);
        pw.flush();
    }

    private void sendJsonError(HttpServletResponse response, String message) throws IOException {
        sendJson(response, "{\"ok\":false,\"message\":" + jsonStr(message) + "}");
    }

    private String jsonStr(String s) {
        if (s == null) return "null";
        return "\"" + s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t") + "\"";
    }

    private Map<String, CartItem> layGioHang(HttpSession session) {
        @SuppressWarnings("unchecked")
        Map<String, CartItem> gh = (Map<String, CartItem>) session.getAttribute("gioHangV2");
        if (gh == null) { gh = new LinkedHashMap<>(); session.setAttribute("gioHangV2", gh); }
        return gh;
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

    private List<Voucher> filterVouchersForCustomerType(List<Voucher> vouchers, boolean isNewCustomer) {
        if (vouchers == null) return vouchers;
        return vouchers.stream().filter(v -> {
            String code = v.getMaCode().toUpperCase();
            return isNewCustomer ? !code.contains("MEMBER") : !code.contains("WELCOME");
        }).collect(Collectors.toList());
    }
}