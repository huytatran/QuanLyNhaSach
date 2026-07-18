package entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "Sach")
public class Sach {
    @Id
    @Column(name = "MaSach")
    private String maSach;

    @Column(name = "TenSach")
    private String tenSach;

    @Column(name = "NamXB")
    private Integer namXB;

    @Column(name = "GiaBan")
    private BigDecimal giaBan;

    @ManyToOne
    @JoinColumn(name = "MaTL")
    private TheLoai theLoai;

    @ManyToOne
    @JoinColumn(name = "MaNXB")
    private NhaXuatBan nhaXuatBan;

    @ManyToOne
    @JoinColumn(name = "MaBoSach")
    private BoSach boSach;

    @Column(name = "SoPhan")
    private Integer soPhan;
}