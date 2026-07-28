package entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "BoSach")
public class BoSach {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaBoSach")
    private Integer maBoSach;
    @Column(name = "TenBoSach")
    private String tenBoSach;
    @Column(name = "MoTa")
    private String moTa;
}