<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>Báo cáo doanh thu - Portal.BookStore</title>
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

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color:#0f172a;">Báo cáo doanh thu</h4>
                <p class="text-muted mb-0" style="font-size:13px;">Thống kê từ bảng DonHang / ChiTietDonHang (bỏ đơn đã hủy).</p>
            </div>
        </div>

        <div class="card bg-white border mb-3" style="border-color:#e2e8f0;border-radius:10px;">
            <div class="card-body p-3">
                <form method="get" class="row g-2 align-items-end">
                    <div class="col-auto">
                        <label class="form-label mb-1" style="font-size:12px;font-weight:600;color:#64748b;">Từ ngày</label>
                        <input type="date" name="from" value="${from}" class="form-control" style="font-size:13.5px;">
                    </div>
                    <div class="col-auto">
                        <label class="form-label mb-1" style="font-size:12px;font-weight:600;color:#64748b;">Đến ngày</label>
                        <input type="date" name="to" value="${to}" class="form-control" style="font-size:13.5px;">
                    </div>
                    <div class="col-auto">
                        <button class="btn text-white" style="background:#4f46e5;border-radius:6px;font-size:13.5px;">Lọc báo cáo</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="card bg-white p-3 border" style="border-color:#e2e8f0;border-radius:10px;">
                    <h6 class="mb-1" style="color:#64748b;font-size:13px;">Số đơn (không hủy)</h6>
                    <h3 class="fw-bold mb-0" style="color:#0f172a;"><fmt:formatNumber value="${soDon}" pattern="#,##0"/></h3>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card bg-white p-3 border" style="border-color:#e2e8f0;border-radius:10px;">
                    <h6 class="mb-1" style="color:#64748b;font-size:13px;">Doanh thu</h6>
                    <h3 class="fw-bold mb-0" style="color:#4f46e5;"><fmt:formatNumber value="${doanhThu}" pattern="#,##0"/> ₫</h3>
                </div>
            </div>
        </div>

        <div class="row g-3">
            <div class="col-lg-6">
                <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="card-body p-3">
                        <h6 class="fw-bold mb-3">Doanh thu theo ngày</h6>
                        <div class="table-responsive">
                            <table class="table mb-0">
                                <thead><tr><th>Ngày</th><th class="text-center">Số đơn</th><th class="text-end">Doanh thu</th></tr></thead>
                                <tbody>
                                <c:forEach var="r" items="${doanhThuTheoNgay}">
                                    <tr>
                                        <td>${r[0]}</td>
                                        <td class="text-center">${r[1]}</td>
                                        <td class="text-end"><fmt:formatNumber value="${r[2]}" pattern="#,##0"/> ₫</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty doanhThuTheoNgay}">
                                    <tr><td colspan="3" class="text-center text-muted py-4">Không có dữ liệu trong khoảng ngày này.</td></tr>
                                </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-6">
                <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="card-body p-3">
                        <h6 class="fw-bold mb-3">Top sách bán chạy</h6>
                        <div class="table-responsive">
                            <table class="table mb-0">
                                <thead><tr><th>Mã</th><th>Tên sách</th><th class="text-center">SL</th><th class="text-end">Doanh thu</th></tr></thead>
                                <tbody>
                                <c:forEach var="r" items="${topSach}">
                                    <tr>
                                        <td class="fw-semibold">${r[0]}</td>
                                        <td>${r[1]}</td>
                                        <td class="text-center">${r[2]}</td>
                                        <td class="text-end"><fmt:formatNumber value="${r[3]}" pattern="#,##0"/> ₫</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty topSach}">
                                    <tr><td colspan="4" class="text-center text-muted py-4">Chưa có sách bán trong khoảng này.</td></tr>
                                </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
