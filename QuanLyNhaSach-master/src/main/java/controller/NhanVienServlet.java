package controller;

import dao.NhanVienDAO;
import entity.NhanVien;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/nhanvien")
public class NhanVienServlet extends HttpServlet {

    private final NhanVienDAO nhanVienDAO = new NhanVienDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        request.setAttribute("activeMenu", "nhanvien");

        if ("new".equals(action)) {
            request.setAttribute("nhanVien", new NhanVien());
            request.setAttribute("dangSua", false);
            request.getRequestDispatcher("/view/nhanvien-form.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action)) {
            Integer ma = parseInt(request.getParameter("ma"));
            NhanVien nv = nhanVienDAO.getById(ma);
            if (nv == null) {
                request.setAttribute("thongBaoLoi", "Không tìm thấy nhân viên.");
                hienDanhSach(request, response, null);
                return;
            }
            nv.setMatKhau(null);
            request.setAttribute("nhanVien", nv);
            request.setAttribute("dangSua", true);
            request.getRequestDispatcher("/view/nhanvien-form.jsp").forward(request, response);
            return;
        }

        hienDanhSach(request, response, request.getParameter("q"));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            Integer ma = parseInt(request.getParameter("ma"));
            HttpSession session = request.getSession();
            NhanVien current = (NhanVien) session.getAttribute("currentUser");
            if (current != null && current.getMaNV().equals(ma)) {
                response.sendRedirect(request.getContextPath() + "/nhanvien?loiXoa=" +
                        java.net.URLEncoder.encode("Không thể xóa tài khoản đang đăng nhập.", "UTF-8"));
                return;
            }
            boolean ok = nhanVienDAO.delete(ma);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/nhanvien?xoaThanhCong=1");
            } else {
                response.sendRedirect(request.getContextPath() + "/nhanvien?loiXoa=" +
                        java.net.URLEncoder.encode("Không xóa được (có thể đã lập đơn hàng).", "UTF-8"));
            }
            return;
        }

        // save
        String mode = request.getParameter("mode");
        NhanVien nv = new NhanVien();
        nv.setMaNV(parseInt(request.getParameter("maNV")));
        nv.setTenNV(trim(request.getParameter("tenNV")));
        nv.setSdt(trim(request.getParameter("sdt")));
        nv.setEmail(trim(request.getParameter("email")));
        nv.setDiaChi(trim(request.getParameter("diaChi")));
        nv.setTaiKhoan(trim(request.getParameter("taiKhoan")));
        nv.setMatKhau(trim(request.getParameter("matKhau")));
        nv.setVaiTroNV(parseInt(request.getParameter("vaiTroNV")) == null ? 0 : parseInt(request.getParameter("vaiTroNV")));

        String loi = kiemTra(nv, "sua".equals(mode));
        if (loi != null) {
            request.setAttribute("thongBaoLoi", loi);
            request.setAttribute("nhanVien", nv);
            request.setAttribute("dangSua", "sua".equals(mode));
            request.setAttribute("activeMenu", "nhanvien");
            request.getRequestDispatcher("/view/nhanvien-form.jsp").forward(request, response);
            return;
        }

        try {
            if ("sua".equals(mode)) {
                nhanVienDAO.update(nv);
            } else {
                nhanVienDAO.insert(nv);
            }
            response.sendRedirect(request.getContextPath() + "/nhanvien?thanhCong=1");
        } catch (Exception e) {
            request.setAttribute("thongBaoLoi", "Không lưu được: " + e.getMessage());
            request.setAttribute("nhanVien", nv);
            request.setAttribute("dangSua", "sua".equals(mode));
            request.setAttribute("activeMenu", "nhanvien");
            request.getRequestDispatcher("/view/nhanvien-form.jsp").forward(request, response);
        }
    }

    private void hienDanhSach(HttpServletRequest request, HttpServletResponse response, String q)
            throws ServletException, IOException {
        List<NhanVien> list = (q != null && !q.isBlank())
                ? nhanVienDAO.search(q.trim())
                : nhanVienDAO.getAll();
        request.setAttribute("danhSachNV", list);
        request.setAttribute("tuKhoa", q);
        request.setAttribute("activeMenu", "nhanvien");
        request.getRequestDispatcher("/view/nhanvien.jsp").forward(request, response);
    }

    private String kiemTra(NhanVien nv, boolean dangSua) {
        if (nv.getTenNV() == null || nv.getTenNV().isBlank()) return "Vui lòng nhập tên nhân viên.";
        if (nv.getTaiKhoan() == null || nv.getTaiKhoan().isBlank()) return "Vui lòng nhập tài khoản.";
        if (!dangSua && (nv.getMatKhau() == null || nv.getMatKhau().isBlank())) {
            return "Vui lòng nhập mật khẩu.";
        }
        Integer exclude = dangSua ? nv.getMaNV() : null;
        if (nhanVienDAO.taiKhoanTonTai(nv.getTaiKhoan(), exclude)) {
            return "Tài khoản đã tồn tại.";
        }
        return null;
    }

    private Integer parseInt(String s) {
        try { return (s == null || s.isBlank()) ? null : Integer.valueOf(s.trim()); }
        catch (Exception e) { return null; }
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }
}
