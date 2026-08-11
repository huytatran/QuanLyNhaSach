package controller;

import dao.DonHangDAO;
import dao.SachDAO;
import entity.DonHang;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;
import java.util.List;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
@WebServlet("/don-hang")
public class DonHangServlet extends HttpServlet {

    private final DonHangDAO donHangDAO = new DonHangDAO();
    private final SachDAO sachDAO = new SachDAO();

    // Moi: so don hang hien thi moi trang
    private static final int SO_DONG_MOI_TRANG = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("view".equals(action)) {
            Integer ma = Integer.valueOf(request.getParameter("ma"));
            DonHang dh = donHangDAO.getById(ma);
            request.setAttribute("donHang", dh);
            // Moi: danh sach sach dang ban de chon khi doi mon, va so luong con lai co the tra/doi tung dong
            request.setAttribute("danhSachSachDangBan", sachDAO.getAllDangBan());
            request.setAttribute("soLuongConLaiMap", donHangDAO.getSoLuongConLaiTheoDon(ma));
            // Moi: lich su doi/tra cua don nay, hien thi trong trang chi tiet
            request.setAttribute("lichSuDoiTra", donHangDAO.getLichSuDoiTraTheoDon(ma));
            request.setAttribute("activeMenu", "donhang");
            request.getRequestDispatcher("/view/don-hang-chi-tiet.jsp").forward(request, response);
            return;
        }

        // Moi: phan trang cho danh sach don hang
        int trang = 1;
        try {
            if (request.getParameter("trang") != null) {
                trang = Integer.parseInt(request.getParameter("trang"));
            }
        } catch (NumberFormatException ignored) {
        }
        if (trang < 1) trang = 1;

        String tab = request.getParameter("tab");

        if ("doi-tra".equals(tab)) {
            // Moi: loc theo khoang ngay, ma don va ten khach hang, thay cho o tim kiem chung khong hoat dong tren trang nay
            java.time.LocalDate tuNgay = parseNgay(request.getParameter("tuNgay"));
            java.time.LocalDate denNgay = parseNgay(request.getParameter("denNgay"));
            Integer maDon = parseIntOrNull(request.getParameter("maDon"));
            String tenKH = request.getParameter("tenKH");

            if ("export".equals(action)) {
                xuatExcelDoiTra(response, tuNgay, denNgay, maDon, tenKH);
                return;
            }

            long tongSoDon = donHangDAO.countCoTheDoiTra(tuNgay, denNgay, maDon, tenKH);
            int tongSoTrangDoiTra = (int) Math.max(1, Math.ceil(tongSoDon / (double) SO_DONG_MOI_TRANG));
            if (trang > tongSoTrangDoiTra) trang = tongSoTrangDoiTra;

            // Moi: bo 2 bang lich su "da doi" / "da tra" rieng - doi-tra gio la 1 danh sach don
            // hang duy nhat (giong cau truc don-hang.jsp), thao tac "Xu ly doi/tra" dan vao dung
            // trang chi tiet don hang de xu ly, thay vi tach rieng theo loai giao dich.
            request.setAttribute("danhSachDonHang", donHangDAO.getAllCoTheDoiTra(trang, SO_DONG_MOI_TRANG, tuNgay, denNgay, maDon, tenKH));
            request.setAttribute("tongSoTrang", tongSoTrangDoiTra);
            request.setAttribute("trangHienTai", trang);
            request.setAttribute("tuNgay", request.getParameter("tuNgay"));
            request.setAttribute("denNgay", request.getParameter("denNgay"));
            request.setAttribute("maDon", request.getParameter("maDon"));
            request.setAttribute("tenKH", tenKH);
            request.setAttribute("tab", "doi-tra");
            request.setAttribute("activeMenu", "doitra");
            request.getRequestDispatcher("/view/doi-tra.jsp").forward(request, response);
            return;
        }

        // Moi: loc danh sach don hang theo khoang ngay, ma don va ten khach hang, thay cho o tim kiem khong hoat dong
        java.time.LocalDate tuNgayDon = parseNgay(request.getParameter("tuNgay"));
        java.time.LocalDate denNgayDon = parseNgay(request.getParameter("denNgay"));
        Integer maDonLoc = parseIntOrNull(request.getParameter("maDon"));
        String tenKHLoc = request.getParameter("tenKH");

        if ("export".equals(action)) {
            xuatExcelDonHang(response, tuNgayDon, denNgayDon, maDonLoc, tenKHLoc);
            return;
        }

        long tongSoDon = donHangDAO.countAll(tuNgayDon, denNgayDon, maDonLoc, tenKHLoc);
        int tongSoTrang = (int) Math.max(1, Math.ceil(tongSoDon / (double) SO_DONG_MOI_TRANG));
        if (trang > tongSoTrang) trang = tongSoTrang;

        request.setAttribute("danhSachDonHang", donHangDAO.getAll(trang, SO_DONG_MOI_TRANG, tuNgayDon, denNgayDon, maDonLoc, tenKHLoc));
        request.setAttribute("trangHienTai", trang);
        request.setAttribute("tongSoTrang", tongSoTrang);
        request.setAttribute("tuNgay", request.getParameter("tuNgay"));
        request.setAttribute("denNgay", request.getParameter("denNgay"));
        request.setAttribute("maDon", request.getParameter("maDon"));
        request.setAttribute("tenKH", tenKHLoc);
        request.setAttribute("tab", "don-hang");
        request.setAttribute("activeMenu", "donhang");
        request.getRequestDispatcher("/view/don-hang.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try { request.setCharacterEncoding("UTF-8"); } catch (Exception ignored) {}
        String action = request.getParameter("action");
        Integer maDH = parseIntOrNull(request.getParameter("maDH"));
        // Moi: ly do doi/tra - khong bat buoc nhap
        String lyDo = request.getParameter("lyDo");

        try {
            if ("tra".equals(action)) {
                Integer maCTDH = Integer.valueOf(request.getParameter("maCTDH"));
                int soLuong = Integer.parseInt(request.getParameter("soLuong"));
                String tenSach = request.getParameter("tenSach");
                donHangDAO.traMon(maCTDH, soLuong, lyDo);
                redirectPhieuInDoiTra(request, response, maDH, "TRA", tenSach, soLuong, null);
            } else if ("doi".equals(action)) {
                Integer maCTDH = Integer.valueOf(request.getParameter("maCTDH"));
                int soLuong = Integer.parseInt(request.getParameter("soLuong"));
                String maSachMoi = request.getParameter("maSachMoi");
                String tenSach = request.getParameter("tenSach");
                donHangDAO.doiMon(maCTDH, soLuong, maSachMoi, lyDo);
                redirectPhieuInDoiTra(request, response, maDH, "DOI", tenSach, soLuong, maSachMoi);
            } else if ("gui-email".equals(action)) {
                // Moi: gui hoa don qua email cho khach hang, xem trong trang chi tiet don hang
                guiHoaDonQuaEmail(maDH);
                redirectWithMessage(request, response, maDH, "Đã gửi hóa đơn qua email cho khách hàng.");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            // Toi uu: log day du loi ra console server (thay vi nuot loi lang le) de de debug,
            // va co gang lay thong diep loi cu the nhat co the (ke ca loi do he thong ném ra
            // ma khong co message, vi du NullPointerException) thay vi luon hien mot cau chung chung.
            e.printStackTrace();
            String message = (e.getMessage() == null || e.getMessage().isBlank())
                    ? "Không thể thực hiện thao tác (" + e.getClass().getSimpleName() + "). Vui lòng xem log server để biết chi tiết."
                    : e.getMessage();
            redirectWithMessage(request, response, maDH, message);
        }
    }

    private java.time.LocalDate parseNgay(String s) {
        try {
            return (s == null || s.isBlank()) ? null : java.time.LocalDate.parse(s);
        } catch (Exception e) {
            return null;
        }
    }

    // Moi: xuat file Excel danh sach don hang theo bo loc hien tai (thay cho o tim kiem chung)
    private void xuatExcelDonHang(HttpServletResponse response, java.time.LocalDate tuNgay,
                                  java.time.LocalDate denNgay, Integer maDon, String tenKH) throws IOException {
        List<entity.DonHang> danhSach = donHangDAO.getAllKhongPhanTrang(tuNgay, denNgay, maDon, tenKH);
        ghiDanhSachDonHangRaExcel(response, danhSach, "don-hang.xlsx");
    }

    // Moi: xuat file Excel danh sach don co the doi/tra theo bo loc hien tai (thay cho o tim kiem chung)
    private void xuatExcelDoiTra(HttpServletResponse response, java.time.LocalDate tuNgay,
                                 java.time.LocalDate denNgay, Integer maDon, String tenKH) throws IOException {
        List<entity.DonHang> danhSach = donHangDAO.getAllCoTheDoiTraKhongPhanTrang(tuNgay, denNgay, maDon, tenKH);
        ghiDanhSachDonHangRaExcel(response, danhSach, "don-hang-doi-tra.xlsx");
    }

    // Moi: gui hoa don qua email cho khach hang cua don hang - xem nut trong don-hang-chi-tiet.jsp
    private void guiHoaDonQuaEmail(Integer maDH) throws Exception {
        if (maDH == null) throw new IllegalArgumentException("Thiếu mã đơn hàng.");
        DonHang dh = donHangDAO.getById(maDH);
        if (dh == null) throw new IllegalArgumentException("Không tìm thấy đơn hàng.");
        if (dh.getKhachHang() == null || dh.getKhachHang().getEmail() == null || dh.getKhachHang().getEmail().isBlank()) {
            throw new IllegalArgumentException("Khách hàng của đơn này chưa có email.");
        }
        utils.MailUtil.guiHoaDon(dh);
    }

    private void ghiDanhSachDonHangRaExcel(HttpServletResponse response, List<entity.DonHang> danhSach,
                                           String tenFile) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("DonHang");

            CellStyle tieuDeStyle = workbook.createCellStyle();
            Font tieuDeFont = workbook.createFont();
            tieuDeFont.setBold(true);
            tieuDeStyle.setFont(tieuDeFont);

            String[] tieuDe = {"Mã đơn", "Thời gian", "Khách hàng", "Nhân viên", "Tổng tiền", "PT thanh toán"};
            Row hangTieuDe = sheet.createRow(0);
            for (int i = 0; i < tieuDe.length; i++) {
                Cell cell = hangTieuDe.createCell(i);
                cell.setCellValue(tieuDe[i]);
                cell.setCellStyle(tieuDeStyle);
            }

            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            int soDong = 1;
            for (entity.DonHang dh : danhSach) {
                Row row = sheet.createRow(soDong++);
                row.createCell(0).setCellValue(dh.getMaDH());
                row.createCell(1).setCellValue(dh.getNgayLap() == null ? "" : dh.getNgayLap().format(dtf));
                row.createCell(2).setCellValue(dh.getKhachHang() == null ? "" : dh.getKhachHang().getTenKH());
                row.createCell(3).setCellValue(dh.getNhanVien() == null ? "" : dh.getNhanVien().getTenNV());
                row.createCell(4).setCellValue(dh.getTongTien() == null ? 0 : dh.getTongTien().doubleValue());
                row.createCell(5).setCellValue(dh.getPhuongThucThanhToan());
            }

            for (int i = 0; i < tieuDe.length; i++) {
                sheet.autoSizeColumn(i);
            }

            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + tenFile + "\"");
            workbook.write(response.getOutputStream());
        }
    }

    private Integer parseIntOrNull(String s) {
        try {
            return s == null ? null : Integer.valueOf(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void redirectWithMessage(HttpServletRequest request, HttpServletResponse response, Integer maDH,
                                     String message) throws IOException {
        if (maDH == null) {
            response.sendRedirect(request.getContextPath() + "/don-hang?message=" +
                    URLEncoder.encode(message, StandardCharsets.UTF_8));
            return;
        }
        response.sendRedirect(request.getContextPath() + "/don-hang?action=view&ma=" + maDH + "&message=" +
                URLEncoder.encode(message, StandardCharsets.UTF_8));
    }

    // Moi: sau khi tra/doi thanh cong, redirect ve trang chi tiet kem du lieu de tu dong mo phieu in
    // (khong luu phieu vao DB - chi truyen qua tham so de trang JSP dung JS render + in ngay).
    private void redirectPhieuInDoiTra(HttpServletRequest request, HttpServletResponse response, Integer maDH,
                                       String loai, String tenSach, int soLuong, String maSachMoi)
            throws IOException {
        String msg = "TRA".equals(loai)
                ? "Đã trả " + soLuong + " cuốn \"" + tenSach + "\" và hoàn lại tồn kho."
                : "Đã đổi " + soLuong + " cuốn \"" + tenSach + "\" sang sách mới.";
        StringBuilder url = new StringBuilder(request.getContextPath())
                .append("/don-hang?action=view&ma=").append(maDH)
                .append("&message=").append(URLEncoder.encode(msg, StandardCharsets.UTF_8))
                .append("&in=1&loai=").append(loai)
                .append("&tenSach=").append(URLEncoder.encode(tenSach == null ? "" : tenSach, StandardCharsets.UTF_8))
                .append("&soLuong=").append(soLuong);
        if (maSachMoi != null) {
            url.append("&maSachMoi=").append(URLEncoder.encode(maSachMoi, StandardCharsets.UTF_8));
        }
        response.sendRedirect(url.toString());
    }
}
