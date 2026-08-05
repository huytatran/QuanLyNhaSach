import dao.DonHangDAO;
import entity.DonHang;

public class DoiTraProbe {
    public static void main(String[] args) {
        DonHangDAO dao = new DonHangDAO();
        DonHang donHang = dao.getAll().stream().findFirst().orElse(null);
        if (donHang == null) {
            System.out.println("NO_ORDERS");
            return;
        }
        DonHang chiTiet = dao.getById(donHang.getMaDH());
        int soLichSu = dao.getLichSuDoiTra(donHang.getMaDH()).size();
        System.out.println("DOI_TRA_PAGE_OK: " + chiTiet.getMaDH() + ", history=" + soLichSu);
    }
}
