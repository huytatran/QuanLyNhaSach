package entity;

import lombok.*;
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SachTacGiaId implements Serializable {
    private String sach;
    private Integer tacGia;
}