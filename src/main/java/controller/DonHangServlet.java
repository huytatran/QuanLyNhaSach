package controller;

import dao.DonHangDAO;
import dao.SachDAO;
import entity.DonHang;
import entity.LichSuDoiTra;
import entity.Sach;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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
            if (dh == null) {
                response.sendRedirect(request.getContextPath() + "/don-hang?message=" +
                        URLEncoder.encode("Không tìm thấy đơn hàng.", StandardCharsets.UTF_8));
                return;
            }
            request.setAttribute("donHang", dh);
            request.setAttribute("lichSuDoiTra", donHangDAO.getLichSuDoiTra(ma));
            request.setAttribute("sachCoTheDoi", laySachCoTheDungDeDoi());
            request.setAttribute("activeMenu", "donhang");
            request.getRequestDispatcher("/view/don-hang-chi-tiet.jsp").forward(request, response);
            return;
        }

        if ("in-phieu".equals(action)) {
            Integer maDoiTra = Integer.valueOf(request.getParameter("maDoiTra"));
            LichSuDoiTra lichSu = donHangDAO.getLichSuDoiTraById(maDoiTra);
            if (lichSu == null) {
                response.sendRedirect(request.getContextPath() + "/don-hang?message=" +
                        URLEncoder.encode("Không tìm thấy phiếu đổi/trả.", StandardCharsets.UTF_8));
                return;
            }
            request.setAttribute("lichSu", lichSu);
            request.getRequestDispatcher("/view/phieu-doi-tra.jsp").forward(request, response);
            return;
        }

        if ("in-hoa-don".equals(action)) {
            Integer ma = Integer.valueOf(request.getParameter("ma"));
            DonHang dh = donHangDAO.getById(ma);
            if (dh == null) {
                response.sendRedirect(request.getContextPath() + "/don-hang?message=" +
                        URLEncoder.encode("Không tìm thấy đơn hàng.", StandardCharsets.UTF_8));
                return;
            }
            request.setAttribute("donHang", dh);
            request.getRequestDispatcher("/view/hoa-don-in.jsp").forward(request, response);
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
                String lyDo = request.getParameter("lyDo");
                LichSuDoiTra lichSu = donHangDAO.traHangTheoDong(maCTDH, soLuong, lyDo);
                redirectVeChiTiet(request, response, lichSu.getDonHang().getMaDH(),
                        "Đã trả " + soLuong + " cuốn. Bấm \"In phiếu\" ở lịch sử để in phiếu trả hàng.");
                return;
            }

            if ("doi".equals(action)) {
                Integer maCTDH = Integer.valueOf(request.getParameter("maCTDH"));
                int soLuongTra = Integer.parseInt(request.getParameter("soLuongTra"));
                String maSachMoi = request.getParameter("maSachMoi");
                int soLuongMoi = Integer.parseInt(request.getParameter("soLuongMoi"));
                String lyDo = request.getParameter("lyDo");
                LichSuDoiTra lichSu = donHangDAO.doiHang(maCTDH, soLuongTra, maSachMoi, soLuongMoi, lyDo);
                redirectVeChiTiet(request, response, lichSu.getDonHang().getMaDH(),
                        "Đã đổi hàng thành công. Bấm \"In phiếu\" ở lịch sử để in phiếu đổi hàng.");
                return;
            }

            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (IllegalArgumentException | IllegalStateException e) {
            String message = e.getMessage() == null ? "Thao tác không thực hiện được." : e.getMessage();
            if (maDH != null) {
                redirectVeChiTiet(request, response, maDH, message);
            } else {
                redirectWithMessage(request, response, message);
            }
        } catch (Exception e) {
            String message = "Có lỗi xảy ra, vui lòng thử lại.";
            if (maDH != null) {
                redirectVeChiTiet(request, response, maDH, message);
            } else {
                redirectWithMessage(request, response, message);
            }
        }
    }

    /** Nhung sach dang con kinh doanh va con it nhat 1 cuon trong kho, dung cho combobox "doi sang sach". */
    private List<Sach> laySachCoTheDungDeDoi() {
        Map<String, Long> tonKho = sachDAO.getTonKhoMap();
        List<Sach> ketQua = new ArrayList<>();
        for (Sach s : sachDAO.getAllDangBan()) {
            Long ton = tonKho.get(s.getMaSach());
            if (ton != null && ton > 0) {
                ketQua.add(s);
            }
        }
        return ketQua;
    }

    private Integer parseIntOrNull(String value) {
        try {
            return value == null ? null : Integer.valueOf(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void redirectVeChiTiet(HttpServletRequest request, HttpServletResponse response, Integer maDH, String message)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/don-hang?action=view&ma=" + maDH +
                "&message=" + URLEncoder.encode(message, StandardCharsets.UTF_8));
    }

    private void redirectWithMessage(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/don-hang?message=" +
                URLEncoder.encode(message, StandardCharsets.UTF_8));
    }
}
