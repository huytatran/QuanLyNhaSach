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
        
        // Lay thong tin tu form nhap kho
        String maSach = request.getParameter("maSach");
        String danhSachSerial = request.getParameter("danhSachSerial"); // Chuoi cac serial cach nhau boi dau phay hoac xuong dong

        if (maSach == null || danhSachSerial == null || danhSachSerial.isBlank()) {
            doGet(request, response);
            return;
        }

        Sach sach = sachDAO.getById(maSach);
        if (sach == null) {
            response.sendRedirect(request.getContextPath() + "/sach");
            return;
        }

        // Xu ly chuoi serial nguoi dung nhap (tach theo dong hoac dau phay)
        String[] lines = danhSachSerial.split("[\\r\\n,]+");
        List<SachVatLy> listToInsert = new ArrayList<>();
        
        for (String s : lines) {
            String serial = s.trim();
            if (!serial.isEmpty()) {
                // Tao doi tuong sach vat ly moi cho moi ma serial
                SachVatLy sv = new SachVatLy();
                sv.setMaSerial(serial);
                sv.setSach(sach);
                sv.setTrangThai("Có sẵn"); // Trang thai mac dinh khi nhap kho
                listToInsert.add(sv);
            }
        }

        try {
            // Goi DAO de thuc hien insert hang loat vao database
            if (!listToInsert.isEmpty()) {
                sachVatLyDAO.insertBatch(listToInsert);
            }
            // Chuyen huong ve danh sach kem thong bao thanh cong
            response.sendRedirect(request.getContextPath() + "/sach?nhapKhoThanhCong=1");
        } catch (Exception e) {
            // Neu co loi (vi du trung ma serial) thi hien thi lai trang nhap kem thong bao loi
            request.setAttribute("thongBaoLoi", "Lỗi khi nhập kho: " + e.getMessage());
            request.setAttribute("sach", sach);
            request.getRequestDispatcher("/view/nhap-kho.jsp").forward(request, response);
        }
    }
}
