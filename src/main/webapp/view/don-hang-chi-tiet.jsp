<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>Chi tiết đơn hàng #${donHang.maDH} - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        .info-label { font-size: 12px; text-transform: uppercase; color: #64748b; font-weight: 600; }
        .info-value { font-size: 14px; color: #0f172a; font-weight: 500; }
        @media print {
            body { background: #fff; }
            .no-print, body > div[style*="position: fixed"], nav, header { display: none !important; }
            body > div[style*="margin-left"] { margin: 0 !important; padding: 0 !important; }
            .card { border: 0 !important; }
        }
    </style>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid" style="max-width: 900px;">
        <div class="mb-4">
            <%-- Nut quay lai danh sach don hang --%>
            <a href="${pageContext.request.contextPath}/don-hang" class="text-decoration-none text-muted" style="font-size: 13px;">
                <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
            </a>
            <h4 class="fw-bold mt-2" style="color:#0f172a;">Chi tiết đơn hàng #${donHang.maDH}</h4>
            <div class="mt-2 no-print">
                <button type="button" class="btn btn-primary" onclick="window.print()">
                    <i class="bi bi-printer me-1"></i> In hóa đơn
                </button>
            </div>
        </div>

        <%-- Card hien thi thong tin chung cua hoa don --%>
        <div class="card bg-white border mb-4" style="border-radius:12px;">
            <div class="card-body p-4">
                <div class="row g-4">
                    <div class="col-md-3">
                        <div class="info-label">Thời gian lập</div>
                        <div class="info-value">
                            <fmt:parseDate value="${donHang.ngayLap}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDT" type="both" />
                            <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedDT}" />
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="info-label">Khách hàng</div>
                        <div class="info-value">${donHang.khachHang.tenKH}</div>
                    </div>
                    <div class="col-md-3">
                        <div class="info-label">Nhân viên bán</div>
                        <div class="info-value">${donHang.nhanVien.tenNV}</div>
                    </div>
                    <div class="col-md-3">
                        <div class="info-label">Thanh toán</div>
                        <div class="info-value">${donHang.phuongThucThanhToan}</div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Bang hien thi danh sach cac san pham trong don hang --%>
        <div class="card bg-white border" style="border-radius:12px;">
            <div class="table-responsive">
                <table class="table mb-0">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4">Sách</th>
                        <th class="text-center">Số lượng</th>
                        <th class="text-end">Đơn giá</th>
                        <th class="text-end pe-4">Thành tiền</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="ct" items="${donHang.chiTietDonHangs}">
                        <tr>
                            <td class="ps-4">
                                <div class="fw-semibold">${ct.sach.tenSach}</div>
                                <div class="text-muted" style="font-size:12px;">Mã: ${ct.sach.maSach}</div>
                            </td>
                            <td class="text-center">${ct.soLuong}</td>
                            <td class="text-end"><fmt:formatNumber value="${ct.donGia}" pattern="#,##0"/> ₫</td>
                            <%-- Thanh tien = So luong * Don gia --%>
                            <td class="text-end pe-4 fw-bold"><fmt:formatNumber value="${ct.soLuong * ct.donGia}" pattern="#,##0"/> ₫</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                    <tfoot>
                    <tr class="table-light">
                        <td colspan="3" class="text-end fw-bold py-3">TỔNG CỘNG:</td>
                        <td class="text-end pe-4 fw-bold py-3" style="font-size:18px; color:#4f46e5;">
                            <fmt:formatNumber value="${donHang.tongTien}" pattern="#,##0"/> ₫
                        </td>
                    </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>
