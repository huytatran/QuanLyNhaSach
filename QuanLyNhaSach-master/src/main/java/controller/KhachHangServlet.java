package controller;

import dao.DiaChiKhachHangDAO;
import dao.KhachHangDAO;
import entity.KhachHang;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Servlet quan ly Khach hang (ban offline tai quay - khong giao hang).
 *
 * URL:
 *  GET  /khachhang                      -> danh sach (co the kem ?q=&page=)
 *  GET  /khachhang?action=new           -> form them moi
 *  GET  /khachhang?action=edit&ma=...   -> form sua + danh sach dia chi cua khach
 *  POST /khachhang?action=save          -> luu khach hang (them/sua)
 *  POST /khachhang?action=delete&ma=... -> xoa khach hang
 *
 *  Quan ly dia chi (nam ngay trong man hinh sua khach hang):
 *  POST /khachhang?action=themDiaChi&maKH=...
 *  POST /khachhang?action=xoaDiaChi&maDiaChi=...&maKH=...
 *  POST /khachhang?action=macDinhDiaChi&maDiaChi=...&maKH=...
 */
@WebServlet("/khachhang")
public class KhachHangServlet extends HttpServlet {

    private static final int SO_DONG_MOI_TRANG = 10;

    private final KhachHangDAO khachHangDAO = new KhachHangDAO();
    private final DiaChiKhachHangDAO diaChiDAO = new DiaChiKhachHangDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        request.setAttribute("activeMenu", "khachhang");

        if ("new".equals(action)) {
            request.setAttribute("khachHang", new KhachHang());
            request.setAttribute("dangSua", false);
            request.getRequestDispatcher("/view/khachhang-form.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action)) {
            Integer ma = parseInt(request.getParameter("ma"));
            KhachHang kh = khachHangDAO.getById(ma);
            if (kh == null) {
                request.setAttribute("thongBaoLoi", "Không tìm thấy khách hàng.");
                hienDanhSach(request, response, null);
                return;
            }
            request.setAttribute("khachHang", kh);
            request.setAttribute("dangSua", true);
            request.setAttribute("dsDiaChi", diaChiDAO.getByKhachHang(ma));
            request.getRequestDispatcher("/view/khachhang-form.jsp").forward(request, response);
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
            xuLyXoaKhachHang(request, response);
            return;
        }
        if ("toggleTrangThai".equals(action)) {
            xuLyDoiTrangThai(request, response);
            return;
        }
        if ("themDiaChi".equals(action)) {
            xuLyThemDiaChi(request, response);
            return;
        }
        if ("xoaDiaChi".equals(action)) {
            xuLyXoaDiaChi(request, response);
            return;
        }
        if ("macDinhDiaChi".equals(action)) {
            xuLyMacDinhDiaChi(request, response);
            return;
        }

        xuLyLuuKhachHang(request, response);
    }

    // ================================================================
    private void hienDanhSach(HttpServletRequest request, HttpServletResponse response, String q)
            throws ServletException, IOException {

        int trang = parseTrang(request.getParameter("page"));
        boolean coTimKiem = (q != null && !q.isBlank());

        long tongSo = coTimKiem ? khachHangDAO.countSearch(q.trim()) : khachHangDAO.countAll();
        int tongSoTrang = (int) Math.max(1, Math.ceil(tongSo / (double) SO_DONG_MOI_TRANG));
        if (trang > tongSoTrang) trang = tongSoTrang;

        List<KhachHang> list = coTimKiem
                ? khachHangDAO.search(q.trim(), trang, SO_DONG_MOI_TRANG)
                : khachHangDAO.getAll(trang, SO_DONG_MOI_TRANG);

        Map<Integer, String> diaChiMacDinhMap = khachHangDAO.getDiaChiMacDinhMap();

        request.setAttribute("danhSachKH", list);
        request.setAttribute("diaChiMacDinhMap", diaChiMacDinhMap);
        request.setAttribute("tuKhoa", q);
        request.setAttribute("trangHienTai", trang);
        request.setAttribute("tongSoTrang", tongSoTrang);
        request.setAttribute("tongSoKhach", tongSo);
        request.setAttribute("activeMenu", "khachhang");
        request.getRequestDispatcher("/view/khachhang.jsp").forward(request, response);
    }

    private int parseTrang(String s) {
        try {
            int trang = Integer.parseInt(s.trim());
            return Math.max(trang, 1);
        } catch (Exception e) {
            return 1;
        }
    }

    // ================================================================
    private void xuLyLuuKhachHang(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String mode = request.getParameter("mode"); // "them" hoac "sua"
        KhachHang kh = new KhachHang();
        kh.setMaKH(parseInt(request.getParameter("maKH")));
        kh.setTenKH(trim(request.getParameter("tenKH")));
        kh.setSdt(trim(request.getParameter("sdt")));
        kh.setEmail(trim(request.getParameter("email")));

        String loi = kiemTraHopLe(kh);
        if (loi != null) {
            request.setAttribute("thongBaoLoi", loi);
            request.setAttribute("khachHang", kh);
            request.setAttribute("dangSua", "sua".equals(mode));
            request.setAttribute("activeMenu", "khachhang");
            if ("sua".equals(mode)) {
                request.setAttribute("dsDiaChi", diaChiDAO.getByKhachHang(kh.getMaKH()));
            }
            request.getRequestDispatcher("/view/khachhang-form.jsp").forward(request, response);
            return;
        }

        try {
            if ("sua".equals(mode)) {
                khachHangDAO.update(kh);
            } else {
                khachHangDAO.insert(kh);
            }
            response.sendRedirect(request.getContextPath() + "/khachhang?thanhCong=1");
        } catch (Exception e) {
            request.setAttribute("thongBaoLoi", "Không lưu được: " + e.getMessage());
            request.setAttribute("khachHang", kh);
            request.setAttribute("dangSua", "sua".equals(mode));
            request.setAttribute("activeMenu", "khachhang");
            request.getRequestDispatcher("/view/khachhang-form.jsp").forward(request, response);
        }
    }

    private String kiemTraHopLe(KhachHang kh) {
        if (kh.getTenKH() == null || kh.getTenKH().isBlank()) return "Vui lòng nhập tên khách hàng.";
        return null;
    }

    /**
     * Nut "Xoa" tren giao dien KHONG xoa cung ban ghi (se loi vi lien
     * quan bang phu DiaChiKhachHang / DonHang) - chi cap nhat
     * TrangThai = false (ngung hoat dong). Du lieu khach hang va lich
     * su don hang van con nguyen.
     */
    private void xuLyXoaKhachHang(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer ma = parseInt(request.getParameter("ma"));
        try {
            khachHangDAO.ngungHoatDong(ma);
            response.sendRedirect(request.getContextPath() + "/khachhang?xoaThanhCong=1");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/khachhang?loiXoa=" +
                    java.net.URLEncoder.encode("Không thể cập nhật trạng thái: " + e.getMessage(), "UTF-8"));
        }
    }

    private void xuLyDoiTrangThai(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer ma = parseInt(request.getParameter("ma"));
        String trang = request.getParameter("page");
        String q = request.getParameter("q");
        try {
            khachHangDAO.doiTrangThai(ma);
        } catch (Exception ignored) {
            // bo qua loi nho, quay ve danh sach binh thuong
        }
        String redirect = request.getContextPath() + "/khachhang?"
                + (trang != null ? "page=" + trang : "page=1")
                + (q != null && !q.isBlank() ? "&q=" + java.net.URLEncoder.encode(q, "UTF-8") : "");
        response.sendRedirect(redirect);
    }

    // ================================================================
    private void xuLyThemDiaChi(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer maKH = parseInt(request.getParameter("maKH"));
        String diaChi = trim(request.getParameter("diaChiChiTiet"));
        boolean laMacDinh = "1".equals(request.getParameter("laMacDinh"));

        if (diaChi == null || diaChi.isBlank()) {
            chuyenVeFormSua(request, response, maKH, "Vui lòng nhập nội dung địa chỉ.");
            return;
        }
        try {
            diaChiDAO.insert(maKH, diaChi, laMacDinh);
            response.sendRedirect(request.getContextPath() + "/khachhang?action=edit&ma=" + maKH + "&luuDiaChi=1");
        } catch (Exception e) {
            chuyenVeFormSua(request, response, maKH, "Không thêm được địa chỉ: " + e.getMessage());
        }
    }

    private void xuLyXoaDiaChi(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer maDiaChi = parseInt(request.getParameter("maDiaChi"));
        Integer maKH = parseInt(request.getParameter("maKH"));
        diaChiDAO.delete(maDiaChi);
        response.sendRedirect(request.getContextPath() + "/khachhang?action=edit&ma=" + maKH + "&xoaDiaChi=1");
    }

    private void xuLyMacDinhDiaChi(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer maDiaChi = parseInt(request.getParameter("maDiaChi"));
        Integer maKH = parseInt(request.getParameter("maKH"));
        diaChiDAO.datMacDinh(maDiaChi);
        response.sendRedirect(request.getContextPath() + "/khachhang?action=edit&ma=" + maKH);
    }

    private void chuyenVeFormSua(HttpServletRequest request, HttpServletResponse response, Integer maKH, String loi) throws IOException {
        response.sendRedirect(request.getContextPath() + "/khachhang?action=edit&ma=" + maKH + "&loiDiaChi=" +
                java.net.URLEncoder.encode(loi, "UTF-8"));
    }

    // ================================================================
    private Integer parseInt(String s) {
        try { return (s == null || s.isBlank()) ? null : Integer.valueOf(s.trim()); }
        catch (Exception e) { return null; }
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }
}
