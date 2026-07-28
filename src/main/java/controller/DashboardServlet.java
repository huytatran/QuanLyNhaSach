package controller;

import dao.NhanVienDAO;
import dao.ThongKeDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private final ThongKeDAO thongKeDAO = new ThongKeDAO();
    private final NhanVienDAO nhanVienDAO = new NhanVienDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("soDonHomNay", thongKeDAO.demDonHomNay());
        request.setAttribute("tongTonKho", thongKeDAO.demTonKho());
        request.setAttribute("soDauSach", thongKeDAO.demDauSach());
        request.setAttribute("soNhanVien", nhanVienDAO.demTatCa());
        request.setAttribute("donHangGanDay", thongKeDAO.getDonHangGanDay(8));
        request.setAttribute("activeMenu", "dashboard");

        request.getRequestDispatcher("/view/dashboard.jsp").forward(request, response);
    }
}
