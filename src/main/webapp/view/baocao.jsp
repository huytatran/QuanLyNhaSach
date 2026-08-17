<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>Báo cáo doanh thu - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
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

        <%-- Tiêu đề --%>
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color:#0f172a;">Báo cáo doanh thu</h4>
                <p class="text-muted mb-0" style="font-size:13px;">Thống kê từ bảng DonHang / ChiTietDonHang (bỏ đơn đã hủy).</p>
            </div>
        </div>

        <%-- Bộ lọc ngày --%>
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
                        <button class="btn text-white" style="background:#4f46e5;border-radius:6px;font-size:13.5px;">
                            <i class="bi bi-funnel me-1"></i>Lọc báo cáo
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <%-- KPI Cards --%>
        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="card bg-white p-3 border" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="d-flex align-items-center gap-3">
                        <div class="p-3 rounded-3" style="background:#eff6ff;color:#2563eb;">
                            <i class="bi bi-receipt-cutoff fs-4"></i>
                        </div>
                        <div>
                            <h6 class="mb-1" style="color:#64748b;font-size:13px;">Số đơn (không hủy)</h6>
                            <h3 class="fw-bold mb-0" style="color:#0f172a;"><fmt:formatNumber value="${soDon}" pattern="#,##0"/></h3>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card bg-white p-3 border" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="d-flex align-items-center gap-3">
                        <div class="p-3 rounded-3" style="background:#eef2ff;color:#4f46e5;">
                            <i class="bi bi-currency-dollar fs-4"></i>
                        </div>
                        <div>
                            <h6 class="mb-1" style="color:#64748b;font-size:13px;">Tổng doanh thu</h6>
                            <h3 class="fw-bold mb-0" style="color:#4f46e5;"><fmt:formatNumber value="${doanhThu}" pattern="#,##0"/> ₫</h3>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Biểu đồ doanh thu theo ngày --%>
        <div class="card bg-white border mb-4" style="border-color:#e2e8f0;border-radius:10px;">
            <div class="card-body p-4">
                <h6 class="fw-bold mb-3"><i class="bi bi-graph-up me-2" style="color:#4f46e5;"></i>Doanh thu theo ngày</h6>
                <c:choose>
                    <c:when test="${not empty doanhThuTheoNgay}">
                        <canvas id="chartDoanhThu" height="80"></canvas>
                    </c:when>
                    <c:otherwise>
                        <p class="text-center text-muted py-4">Không có dữ liệu trong khoảng ngày này.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <%-- Bảng chi tiết + Biểu đồ top sách --%>
        <div class="row g-3">
            <%-- Bảng doanh thu theo ngày --%>
            <div class="col-lg-5">
                <div class="card bg-white border h-100" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="card-body p-3">
                        <h6 class="fw-bold mb-3">Chi tiết theo ngày</h6>
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
                                    <tr><td colspan="3" class="text-center text-muted py-4">Không có dữ liệu.</td></tr>
                                </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Biểu đồ + bảng top sách --%>
            <div class="col-lg-7">
                <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="card-body p-4">
                        <h6 class="fw-bold mb-3"><i class="bi bi-bar-chart-fill me-2" style="color:#4f46e5;"></i>Top sách bán chạy</h6>
                        <c:if test="${not empty topSach}">
                            <canvas id="chartTopSach" height="120" class="mb-3"></canvas>
                        </c:if>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ===== DỮ LIỆU TỪ SERVER =====
const doanhThuData = [
    <c:forEach var="r" items="${doanhThuTheoNgay}" varStatus="st">
        { ngay: "${r[0]}", soDon: ${r[1]}, doanhThu: ${r[2]} }<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];

const topSachData = [
    <c:forEach var="r" items="${topSach}" varStatus="st">
        { ten: "${r[1]}", soLuong: ${r[2]}, doanhThu: ${r[3]} }<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];

// ===== BIỂU ĐỒ ĐƯỜNG: DOANH THU THEO NGÀY =====
if (doanhThuData.length > 0) {
    const ctx1 = document.getElementById('chartDoanhThu').getContext('2d');
    new Chart(ctx1, {
        type: 'line',
        data: {
            labels: doanhThuData.map(d => d.ngay),
            datasets: [{
                label: 'Doanh thu (₫)',
                data: doanhThuData.map(d => d.doanhThu),
                borderColor: '#4f46e5',
                backgroundColor: 'rgba(79,70,229,0.08)',
                borderWidth: 2.5,
                pointBackgroundColor: '#4f46e5',
                pointRadius: 4,
                tension: 0.3,
                fill: true
            }, {
                label: 'Số đơn',
                data: doanhThuData.map(d => d.soDon),
                borderColor: '#10b981',
                backgroundColor: 'rgba(16,185,129,0.06)',
                borderWidth: 2,
                pointBackgroundColor: '#10b981',
                pointRadius: 3,
                tension: 0.3,
                fill: false,
                yAxisID: 'y2'
            }]
        },
        options: {
            responsive: true,
            interaction: { mode: 'index', intersect: false },
            plugins: {
                legend: { position: 'top' },
                tooltip: {
                    callbacks: {
                        label: ctx => {
                            if (ctx.datasetIndex === 0)
                                return ' Doanh thu: ' + ctx.raw.toLocaleString('vi-VN') + ' ₫';
                            return ' Số đơn: ' + ctx.raw;
                        }
                    }
                }
            },
            scales: {
                y: {
                    position: 'left',
                    ticks: {
                        callback: v => v.toLocaleString('vi-VN') + '₫',
                        font: { size: 11 }
                    },
                    grid: { color: '#f1f5f9' }
                },
                y2: {
                    position: 'right',
                    grid: { drawOnChartArea: false },
                    ticks: { font: { size: 11 } }
                },
                x: {
                    ticks: { font: { size: 11 } },
                    grid: { color: '#f1f5f9' }
                }
            }
        }
    });
}

// ===== BIỂU ĐỒ CỘT: TOP SÁCH BÁN CHẠY =====
if (topSachData.length > 0) {
    const ctx2 = document.getElementById('chartTopSach').getContext('2d');
    const colors = ['#4f46e5','#7c3aed','#2563eb','#0891b2','#059669','#d97706','#dc2626','#db2777','#7c3aed','#64748b'];
    new Chart(ctx2, {
        type: 'bar',
        data: {
            labels: topSachData.map(d => d.ten.length > 20 ? d.ten.substring(0, 20) + '...' : d.ten),
            datasets: [{
                label: 'Số lượng bán',
                data: topSachData.map(d => d.soLuong),
                backgroundColor: colors.slice(0, topSachData.length),
                borderRadius: 6,
                borderSkipped: false
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: ctx => ' Số lượng: ' + ctx.raw + ' cuốn'
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { font: { size: 11 }, stepSize: 1 },
                    grid: { color: '#f1f5f9' }
                },
                x: {
                    ticks: { font: { size: 10 } },
                    grid: { display: false }
                }
            }
        }
    });
}
</script>
</body>
</html>
