<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>${dangSua ? 'Sửa khách hàng' : 'Thêm khách hàng'} - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        label.form-label { font-size: 12.5px; font-weight: 600; color: #475569; }
        .form-control, .form-select { font-size: 13.5px; border-color: #cbd5e1; border-radius: 6px; }
        .form-control:focus, .form-select:focus { border-color: #4f46e5; box-shadow: 0 0 0 3px rgba(79,70,229,0.12); }
    </style>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid" style="max-width: 760px;">

        <div class="mb-4">
            <a href="${pageContext.request.contextPath}/khachhang" class="text-decoration-none" style="font-size:13px;color:#64748b;">
                <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách khách hàng
            </a>
            <h4 class="fw-bold mt-2 mb-0" style="color:#0f172a;">${dangSua ? 'Sửa thông tin khách hàng' : 'Thêm khách hàng mới'}</h4>
        </div>

        <c:if test="${not empty thongBaoLoi}">
            <div class="alert border-0 mb-4" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">${thongBaoLoi}</div>
        </c:if>

        <!-- ===== Thông tin khách hàng ===== -->
        <div class="card bg-white border mb-4" style="border-color:#e2e8f0;border-radius:10px;">
            <div class="card-body p-4">
                <form method="post" action="${pageContext.request.contextPath}/khachhang">
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="mode" value="${dangSua ? 'sua' : 'them'}">
                    <c:if test="${dangSua}">
                        <input type="hidden" name="maKH" value="${khachHang.maKH}">
                    </c:if>

                    <div class="row g-3">
                        <div class="col-md-12">
                            <label class="form-label">Họ tên *</label>
                            <input type="text" name="tenKH" value="${khachHang.tenKH}" class="form-control" placeholder="Nhập họ tên khách hàng" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số điện thoại</label>
                            <input type="text" name="sdt" value="${khachHang.sdt}" class="form-control" placeholder="09xxxxxxxx">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" value="${khachHang.email}" class="form-control" placeholder="email@vidu.com">
                        </div>
                    </div>

                    <hr class="my-4" style="border-color:#e2e8f0;">
                    <div class="d-flex justify-content-end gap-2">
                        <a href="${pageContext.request.contextPath}/khachhang" class="btn btn-outline-secondary" style="border-radius:6px;font-size:13.5px;">Hủy</a>
                        <button type="submit" class="btn text-white fw-semibold" style="background-color:#4f46e5;border-radius:6px;font-size:13.5px;padding:8px 22px;">
                            <i class="bi bi-check-lg me-1"></i> Lưu khách hàng
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- ===== Địa chỉ liên hệ (chỉ hiện khi đang sửa khách đã tồn tại) ===== -->
        <c:if test="${dangSua}">
            <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
                <div class="card-body p-4">
                    <h6 class="fw-bold mb-1" style="color:#0f172a;">Địa chỉ liên hệ</h6>
                    <p class="text-muted mb-3" style="font-size:12.5px;">
                        Dùng để xuất hóa đơn hoặc chăm sóc khách thân thiết. Khách có thể có nhiều địa chỉ; địa chỉ mặc định được chọn sẵn khi lập đơn.
                    </p>

                    <c:if test="${not empty param.loiDiaChi}">
                        <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13px;">${param.loiDiaChi}</div>
                    </c:if>
                    <c:if test="${not empty param.luuDiaChi}">
                        <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13px;">Đã thêm địa chỉ.</div>
                    </c:if>

                    <c:forEach var="dc" items="${dsDiaChi}">
                        <div class="d-flex align-items-center justify-content-between p-2 mb-2 border rounded" style="border-color:#e2e8f0 !important;">
                            <div class="d-flex align-items-center gap-2">
                                <c:if test="${dc.laMacDinh}">
                                    <span class="badge rounded-pill" style="background:#eef2ff;color:#4338ca;font-size:10.5px;">Mặc định</span>
                                </c:if>
                                <span style="font-size:13.5px;color:#0f172a;">${dc.diaChiChiTiet}</span>
                            </div>
                            <div class="d-flex gap-1">
                                <c:if test="${!dc.laMacDinh}">
                                    <form method="post" action="${pageContext.request.contextPath}/khachhang" class="d-inline">
                                        <input type="hidden" name="action" value="macDinhDiaChi">
                                        <input type="hidden" name="maDiaChi" value="${dc.maDiaChi}">
                                        <input type="hidden" name="maKH" value="${khachHang.maKH}">
                                        <button type="submit" class="btn btn-sm btn-outline-secondary" style="border-radius:6px;font-size:11.5px;">Đặt mặc định</button>
                                    </form>
                                </c:if>
                                <form method="post" action="${pageContext.request.contextPath}/khachhang" class="d-inline"
                                      onsubmit="return confirm('Xóa địa chỉ này?');">
                                    <input type="hidden" name="action" value="xoaDiaChi">
                                    <input type="hidden" name="maDiaChi" value="${dc.maDiaChi}">
                                    <input type="hidden" name="maKH" value="${khachHang.maKH}">
                                    <button type="submit" class="btn btn-sm btn-outline-danger" style="border-radius:6px;"><i class="bi bi-trash"></i></button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty dsDiaChi}">
                        <p class="text-muted" style="font-size:13px;">Chưa có địa chỉ nào.</p>
                    </c:if>

                    <hr style="border-color:#e2e8f0;">

                    <form method="post" action="${pageContext.request.contextPath}/khachhang" class="d-flex gap-2 align-items-start">
                        <input type="hidden" name="action" value="themDiaChi">
                        <input type="hidden" name="maKH" value="${khachHang.maKH}">
                        <input type="text" name="diaChiChiTiet" class="form-control" placeholder="Nhập địa chỉ mới..." required>
                        <div class="form-check pt-2" style="white-space:nowrap;">
                            <input class="form-check-input" type="checkbox" name="laMacDinh" value="1" id="chkMacDinh">
                            <label class="form-check-label" for="chkMacDinh" style="font-size:12.5px;">Đặt mặc định</label>
                        </div>
                        <button type="submit" class="btn btn-outline-primary" style="border-radius:6px;font-size:13px;white-space:nowrap;">
                            <i class="bi bi-plus-lg"></i> Thêm
                        </button>
                    </form>
                </div>
            </div>
        </c:if>

    </div>
</div>
</body>
</html>
