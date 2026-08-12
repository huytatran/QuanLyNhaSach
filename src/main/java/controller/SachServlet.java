package controller;

import dao.*;
import entity.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
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
@MultipartConfig(
        maxFileSize = 3 * 1024 * 1024,       // 3MB / file
        maxRequestSize = 4 * 1024 * 1024     // 4MB / request
)
public class SachServlet extends HttpServlet {

    private static final String THU_MUC_ANH_BIA = "/uploads/books";

    private final SachDAO sachDAO = new SachDAO();
    private final TheLoaiDAO theLoaiDAO = new TheLoaiDAO();
    private final NhaXuatBanDAO nxbDAO = new NhaXuatBanDAO();
    private final BoSachDAO boSachDAO = new BoSachDAO();
    private final TacGiaDAO tacGiaDAO = new TacGiaDAO();
    private final SachBienTheDAO bienTheDAO = new SachBienTheDAO();
    private final SachVatLyDAO sachVatLyDAO = new SachVatLyDAO();

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
            request.setAttribute("dsBienThe", bienTheDAO.getBySach(ma));
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
        if ("toggleTrangThai".equals(action)) {
            xuLyDoiTrangThai(request, response);
            return;
        }
        if ("themBienThe".equals(action)) {
            xuLyThemBienThe(request, response);
            return;
        }
        if ("suaBienThe".equals(action)) {
            xuLySuaBienThe(request, response);
            return;
        }
        if ("xoaBienThe".equals(action)) {
            xuLyXoaBienThe(request, response);
            return;
        }
        if ("toggleBienThe".equals(action)) {
            xuLyToggleBienThe(request, response);
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
        String soLuongBanDauStr = request.getParameter("soLuongBanDau");

        // ---- Kiem tra hop le du lieu dau vao ----
        String loi = kiemTraHopLe(maSach, tenSach, giaBanStr, maTLStr, maNXBStr);
        if (loi != null) {
            request.setAttribute("thongBaoLoi", loi);
            request.setAttribute("dangSua", "sua".equals(mode));
            request.setAttribute("activeMenu", "sach");
            napDuLieuDropdown(request);
            // giu lai du lieu nguoi dung da nhap de khong phai go lai
            Sach sachTam = taoSachTuForm(maSach, tenSach, namXBStr, giaBanStr, maTLStr, maNXBStr, maBoSachStr, soPhanStr);
            sachTam.setAnhBia(request.getParameter("anhBiaHienTai"));
            request.setAttribute("sach", sachTam);
            request.getRequestDispatcher("/view/sach-form.jsp").forward(request, response);
            return;
        }

        Sach sach = taoSachTuForm(maSach, tenSach, namXBStr, giaBanStr, maTLStr, maNXBStr, maBoSachStr, soPhanStr);
        Integer maTacGia = (maTacGiaStr == null || maTacGiaStr.isEmpty()) ? null : Integer.valueOf(maTacGiaStr);

        // Neu nguoi dung chon anh moi (file hoac URL) thi luu/gan duong dan; neu khong thi giu anh cu (khi sua)
        String anhBiaHienTai = request.getParameter("anhBiaHienTai");
        String anhBiaUrl = request.getParameter("anhBiaUrl");
        sach.setAnhBia(xuLyUploadAnh(request, maSach.trim(), anhBiaHienTai, anhBiaUrl));

        try {
            if ("sua".equals(mode)) {
                sachDAO.update(sach, maTacGia);
                // Nhap them kho khi sua sach (neu nguoi dung nhap so luong > 0)
                nhapKhoBanDau(maSach.trim(), soLuongBanDauStr);
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
                // Luu bien the kem theo (neu nguoi dung them khi tao moi sach)
                luuBienTheTuForm(request, maSach.trim());
                // Nhap kho ban dau neu nguoi dung nhap so luong > 0
                nhapKhoBanDau(maSach.trim(), soLuongBanDauStr);
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

    /**
     * Luu anh bia theo thu tu uu tien:
     *  1) File upload (anhBiaFile) - neu co chon, luu vao THU_MUC_ANH_BIA, ten = maSach + duoi anh.
     *  2) URL anh (anhBiaUrl) - neu khong co file nhung co dan URL hop le, luu thang URL do.
     *  3) Khong co gi moi -> giu nguyen anhBiaHienTai (dung khi sua sach, khong doi anh).
     */
    private String xuLyUploadAnh(HttpServletRequest request, String maSach, String anhBiaHienTai, String anhBiaUrl) {
        try {
            Part part = request.getPart("anhBiaFile");
            if (part != null && part.getSize() > 0) {
                String tenGoc = part.getSubmittedFileName();
                String duoiFile = (tenGoc != null && tenGoc.contains("."))
                        ? tenGoc.substring(tenGoc.lastIndexOf('.')).toLowerCase()
                        : "";
                if (duoiFile.matches("\\.(jpg|jpeg|png|webp)")) {
                    String realPath = getServletContext().getRealPath(THU_MUC_ANH_BIA);
                    File thuMuc = new File(realPath);
                    if (!thuMuc.exists()) thuMuc.mkdirs();

                    String tenFile = maSach + duoiFile;
                    Path duongDanDich = new File(thuMuc, tenFile).toPath();
                    try (InputStream in = part.getInputStream()) {
                        Files.copy(in, duongDanDich, StandardCopyOption.REPLACE_EXISTING);
                    }
                    // Bo dau "/" o dau de khop kieu duong dan tuong doi da dung trong sach.jsp/pos.jsp
                    return THU_MUC_ANH_BIA.substring(1) + "/" + tenFile;
                }
                // File co nhung sai dinh dang -> bo qua, roi thu tiep URL/anh cu ben duoi
            }

            if (anhBiaUrl != null && !anhBiaUrl.trim().isEmpty()) {
                String url = anhBiaUrl.trim();
                if (url.matches("(?i)^https?://.+")) {
                    return url;
                }
                // URL khong hop le -> bo qua, giu anh cu
            }

            return anhBiaHienTai;
        } catch (Exception e) {
            return anhBiaHienTai; // co loi khi upload -> khong lam hong viec luu sach, giu anh cu
        }
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
    /**
     * Nut "Xoa" tren giao dien KHONG xoa cung ban ghi nua (se loi vi
     * pham khoa ngoai FK_CTDH_Sach neu sach da tung ban) - chi cap nhat
     * TrangThai = false (ngung kinh doanh).
     */
    private void xuLyXoa(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String maSach = request.getParameter("ma");
        try {
            sachDAO.ngungKinhDoanh(maSach);
            response.sendRedirect(request.getContextPath() + "/sach?xoaThanhCong=1");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath()
                    + "/sach?loiXoa=" + java.net.URLEncoder.encode(
                    "Không thể cập nhật trạng thái sách \"" + maSach + "\": " + e.getMessage(), "UTF-8"));
        }
    }

    private void xuLyDoiTrangThai(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String maSach = request.getParameter("ma");
        String trang = request.getParameter("page");
        String q = request.getParameter("q");
        try {
            sachDAO.doiTrangThai(maSach);
        } catch (Exception ignored) {
            // bo qua loi nho, quay ve danh sach binh thuong
        }
        String redirect = request.getContextPath() + "/sach?"
                + (trang != null ? "page=" + trang : "page=1")
                + (q != null && !q.isBlank() ? "&q=" + java.net.URLEncoder.encode(q, "UTF-8") : "");
        response.sendRedirect(redirect);
    }

    // ================================================================
    // Quan ly Bien the sach (nam ngay trong man hinh sua Sach)
    // ================================================================
    private void xuLyThemBienThe(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String maSach = request.getParameter("maSach");
        String loaiBia = request.getParameter("loaiBia");
        String ngonNgu = request.getParameter("ngonNgu");
        String maBienTheCode = request.getParameter("maBienTheCode");
        String giaBanStr = request.getParameter("giaBanBienThe");

        if (maBienTheCode == null || maBienTheCode.isBlank()) {
            chuyenVeSuaVoiLoi(request, response, maSach, "Vui lòng nhập mã biến thể.");
            return;
        }
        BigDecimal giaBan = chuoiSangTien(giaBanStr);
        try {
            boolean ok = bienTheDAO.insert(maSach, loaiBia, ngonNgu, maBienTheCode, giaBan);
            if (!ok) {
                chuyenVeSuaVoiLoi(request, response, maSach, "Mã biến thể \"" + maBienTheCode + "\" đã tồn tại.");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/sach?action=edit&ma=" + maSach + "&luuBienThe=1");
        } catch (Exception e) {
            chuyenVeSuaVoiLoi(request, response, maSach, "Không thêm được biến thể: " + e.getMessage());
        }
    }

    private void xuLySuaBienThe(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String maSach = request.getParameter("maSach");
        Integer maBienThe = chuoiSangSoNguyen(request.getParameter("maBienThe"));
        String loaiBia = request.getParameter("loaiBia");
        String ngonNgu = request.getParameter("ngonNgu");
        String maBienTheCode = request.getParameter("maBienTheCode");
        BigDecimal giaBan = chuoiSangTien(request.getParameter("giaBanBienThe"));

        if (maBienTheCode == null || maBienTheCode.isBlank()) {
            chuyenVeSuaVoiLoi(request, response, maSach, "Vui lòng nhập mã biến thể.");
            return;
        }
        try {
            boolean ok = bienTheDAO.update(maBienThe, loaiBia, ngonNgu, maBienTheCode, giaBan);
            if (!ok) {
                chuyenVeSuaVoiLoi(request, response, maSach, "Mã biến thể \"" + maBienTheCode + "\" đã tồn tại.");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/sach?action=edit&ma=" + maSach + "&luuBienThe=1");
        } catch (Exception e) {
            chuyenVeSuaVoiLoi(request, response, maSach, "Không sửa được biến thể: " + e.getMessage());
        }
    }

    private void xuLyXoaBienThe(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String maSach = request.getParameter("maSach");
        Integer maBienThe = chuoiSangSoNguyen(request.getParameter("maBienThe"));
        boolean ok = bienTheDAO.delete(maBienThe);
        if (ok) {
            response.sendRedirect(request.getContextPath() + "/sach?action=edit&ma=" + maSach + "&xoaBienThe=1");
        } else {
            chuyenVeSuaVoiLoi(request, response, maSach,
                    "Không thể xóa biến thể này vì đã có trong kho hoặc đã từng bán. Hãy dùng công tắc để ngừng bán thay vì xóa.");
        }
    }

    private void xuLyToggleBienThe(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String maSach = request.getParameter("maSach");
        Integer maBienThe = chuoiSangSoNguyen(request.getParameter("maBienThe"));
        try {
            bienTheDAO.doiTrangThai(maBienThe);
        } catch (Exception ignored) {
            // bo qua loi nho
        }
        response.sendRedirect(request.getContextPath() + "/sach?action=edit&ma=" + maSach);
    }

    /**
     * Đọc danh sách biến thể được nhập trên form thêm mới sách.
     * Các tham số có dạng mảng indexed:
     *   btBia[0], btNgonNgu[0], btMaCode[0], btGia[0]
     *   btBia[1], btNgonNgu[1], btMaCode[1], btGia[1] ...
     * Bỏ qua dòng nào thiếu mã biến thể hoặc giá.
     */
    private void luuBienTheTuForm(HttpServletRequest request, String maSach) {
        String[] arrBia    = request.getParameterValues("btBia");
        String[] arrNgonNgu = request.getParameterValues("btNgonNgu");
        String[] arrMaCode = request.getParameterValues("btMaCode");
        String[] arrGia    = request.getParameterValues("btGia");

        if (arrMaCode == null || arrMaCode.length == 0) return;

        for (int i = 0; i < arrMaCode.length; i++) {
            String maCode = arrMaCode[i];
            if (maCode == null || maCode.isBlank()) continue;

            String bia     = (arrBia     != null && i < arrBia.length)     ? arrBia[i]     : null;
            String ngonNgu = (arrNgonNgu != null && i < arrNgonNgu.length)  ? arrNgonNgu[i] : null;
            String giaStr  = (arrGia     != null && i < arrGia.length)      ? arrGia[i]     : null;
            BigDecimal gia = chuoiSangTien(giaStr);
            try {
                bienTheDAO.insert(maSach, bia, ngonNgu, maCode.trim(), gia);
            } catch (Exception ignored) {
                // Bo qua loi 1 dong bien the, khong cancel toan bo
            }
        }
    }

    /**
     * Tự động tạo và nhập kho các bản SachVatLy.
     * Serial được sinh theo dạng: {maSach}-{STT 3 chữ số}, tiếp nối từ số hiện có.
     * VD: đã có 5 cuốn → nhập thêm 3 → tạo serial -006, -007, -008.
     * Bỏ qua nếu soLuongStr rỗng, null, hoặc <= 0.
     */
    private void nhapKhoBanDau(String maSach, String soLuongStr) {
        int soLuong;
        try {
            soLuong = Integer.parseInt(soLuongStr == null ? "0" : soLuongStr.trim());
        } catch (NumberFormatException e) {
            return;
        }
        if (soLuong <= 0) return;

        // Lay so luong hien co de tiep noi STT serial
        long offset = sachVatLyDAO.countBySach(maSach);

        Sach sachRef = new Sach();
        sachRef.setMaSach(maSach);

        java.util.List<SachVatLy> list = new java.util.ArrayList<>();
        for (int i = 1; i <= soLuong; i++) {
            SachVatLy sv = new SachVatLy();
            sv.setMaSerial(maSach + "-" + String.format("%03d", offset + i));
            sv.setSach(sachRef);
            sv.setTrangThai("Có sẵn");
            list.add(sv);
        }
        try {
            sachVatLyDAO.insertBatch(list);
        } catch (Exception ignored) {
            // Khong lam hong toan bo luong luu sach neu nhap kho that bai
        }
    }

    private void chuyenVeSuaVoiLoi(HttpServletRequest request, HttpServletResponse response, String maSach, String loi) throws IOException {
        response.sendRedirect(request.getContextPath() + "/sach?action=edit&ma=" + maSach + "&loiBienThe="
                + java.net.URLEncoder.encode(loi, "UTF-8"));
    }
}

