package controller;

import dao.DiaChiKhachHangDAO;
import dao.KhachHangDAO;
import entity.KhachHang;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.time.LocalDate;
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

        if ("xuatExcel".equals(action)) {
            xuLyXuatExcel(request, response);
            return;
        }

        hienDanhSach(request, response, request.getParameter("q"), request.getParameter("trangThai"));
    }

    private void hienDanhSach(HttpServletRequest request, HttpServletResponse response, Object o) {
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
    private void hienDanhSach(HttpServletRequest request, HttpServletResponse response,
                              String q, String trangThaiParam)
            throws ServletException, IOException {

        int trang = parseTrang(request.getParameter("page"));
        boolean coTimKiem = (q != null && !q.isBlank());

        Boolean trangThaiLoc = null;
        if ("1".equals(trangThaiParam)) trangThaiLoc = Boolean.TRUE;
        else if ("0".equals(trangThaiParam)) trangThaiLoc = Boolean.FALSE;

        long tongSo;
        List<KhachHang> list;

        if (coTimKiem) {
            tongSo = khachHangDAO.countSearchByTrangThai(q.trim(), trangThaiLoc);
            int tongSoTrang = (int) Math.max(1, Math.ceil(tongSo / (double) SO_DONG_MOI_TRANG));
            if (trang > tongSoTrang) trang = tongSoTrang;
            list = khachHangDAO.searchByTrangThai(q.trim(), trangThaiLoc, trang, SO_DONG_MOI_TRANG);
        } else {
            tongSo = khachHangDAO.countAllByTrangThai(trangThaiLoc);
            int tongSoTrang = (int) Math.max(1, Math.ceil(tongSo / (double) SO_DONG_MOI_TRANG));
            if (trang > tongSoTrang) trang = tongSoTrang;
            list = khachHangDAO.getAllByTrangThai(trangThaiLoc, trang, SO_DONG_MOI_TRANG);
        }

        int tongSoTrang = (int) Math.max(1, Math.ceil(tongSo / (double) SO_DONG_MOI_TRANG));

        Map<Integer, String> diaChiMacDinhMap = khachHangDAO.getDiaChiMacDinhMap();

        request.setAttribute("danhSachKH",       list);
        request.setAttribute("diaChiMacDinhMap", diaChiMacDinhMap);
        request.setAttribute("tuKhoa",           q);
        request.setAttribute("trangThaiLoc",     trangThaiParam != null ? trangThaiParam : "");
        request.setAttribute("trangHienTai",     trang);
        request.setAttribute("tongSoTrang",      tongSoTrang);
        request.setAttribute("tongSoKhach",      tongSo);
        request.setAttribute("activeMenu",       "khachhang");
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
        String trangThai = request.getParameter("trangThai");
        try {
            khachHangDAO.doiTrangThai(ma);
        } catch (Exception ignored) {
            // bo qua loi nho, quay ve danh sach binh thuong
        }
        String redirect = request.getContextPath() + "/khachhang?"
                + (trang != null ? "page=" + trang : "page=1")
                + (q != null && !q.isBlank() ? "&q=" + java.net.URLEncoder.encode(q, "UTF-8") : "")
                + (trangThai != null && !trangThai.isBlank() ? "&trangThai=" + trangThai : "");
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
    // Xuat Excel
    // ================================================================
    private void xuLyXuatExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String tuKhoa = request.getParameter("q");
        String trangThaiParam = request.getParameter("trangThai");

        Boolean trangThaiLoc = null;
        if ("1".equals(trangThaiParam)) trangThaiLoc = Boolean.TRUE;
        else if ("0".equals(trangThaiParam)) trangThaiLoc = Boolean.FALSE;

        List<KhachHang> danhSach = khachHangDAO.getAllForExport(
                tuKhoa != null && !tuKhoa.isBlank() ? tuKhoa.trim() : null, trangThaiLoc);

        try (XSSFWorkbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("Danh sach khach hang");
            sheet.setDefaultColumnWidth(20);

            // --- Style: tiêu đề chính ---
            CellStyle styleTieuDe = wb.createCellStyle();
            Font fontTieuDe = wb.createFont();
            fontTieuDe.setBold(true);
            fontTieuDe.setFontHeightInPoints((short) 14);
            styleTieuDe.setFont(fontTieuDe);
            styleTieuDe.setAlignment(HorizontalAlignment.CENTER);
            styleTieuDe.setVerticalAlignment(VerticalAlignment.CENTER);

            // --- Style: header cột ---
            CellStyle styleHeader = wb.createCellStyle();
            Font fontHeaderWhite = wb.createFont();
            fontHeaderWhite.setBold(true);
            fontHeaderWhite.setColor(IndexedColors.WHITE.getIndex());
            fontHeaderWhite.setFontHeightInPoints((short) 11);
            styleHeader.setFont(fontHeaderWhite);
            styleHeader.setFillForegroundColor(IndexedColors.INDIGO.getIndex());
            styleHeader.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            styleHeader.setAlignment(HorizontalAlignment.CENTER);
            styleHeader.setVerticalAlignment(VerticalAlignment.CENTER);
            styleHeader.setBorderBottom(BorderStyle.THIN);
            styleHeader.setBorderTop(BorderStyle.THIN);
            styleHeader.setBorderLeft(BorderStyle.THIN);
            styleHeader.setBorderRight(BorderStyle.THIN);

            // --- Style: dữ liệu ---
            CellStyle styleData = wb.createCellStyle();
            styleData.setBorderBottom(BorderStyle.THIN);
            styleData.setBorderTop(BorderStyle.THIN);
            styleData.setBorderLeft(BorderStyle.THIN);
            styleData.setBorderRight(BorderStyle.THIN);
            styleData.setVerticalAlignment(VerticalAlignment.CENTER);

            CellStyle styleDataAlt = wb.createCellStyle();
            styleDataAlt.cloneStyleFrom(styleData);
            styleDataAlt.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            styleDataAlt.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            CellStyle styleCenter = wb.createCellStyle();
            styleCenter.cloneStyleFrom(styleData);
            styleCenter.setAlignment(HorizontalAlignment.CENTER);

            CellStyle styleCenterAlt = wb.createCellStyle();
            styleCenterAlt.cloneStyleFrom(styleCenter);
            styleCenterAlt.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            styleCenterAlt.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            CellStyle styleNum = wb.createCellStyle();
            styleNum.cloneStyleFrom(styleData);
            styleNum.setAlignment(HorizontalAlignment.RIGHT);

            CellStyle styleNumAlt = wb.createCellStyle();
            styleNumAlt.cloneStyleFrom(styleNum);
            styleNumAlt.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            styleNumAlt.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            // --- Dòng 0: Tiêu đề ---
            Row rowTitle = sheet.createRow(0);
            rowTitle.setHeightInPoints(28);
            Cell cellTitle = rowTitle.createCell(0);
            cellTitle.setCellValue("DANH SÁCH KHÁCH HÀNG — " + LocalDate.now());
            cellTitle.setCellStyle(styleTieuDe);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 6));

            // --- Dòng 1: Header ---
            String[] headers = {"STT", "Mã KH", "Họ tên", "Số điện thoại", "Email", "Điểm tích lũy", "Trạng thái"};
            int[]    colWidths = {6,     10,      24,       16,              26,      16,               18};

            Row rowHeader = sheet.createRow(1);
            rowHeader.setHeightInPoints(22);
            for (int i = 0; i < headers.length; i++) {
                Cell c = rowHeader.createCell(i);
                c.setCellValue(headers[i]);
                c.setCellStyle(styleHeader);
                sheet.setColumnWidth(i, colWidths[i] * 256);
            }

            // --- Dữ liệu ---
            int rowIdx = 2;
            int stt = 1;
            for (KhachHang kh : danhSach) {
                boolean alt = (stt % 2 == 0);
                Row row = sheet.createRow(rowIdx++);
                row.setHeightInPoints(18);

                boolean dangHD = !Boolean.FALSE.equals(kh.getTrangThai());

                setCellStr(row, 0, String.valueOf(stt++),             alt ? styleCenterAlt : styleCenter);
                setCellStr(row, 1, "KH" + kh.getMaKH(),              alt ? styleDataAlt : styleData);
                setCellStr(row, 2, kh.getTenKH(),                     alt ? styleDataAlt : styleData);
                setCellStr(row, 3, kh.getSdt()   != null ? kh.getSdt()   : "", alt ? styleDataAlt : styleData);
                setCellStr(row, 4, kh.getEmail() != null ? kh.getEmail() : "", alt ? styleDataAlt : styleData);
                setCellNum(row, 5, kh.getDiemTichLuy() != null ? kh.getDiemTichLuy() : 0, alt ? styleNumAlt : styleNum);
                setCellStr(row, 6, dangHD ? "Đang hoạt động" : "Ngừng hoạt động", alt ? styleCenterAlt : styleCenter);
            }

            // --- Dòng tổng kết ---
            CellStyle styleSum = wb.createCellStyle();
            Font fontSum = wb.createFont();
            fontSum.setBold(true);
            styleSum.setFont(fontSum);
            styleSum.setBorderTop(BorderStyle.MEDIUM);
            styleSum.setBorderBottom(BorderStyle.THIN);
            styleSum.setBorderLeft(BorderStyle.THIN);
            styleSum.setBorderRight(BorderStyle.THIN);

            Row rowSum = sheet.createRow(rowIdx);
            rowSum.setHeightInPoints(20);
            Cell cellSumLabel = rowSum.createCell(0);
            cellSumLabel.setCellValue("Tổng cộng: " + danhSach.size() + " khách hàng");
            cellSumLabel.setCellStyle(styleSum);
            sheet.addMergedRegion(new CellRangeAddress(rowIdx, rowIdx, 0, 6));
            for (int i = 1; i <= 6; i++) rowSum.createCell(i).setCellStyle(styleSum);

            // --- Xuất ra response ---
            String tenFile = "danh-sach-khach-hang-" + LocalDate.now() + ".xlsx";
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition",
                    "attachment; filename*=UTF-8''" + java.net.URLEncoder.encode(tenFile, "UTF-8").replace("+", "%20"));
            wb.write(response.getOutputStream());
            response.getOutputStream().flush();
        }
    }

    private void setCellStr(Row row, int col, String value, CellStyle style) {
        Cell c = row.createCell(col);
        c.setCellValue(value != null ? value : "");
        c.setCellStyle(style);
    }

    private void setCellNum(Row row, int col, double value, CellStyle style) {
        Cell c = row.createCell(col);
        c.setCellValue(value);
        c.setCellStyle(style);
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
