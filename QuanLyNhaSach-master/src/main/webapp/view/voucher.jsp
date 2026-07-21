<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="java.util.List" %>
<%@ page import="entity.Voucher" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý Voucher - Portal Work</title>
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
        .badge-active { background-color: #dcfce7; color: #166534; padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 600;}
        .badge-warning { background-color: #fef9c3; color: #854d0e; padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 600;}
        .badge-expired { background-color: #fee2e2; color: #991b1b; padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 600;}
    </style>
</head>
<body>

<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div class="content-wrapper">
    <div class="mb-4">
        <span class="text-uppercase" style="font-size: 11px; font-weight: 700; color: #64748b; letter-spacing: 0.05em;">NV4 - Tích hợp POS</span>
        <h3 class="fw-bold mt-1" style="color: #0f172a;"><i class="bi bi-ticket-perforated-fill me-2" style="color: #4f46e5;"></i> Voucher giảm giá</h3>
        <p class="text-muted mb-0" style="font-size: 14px;">Tạo mã giảm giá, điều kiện áp dụng và tính SoTienGiam ngay trên màn hình POS.</p>
    </div>

    <div class="row g-4">
        <div class="col-lg-4">
            <div class="card-custom p-4">
                <h6 class="fw-bold mb-4" style="color: #0f172a;">Tạo voucher</h6>
                <form action="${pageContext.request.contextPath}/voucher/them" method="POST">
                    <div class="mb-3">
                        <label class="form-label">Mã voucher</label>
                        <input type="text" class="form-control" name="maCode" placeholder="VD: SACHMOI10" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Kiểu giảm</label>
                        <select class="form-select" name="loaiGiam">
                            <option value="1">Giảm theo phần trăm (%)</option>
                            <option value="2">Giảm tiền mặt (đ)</option>
                        </select>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label">Giá trị giảm</label>
                            <input type="number" step="0.01" class="form-control" name="giaTri" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Giảm tối đa</label>
                            <input type="number" step="0.01" class="form-control" name="giaGiamToiDa" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Đơn tối thiểu</label>
                        <input type="number" step="0.01" class="form-control" name="giaTriDonToiThieu" required>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label">Hiệu lực từ</label>
                            <input type="datetime-local" class="form-control" name="ngayBatDau" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Đến ngày</label>
                            <input type="datetime-local" class="form-control" name="ngayKetThuc" required>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label">Số lượng mã</label>
                        <input type="number" class="form-control" name="soLuongToiDa" required>
                    </div>
                    <button type="submit" class="btn-primary-custom"><i class="bi bi-floppy-fill me-2"></i> Lưu voucher</button>
                </form>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card-custom p-4 h-100">
                <table class="table table-custom table-borderless w-100">
                    <thead>
                    <tr>
                        <th>MÃ VOUCHER</th>
                        <th>ĐIỀU KIỆN</th>
                        <th>HIỆU LỰC</th>
                        <th>SỐ LẦN DÙNG</th>
                        <th>TRẠNG THÁI</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        List<Voucher> list = (List<Voucher>) request.getAttribute("listVoucher");
                        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM");
                        LocalDateTime now = LocalDateTime.now();
                        if (list != null && !list.isEmpty()) {
                            for (Voucher v : list) {
                                String giaTri = v.getGiaTri().stripTrailingZeros().toPlainString();
                                String donToiThieu = v.getGiaTriDonToiThieu().stripTrailingZeros().toPlainString();
                                String dieuKien = v.getLoaiGiam() == 1 ? "Giảm " + giaTri + "%, đơn từ " + donToiThieu + " đ" : "Giảm " + giaTri + " đ, đơn từ " + donToiThieu + " đ";

                                String badgeClass = "badge-active";
                                String trangThai = "Đang chạy";
                                if (v.getDaSuDung() >= v.getSoLuongToiDa()) { badgeClass = "badge-expired"; trangThai = "Hết lượt"; }
                                else if (now.isAfter(v.getNgayKetThuc())) { badgeClass = "badge-expired"; trangThai = "Đã kết thúc"; }
                                else if (now.isBefore(v.getNgayBatDau())) { badgeClass = "badge-warning"; trangThai = "Sắp diễn ra"; }
                    %>
                    <tr>
                        <td class="fw-bold" style="color: #0f172a;"><%= v.getMaCode() %></td>
                        <td><%= dieuKien %></td>
                        <td><%= v.getNgayBatDau().format(dtf) %> - <%= v.getNgayKetThuc().format(dtf) %></td>
                        <td style="color: #64748b;"><%= v.getDaSuDung() %>/<%= v.getSoLuongToiDa() %></td>
                        <td><span class="<%= badgeClass %>"><%= trangThai %></span></td>
                    </tr>
                    <% }} %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>