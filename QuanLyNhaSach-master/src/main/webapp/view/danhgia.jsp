<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="java.util.List" %>
<%@ page import="entity.DanhGia" %>
<%@ page import="entity.Sach" %>
<%@ page import="entity.KhachHang" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đánh giá sách - Portal Work</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        .content-wrapper { margin-left: 280px; margin-top: 60px; padding: 30px; }
        .card-custom { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
        .form-label { font-size: 13px; font-weight: 500; color: #475569; margin-bottom: 6px; }
        .form-control, .form-select { border-radius: 8px; border: 1px solid #cbd5e1; font-size: 14px; padding: 10px 12px; }
        .btn-primary-custom { background-color: #4f46e5; color: white; border: none; border-radius: 8px; padding: 10px; font-weight: 600; width: 100%; transition: 0.2s;}
        .btn-primary-custom:hover { background-color: #4338ca; }
        .table-custom th { color: #64748b; font-size: 11px; font-weight: 700; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; padding-bottom: 12px; }
        .table-custom td { padding: 16px 8px; font-size: 14px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }

        /* Hiệu ứng màu sao đánh giá */
        .star-rating { color: #eab308; }
    </style>
</head>
<body>

<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div class="content-wrapper">
    <div class="mb-4">
        <span class="text-uppercase" style="font-size: 11px; font-weight: 700; color: #64748b; letter-spacing: 0.05em;">NV4 - Mở rộng</span>
        <h3 class="fw-bold mt-1" style="color: #0f172a;"><i class="bi bi-star-half me-2" style="color: #4f46e5;"></i> Đánh giá sách</h3>
        <p class="text-muted mb-0" style="font-size: 14px;">Ghi nhận điểm và nhận xét của khách cho từng đầu sách sau khi mua.</p>
    </div>

    <div class="row g-4">
        <!-- CỘT TRÁI: FORM THÊM ĐÁNH GIÁ -->
        <div class="col-lg-4">
            <div class="card-custom p-4">
                <h6 class="fw-bold mb-4" style="color: #0f172a;">Thêm đánh giá</h6>
                <form action="${pageContext.request.contextPath}/danhgia/them" method="POST">

                    <div class="mb-3">
                        <label class="form-label">Khách hàng</label>
                        <select class="form-select" name="maKH" required>
                            <option value="">-- Chọn khách hàng --</option>
                            <%
                                List<KhachHang> listKH = (List<KhachHang>) request.getAttribute("listKhachHang");
                                if(listKH != null) {
                                    for(KhachHang kh : listKH) {
                            %>
                            <option value="<%= kh.getMaKH() %>"><%= kh.getTenKH() %> - <%= kh.getSdt() %></option>
                            <% }} %>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Sách</label>
                        <select class="form-select" name="maSach" required>
                            <option value="">-- Chọn sách --</option>
                            <%
                                List<Sach> listS = (List<Sach>) request.getAttribute("listSach");
                                if(listS != null) {
                                    for(Sach s : listS) {
                            %>
                            <option value="<%= s.getMaSach() %>"><%= s.getTenSach() %></option>
                            <% }} %>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Điểm</label>
                        <select class="form-select" name="diem" required>
                            <option value="5">⭐⭐⭐⭐⭐ - 5 sao</option>
                            <option value="4">⭐⭐⭐⭐ - 4 sao</option>
                            <option value="3">⭐⭐⭐ - 3 sao</option>
                            <option value="2">⭐⭐ - 2 sao</option>
                            <option value="1">⭐ - 1 sao</option>
                        </select>
                    </div>

                    <div class="mb-4">
                        <label class="form-label">Nhận xét</label>
                        <textarea class="form-control" name="binhLuan" rows="3" placeholder="Sách đẹp, nội dung dễ đọc..." required></textarea>
                    </div>

                    <button type="submit" class="btn-primary-custom">
                        <i class="bi bi-star-fill me-2"></i> Lưu đánh giá
                    </button>
                </form>
            </div>
        </div>

        <!-- CỘT PHẢI: BẢNG DANH SÁCH ĐÁNH GIÁ -->
        <div class="col-lg-8">
            <div class="card-custom p-4 h-100">
                <table class="table table-custom table-borderless w-100">
                    <thead>
                    <tr>
                        <th>KHÁCH HÀNG</th>
                        <th>TÊN SÁCH</th>
                        <th>ĐIỂM</th>
                        <th>NHẬN XÉT GẦN ĐÂY</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        List<DanhGia> listDG = (List<DanhGia>) request.getAttribute("listDanhGia");
                        if (listDG != null && !listDG.isEmpty()) {
                            for (DanhGia dg : listDG) {
                                // Render số sao (Đã sửa thành getSoSao)
                                String stars = "";
                                for(int i = 0; i < dg.getSoSao(); i++) stars += "★";
                    %>
                    <tr>
                        <td class="fw-bold" style="color: #0f172a;"><%= dg.getKhachHang().getTenKH() %></td>
                        <td style="color: #64748b;"><%= dg.getSach().getTenSach() %></td>
                        <td class="star-rating fs-5"><%= stars %></td>
                        <td style="font-style: italic; color: #475569;">"<%= dg.getNoiDung() %>"</td>
                    </tr>
                    <% }} else { %>
                    <tr>
                        <td colspan="4" class="text-center text-muted py-5">
                            <i class="bi bi-chat-square-text fs-2 d-block mb-2 text-black-50"></i>
                            Chưa có đánh giá nào được ghi nhận.
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>