<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>Dashboard - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8fafc;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }
        table.table thead th { font-size: 12px; text-transform: uppercase; letter-spacing: 0.04em; color: #64748b; border-bottom: 1px solid #e2e8f0; background-color: #f8fafc; }
        table.table td { font-size: 13.5px; vertical-align: middle; color: #0f172a; }
    </style>
</head>
<body>

<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid">

        <div class="row mb-4">
            <div class="col-12">
                <div class="p-4 bg-white rounded-3 shadow-sm border" style="border-color: #e2e8f0; border-left: 4px solid #4f46e5 !important;">
                    <h4 class="fw-bold" style="color: #0f172a;">Xin chào, ${sessionScope.currentUser.tenNV}</h4>
                    <p class="text-muted mb-0" style="font-size: 14px;">Dữ liệu dưới đây lấy trực tiếp từ database QuanLyNhaSach.</p>
                </div>
            </div>
        </div>

        <c:if test="${param.error == 'permission-denied'}">
            <div class="alert alert-danger d-flex align-items-center mb-4 border-0" role="alert" style="background-color: #fef2f2; color: #991b1b; border-radius: 8px;">
                <i class="bi bi-shield-slash-fill fs-5 me-2"></i>
                <div style="font-size: 14px;">
                    <strong>Từ chối truy cập:</strong> Tài khoản của bạn không có đặc quyền truy cập trang quản trị này!
                </div>
            </div>
        </c:if>

        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="card bg-white p-3 border" style="border-color: #e2e8f0; border-radius: 10px;">
                    <div class="d-flex align-items-center">
                        <div class="p-3 rounded-3 me-3" style="background-color: #eff6ff; color: #2563eb;">
                            <i class="bi bi-file-earmark-text-fill fs-4"></i>
                        </div>
                        <div>
                            <h6 class="mb-1" style="color: #64748b; font-size: 13px;">Đơn hàng hôm nay</h6>
                            <h4 class="fw-bold mb-0" style="color: #0f172a;">
                                <fmt:formatNumber value="${soDonHomNay}" pattern="#,##0"/> đơn
                            </h4>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-white p-3 border" style="border-color: #e2e8f0; border-radius: 10px;">
                    <div class="d-flex align-items-center">
                        <div class="p-3 rounded-3 me-3" style="background-color: #e0f2fe; color: #0284c7;">
                            <i class="bi bi-archive-fill fs-4"></i>
                        </div>
                        <div>
                            <h6 class="mb-1" style="color: #64748b; font-size: 13px;">Tồn kho (có sẵn)</h6>
                            <h4 class="fw-bold mb-0" style="color: #0f172a;">
                                <fmt:formatNumber value="${tongTonKho}" pattern="#,##0"/> cuốn
                            </h4>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-white p-3 border" style="border-color: #e2e8f0; border-radius: 10px;">
                    <div class="d-flex align-items-center">
                        <div class="p-3 rounded-3 me-3" style="background-color: #eef2ff; color: #4f46e5;">
                            <i class="bi bi-journal-bookmark-fill fs-4"></i>
                        </div>
                        <div>
                            <h6 class="mb-1" style="color: #64748b; font-size: 13px;">Đầu sách</h6>
                            <h4 class="fw-bold mb-0" style="color: #0f172a;">
                                <fmt:formatNumber value="${soDauSach}" pattern="#,##0"/>
                            </h4>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-white p-3 border" style="border-color: #e2e8f0; border-radius: 10px;">
                    <div class="d-flex align-items-center">
                        <div class="p-3 rounded-3 me-3" style="background-color: #f0fdf4; color: #16a34a;">
                            <i class="bi bi-person-badge-fill fs-4"></i>
                        </div>
                        <div>
                            <h6 class="mb-1" style="color: #64748b; font-size: 13px;">Nhân viên</h6>
                            <h4 class="fw-bold mb-0" style="color: #0f172a;">
                                <fmt:formatNumber value="${soNhanVien}" pattern="#,##0"/> người
                            </h4>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card bg-white border" style="border-color: #e2e8f0; border-radius: 10px;">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <h6 class="fw-bold mb-0" style="color: #0f172a;"><i class="bi bi-clock-history me-2"></i>Đơn hàng gần đây</h6>
                    <a href="${pageContext.request.contextPath}/sach" class="btn btn-sm text-white" style="background-color:#4f46e5;border-radius:6px;font-size:12.5px;">
                        Quản lý sách
                    </a>
                </div>
                <hr style="border-color: #e2e8f0;">

                <div class="table-responsive">
                    <table class="table mb-0">
                        <thead>
                        <tr>
                            <th>Mã ĐH</th>
                            <th>Khách hàng</th>
                            <th>Ngày lập</th>
                            <th class="text-end">Tổng tiền</th>
                            <th class="text-center">Trạng thái</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="row" items="${donHangGanDay}">
                            <tr>
                                <td class="fw-semibold">#${row[0]}</td>
                                <td>${row[4]}</td>
                                <td>${row[1]}</td>
                                <td class="text-end"><fmt:formatNumber value="${row[2]}" pattern="#,##0"/> ₫</td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${row[3] == 0}"><span class="badge rounded-pill" style="background:#fffbeb;color:#92400e;">Chờ xử lý</span></c:when>
                                        <c:when test="${row[3] == 1}"><span class="badge rounded-pill" style="background:#f0fdf4;color:#166534;">Đã giao</span></c:when>
                                        <c:when test="${row[3] == 2}"><span class="badge rounded-pill" style="background:#fef2f2;color:#991b1b;">Đã hủy</span></c:when>
                                        <c:otherwise><span class="badge bg-secondary">${row[3]}</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty donHangGanDay}">
                            <tr>
                                <td colspan="5" class="text-center text-muted py-5" style="font-size: 13.5px;">
                                    <i class="bi bi-inbox fs-3 d-block mb-2"></i>
                                    Chưa có đơn hàng trong database.
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
