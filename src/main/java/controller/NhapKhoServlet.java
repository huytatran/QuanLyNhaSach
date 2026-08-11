package controller;

import dao.SachDAO;
import dao.SachVatLyDAO;
import entity.Sach;
import entity.SachVatLy;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/nhap-kho")
public class NhapKhoServlet extends HttpServlet {

    private final SachDAO sachDAO = new SachDAO();
    private final SachVatLyDAO sachVatLyDAO = new SachVatLyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lay ma sach tu request de biet dang nhap kho cho dau sach nao
        String maSach = request.getParameter("maSach");
        if (maSach == null || maSach.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/sach");
            return;
        }

        // Kiem tra xem sach co ton tai trong he thong khong
        Sach sach = sachDAO.getById(maSach);
        if (sach == null) {
            response.sendRedirect(request.getContextPath() + "/sach");
            return;
        }

        // Gui thong tin sach sang trang JSP de hien thi tieu de
        request.setAttribute("sach", sach);
        request.setAttribute("activeMenu", "sach");
        request.getRequestDispatcher("/view/nhap-kho.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action  = request.getParameter("action");
        String maSach  = request.getParameter("maSach");

        Sach sach = sachDAO.getById(maSach);
        if (sach == null) {
            response.sendRedirect(request.getContextPath() + "/sach");
            return;
        }

        // ---- Nhập nhanh theo số lượng ----
        if ("nhapNhanh".equals(action)) {
            String soLuongStr = request.getParameter("soLuong");
            int soLuong;
            try { soLuong = Integer.parseInt(soLuongStr.trim()); }
            catch (Exception e) { soLuong = 0; }

            if (soLuong <= 0) {
                response.sendRedirect(request.getContextPath() + "/sach?loiNhapKho="
                        + java.net.URLEncoder.encode("Số lượng phải lớn hơn 0.", "UTF-8"));
                return;
            }

            // Tìm số serial hiện có lớn nhất để tiếp tục đánh số
            List<SachVatLy> daDuaVao = sachVatLyDAO.getByMaSach(maSach);
            int sttBatDau = daDuaVao.size() + 1;

            List<SachVatLy> listToInsert = new ArrayList<>();
            for (int i = 0; i < soLuong; i++) {
                SachVatLy sv = new SachVatLy();
                sv.setMaSerial(maSach + "-" + String.format("%04d", sttBatDau + i));
                sv.setSach(sach);
                sv.setTrangThai("Có sẵn");
                listToInsert.add(sv);
            }
            try {
                sachVatLyDAO.insertBatch(listToInsert);
                response.sendRedirect(request.getContextPath() + "/sach?nhapKhoThanhCong=1");
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/sach?loiNhapKho="
                        + java.net.URLEncoder.encode("Lỗi nhập kho: " + e.getMessage(), "UTF-8"));
            }
            return;
        }

        // ---- Nhập theo danh sách serial ----
        String danhSachSerial = request.getParameter("danhSachSerial");
        if (danhSachSerial == null || danhSachSerial.isBlank()) {
            doGet(request, response);
            return;
        }

        String[] lines = danhSachSerial.split("[\\r\\n,]+");
        List<SachVatLy> listToInsert = new ArrayList<>();
        for (String s : lines) {
            String serial = s.trim();
            if (!serial.isEmpty()) {
                SachVatLy sv = new SachVatLy();
                sv.setMaSerial(serial);
                sv.setSach(sach);
                sv.setTrangThai("Có sẵn");
                listToInsert.add(sv);
            }
        }
        try {
            if (!listToInsert.isEmpty()) sachVatLyDAO.insertBatch(listToInsert);
            response.sendRedirect(request.getContextPath() + "/sach?nhapKhoThanhCong=1");
        } catch (Exception e) {
            request.setAttribute("thongBaoLoi", "Lỗi khi nhập kho: " + e.getMessage());
            request.setAttribute("sach", sach);
            request.getRequestDispatcher("/view/nhap-kho.jsp").forward(request, response);
        }
    }
}
