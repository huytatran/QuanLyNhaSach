package entity;

import jakarta.persistence.*;
import lombok.*;

@Data @NoArgsConstructor @AllArgsConstructor
@Entity @Table(name = "KhachHang")
public class KhachHang {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaKH")
    private Integer maKH;

    @Column(name = "TenKH")
    private String tenKH;

    @Column(name = "Sdt")
    private String sdt;

    @Column(name = "Email")
    private String email;

    @Column(name = "DiemTichLuy")
    private Integer diemTichLuy;

    @Column(name = "TrangThai")
    private Boolean trangThai;
}