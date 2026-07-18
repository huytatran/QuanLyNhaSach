package entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "Sach_TacGia")
@IdClass(SachTacGiaId.class)
public class SachTacGia {
    @Id
    @ManyToOne
    @JoinColumn(name = "MaSach")
    private Sach sach;

    @Id
    @ManyToOne
    @JoinColumn(name = "MaTG")
    private TacGia tacGia;

    @Column(name = "VaiTroTG")
    private String vaiTroTG;
}