package controller;

import entity.DanhGia;
import entity.KhachHang;
import entity.Sach;
import repository.DanhGiaRepo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet({"/danhgia/hien-thi", "/danhgia/them", "/danhgia"})
public class DanhGiaServlet extends HttpServlet {

    private DanhGiaRepo danhGiaRepo = new DanhGiaRepo();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Lấy toàn bộ dữ liệu cần thiết
        List<DanhGia> listDanhGia = danhGiaRepo.getAll();
        List<Sach> listSach = danhGiaRepo.getListSach();
        List<KhachHang> listKhachHang = danhGiaRepo.getListKhachHang();

        // Đẩy lên JSP
        request.setAttribute("listDanhGia", listDanhGia);
        request.setAttribute("listSach", listSach);
        request.setAttribute("listKhachHang", listKhachHang);

        // Kích hoạt màu xanh cho menu Đánh giá
        request.setAttribute("activeMenu", "danhgia");

        request.getRequestDispatcher("/view/danhgia.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String uri = request.getRequestURI();

        if (uri.contains("/them")) {
            try {
                String maKH = request.getParameter("maKH");
                String maSach = request.getParameter("maSach");
                String soSao = request.getParameter("soSao");
                String noiDung = request.getParameter("noiDung");

                // Tạo đối tượng Rỗng chỉ chứa ID để map khóa ngoại vào Hibernate
                KhachHang kh = new KhachHang();
                kh.setMaKH(Integer.parseInt(maKH));

                Sach sach = new Sach();
                sach.setMaSach(maSach); // Mã sách thường là String (VD: S01)

                // Đóng gói dữ liệu
                DanhGia dg = new DanhGia();
                dg.setKhachHang(kh);
                dg.setSach(sach);
                dg.setSoSao(Integer.parseInt(soSao));
                dg.setNoiDung(noiDung);

                // Lưu xuống DB
                danhGiaRepo.add(dg);

                // Load lại trang
                response.sendRedirect(request.getContextPath() + "/danhgia/hien-thi");

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}