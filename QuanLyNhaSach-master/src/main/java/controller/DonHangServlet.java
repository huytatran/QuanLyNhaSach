package controller;

import dao.DonHangDAO;
import entity.DonHang;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

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
}
