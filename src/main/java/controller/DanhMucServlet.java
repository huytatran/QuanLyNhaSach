package controller;

import dao.BoSachDAO;
import dao.NhaXuatBanDAO;
import dao.TacGiaDAO;
import dao.TheLoaiDAO;
import entity.TheLoai;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Servlet quan ly trang "Thuoc tinh sach" (danh muc nen du lieu).
 * Hien tai code day du CRUD cho tab "the loai" - cac tab con lai
 * (tac gia, nha xuat ban, bo sach) van dang o dang xem truoc,
 * se lam o buoc tiep theo.
 *
 * URL:
 *  GET  /danhmuc?tab=theloai            -> danh sach the loai (mac dinh)
 *  GET  /danhmuc?tab=tacgia|nxb|bosach  -> tab khac (con la xem truoc)
 *  POST /danhmuc?action=save            -> luu the loai (them/sua qua hidden field "mode")
 *  POST /danhmuc?action=delete&ma=...   -> xoa the loai
 */
@WebServlet("/danhmuc")
public class DanhMucServlet extends HttpServlet {

    private final TheLoaiDAO theLoaiDAO = new TheLoaiDAO();
    private final TacGiaDAO tacGiaDAO = new TacGiaDAO();
    private final NhaXuatBanDAO nxbDAO = new NhaXuatBanDAO();
    private final BoSachDAO boSachDAO = new BoSachDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        hienTrang(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            xuLyXoa(request, response);
            return;
        }
        xuLyLuu(request, response);
    }

    // ================================================================
    private void hienTrang(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tab = request.getParameter("tab");
        if (tab == null || tab.isBlank()) tab = "theloai";

        request.setAttribute("activeMenu", "danhmuc");
        request.setAttribute("tab", tab);

        // 4 the so lieu tong quan - luon lay du lieu that
        request.setAttribute("soTheLoai", theLoaiDAO.countAll());
        request.setAttribute("soTacGia", tacGiaDAO.countAll());
        request.setAttribute("soNXB", nxbDAO.countAll());
        request.setAttribute("soBoSach", boSachDAO.countAll());

        switch (tab) {

            case "theloai":
                request.setAttribute("danhSachTheLoai", theLoaiDAO.getAll());
                request.setAttribute("soSachTheoTL", theLoaiDAO.demSachTheoTheLoai());
                break;

            case "tacgia":
                request.setAttribute("danhSachTacGia", tacGiaDAO.getAll());
                request.setAttribute("soSachTheoTG", tacGiaDAO.demSachTheoTacGia());
                break;

            case "nxb":
                request.setAttribute("danhSachNXB", nxbDAO.getAll());
                request.setAttribute("soSachTheoNXB", nxbDAO.demSachTheoNXB());
                break;

            case "bosach":
                request.setAttribute("danhSachBoSach", boSachDAO.getAll());
                request.setAttribute("soSachTheoBoSach", boSachDAO.demSachTheoBoSach());
                break;
        }
        request.getRequestDispatcher("/view/danhmuc.jsp").forward(request, response);
    }

    // ================================================================
    private void xuLyLuu(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tab = request.getParameter("tab");
        String mode = request.getParameter("mode");

        try {

            boolean thanhCong = false;

            switch (tab) {

                case "theloai": {

                    Integer maTL = parseInt(request.getParameter("maTL"));
                    String tenTL = request.getParameter("tenTL");

                    if (tenTL == null || tenTL.trim().isEmpty()) {
                        chuyenVeVoiLoi(response, tab, "Vui lòng nhập tên thể loại.");
                        return;
                    }

                    thanhCong = "sua".equals(mode)
                            ? theLoaiDAO.update(maTL, tenTL)
                            : theLoaiDAO.insert(tenTL);

                    if (!thanhCong) {
                        chuyenVeVoiLoi(response, tab, "Tên thể loại đã tồn tại.");
                        return;
                    }

                    break;
                }

                case "tacgia": {

                    Integer maTG = parseInt(request.getParameter("maTG"));
                    String tenTG = request.getParameter("tenTG");
                    String tieuSu = request.getParameter("tieuSu");

                    if (tenTG == null || tenTG.trim().isEmpty()) {
                        chuyenVeVoiLoi(response, tab, "Vui lòng nhập tên tác giả.");
                        return;
                    }

                    thanhCong = "sua".equals(mode)
                            ? tacGiaDAO.update(maTG, tenTG, tieuSu)
                            : tacGiaDAO.insert(tenTG, tieuSu);

                    if (!thanhCong) {
                        chuyenVeVoiLoi(response, tab, "Tên tác giả đã tồn tại.");
                        return;
                    }

                    break;
                }

                case "nxb": {

                    Integer maNXB = parseInt(request.getParameter("maNXB"));
                    String tenNXB = request.getParameter("tenNXB");
                    String sdt = request.getParameter("sdt");
                    String diaChi = request.getParameter("diaChi");

                    if (tenNXB == null || tenNXB.trim().isEmpty()) {
                        chuyenVeVoiLoi(response, tab, "Vui lòng nhập tên nhà xuất bản.");
                        return;
                    }

                    thanhCong = "sua".equals(mode)
                            ? nxbDAO.update(maNXB, tenNXB, sdt, diaChi)
                            : nxbDAO.insert(tenNXB, sdt, diaChi);

                    if (!thanhCong) {
                        chuyenVeVoiLoi(response, tab, "Tên nhà xuất bản đã tồn tại.");
                        return;
                    }

                    break;
                }

                case "bosach": {

                    Integer maBoSach = parseInt(request.getParameter("maBoSach"));
                    String tenBoSach = request.getParameter("tenBoSach");
                    String moTa = request.getParameter("moTa");

                    if (tenBoSach == null || tenBoSach.trim().isEmpty()) {
                        chuyenVeVoiLoi(response, tab, "Vui lòng nhập tên bộ sách.");
                        return;
                    }

                    thanhCong = "sua".equals(mode)
                            ? boSachDAO.update(maBoSach, tenBoSach, moTa)
                            : boSachDAO.insert(tenBoSach, moTa);

                    if (!thanhCong) {
                        chuyenVeVoiLoi(response, tab, "Tên bộ sách đã tồn tại.");
                        return;
                    }

                    break;
                }
            }

            response.sendRedirect(request.getContextPath() + "/danhmuc?tab=" + tab + "&thanhCong=1");

        } catch (Exception e) {
            chuyenVeVoiLoi(response, tab, "Không lưu được: " + e.getMessage());
        }
    }

    private void xuLyXoa(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String tab = request.getParameter("tab");
        Integer ma = parseInt(request.getParameter("ma"));

        boolean thanhCong = false;

        switch (tab) {

            case "theloai":
                thanhCong = theLoaiDAO.delete(ma);
                break;

            case "tacgia":
                thanhCong = tacGiaDAO.delete(ma);
                break;

            case "nxb":
                thanhCong = nxbDAO.delete(ma);
                break;

            case "bosach":
                thanhCong = boSachDAO.delete(ma);
                break;
        }

        if (thanhCong) {
            response.sendRedirect(request.getContextPath()
                    + "/danhmuc?tab=" + tab + "&xoaThanhCong=1");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/danhmuc?tab=" + tab
                    + "&loiXoa="
                    + java.net.URLEncoder.encode("Không thể xóa vì đang có sách sử dụng.", "UTF-8"));
        }
    }

    private void chuyenVeVoiLoi(HttpServletResponse response,
                                String tab,
                                String loi) throws IOException {

        response.sendRedirect(
                "danhmuc?tab=" + tab +
                        "&loi=" +
                        java.net.URLEncoder.encode(loi, "UTF-8")
        );
    }
    private Integer parseInt(String s) {
        try { return (s == null || s.isBlank()) ? null : Integer.valueOf(s.trim()); }
        catch (Exception e) { return null; }
    }
}
