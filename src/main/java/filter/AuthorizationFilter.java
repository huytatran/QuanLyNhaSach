package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String requestURI = req.getRequestURI();
        String contextPath = req.getContextPath();

        // 1. Các tài nguyên không cần kiểm tra đăng nhập
        boolean isLoginRequest = requestURI.equals(contextPath + "/login");
        boolean isStaticResource = requestURI.startsWith(contextPath + "/css/")
                || requestURI.startsWith(contextPath + "/js/")
                || requestURI.startsWith(contextPath + "/images/")
                || requestURI.startsWith(contextPath + "/assets/");

        // 2. Kiểm tra xem đã đăng nhập chưa
        boolean isLoggedIn = (session != null && session.getAttribute("currentUser") != null);

        if (isLoggedIn) {
            // --- BẮT ĐẦU PHÂN QUYỀN (AUTHORIZATION) Ở ĐÂY ---

            // Lấy thông tin user hiện tại từ Session
            Object currentUser = session.getAttribute("currentUser");
            int vaiTro = 0; // Mặc định là nhân viên thường

            // Lấy vai trò động từ đối tượng User (dùng Reflection để an toàn với mọi kiểu Class Entity của bạn)
            try {
                java.lang.reflect.Method getVaiTroMethod = currentUser.getClass().getMethod("getVaiTroNV");
                Object raw = getVaiTroMethod.invoke(currentUser);
                if (raw instanceof Number) {
                    vaiTro = ((Number) raw).intValue();
                }
            } catch (Exception e) {
                vaiTro = 0;
            }

            // Định nghĩa danh sách các URL chỉ dành riêng cho ADMIN (vaiTro = 1)
            boolean isAdminPath = requestURI.equals(contextPath + "/nhanvien")
                    || requestURI.equals(contextPath + "/baocao");

            if (isAdminPath && vaiTro != 1) {
                // Nếu là nhân viên thường nhưng cố tình truy cập trang Admin -> Chặn lại và đẩy về Dashboard
                res.sendRedirect(contextPath + "/dashboard?error=permission-denied");
            } else {
                // Hợp lệ -> Cho qua
                chain.doFilter(request, response);
            }

        } else if (isLoginRequest || isStaticResource) {
            // Chưa đăng nhập nhưng truy cập trang Login hoặc file tĩnh -> Cho qua
            chain.doFilter(request, response);
        } else {
            // Chưa đăng nhập và truy cập trang nội bộ -> Đá về trang Login
            res.sendRedirect(contextPath + "/login");
        }
    }

    @Override
    public void destroy() {}
}