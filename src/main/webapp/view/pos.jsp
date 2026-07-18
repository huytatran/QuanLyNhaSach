<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>Bán hàng (POS) - Portal.BookStore</title>
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
                <h4 class="fw-bold mb-0" style="color:#0f172a;">Bán hàng (POS)</h4>
                <p class="text-muted mb-0" style="font-size:13px;">Chọn sách, thêm vào giỏ và thanh toán — dữ liệu thật từ database.</p>
            </div>
        </div>

        <c:if test="${not empty param.thanhCong}">
            <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13.5px;">
                <i class="bi bi-check-circle-fill me-2"></i>Tạo đơn hàng #${param.thanhCong} thành công. Tồn kho đã được trừ.
            </div>
        </c:if>
        <c:if test="${not empty param.loi}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${param.loi}
            </div>
        </c:if>

        <div class="row g-3">
            <div class="col-lg-7">
                <div class="card bg-white border mb-3" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="card-body p-3">
                        <form method="get" action="${pageContext.request.contextPath}/pos" class="d-flex gap-2">
                            <input type="text" name="q" value="${tuKhoa}" class="form-control" placeholder="Tìm mã / tên sách..." style="font-size:13.5px;max-width:320px;">
                            <button class="btn btn-outline-secondary" style="font-size:13px;border-radius:6px;">Tìm</button>
                        </form>
                    </div>
                </div>
                <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="table-responsive" style="max-height:560px;overflow:auto;">
                        <table class="table mb-0">
                            <thead><tr><th class="ps-3">Mã</th><th>Tên sách</th><th class="text-end">Giá</th><th class="text-center">Tồn</th><th></th></tr></thead>
                            <tbody>
                            <c:forEach var="s" items="${danhSachSach}">
                                <c:set var="ton" value="${empty tonKhoMap[s.maSach] ? 0 : tonKhoMap[s.maSach]}" />
                                <tr>
                                    <td class="ps-3 fw-semibold">${s.maSach}</td>
                                    <td>${s.tenSach}</td>
                                    <td class="text-end"><fmt:formatNumber value="${s.giaBan}" pattern="#,##0"/> ₫</td>
                                    <td class="text-center">${ton}</td>
                                    <td class="text-end pe-3">
                                        <form method="post" action="${pageContext.request.contextPath}/pos" class="d-inline">
                                            <input type="hidden" name="action" value="add">
                                            <input type="hidden" name="ma" value="${s.maSach}">
                                            <button class="btn btn-sm text-white" style="background:#4f46e5;border-radius:6px;" ${ton == 0 ? 'disabled' : ''}>
                                                <i class="bi bi-cart-plus"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-lg-5">
                <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0">Giỏ hàng</h6>
                            <form method="post" action="${pageContext.request.contextPath}/pos">
                                <input type="hidden" name="action" value="clear">
                                <button class="btn btn-link btn-sm text-danger text-decoration-none" style="font-size:12.5px;">Xóa giỏ</button>
                            </form>
                        </div>

                        <c:choose>
                            <c:when test="${empty chiTietGio}">
                                <p class="text-muted text-center py-4" style="font-size:13.5px;">Chưa có sách trong giỏ.</p>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="item" items="${chiTietGio}">
                                    <div class="border-bottom py-2" style="border-color:#e2e8f0 !important;">
                                        <div class="fw-semibold" style="font-size:13.5px;">${item.tenSach}</div>
                                        <div class="d-flex justify-content-between align-items-center mt-1">
                                            <span class="text-muted" style="font-size:12.5px;"><fmt:formatNumber value="${item.donGia}" pattern="#,##0"/> ₫</span>
                                            <div class="d-flex align-items-center gap-1">
                                                <form method="post" action="${pageContext.request.contextPath}/pos" class="d-flex gap-1">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="ma" value="${item.maSach}">
                                                    <input type="number" name="soLuong" value="${item.soLuong}" min="1" max="${item.ton}" class="form-control form-control-sm" style="width:70px;">
                                                    <button class="btn btn-sm btn-outline-secondary">OK</button>
                                                </form>
                                                <form method="post" action="${pageContext.request.contextPath}/pos">
                                                    <input type="hidden" name="action" value="remove">
                                                    <input type="hidden" name="ma" value="${item.maSach}">
                                                    <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
                                                </form>
                                            </div>
                                        </div>
                                        <div class="text-end" style="font-size:13px;"><fmt:formatNumber value="${item.thanhTien}" pattern="#,##0"/> ₫</div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>

                        <div class="d-flex justify-content-between mt-3 mb-3">
                            <span class="fw-semibold">Tổng tiền</span>
                            <span class="fw-bold" style="color:#4f46e5;font-size:18px;"><fmt:formatNumber value="${tongTienGio}" pattern="#,##0"/> ₫</span>
                        </div>

                        <form method="post" action="${pageContext.request.contextPath}/pos">
                            <input type="hidden" name="action" value="checkout">
                            <div class="mb-2">
                                <label class="form-label" style="font-size:12.5px;font-weight:600;color:#475569;">Khách hàng *</label>
                                <select name="maKH" class="form-select" required style="font-size:13.5px;">
                                    <option value="">-- Chọn khách hàng --</option>
                                    <c:forEach var="kh" items="${dsKhachHang}">
                                        <option value="${kh.maKH}">${kh.tenKH} <c:if test="${not empty kh.sdt}">(${kh.sdt})</c:if></option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label" style="font-size:12.5px;font-weight:600;color:#475569;">Thanh toán</label>
                                <select name="phuongThuc" class="form-select" style="font-size:13.5px;">
                                    <option>Tiền mặt</option>
                                    <option>Chuyển khoản</option>
                                    <option>Thẻ</option>
                                </select>
                            </div>
                            <button type="submit" class="btn w-100 text-white fw-semibold" style="background:#4f46e5;border-radius:8px;" ${empty chiTietGio ? 'disabled' : ''}>
                                <i class="bi bi-bag-check me-1"></i> Thanh toán
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
