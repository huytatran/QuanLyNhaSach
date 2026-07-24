package controller;

import dao.DonHangDAO;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        
        if ("view".equals(action)) {
            Integer ma = Integer.valueOf(request.getParameter("ma"));
            DonHang dh = donHangDAO.getById(ma);
            request.setAttribute("donHang", dh);
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
        if (!"return".equals(request.getParameter("action"))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            donHangDAO.traDonHang(Integer.valueOf(request.getParameter("ma")));
            redirectWithMessage(request, response, "Đơn hàng đã được đổi/trả và tồn kho đã được hoàn lại.");
        } catch (Exception e) {
            String message = e.getMessage() == null ? "Không thể đổi/trả đơn hàng." : e.getMessage();
            redirectWithMessage(request, response, message);
        }
    }

    private void redirectWithMessage(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/don-hang?message=" +
                URLEncoder.encode(message, StandardCharsets.UTF_8));
    }
}
