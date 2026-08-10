package entity;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Đại diện cho 1 dòng trong giỏ hàng POS.
 * Key trong Map session: maSach + "|" + maBienThe  (maBienThe = 0 nếu không có biến thể)
 */
public class CartItem implements Serializable {

    private String maSach;
    private Integer maBienThe;   // null / 0 = bán theo giá gốc của Sach
    private int soLuong;
    private BigDecimal donGia;   // giá tại thời điểm thêm vào giỏ (snapshot)
    private String tenSach;
    private String tenBienThe;   // chuỗi hiển thị VD: "Bìa cứng – Tiếng Việt"
    private String anhBia;

    public CartItem() {}

    public CartItem(String maSach, Integer maBienThe, int soLuong,
                    BigDecimal donGia, String tenSach, String tenBienThe, String anhBia) {
        this.maSach     = maSach;
        this.maBienThe  = maBienThe;
        this.soLuong    = soLuong;
        this.donGia     = donGia;
        this.tenSach    = tenSach;
        this.tenBienThe = tenBienThe;
        this.anhBia     = anhBia;
    }

    /** Key dùng làm khóa trong Map giỏ hàng session */
    public static String buildKey(String maSach, Integer maBienThe) {
        return maSach + "|" + (maBienThe == null ? 0 : maBienThe);
    }

    public BigDecimal getThanhTien() {
        if (donGia == null) return BigDecimal.ZERO;
        return donGia.multiply(BigDecimal.valueOf(soLuong));
    }

    // ---- Getters / Setters ----
    public String getMaSach()           { return maSach; }
    public void setMaSach(String v)     { this.maSach = v; }

    public Integer getMaBienThe()           { return maBienThe; }
    public void setMaBienThe(Integer v)     { this.maBienThe = v; }

    public int getSoLuong()             { return soLuong; }
    public void setSoLuong(int v)       { this.soLuong = v; }

    public BigDecimal getDonGia()           { return donGia; }
    public void setDonGia(BigDecimal v)     { this.donGia = v; }

    public String getTenSach()          { return tenSach; }
    public void setTenSach(String v)    { this.tenSach = v; }

    public String getTenBienThe()       { return tenBienThe; }
    public void setTenBienThe(String v) { this.tenBienThe = v; }

    public String getAnhBia()           { return anhBia; }
    public void setAnhBia(String v)     { this.anhBia = v; }
}
