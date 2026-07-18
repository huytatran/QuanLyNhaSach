package entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "SachVatLy")
public class SachVatLy {
    @Id
    @Column(name = "MaSerial")
    private String maSerial;

    @ManyToOne
    @JoinColumn(name = "MaSach")
    private Sach sach;

    @Column(name = "TrangThai")
    private String trangThai;

    @ManyToOne
    @JoinColumn(name = "MaCTDH")
    private ChiTietDonHang chiTietDonHang;
}