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
}