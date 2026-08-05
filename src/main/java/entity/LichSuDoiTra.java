package entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Ghi lai lich su moi lan tra hang / doi hang tren mot don hang.
 * LoaiGiaoDich = "TRA" -> chi tra lai hang, khong nhan hang moi.
 * LoaiGiaoDich = "DOI" -> tra lai hang cu va nhan hang moi, co the phat sinh chenh lech tien.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "LichSuDoiTra")
public class LichSuDoiTra {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaDoiTra")
    private Integer maDoiTra;

    @ManyToOne
    @JoinColumn(name = "MaDH")
    private DonHang donHang;

    @Column(name = "LoaiGiaoDich")
    private String loaiGiaoDich; // "TRA" hoac "DOI"

    @Column(name = "NgayThucHien")
    private LocalDateTime ngayThucHien;

    // Dong san pham cu bi tra lai
    @ManyToOne
    @JoinColumn(name = "MaCTDHCu")
    private ChiTietDonHang chiTietCu;

    @Column(name = "SoLuongTra")
    private Integer soLuongTra;

    // Chi co gia tri khi LoaiGiaoDich = "DOI"
    @ManyToOne
    @JoinColumn(name = "MaSachMoi")
    private Sach sachMoi;

    @Column(name = "SoLuongMoi")
    private Integer soLuongMoi;

    // Duong = khach can tra them, Am = cua hang phai hoan lai cho khach
    @Column(name = "ChenhLechTien")
    private BigDecimal chenhLechTien;

    @Column(name = "LyDo")
    private String lyDo;
}
