package entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "TacGia")
public class TacGia {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaTG")
    private Integer maTG;
    @Column(name = "TenTG")
    private String tenTG;
    @Column(name = "TieuSu")
    private String tieuSu;
}