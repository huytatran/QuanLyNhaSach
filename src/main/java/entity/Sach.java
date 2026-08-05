package entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

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

    @Column(name = "TrangThai")
    private Boolean trangThai;

    // Lưu path tương đối để hiển thị ảnh (ví dụ: uploads/books/S001.jpg)
    @Column(name = "AnhBia")
    private String anhBia;

    // Biến thể: loại bìa (VD: Bìa mềm, Bìa cứng, Bìa đặc biệt)
    @Column(name = "BiaSach")
    private String biaSach;

    // Biến thể: ngôn ngữ (VD: Tiếng Việt, Tiếng Anh, Song ngữ Anh-Việt)
    @Column(name = "NgonNgu")
    private String ngonNgu;

    // MỚI: quan hệ ngược tới bảng trung gian Sach_TacGia
    @OneToMany(mappedBy = "sach", fetch = FetchType.LAZY)
    @ToString.Exclude
    private List<SachTacGia> danhSachTacGia;
}