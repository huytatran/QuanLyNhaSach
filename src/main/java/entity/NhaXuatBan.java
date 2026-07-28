package entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "NhaXuatBan")
public class NhaXuatBan {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaNXB")
    private Integer maNXB;
    @Column(name = "TenNXB")
    private String tenNXB;
    @Column(name = "Sdt")
    private String sdt;
    @Column(name = "DiaChi")
    private String diaChi;
}