package dao;

import entity.*;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class DonHangDAO {

    public static final int TRANG_THAI_DA_GIAO = 1;
    public static final int TRANG_THAI_DA_TRA = 2;        // da tra toan bo (khong con dong nao con hang)
    public static final int TRANG_THAI_DOI_TRA_MOT_PHAN = 3; // co phat sinh doi/tra mot phan

    public static final String LOAI_GD_TRA = "TRA";
    public static final String LOAI_GD_DOI = "DOI";

    private static final String CO_SAN = "Có sẵn";
    private static final String DA_BAN = "Đã bán";

    // Lay danh sach tat ca don hang de hien thi o trang quan ly
    public List<DonHang> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT DISTINCT dh FROM DonHang dh " +
                    "LEFT JOIN FETCH dh.khachHang " +
                    "LEFT JOIN FETCH dh.nhanVien " +
                    "ORDER BY dh.ngayLap DESC", DonHang.class)
                    .getResultList();
        }
    }

    // Lay chi tiet mot don hang kem theo danh sach cac san pham (chi tiet don hang)
    public DonHang getById(Integer maDH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT dh FROM DonHang dh " +
                    "LEFT JOIN FETCH dh.khachHang " +
                    "LEFT JOIN FETCH dh.nhanVien " +
                    "LEFT JOIN FETCH dh.chiTietDonHangs ct " +
                    "LEFT JOIN FETCH ct.sach " +
                    "WHERE dh.maDH = :ma", DonHang.class)
                    .setParameter("ma", maDH)
                    .uniqueResult();
        }
    }

    /**
     * Tao don ban hang POS: 
     * 1. Tao ban ghi DonHang
     * 2. Voi moi mon hang: Tao ChiTietDonHang + Cap nhat tung cuon SachVatLy tu 'Có sẵn' sang 'Đã bán'
     * @param gioHang map maSach -> soLuong
     * @return maDH vua tao
     */
    public int taoDonHang(Integer maKH, Integer maNV, String phuongThuc,
                          Map<String, Integer> gioHang) {
        if (gioHang == null || gioHang.isEmpty()) {
            throw new IllegalArgumentException("Giỏ hàng trống.");
        }

        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();

            // Lay thong tin Khach hang va Nhan vien tu DB
            KhachHang kh = session.get(KhachHang.class, maKH);
            NhanVien nv = session.get(NhanVien.class, maNV);
            if (kh == null) throw new IllegalArgumentException("Không tìm thấy khách hàng.");
            if (nv == null) throw new IllegalArgumentException("Không tìm thấy nhân viên.");

            // Khoi tao doi tuong DonHang moi
            DonHang dh = new DonHang();
            dh.setNgayLap(LocalDateTime.now());
            dh.setTongTien(BigDecimal.ZERO); 
            dh.setTrangThai(TRANG_THAI_DA_GIAO); // Mac dinh 1 la Da giao
            dh.setPhuongThucThanhToan(phuongThuc);
            dh.setKhachHang(kh);
            dh.setNhanVien(nv);
            dh.setSoTienGiam(BigDecimal.ZERO);
            session.persist(dh);
            session.flush(); // Day xuong DB de lay MaDH tu dong tang

            BigDecimal tong = BigDecimal.ZERO;

            // Duyet qua tung mat hang trong gio hang
            for (Map.Entry<String, Integer> entry : gioHang.entrySet()) {
                String maSach = entry.getKey();
                int soLuong = entry.getValue();
                if (soLuong <= 0) continue;

                Sach sach = session.get(Sach.class, maSach);
                if (sach == null) {
                    throw new IllegalArgumentException("Không tìm thấy sách " + maSach);
                }

                // Tim cac cuon sach vat ly con trong kho de ban
                List<SachVatLy> cuonCoSan = session.createQuery(
                                "FROM SachVatLy sv WHERE sv.sach.maSach = :ma AND sv.trangThai = :tt",
                                SachVatLy.class)
                        .setParameter("ma", maSach)
                        .setParameter("tt", CO_SAN)
                        .setMaxResults(soLuong)
                        .getResultList();

                if (cuonCoSan.size() < soLuong) {
                    throw new IllegalArgumentException(
                            "Sách \"" + sach.getTenSach() + "\" chỉ còn " + cuonCoSan.size() + " cuốn.");
                }

                // Tao chi tiet don hang cho dau sach nay
                ChiTietDonHang ct = new ChiTietDonHang();
                ct.setDonHang(dh);
                ct.setSach(sach);
                ct.setSoLuong(soLuong);
                ct.setDonGia(sach.getGiaBan() != null ? sach.getGiaBan() : BigDecimal.ZERO);
                session.persist(ct);
                session.flush(); 

                // Tinh luy ke tong tien don hang
                tong = tong.add(ct.getDonGia().multiply(BigDecimal.valueOf(soLuong)));

                // Gan tung cuon sach vat ly cu the vao chi tiet don hang va doi trang thai thanh 'Đã bán'
                for (SachVatLy sv : cuonCoSan) {
                    sv.setTrangThai(DA_BAN);
                    sv.setChiTietDonHang(ct);
                    session.merge(sv);
                }
            }

            // Cap nhat tong tien cuoi cung cho don hang
            dh.setTongTien(tong);
            session.merge(dh);

            tx.commit();
            return dh.getMaDH();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Tra lai mot phan (hoac toan bo) so luong cua MOT dong san pham trong don hang.
     * Khong nhan hang moi thay the.
     * @return ban ghi lich su vua tao (dung de in phieu tra)
     */
    public LichSuDoiTra traHangTheoDong(Integer maCTDH, int soLuongTra, String lyDo) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();

            ChiTietDonHang ct = session.get(ChiTietDonHang.class, maCTDH);
            if (ct == null) {
                throw new IllegalArgumentException("Không tìm thấy dòng sản phẩm trong đơn hàng.");
            }
            DonHang donHang = ct.getDonHang();
            kiemTraDonConTheDoiTra(donHang);

            int daTra = ct.getSoLuongDaTra() == null ? 0 : ct.getSoLuongDaTra();
            int conLai = ct.getSoLuong() - daTra;
            if (soLuongTra <= 0 || soLuongTra > conLai) {
                throw new IllegalArgumentException(
                        "Số lượng trả không hợp lệ. Dòng này chỉ còn có thể trả tối đa " + conLai + " cuốn.");
            }

            hoanKhoChoDongCu(session, ct, soLuongTra);

            ct.setSoLuongDaTra(daTra + soLuongTra);
            session.merge(ct);
            session.flush(); // Dam bao trang thai 'Co san' cua sach vua tra duoc ghi nhan ngay

            BigDecimal soTienHoan = ct.getDonGia().multiply(BigDecimal.valueOf(soLuongTra));
            donHang.setTongTien(donHang.getTongTien().subtract(soTienHoan));

            LichSuDoiTra lichSu = new LichSuDoiTra();
            lichSu.setDonHang(donHang);
            lichSu.setLoaiGiaoDich(LOAI_GD_TRA);
            lichSu.setNgayThucHien(LocalDateTime.now());
            lichSu.setChiTietCu(ct);
            lichSu.setSoLuongTra(soLuongTra);
            lichSu.setChenhLechTien(soTienHoan.negate());
            lichSu.setLyDo(lyDo);
            session.persist(lichSu);
            session.flush();

            capNhatTrangThaiDonSauDoiTra(session, donHang);
            session.merge(donHang);

            tx.commit();
            return lichSu;
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Tra lai mot phan so luong cua MOT dong san pham va nhan mot sach khac thay the,
     * tu dong tinh chenh lech tien (duong = khach tra them, am = hoan lai khach).
     * @return ban ghi lich su vua tao (dung de in phieu doi)
     */
    public LichSuDoiTra doiHang(Integer maCTDH, int soLuongTra, String maSachMoi, int soLuongMoi, String lyDo) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();

            ChiTietDonHang ctCu = session.get(ChiTietDonHang.class, maCTDH);
            if (ctCu == null) {
                throw new IllegalArgumentException("Không tìm thấy dòng sản phẩm trong đơn hàng.");
            }
            DonHang donHang = ctCu.getDonHang();
            kiemTraDonConTheDoiTra(donHang);

            int daTra = ctCu.getSoLuongDaTra() == null ? 0 : ctCu.getSoLuongDaTra();
            int conLai = ctCu.getSoLuong() - daTra;
            if (soLuongTra <= 0 || soLuongTra > conLai) {
                throw new IllegalArgumentException(
                        "Số lượng trả không hợp lệ. Dòng này chỉ còn có thể trả tối đa " + conLai + " cuốn.");
            }
            if (soLuongMoi <= 0) {
                throw new IllegalArgumentException("Số lượng sách mới không hợp lệ.");
            }

            Sach sachMoi = session.get(Sach.class, maSachMoi);
            if (sachMoi == null) {
                throw new IllegalArgumentException("Không tìm thấy sách muốn đổi sang.");
            }
            if (Boolean.FALSE.equals(sachMoi.getTrangThai())) {
                throw new IllegalStateException("Sách \"" + sachMoi.getTenSach() + "\" đã ngừng kinh doanh, không thể chọn để đổi.");
            }

            // Dieu kien doi hang: chi duoc doi sang sach co gia BANG hoac CAO HON gia sach cu
            // (khong cho doi sang sach re hon de tranh phat sinh hoan tien qua chuc nang doi;
            // neu khach muon lay sach re hon, nghiep vu se la Tra hang roi mua lai).
            BigDecimal giaCu = ctCu.getDonGia() == null ? BigDecimal.ZERO : ctCu.getDonGia();
            BigDecimal giaMoi = sachMoi.getGiaBan() == null ? BigDecimal.ZERO : sachMoi.getGiaBan();
            if (giaMoi.compareTo(giaCu) < 0) {
                throw new IllegalArgumentException(
                        "Chỉ được đổi sang sách có giá bằng hoặc cao hơn giá sách \"" + ctCu.getSach().getTenSach() +
                        "\" (" + formatTien(giaCu) + " ₫). Sách \"" + sachMoi.getTenSach() + "\" có giá " +
                        formatTien(giaMoi) + " ₫, thấp hơn nên không thể chọn để đổi.");
            }

            // Hoan kho hang cu
            hoanKhoChoDongCu(session, ctCu, soLuongTra);
            ctCu.setSoLuongDaTra(daTra + soLuongTra);
            session.merge(ctCu);
            session.flush(); // Dam bao cac cuon vua hoan kho duoc thay ngay neu doi sang cung dau sach

            // Xuat kho hang moi
            List<SachVatLy> cuonCoSan = session.createQuery(
                            "FROM SachVatLy sv WHERE sv.sach.maSach = :ma AND sv.trangThai = :tt",
                            SachVatLy.class)
                    .setParameter("ma", maSachMoi)
                    .setParameter("tt", CO_SAN)
                    .setMaxResults(soLuongMoi)
                    .getResultList();
            if (cuonCoSan.size() < soLuongMoi) {
                throw new IllegalArgumentException(
                        "Sách \"" + sachMoi.getTenSach() + "\" chỉ còn " + cuonCoSan.size() + " cuốn trong kho.");
            }

            ChiTietDonHang ctMoi = new ChiTietDonHang();
            ctMoi.setDonHang(donHang);
            ctMoi.setSach(sachMoi);
            ctMoi.setSoLuong(soLuongMoi);
            ctMoi.setDonGia(sachMoi.getGiaBan() != null ? sachMoi.getGiaBan() : BigDecimal.ZERO);
            ctMoi.setSoLuongDaTra(0);
            session.persist(ctMoi);
            session.flush();

            for (SachVatLy sv : cuonCoSan) {
                sv.setTrangThai(DA_BAN);
                sv.setChiTietDonHang(ctMoi);
                session.merge(sv);
            }

            BigDecimal tienHangCu = ctCu.getDonGia().multiply(BigDecimal.valueOf(soLuongTra));
            BigDecimal tienHangMoi = ctMoi.getDonGia().multiply(BigDecimal.valueOf(soLuongMoi));
            BigDecimal chenhLech = tienHangMoi.subtract(tienHangCu);
            donHang.setTongTien(donHang.getTongTien().add(chenhLech));

            LichSuDoiTra lichSu = new LichSuDoiTra();
            lichSu.setDonHang(donHang);
            lichSu.setLoaiGiaoDich(LOAI_GD_DOI);
            lichSu.setNgayThucHien(LocalDateTime.now());
            lichSu.setChiTietCu(ctCu);
            lichSu.setSoLuongTra(soLuongTra);
            lichSu.setSachMoi(sachMoi);
            lichSu.setSoLuongMoi(soLuongMoi);
            lichSu.setChenhLechTien(chenhLech);
            lichSu.setLyDo(lyDo);
            session.persist(lichSu);
            session.flush();

            capNhatTrangThaiDonSauDoiTra(session, donHang);
            session.merge(donHang);

            tx.commit();
            return lichSu;
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /** Danh sach lich su doi/tra cua mot don hang, moi nhat truoc. */
    public List<LichSuDoiTra> getLichSuDoiTra(Integer maDH) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT ls FROM LichSuDoiTra ls " +
                    "LEFT JOIN FETCH ls.chiTietCu ct " +
                    "LEFT JOIN FETCH ct.sach " +
                    "LEFT JOIN FETCH ls.sachMoi " +
                    "WHERE ls.donHang.maDH = :ma " +
                    "ORDER BY ls.ngayThucHien DESC", LichSuDoiTra.class)
                    .setParameter("ma", maDH)
                    .getResultList();
        }
    }

    /** Mot ban ghi lich su doi/tra cu the, du du lieu de in phieu. */
    public LichSuDoiTra getLichSuDoiTraById(Integer maDoiTra) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT ls FROM LichSuDoiTra ls " +
                    "LEFT JOIN FETCH ls.donHang dh " +
                    "LEFT JOIN FETCH dh.khachHang " +
                    "LEFT JOIN FETCH dh.nhanVien " +
                    "LEFT JOIN FETCH ls.chiTietCu ct " +
                    "LEFT JOIN FETCH ct.sach " +
                    "LEFT JOIN FETCH ls.sachMoi " +
                    "WHERE ls.maDoiTra = :ma", LichSuDoiTra.class)
                    .setParameter("ma", maDoiTra)
                    .uniqueResult();
        }
    }

    /** Dinh dang so tien don gian (nhom 3 chu so bang dau cham) de dua vao thong bao loi. */
    private String formatTien(BigDecimal tien) {
        if (tien == null) return "0";
        return String.format("%,d", tien.setScale(0, java.math.RoundingMode.HALF_UP).longValueExact())
                .replace(',', '.');
    }

    private void kiemTraDonConTheDoiTra(DonHang donHang) {
        if (donHang == null) {
            throw new IllegalArgumentException("Không tìm thấy đơn hàng.");
        }
        if (Integer.valueOf(TRANG_THAI_DA_TRA).equals(donHang.getTrangThai())) {
            throw new IllegalStateException("Đơn hàng này đã được trả toàn bộ, không thể đổi/trả thêm.");
        }
    }

    /** Chon dung so luong cuon sach vat ly dang gan voi dong nay va tra ve kho ('Có sẵn'). */
    private void hoanKhoChoDongCu(Session session, ChiTietDonHang ct, int soLuong) {
        List<SachVatLy> sachDaBan = session.createQuery(
                        "FROM SachVatLy sv WHERE sv.chiTietDonHang.maCTDH = :ma AND sv.trangThai = :tt",
                        SachVatLy.class)
                .setParameter("ma", ct.getMaCTDH())
                .setParameter("tt", DA_BAN)
                .setMaxResults(soLuong)
                .getResultList();
        if (sachDaBan.size() < soLuong) {
            throw new IllegalStateException("Dữ liệu tồn kho không khớp, không thể trả đủ số lượng yêu cầu.");
        }
        for (SachVatLy sv : sachDaBan) {
            sv.setTrangThai(CO_SAN);
            sv.setChiTietDonHang(null);
            session.merge(sv);
        }
    }

    /** Xac dinh lai trang thai don: 2 neu tat ca cac dong da tra het, 3 neu co phat sinh doi/tra mot phan. */
    private void capNhatTrangThaiDonSauDoiTra(Session session, DonHang donHang) {
        List<ChiTietDonHang> cacDong = session.createQuery(
                        "FROM ChiTietDonHang ct WHERE ct.donHang.maDH = :ma", ChiTietDonHang.class)
                .setParameter("ma", donHang.getMaDH())
                .getResultList();

        boolean conHangChuaTra = false;
        boolean coDongDaTra = false;
        for (ChiTietDonHang ct : cacDong) {
            int daTra = ct.getSoLuongDaTra() == null ? 0 : ct.getSoLuongDaTra();
            if (daTra > 0) {
                coDongDaTra = true;
            }
            if (daTra < ct.getSoLuong()) {
                conHangChuaTra = true;
            }
        }

        if (!conHangChuaTra) {
            donHang.setTrangThai(TRANG_THAI_DA_TRA);
        } else if (coDongDaTra) {
            donHang.setTrangThai(TRANG_THAI_DOI_TRA_MOT_PHAN);
        }
        // neu chua dong nao bi tra, giu nguyen trang thai hien tai (thuong la Da giao)
    }
}
