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

    /** Biến thể đã bán — NULL nếu bán theo giá gốc không chọn biến thể */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaBienThe")
    @ToString.Exclude
    private SachBienThe sachBienThe;
}