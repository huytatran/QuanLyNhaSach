package controller;

import dao.DonHangDAO;
import dao.SachDAO;
import entity.DonHang;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/don-hang")
public class DonHangServlet extends HttpServlet {

    private final DonHangDAO donHangDAO = new DonHangDAO();
    private final SachDAO sachDAO = new SachDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        
        if ("view".equals(action)) {
            Integer ma = Integer.valueOf(request.getParameter("ma"));
            DonHang dh = donHangDAO.getById(ma);
            request.setAttribute("donHang", dh);
            // Moi: danh sach sach dang ban de chon khi doi mon, va so luong con lai co the tra/doi tung dong
            request.setAttribute("danhSachSachDangBan", sachDAO.getAllDangBan());
            request.setAttribute("soLuongConLaiMap", donHangDAO.getSoLuongConLaiTheoDon(ma));
            request.setAttribute("activeMenu", "donhang");
            request.getRequestDispatcher("/view/don-hang-chi-tiet.jsp").forward(request, response);
            return;
        }

        request.setAttribute("danhSachDonHang", donHangDAO.getAll());
        request.setAttribute("activeMenu", "donhang");
        request.getRequestDispatcher("/view/don-hang.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8);
        String action = request.getParameter("action");
        Integer maDH = parseIntOrNull(request.getParameter("maDH"));

        try {
            if ("tra".equals(action)) {
                Integer maCTDH = Integer.valueOf(request.getParameter("maCTDH"));
                int soLuong = Integer.parseInt(request.getParameter("soLuong"));
                String tenSach = request.getParameter("tenSach");
                donHangDAO.traMon(maCTDH, soLuong);
                redirectPhieuInDoiTra(request, response, maDH, "TRA", tenSach, soLuong, null);
            } else if ("doi".equals(action)) {
                Integer maCTDH = Integer.valueOf(request.getParameter("maCTDH"));
                int soLuong = Integer.parseInt(request.getParameter("soLuong"));
                String maSachMoi = request.getParameter("maSachMoi");
                String tenSach = request.getParameter("tenSach");
                donHangDAO.doiMon(maCTDH, soLuong, maSachMoi);
                redirectPhieuInDoiTra(request, response, maDH, "DOI", tenSach, soLuong, maSachMoi);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            String message = e.getMessage() == null ? "Không thể thực hiện thao tác." : e.getMessage();
            redirectWithMessage(request, response, maDH, message);
        }
    }

    private Integer parseIntOrNull(String s) {
        try {
            return s == null ? null : Integer.valueOf(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void redirectWithMessage(HttpServletRequest request, HttpServletResponse response, Integer maDH,
                                      String message) throws IOException {
        if (maDH == null) {
            response.sendRedirect(request.getContextPath() + "/don-hang?message=" +
                    URLEncoder.encode(message, StandardCharsets.UTF_8));
            return;
        }
        response.sendRedirect(request.getContextPath() + "/don-hang?action=view&ma=" + maDH + "&message=" +
                URLEncoder.encode(message, StandardCharsets.UTF_8));
    }

    // Moi: sau khi tra/doi thanh cong, redirect ve trang chi tiet kem du lieu de tu dong mo phieu in
    // (khong luu phieu vao DB - chi truyen qua tham so de trang JSP dung JS render + in ngay).
    private void redirectPhieuInDoiTra(HttpServletRequest request, HttpServletResponse response, Integer maDH,
                                        String loai, String tenSach, int soLuong, String maSachMoi)
            throws IOException {
        String msg = "TRA".equals(loai)
                ? "Đã trả " + soLuong + " cuốn \"" + tenSach + "\" và hoàn lại tồn kho."
                : "Đã đổi " + soLuong + " cuốn \"" + tenSach + "\" sang sách mới.";
        StringBuilder url = new StringBuilder(request.getContextPath())
                .append("/don-hang?action=view&ma=").append(maDH)
                .append("&message=").append(URLEncoder.encode(msg, StandardCharsets.UTF_8))
                .append("&in=1&loai=").append(loai)
                .append("&tenSach=").append(URLEncoder.encode(tenSach == null ? "" : tenSach, StandardCharsets.UTF_8))
                .append("&soLuong=").append(soLuong);
        if (maSachMoi != null) {
            url.append("&maSachMoi=").append(URLEncoder.encode(maSachMoi, StandardCharsets.UTF_8));
        }
        response.sendRedirect(url.toString());
    }
}
