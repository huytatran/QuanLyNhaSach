package controller;

import entity.Voucher;
import repository.VoucherRepo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet({"/voucher/hien-thi", "/voucher/them"})
public class VoucherServlet extends HttpServlet {

    private VoucherRepo voucherRepo = new VoucherRepo();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        if (uri.contains("/hien-thi")) {
            List<Voucher> listVoucher = voucherRepo.getAll();
            request.setAttribute("listVoucher", listVoucher);
            request.getRequestDispatcher("/view/voucher.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String uri = request.getRequestURI();

        if (uri.contains("/them")) {
            try {
                String maCode = request.getParameter("maCode");
                String loaiGiam = request.getParameter("loaiGiam");
                String giaTri = request.getParameter("giaTri");
                String giaTriDonToiThieu = request.getParameter("giaTriDonToiThieu");
                String giaGiamToiDa = request.getParameter("giaGiamToiDa");
                String soLuongToiDa = request.getParameter("soLuongToiDa");
                String strNgayBatDau = request.getParameter("ngayBatDau");
                String strNgayKetThuc = request.getParameter("ngayKetThuc");

                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
                Voucher v = new Voucher();
                v.setMaCode(maCode);
                v.setLoaiGiam(Integer.parseInt(loaiGiam));
                v.setGiaTri(new BigDecimal(giaTri));
                v.setGiaTriDonToiThieu(new BigDecimal(giaTriDonToiThieu));
                v.setGiaGiamToiDa(new BigDecimal(giaGiamToiDa));
                v.setNgayBatDau(LocalDateTime.parse(strNgayBatDau, formatter));
                v.setNgayKetThuc(LocalDateTime.parse(strNgayKetThuc, formatter));
                v.setSoLuongToiDa(Integer.parseInt(soLuongToiDa));
                v.setDaSuDung(0);

                voucherRepo.add(v);
                response.sendRedirect(request.getContextPath() + "/voucher/hien-thi");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}