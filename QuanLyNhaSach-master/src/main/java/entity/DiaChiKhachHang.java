package entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "DiaChiKhachHang")
public class DiaChiKhachHang {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaDiaChi")
    private Integer maDiaChi;

    @ManyToOne
    @JoinColumn(name = "MaKH")
    private KhachHang khachHang;

    @Column(name = "DiaChiChiTiet")
    private String diaChiChiTiet;

    @Column(name = "LaMacDinh")
    private Boolean laMacDinh;
}