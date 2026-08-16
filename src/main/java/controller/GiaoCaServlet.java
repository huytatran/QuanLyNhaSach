package controller;

import entity.NhanVien;
import repository.NhanVienRepo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/giaoca")
public class GiaoCaServlet extends HttpServlet {

    private NhanVienRepo nhanVienRepo = new NhanVienRepo();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("activeMenu", "giaoca");
        request.getRequestDispatcher("/view/giaoca.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        // XỬ LÝ YÊU CẦU AJAX XÁC MINH MẬT KHẨU TỪ GIAO DIỆN
        if ("xacMinh".equals(action)) {
            String user = request.getParameter("username");
            String pass = request.getParameter("password");

            boolean isHopLe = false;

            try {
                // CHỈ DÙNG DATABASE ĐỂ KIỂM TRA (Đã xóa đoạn fix cứng pass "123")
                NhanVien nv = nhanVienRepo.dangNhap(user, pass);

                if (nv != null) {
                    isHopLe = true;
                    // Xác minh xong thì lưu đè luôn Session để người mới vào ca thay người cũ
                    HttpSession session = request.getSession();
                    session.setAttribute("currentUser", nv);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            // Trả kết quả về lại cho giao diện (JSP)
            response.setContentType("text/plain");
            response.setCharacterEncoding("UTF-8");

            if (isHopLe) {
                response.getWriter().write("SUCCESS"); // Gửi chữ SUCCESS, JS sẽ cho đăng xuất
            } else {
                response.getWriter().write("FAIL");    // Gửi chữ FAIL, JS sẽ hiện câu chửi màu đỏ
            }
            return;
        }
    }
}