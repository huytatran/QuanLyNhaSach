package controller;

import dao.ThongKeDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.Map;

@WebServlet("/baocao")
public class BaoCaoServlet extends HttpServlet {

    private final ThongKeDAO thongKeDAO = new ThongKeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LocalDate to = parseDate(request.getParameter("to"), LocalDate.now());
        LocalDate from = parseDate(request.getParameter("from"), to.minusDays(29));
        if (from.isAfter(to)) {
            from = to.minusDays(29);
        }

        Map<String, Object> tongHop = thongKeDAO.tongHopDoanhThu(from, to);

        request.setAttribute("from", from.toString());
        request.setAttribute("to", to.toString());
        request.setAttribute("soDon", tongHop.get("soDon"));
        request.setAttribute("doanhThu", tongHop.get("doanhThu"));
        request.setAttribute("doanhThuTheoNgay", thongKeDAO.doanhThuTheoNgay(from, to));
        request.setAttribute("topSach", thongKeDAO.topSachBanChay(from, to, 10));
        request.setAttribute("activeMenu", "baocao");
        request.getRequestDispatcher("/view/baocao.jsp").forward(request, response);
    }

    private LocalDate parseDate(String s, LocalDate def) {
        try {
            return (s == null || s.isBlank()) ? def : LocalDate.parse(s.trim());
        } catch (Exception e) {
            return def;
        }
    }
}
