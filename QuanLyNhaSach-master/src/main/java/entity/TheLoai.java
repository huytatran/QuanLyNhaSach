package entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "TheLoai")
public class TheLoai {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaTL")
    private Integer maTL;
    @Column(name = "TenTL")
    private String tenTL;
}