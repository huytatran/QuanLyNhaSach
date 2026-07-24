<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>Danh sách đơn hàng - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        table.table thead th { font-size: 12px; text-transform: uppercase; letter-spacing: 0.04em; color: #64748b; border-bottom: 1px solid #e2e8f0; background-color: #f8fafc; }
        table.table td { font-size: 13.5px; vertical-align: middle; color: #0f172a; }
    </style>
</head>
<body>
<%-- Header va Sidebar --%>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid">
        <div class="mb-4">
            <h4 class="fw-bold mb-0" style="color:#0f172a;">Quản lý Đơn hàng</h4>
            <p class="text-muted mb-0" style="font-size:13px;">Lịch sử các giao dịch đã thực hiện tại quầy.</p>
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
                    <%-- Duyet danh sach don hang duoc gui tu Servlet --%>
                    <c:forEach var="dh" items="${danhSachDonHang}">
                        <tr>
                            <td class="ps-3 fw-semibold">#${dh.maDH}</td>
                            <td>
                                <%-- Dinh dang hien thi ngay gio --%>
                                <fmt:parseDate value="${dh.ngayLap}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDateTime" type="both" />
                                <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedDateTime}" />
                            </td>
                            <td>${dh.khachHang.tenKH}</td>
                            <td>${dh.nhanVien.tenNV}</td>
                            <td class="text-end fw-bold" style="color:#4f46e5;"><fmt:formatNumber value="${dh.tongTien}" pattern="#,##0"/> ₫</td>
                            <td>${dh.phuongThucThanhToan}</td>
                            <td class="text-center">
                                <c:if test="${dh.trangThai != 2}">
                                    <form method="post" action="${pageContext.request.contextPath}/don-hang" class="d-inline"
                                          onsubmit="return confirm('Xác nhận đổi/trả toàn bộ đơn #${dh.maDH}? Sách sẽ được hoàn lại tồn kho.');">
                                        <input type="hidden" name="action" value="return">
                                        <input type="hidden" name="ma" value="${dh.maDH}">
                                        <button type="submit" class="btn btn-sm btn-outline-warning" style="border-radius:6px;">
                                            <i class="bi bi-arrow-return-left me-1"></i> Đổi/trả
                                        </button>
                                    </form>
                                </c:if>
                                <%-- Link xem chi tiet don hang --%>
                                <a href="${pageContext.request.contextPath}/don-hang?action=view&ma=${dh.maDH}"
                                   class="btn btn-sm btn-outline-secondary" style="border-radius:6px;">
                                    <i class="bi bi-eye me-1"></i> Chi tiết
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty danhSachDonHang}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-5">Chưa có đơn hàng nào được ghi nhận.</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
