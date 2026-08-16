package entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "SachBienThe")
public class SachBienThe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaBienThe")
    private Integer maBienThe;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaSach", nullable = false)
    @ToString.Exclude
    private Sach sach;

    /** Mã ngắn do người dùng đặt để phân biệt nhanh, VD: S001-BC-VI */
    @Column(name = "MaBienTheCode")
    private String maBienTheCode;

    /** Loại bìa: 'Bìa mềm' | 'Bìa cứng' | 'Bìa da' */
    @Column(name = "BiaSach")
    private String biaSach;

    /** Ngôn ngữ: 'Tiếng Việt' | 'Tiếng Anh' | ... */
    @Column(name = "NgonNgu")
    private String ngonNgu;

    @Column(name = "GiaBienThe", nullable = false)
    private BigDecimal giaBienThe;

    /** Bí danh giúp JSP/Servlet gọi getGiaBan() cho nhất quán với Sach */
    @Transient
    public BigDecimal getGiaBan() { return giaBienThe; }

    @Column(name = "TrangThai", nullable = false)
    private Boolean trangThai = true;  // true = đang bán

    /** Tên hiển thị gọn cho dropdown POS */
    @Transient
    public String getTenHienThi() {
        StringBuilder sb = new StringBuilder();
        if (biaSach != null && !biaSach.isBlank()) sb.append(biaSach);
        if (ngonNgu != null && !ngonNgu.isBlank()) {
            if (sb.length() > 0) sb.append(" – ");
            sb.append(ngonNgu);
        }

        return sb.toString();
    }
}
