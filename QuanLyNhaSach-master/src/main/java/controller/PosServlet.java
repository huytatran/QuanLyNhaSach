package controller;

import dao.DonHangDAO;
import dao.KhachHangDAO;
import dao.SachDAO;
import entity.KhachHang;
import entity.NhanVien;
import entity.Sach;
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

@WebServlet("/pos")
public class PosServlet extends HttpServlet {

    private final SachDAO sachDAO = new SachDAO();
    private final KhachHangDAO khachHangDAO = new KhachHangDAO();
    private final DonHangDAO donHangDAO = new DonHangDAO();

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String q = request.getParameter("q");
        List<Sach> danhSach = (q != null && !q.isBlank()) ? sachDAO.search(q.trim()) : sachDAO.getAll();
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
        request.setAttribute("chiTietGio", buildChiTietGio(gioHang, tonKho));
        request.setAttribute("tongTienGio", tinhTong(gioHang));
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
        
        // Xu ly AJAX them nhanh khach hang
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
                int maDH = donHangDAO.taoDonHang(
                        Integer.valueOf(maKHStr),
                        nv.getMaNV(),
                        (pttt == null || pttt.isBlank()) ? "Tiền mặt" : pttt,
                        new LinkedHashMap<>(gioHang));
                gioHang.clear();
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
}
