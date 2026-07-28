package entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "Voucher")
public class Voucher {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaVoucher")
    private Integer maVoucher;

    @Column(name = "MaCode")
    private String maCode;

    @Column(name = "LoaiGiam")
    private Integer loaiGiam;

    @Column(name = "GiaTri")
    private BigDecimal giaTri;

    @Column(name = "GiaTriDonToiThieu")
    private BigDecimal giaTriDonToiThieu;

    @Column(name = "GiaGiamToiDa")
    private BigDecimal giaGiamToiDa;

    @Column(name = "NgayBatDau")
    private LocalDateTime ngayBatDau;

    @Column(name = "NgayKetThuc")
    private LocalDateTime ngayKetThuc;

    @Column(name = "SoLuongToiDa")
    private Integer soLuongToiDa;

    @Column(name = "DaSuDung")
    private Integer daSuDung;
}