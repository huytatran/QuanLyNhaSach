package entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "DonHang")
public class DonHang {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaDH")
    private Integer maDH;

    @Column(name = "NgayLap")
    private LocalDateTime ngayLap;

    @Column(name = "TongTien")
    private BigDecimal tongTien;

    @Column(name = "TrangThai")
    private Integer trangThai;

    @Column(name = "PhuongThucThanhToan")
    private String phuongThucThanhToan;

    @ManyToOne
    @JoinColumn(name = "MaKH")
    private KhachHang khachHang;

    @ManyToOne
    @JoinColumn(name = "MaNV")
    private NhanVien nhanVien;

    @ManyToOne
    @JoinColumn(name = "MaVoucher")
    private Voucher voucher;

    @Column(name = "SoTienGiam")
    private BigDecimal soTienGiam;

    @OneToMany(mappedBy = "donHang", fetch = FetchType.LAZY)
    @ToString.Exclude
    private List<ChiTietDonHang> chiTietDonHangs;
}
