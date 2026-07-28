package entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "ChiTietDonHang")
public class ChiTietDonHang {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaCTDH")
    private Integer maCTDH;

    @ManyToOne
    @JoinColumn(name = "MaDH")
    private DonHang donHang;

    @ManyToOne
    @JoinColumn(name = "MaSach")
    private Sach sach;

    @Column(name = "SoLuong")
    private Integer soLuong;

    @Column(name = "DonGia")
    private BigDecimal donGia;

    @Column(name = "ThanhTien", insertable = false, updatable = false)
    private BigDecimal thanhTien;

    // So luong da duoc tra lai tren dong nay (dung de chan tra vuot so luong da mua)
    // Mac dinh 0 de cac cho tao ChiTietDonHang cu (vd DonHangDAO.taoDonHang) khong bi loi NOT NULL
    @Column(name = "SoLuongDaTra")
    private Integer soLuongDaTra = 0;

    // Tien ich: so luong con lai co the tra (chua tra het) - khong anh xa DB, chi tinh toan
    public int soLuongConLaiCoTheTra() {
        int daTra = soLuongDaTra == null ? 0 : soLuongDaTra;
        int soLuongGoc = soLuong == null ? 0 : soLuong;
        return Math.max(0, soLuongGoc - daTra);
    }
}