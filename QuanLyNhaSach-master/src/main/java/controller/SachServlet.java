package controller;

import dao.*;
import entity.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Servlet quan ly Sach (CRUD). Dung theo dung luong nghiep vu muc 6
 * cua tai lieu: danh sach kem The Loai/NXB/Bo Sach, them/sua co kiem
 * tra hop le, xoa chi khi sach chua co ban ghi SachVatLy nao.
 *
 * URL:
 *  GET  /sach                -> danh sach (co the kem ?q=tuKhoa de tim)
 *  GET  /sach?action=new     -> hien form them moi
 *  GET  /sach?action=edit&ma=... -> hien form sua
 *  POST /sach?action=save    -> luu (them moi hoac cap nhat, phan biet qua hidden field "mode")
 *  POST /sach?action=delete&ma=... -> xoa
 */
@WebServlet("/sach")
public class SachServlet extends HttpServlet {

    private final SachDAO sachDAO = new SachDAO();
    private final TheLoaiDAO theLoaiDAO = new TheLoaiDAO();
    private final NhaXuatBanDAO nxbDAO = new NhaXuatBanDAO();
    private final BoSachDAO boSachDAO = new BoSachDAO();
    private final TacGiaDAO tacGiaDAO = new TacGiaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("new".equals(action)) {
            napDuLieuDropdown(request);
            request.setAttribute("sach", new Sach());
            request.setAttribute("dangSua", false);
            request.setAttribute("activeMenu", "sach");
            request.getRequestDispatcher("/view/sach-form.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action)) {
            String ma = request.getParameter("ma");
            Sach sach = sachDAO.getById(ma);
            if (sach == null) {
                request.setAttribute("thongBaoLoi", "Không tìm thấy sách có mã \"" + ma + "\".");
                hienDanhSach(request, response, null);
                return;
            }
            napDuLieuDropdown(request);
            request.setAttribute("sach", sach);
            request.setAttribute("tacGiaChinh", sachDAO.getTacGiaChinh(ma));
            request.setAttribute("dangSua", true);
            request.setAttribute("activeMenu", "sach");
            request.getRequestDispatcher("/view/sach-form.jsp").forward(request, response);
            return;
        }

        // Mac dinh: hien danh sach (co the kem tu khoa tim kiem)
        hienDanhSach(request, response, request.getParameter("q"));
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

        // Mac dinh: luu (them moi hoac cap nhat)
        xuLyLuu(request, response);
    }

    // ================================================================
    private static final int SO_DONG_MOI_TRANG = 10;

    private void hienDanhSach(HttpServletRequest request, HttpServletResponse response, String tuKhoa)
            throws ServletException, IOException {

        int trang = parseTrang(request.getParameter("page"));
        boolean coTimKiem = (tuKhoa != null && !tuKhoa.trim().isEmpty());

        long tongSo = coTimKiem ? sachDAO.countSearch(tuKhoa.trim()) : sachDAO.countAll();
        int tongSoTrang = (int) Math.max(1, Math.ceil(tongSo / (double) SO_DONG_MOI_TRANG));
        if (trang > tongSoTrang) trang = tongSoTrang;

        List<Sach> danhSach = coTimKiem
                ? sachDAO.search(tuKhoa.trim(), trang, SO_DONG_MOI_TRANG)
                : sachDAO.getAll(trang, SO_DONG_MOI_TRANG);

        Map<String, Long> tonKhoMap = sachDAO.getTonKhoMap();

        request.setAttribute("danhSachSach", danhSach);
        request.setAttribute("tonKhoMap", tonKhoMap);
        request.setAttribute("tuKhoa", tuKhoa);
        request.setAttribute("trangHienTai", trang);
        request.setAttribute("tongSoTrang", tongSoTrang);
        request.setAttribute("tongSoSach", tongSo);
        request.setAttribute("activeMenu", "sach");
        request.getRequestDispatcher("/view/sach.jsp").forward(request, response);
    }

    private int parseTrang(String s) {
        try {
            int trang = Integer.parseInt(s.trim());
            return Math.max(trang, 1);
        } catch (Exception e) {
            return 1;
        }
    }

    private void napDuLieuDropdown(HttpServletRequest request) {
        request.setAttribute("dsTheLoai", theLoaiDAO.getAll());
        request.setAttribute("dsNXB", nxbDAO.getAll());
        request.setAttribute("dsBoSach", boSachDAO.getAll());
        request.setAttribute("dsTacGia", tacGiaDAO.getAll());
    }

    // ================================================================
    private void xuLyLuu(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String mode = request.getParameter("mode"); // "them" hoac "sua"
        String maSach = request.getParameter("maSach");
        String tenSach = request.getParameter("tenSach");
        String namXBStr = request.getParameter("namXB");
        String giaBanStr = request.getParameter("giaBan");
        String maTLStr = request.getParameter("maTL");
        String maNXBStr = request.getParameter("maNXB");
        String maBoSachStr = request.getParameter("maBoSach");
        String soPhanStr = request.getParameter("soPhan");
        String maTacGiaStr = request.getParameter("maTacGia");

        // ---- Kiem tra hop le du lieu dau vao ----
        String loi = kiemTraHopLe(maSach, tenSach, giaBanStr, maTLStr, maNXBStr);
        if (loi != null) {
            request.setAttribute("thongBaoLoi", loi);
            request.setAttribute("dangSua", "sua".equals(mode));
            request.setAttribute("activeMenu", "sach");
            napDuLieuDropdown(request);
            // giu lai du lieu nguoi dung da nhap de khong phai go lai
            request.setAttribute("sach", taoSachTuForm(maSach, tenSach, namXBStr, giaBanStr, maTLStr, maNXBStr, maBoSachStr, soPhanStr));
            request.getRequestDispatcher("/view/sach-form.jsp").forward(request, response);
            return;
        }

        Sach sach = taoSachTuForm(maSach, tenSach, namXBStr, giaBanStr, maTLStr, maNXBStr, maBoSachStr, soPhanStr);
        Integer maTacGia = (maTacGiaStr == null || maTacGiaStr.isEmpty()) ? null : Integer.valueOf(maTacGiaStr);

        try {
            if ("sua".equals(mode)) {
                sachDAO.update(sach, maTacGia);
            } else {
                boolean thanhCong = sachDAO.insert(sach, maTacGia);
                if (!thanhCong) {
                    request.setAttribute("thongBaoLoi", "Mã sách \"" + maSach + "\" đã tồn tại, vui lòng chọn mã khác.");
                    request.setAttribute("dangSua", false);
                    request.setAttribute("activeMenu", "sach");
                    napDuLieuDropdown(request);
                    request.setAttribute("sach", sach);
                    request.getRequestDispatcher("/view/sach-form.jsp").forward(request, response);
                    return;
                }
            }
        } catch (RuntimeException e) {
            request.setAttribute("thongBaoLoi", "Không thể lưu sách: " + e.getMessage());
            request.setAttribute("dangSua", "sua".equals(mode));
            request.setAttribute("activeMenu", "sach");
            napDuLieuDropdown(request);
            request.setAttribute("sach", sach);
            request.getRequestDispatcher("/view/sach-form.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/sach?thanhCong=1");
    }

    private String kiemTraHopLe(String maSach, String tenSach, String giaBanStr, String maTLStr, String maNXBStr) {
        if (maSach == null || maSach.trim().isEmpty()) return "Vui lòng nhập mã sách.";
        if (tenSach == null || tenSach.trim().isEmpty()) return "Vui lòng nhập tên sách.";
        if (maTLStr == null || maTLStr.isEmpty()) return "Vui lòng chọn thể loại.";
        if (maNXBStr == null || maNXBStr.isEmpty()) return "Vui lòng chọn nhà xuất bản.";
        try {
            BigDecimal gia = new BigDecimal(giaBanStr);
            if (gia.compareTo(BigDecimal.ZERO) < 0) return "Giá bán không được nhỏ hơn 0.";
        } catch (Exception e) {
            return "Giá bán không hợp lệ.";
        }
        return null;
    }

    private Sach taoSachTuForm(String maSach, String tenSach, String namXBStr, String giaBanStr,
                               String maTLStr, String maNXBStr, String maBoSachStr, String soPhanStr) {
        Sach sach = new Sach();
        sach.setMaSach(maSach == null ? null : maSach.trim());
        sach.setTenSach(tenSach == null ? null : tenSach.trim());
        sach.setNamXB(chuoiSangSoNguyen(namXBStr));
        sach.setGiaBan(chuoiSangTien(giaBanStr));

        if (maTLStr != null && !maTLStr.isEmpty()) {
            TheLoai tl = new TheLoai();
            tl.setMaTL(Integer.valueOf(maTLStr));
            sach.setTheLoai(tl);
        }
        if (maNXBStr != null && !maNXBStr.isEmpty()) {
            NhaXuatBan nxb = new NhaXuatBan();
            nxb.setMaNXB(Integer.valueOf(maNXBStr));
            sach.setNhaXuatBan(nxb);
        }
        if (maBoSachStr != null && !maBoSachStr.isEmpty()) {
            BoSach bs = new BoSach();
            bs.setMaBoSach(Integer.valueOf(maBoSachStr));
            sach.setBoSach(bs);
            sach.setSoPhan(chuoiSangSoNguyen(soPhanStr));
        }
        return sach;
    }

    private Integer chuoiSangSoNguyen(String s) {
        try { return (s == null || s.isEmpty()) ? null : Integer.valueOf(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private BigDecimal chuoiSangTien(String s) {
        try { return (s == null || s.isEmpty()) ? BigDecimal.ZERO : new BigDecimal(s.trim()); }
        catch (NumberFormatException e) { return BigDecimal.ZERO; }
    }

    // ================================================================
    private void xuLyXoa(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String maSach = request.getParameter("ma");
        boolean thanhCong = sachDAO.delete(maSach);
        if (thanhCong) {
            response.sendRedirect(request.getContextPath() + "/sach?xoaThanhCong=1");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/sach?loiXoa=" + java.net.URLEncoder.encode(
                    "Không thể xóa \"" + maSach + "\" vì sách này đã có trong kho hoặc đã từng được bán.", "UTF-8"));
        }
    }
}

