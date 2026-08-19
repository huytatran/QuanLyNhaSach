package entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "NhanVien")
public class NhanVien {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaNV")
    private Integer maNV;

    @Column(name = "TenNV")
    private String tenNV;

    @Column(name = "Sdt")
    private String sdt;

    @Column(name = "Email")
    private String email;

    @Column(name = "DiaChi")
    private String diaChi;

    @Column(name = "TaiKhoan")
    private String taiKhoan;

    @Column(name = "MatKhau")
    private String matKhau;

    @Column(name = "VaiTroNV")
    private Short vaiTroNV;

    @Column(name = "TrangThai")
    private Boolean trangThai;

    // Bổ sung thêm trường Ca làm việc
    @Column(name = "CaLamViec", columnDefinition = "NVARCHAR(100)")
    private String caLamViec;

}