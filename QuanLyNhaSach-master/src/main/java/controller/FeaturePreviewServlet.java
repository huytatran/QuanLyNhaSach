package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

// Đã xóa "/danhgia" và "/voucher" để nhường đường dẫn cho Servlet thật hoạt động
@WebServlet({"/khachhang", "/donhang", "/danhmuc"})
public class FeaturePreviewServlet extends HttpServlet {

    private static final Map<String, FeatureInfo> FEATURES = new HashMap<>();

    static {
        FEATURES.put("/khachhang", new FeatureInfo("khachhang", "Quan ly khach hang",
                "Luu thong tin khach mua tai quay, tim theo ten hoac so dien thoai va chon nhanh trong POS.",
                "bi-people-fill", "NV2", "Can cho POS"));
        FEATURES.put("/donhang", new FeatureInfo("donhang", "Don hang va doi tra",
                "Theo doi lich su don, huy don, doi tra sach va in hoa don tu du lieu DonHang.",
                "bi-receipt-cutoff", "NV3", "Vong doi ban hang"));
        FEATURES.put("/voucher", new FeatureInfo("voucher", "Voucher giam gia",
                "Tao ma giam gia, dieu kien ap dung va tinh SoTienGiam ngay tren man hinh POS.",
                "bi-ticket-perforated-fill", "NV4", "Tich hop POS"));
        FEATURES.put("/danhmuc", new FeatureInfo("danhmuc", "Thuoc tinh sach",
                "Quan ly the loai, tac gia, nha xuat ban, bo sach va thong tin phan loai sach.",
                "bi-tags-fill", "Danh muc", "Nen du lieu"));
        FEATURES.put("/danhgia", new FeatureInfo("danhgia", "Danh gia sach",
                "Ghi nhan diem va nhan xet cua khach cho tung dau sach sau khi mua.",
                "bi-star-half", "NV4", "Mo rong"));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        FeatureInfo info = FEATURES.getOrDefault(request.getServletPath(), FEATURES.get("/khachhang"));
        request.setAttribute("activeMenu", info.activeMenu);
        request.setAttribute("feature", info);
        request.getRequestDispatcher("/view/feature-preview.jsp").forward(request, response);
    }

    public static class FeatureInfo {
        private final String activeMenu;
        private final String title;
        private final String description;
        private final String icon;
        private final String owner;
        private final String status;

        public FeatureInfo(String activeMenu, String title, String description, String icon, String owner, String status) {
            this.activeMenu = activeMenu;
            this.title = title;
            this.description = description;
            this.icon = icon;
            this.owner = owner;
            this.status = status;
        }

        public String getActiveMenu() { return activeMenu; }
        public String getTitle() { return title; }
        public String getDescription() { return description; }
        public String getIcon() { return icon; }
        public String getOwner() { return owner; }
        public String getStatus() { return status; }
    }
}