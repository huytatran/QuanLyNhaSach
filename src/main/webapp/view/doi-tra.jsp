<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>Đổi / Trả hàng - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        table.table thead th { font-size: 12px; text-transform: uppercase; letter-spacing: 0.04em; color: #64748b; border-bottom: 1px solid #e2e8f0; background-color: #f8fafc; }
        table.table td { font-size: 13.5px; vertical-align: middle; color: #0f172a; }
    </style>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left:280px; margin-top:60px;" class="p-4">
    <div class="container-fluid">

        <div class="mb-4">
            <h4 class="fw-bold mb-0" style="color:#0f172a;">
                <i class="bi bi-arrow-left-right me-2" style="color:#4f46e5;"></i>Đổi / Trả hàng
            </h4>
            <p class="text-muted mb-0" style="font-size:13px;">
                Danh sách đơn hàng <strong>đã giao</strong> còn sách có thể đổi hoặc trả lại.
            </p>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                ${param.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
            <div class="table-responsive">
                <table class="table mb-0">
                    <thead>
                    <tr>
                        <th class="ps-3">Mã đơn</th>
                        <th>Thời gian</th>
                        <th>Khách hàng</th>
                        <th>Nhân viên</th>
                        <th class="text-end">Tổng tiền</th>
                        <th>PT Thanh toán</th>
                        <th class="text-center">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="dh" items="${danhSachDonHang}">
                        <tr>
                            <td class="ps-3 fw-semibold">#${dh.maDH}</td>
                            <td>${dh.ngayLap}</td>
                            <td>${dh.khachHang.tenKH}</td>
                            <td>${dh.nhanVien.tenNV}</td>
                            <td class="text-end fw-bold" style="color:#4f46e5;">
                                <fmt:formatNumber value="${dh.tongTien}" pattern="#,##0"/> ₫
                            </td>
                            <td>${dh.phuongThucThanhToan}</td>
                            <td class="text-center">
                                <a href="${pageContext.request.contextPath}/don-hang?action=view&ma=${dh.maDH}"
                                   class="btn btn-sm btn-outline-primary" style="border-radius:6px;">
                                    <i class="bi bi-arrow-left-right me-1"></i> Xử lý đổi/trả
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty danhSachDonHang}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-5">
                                <i class="bi bi-check-circle fs-3 d-block mb-2 text-success"></i>
                                Không có đơn hàng nào cần xử lý đổi/trả.
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- Phân trang --%>
        <c:if test="${tongSoTrang > 1}">
            <nav class="mt-3">
                <ul class="pagination pagination-sm justify-content-center mb-0">
                    <li class="page-item ${trangHienTai <= 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/don-hang?tab=doi-tra&trang=${trangHienTai - 1}">Trước</a>
                    </li>
                    <c:forEach var="i" begin="1" end="${tongSoTrang}">
                        <li class="page-item ${i == trangHienTai ? 'active' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/don-hang?tab=doi-tra&trang=${i}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${trangHienTai >= tongSoTrang ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/don-hang?tab=doi-tra&trang=${trangHienTai + 1}">Sau</a>
                    </li>
                </ul>
            </nav>
        </c:if>

        <%-- Bảng 2: Đơn đã đổi/trả hoàn tất --%>
        <div class="mt-4">
            <h6 class="fw-bold mb-3" style="color:#0f172a;">
                <i class="bi bi-check-circle-fill me-2" style="color:#10b981;"></i>
                Đơn đã đổi/trả hoàn tất
            </h6>
            <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
                <div class="table-responsive">
                    <table class="table mb-0">
                        <thead>
                        <tr>
                            <th class="ps-3">Mã đơn</th>
                            <th>Thời gian</th>
                            <th>Khách hàng</th>
                            <th>Nhân viên</th>
                            <th class="text-end">Tổng tiền</th>
                            <th class="text-center">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="dh" items="${daDOiTra}">
                            <tr>
                                <td class="ps-3 fw-semibold">#${dh.maDH}</td>
                                <td>${dh.ngayLap}</td>
                                <td>${dh.khachHang.tenKH}</td>
                                <td>${dh.nhanVien.tenNV}</td>
                                <td class="text-end fw-bold" style="color:#64748b;">
                                    <fmt:formatNumber value="${dh.tongTien}" pattern="#,##0"/> ₫
                                </td>
                                <td class="text-center">
                                    <a href="${pageContext.request.contextPath}/don-hang?action=view&ma=${dh.maDH}"
                                       class="btn btn-sm btn-outline-secondary" style="border-radius:6px;">
                                        <i class="bi bi-eye me-1"></i> Xem chi tiết
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty daDOiTra}">
                            <tr>
                                <td colspan="6" class="text-center text-muted py-4" style="font-size:13.5px;">
                                    Chưa có đơn nào được xử lý đổi/trả.
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
