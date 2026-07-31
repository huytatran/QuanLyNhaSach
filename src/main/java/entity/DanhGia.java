package entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "DanhGia")
public class DanhGia {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaDanhGia")
    private Integer maDanhGia;

    @ManyToOne
    @JoinColumn(name = "MaKH")
    private KhachHang khachHang;

    @ManyToOne
    @JoinColumn(name = "MaSach")
    private Sach sach;

    @Column(name = "SoSao")
    private Integer soSao;

    @Column(name = "NoiDung")
    private String noiDung;

    @Column(name = "NgayDanhGia")
    private LocalDateTime ngayDanhGia;
}