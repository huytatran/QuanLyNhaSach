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
                <p class="text-muted mb-0" style="font-size:13px;">Chọn sách, thêm vào giỏ và thanh toán.</p>
            </div>
        </div>
        <c:if test="${not empty param.thanhCong}">
            <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13.5px;">
                <i class="bi bi-check-circle-fill me-2"></i>Tạo đơn hàng #${param.thanhCong} thành công.
            </div>
        </c:if>
        <c:if test="${not empty param.loi}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${param.loi}
            </div>
        </c:if>

        <div class="row g-3">
            <%-- ===== CỘT TRÁI: Danh sách sản phẩm ===== --%>
            <div class="col-lg-7">
                <div class="card bg-white border mb-3" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="card-body p-3">
                        <form method="get" action="${pageContext.request.contextPath}/pos" class="d-flex gap-2">
                            <input type="text" name="q" value="${tuKhoa}" class="form-control"
                                   placeholder="Tìm mã / tên sách..." style="font-size:13.5px;max-width:320px;">
                            <button class="btn btn-outline-secondary" style="font-size:13px;border-radius:6px;">Tìm</button>
                        </form>
                    </div>
                </div>
                <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="table-responsive" style="max-height:560px;overflow:auto;">
                        <table class="table mb-0">
                            <thead><tr>
                                <th class="ps-3"></th>
                                <th>Mã</th>
                                <th>Tên sách</th>
                                <th>Biến thể / Giá</th>
                                <th class="text-center">Tồn</th>
                                <th></th>
                            </tr></thead>
                            <tbody>
                            <c:forEach var="s" items="${danhSachSach}">
                                <c:set var="ton" value="${empty tonKhoMap[s.maSach] ? 0 : tonKhoMap[s.maSach]}"/>
                                <c:set var="dsBT" value="${bienTheMap[s.maSach]}"/>
                                <tr>
                                    <td class="ps-3" style="width:44px;">
                                        <div style="width:34px;height:44px;background:#f1f5f9;border-radius:5px;border:1px solid #e2e8f0;overflow:hidden;display:flex;align-items:center;justify-content:center;">
                                            <c:choose>
                                                <c:when test="${not empty s.anhBia}">
                                                    <img src="${s.anhBia}" alt="${s.tenSach}"
                                                         style="width:100%;height:100%;object-fit:cover;"
                                                         onerror="this.parentElement.innerHTML='<i class=\'bi bi-book\' style=\'color:#94a3b8;font-size:14px;\'></i>'"/>
                                                </c:when>
                                                <c:otherwise><i class="bi bi-book" style="color:#94a3b8;font-size:14px;"></i></c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td class="fw-semibold">${s.maSach}</td>
                                    <td>${s.tenSach}</td>
                                    <td style="min-width:220px;">
                                        <c:choose>
                                            <c:when test="${not empty dsBT}">
                                                <%-- Có biến thể: hiển thị dropdown chọn --%>
                                                <select id="bt_${s.maSach}" class="form-select form-select-sm" style="font-size:12.5px;">
                                                    <c:forEach var="bt" items="${dsBT}">
                                                        <option value="${bt.maBienThe}" data-gia="${bt.giaBienThe}">
                                                                ${bt.tenHienThi}
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </c:when>
                                            <c:otherwise>
                                                <%-- Không có biến thể: hiển thị giá gốc --%>
                                                <span style="font-size:13px;">
                                        <fmt:formatNumber value="${s.giaBan}" pattern="#,##0"/> ₫
                                    </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">${ton}</td>
                                    <td class="text-end pe-3">
                                        <c:choose>
                                            <c:when test="${not empty dsBT}">
                                                <%-- Nút thêm vào giỏ kèm biến thể đang chọn --%>
                                                <button class="btn btn-sm text-white" style="background:#4f46e5;border-radius:6px;"
                                                        onclick="themVaoGio('${s.maSach}', 'bt_${s.maSach}')"
                                                    ${ton == 0 ? 'disabled' : ''}>
                                                    <i class="bi bi-cart-plus"></i>
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <form method="post" action="${pageContext.request.contextPath}/pos" class="d-inline">
                                                    <input type="hidden" name="action" value="add">
                                                    <input type="hidden" name="ma" value="${s.maSach}">
                                                    <button class="btn btn-sm text-white" style="background:#4f46e5;border-radius:6px;"
                                                        ${ton == 0 ? 'disabled' : ''}>
                                                        <i class="bi bi-cart-plus"></i>
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div><%-- end col-lg-7 --%>

            <%-- ===== CỘT PHẢI: Giỏ hàng & Thanh toán ===== --%>
            <div class="col-lg-5">
                <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0">Giỏ hàng</h6>
                            <form method="post" action="${pageContext.request.contextPath}/pos"
                                  onsubmit="return confirm('Xóa toàn bộ giỏ hàng?')">
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
                                    <c:set var="itemKey" value="${item.maSach}|${empty item.maBienThe ? 0 : item.maBienThe}"/>
                                    <div class="border-bottom py-2" style="border-color:#e2e8f0 !important;">
                                        <div class="d-flex gap-2 align-items-start">
                                                <%-- Ảnh bìa --%>
                                            <div style="flex-shrink:0;width:60px;height:80px;background:#f1f5f9;border-radius:6px;border:1px solid #e2e8f0;overflow:hidden;display:flex;align-items:center;justify-content:center;">
                                                <c:choose>
                                                    <c:when test="${not empty item.anhBia}">
                                                        <img src="${item.anhBia}" alt="${item.tenSach}"
                                                             style="width:100%;height:100%;object-fit:cover;"
                                                             onerror="this.parentElement.innerHTML='<i class=\'bi bi-book\' style=\'color:#94a3b8;font-size:20px;\'></i>'"/>
                                                    </c:when>
                                                    <c:otherwise><i class="bi bi-book" style="color:#94a3b8;font-size:20px;"></i></c:otherwise>
                                                </c:choose>
                                            </div>
                                                <%-- Thông tin --%>
                                            <div class="flex-grow-1 overflow-hidden">
                                                <div class="fw-semibold text-truncate" style="font-size:13px;" title="${item.tenSach}">${item.tenSach}</div>
                                                <c:if test="${not empty item.tenBienThe}">
                                                    <div style="font-size:11px;color:#7c3aed;margin-bottom:1px;">
                                                        <i class="bi bi-tag-fill me-1"></i>${item.tenBienThe}
                                                    </div>
                                                </c:if>
                                                <div class="text-muted" style="font-size:12px;"><fmt:formatNumber value="${item.donGia}" pattern="#,##0"/> ₫ / cuốn</div>
                                                <div class="d-flex align-items-center gap-1 mt-1">
                                                    <form method="post" action="${pageContext.request.contextPath}/pos" class="d-flex gap-1">
                                                        <input type="hidden" name="action" value="update">
                                                        <input type="hidden" name="key" value="${itemKey}">
                                                        <input type="number" name="soLuong" value="${item.soLuong}" min="1"
                                                               class="form-control form-control-sm" style="width:58px;font-size:12px;">
                                                        <button class="btn btn-sm btn-outline-secondary" style="font-size:11px;padding:2px 7px;">
                                                            <i class="bi bi-check-lg"></i>
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/pos">
                                                        <input type="hidden" name="action" value="remove">
                                                        <input type="hidden" name="key" value="${itemKey}">
                                                        <button class="btn btn-sm btn-outline-danger" style="font-size:11px;padding:2px 7px;"><i class="bi bi-trash"></i></button>
                                                    </form>
                                                </div>
                                            </div>
                                                <%-- Thành tiền --%>
                                            <div class="text-end fw-semibold" style="font-size:13px;white-space:nowrap;flex-shrink:0;">
                                                <fmt:formatNumber value="${item.thanhTien}" pattern="#,##0"/> ₫
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>

                        <%-- Tổng tiền --%>
                        <div class="d-flex justify-content-between mt-3 mb-1">
                            <span class="fw-semibold">Tổng tiền hàng</span>
                            <span class="fw-bold"><fmt:formatNumber value="${tongTienGio}" pattern="#,##0"/> ₫</span>
                        </div>
                        <c:if test="${soTienGiam != null && soTienGiam > 0}">
                            <div class="d-flex justify-content-between mb-2">
                                <span class="fw-semibold text-danger">Tổng giảm</span>
                                <span class="fw-bold text-danger">
                -<fmt:formatNumber value="${soTienGiam}" pattern="#,##0"/> ₫
                <c:if test="${capAmount != null}">
                    / <fmt:formatNumber value="${capAmount}" pattern="#,##0"/> ₫ (${currentDiscountPercent}%/${capPercent}%)
                </c:if>
            </span>
                            </div>
                        </c:if>
                        <div class="d-flex justify-content-between mt-2 mb-3 pt-2 border-top">
                            <span class="fw-bold fs-6">Khách phải trả</span>
                            <span class="fw-bold fs-5" style="color:#4f46e5;">
            <fmt:formatNumber value="${tongTienPhaiTra}" pattern="#,##0"/> ₫
        </span>
                        </div>

                        <%-- Form thanh toán --%>
                        <form method="post" action="${pageContext.request.contextPath}/pos">
                            <div class="mb-2">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <label class="form-label mb-0" style="font-size:12.5px;font-weight:600;color:#475569;">Khách hàng *</label>
                                    <button type="button" class="btn btn-sm btn-link text-decoration-none p-0" style="font-size:12px;"
                                            data-bs-toggle="modal" data-bs-target="#modalThemKH">
                                        <i class="bi bi-plus-circle me-1"></i>Thêm mới
                                    </button>
                                </div>
                                <select name="maKH" id="selectKhachHang" class="form-select" required style="font-size:13.5px;">
                                    <option value="">-- Chọn khách hàng --</option>
                                    <c:forEach var="kh" items="${dsKhachHang}">
                                        <option value="${kh.maKH}" <c:if test="${kh.maKH == maKHSelected}">selected</c:if>>${kh.tenKH} - ${kh.sdt}</option>
                                    </c:forEach>
                                </select>
                                <input type="text" id="tkKhachHang" class="form-control form-control-sm mt-1"
                                       placeholder="Gõ để lọc khách hàng nhanh..." style="font-size:12px;">
                            </div>
                            <%-- Voucher --%>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <label class="form-label mb-0" style="font-size:12.5px;font-weight:600;color:#475569;">Voucher áp dụng</label>
                                    <c:if test="${not empty maKHSelected}">
                                        <c:choose>
                                            <c:when test="${isNewCustomer}"><span class="badge bg-success" style="font-size:11px;">Khách mới (tối đa 40%)</span></c:when>
                                            <c:otherwise><span class="badge bg-info" style="font-size:11px;">Khách cũ (tối đa 20%)</span></c:otherwise>
                                        </c:choose>
                                    </c:if>
                                </div>
                                <c:if test="${not empty appliedVouchers}">
                                    <div class="mb-2 p-2" style="background:#f8fafc;border-radius:6px;border:1px solid #e2e8f0;">
                                        <p class="mb-1" style="font-size:11.5px;color:#64748b;font-weight:600;">Voucher đã áp:</p>
                                        <c:forEach var="maCode" items="${appliedVouchers}">
                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                <span style="font-size:12px;">${maCode}</span>
                                                <button type="button" onclick="submitRemoveAppliedVoucher('${maCode}')"
                                                        class="btn btn-sm btn-link p-0 text-danger" style="font-size:11px;text-decoration:none;">
                                                    <i class="bi bi-x-lg"></i>
                                                </button>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:if>
                                <div class="d-flex gap-2">
                                    <select id="selectVoucher" name="maCode" class="form-select" style="font-size:13.5px;"
                                            <c:if test="${appliedVouchers.size() >= 2}">disabled</c:if>>
                                        <option value="">-- Chọn mã voucher --</option>
                                        <c:forEach var="v" items="${dsVoucher}">
                                            <option value="${v.maCode}" <c:if test="${appliedVouchers.contains(v.maCode)}">disabled</c:if>>
                                                    ${v.maCode} -
                                                    <c:choose>
                                                        <c:when test="${v.loaiGiam == 1}">Giảm ${v.giaTri.intValue()}%</c:when>
                                                        <c:otherwise>Giảm <fmt:formatNumber value="${v.giaTri}" pattern="#,##0"/>đ</c:otherwise>
                                                    </c:choose>
                                                    (đơn từ <fmt:formatNumber value="${v.giaTriDonToiThieu}" pattern="#,##0"/>đ)
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <button type="button" onclick="applyVoucherSingle()" class="btn btn-outline-primary btn-sm px-3"
                                            <c:if test="${appliedVouchers.size() >= 2}">disabled</c:if>>Áp dụng</button>
                                    <c:if test="${not empty appliedVouchers}">
                                        <button type="button" onclick="submitCancelAllVouchers()" class="btn btn-outline-danger btn-sm px-3">Hủy tất cả</button>
                                    </c:if>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label mb-1" style="font-size:12.5px;font-weight:600;color:#475569;">Thanh toán</label>
                                <select name="phuongThuc" class="form-select" style="font-size:13.5px;">
                                    <option>Tiền mặt</option><option>Chuyển khoản</option><option>Thẻ</option>
                                </select>
                            </div>

                            <%-- Tiền khách đưa & Tiền thối --%>
                            <div class="mb-3 p-2 rounded-3" style="background:#f8fafc;border:1px solid #e2e8f0;">
                                <div class="d-flex gap-2 align-items-center mb-2">
                                    <label style="font-size:12.5px;font-weight:600;color:#475569;white-space:nowrap;min-width:90px;">Khách đưa (₫)</label>
                                    <input type="number" id="tienKhachDua" class="form-control form-control-sm"
                                           min="0" step="1000" placeholder="0"
                                           oninput="tinhTienThoi()"
                                           style="font-size:13px;">
                                </div>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span style="font-size:12.5px;font-weight:600;color:#475569;">Tiền thối</span>
                                    <span id="tienThoi" class="fw-bold" style="font-size:15px;color:#16a34a;">0 ₫</span>
                                </div>
                            </div>
                            <button type="submit" name="action" value="checkout"
                                    class="btn w-100 text-white fw-semibold" style="background:#4f46e5;border-radius:8px;"
                            ${empty chiTietGio ? 'disabled' : ''}>
                                <i class="bi bi-bag-check me-1"></i> Thanh toán
                            </button>
                        </form>
                    </div><%-- card-body --%>
                </div><%-- card --%>
            </div><%-- col-lg-5 --%>
        </div><%-- row --%>
    </div><%-- container --%>
</div><%-- margin-left --%>

<%-- Modal thêm khách hàng nhanh --%>
<div class="modal fade" id="modalThemKH" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border-radius:12px;border:none;box-shadow:0 10px 25px rgba(0,0,0,.1);">
            <div class="modal-header border-0 pb-0">
                <h6 class="fw-bold mb-0">Thêm khách hàng nhanh</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" style="font-size:10px;"></button>
            </div>
            <div class="modal-body">
                <div class="mb-2">
                    <label class="form-label" style="font-size:12px;">Họ tên *</label>
                    <input type="text" id="newTenKH" class="form-control form-control-sm" placeholder="Nhập tên khách">
                </div>
                <div class="mb-3">
                    <label class="form-label" style="font-size:12px;">Số điện thoại</label>
                    <input type="text" id="newSdtKH" class="form-control form-control-sm" placeholder="Nhập SĐT">
                </div>
                <button type="button" onclick="ajaxThemKH()" class="btn btn-sm w-100 text-white"
                        style="background:#4f46e5;border-radius:6px;">Lưu và chọn</button>
            </div>
        </div>
    </div>
</div>

<%-- Form ẩn dùng cho thêm vào giỏ khi có biến thể (submit bằng JS) --%>
<form id="formAddBienThe" method="post" action="${pageContext.request.contextPath}/pos" style="display:none;">
    <input type="hidden" name="action" value="add">
    <input type="hidden" name="ma"        id="fAddMaSach">
    <input type="hidden" name="maBienThe" id="fAddMaBienThe">
    <input type="hidden" name="maKH"      id="fAddMaKH">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ---- Lọc khách hàng nhanh ----
    const tkInput = document.getElementById('tkKhachHang');
    const selectKH = document.getElementById('selectKhachHang');
    const originalOptions = Array.from(selectKH.options);
    tkInput.addEventListener('input', function() {
        const val = this.value.toLowerCase().trim();
        selectKH.innerHTML = '';
        originalOptions.forEach(opt => {
            if (opt.text.toLowerCase().includes(val) || opt.value === '') selectKH.add(opt);
        });
    });

    // ---- Thêm vào giỏ khi có biến thể (submit form ẩn) ----
    function themVaoGio(maSach, selectId) {
        const sel = document.getElementById(selectId);
        const maBienThe = sel ? sel.value : '';
        document.getElementById('fAddMaSach').value    = maSach;
        document.getElementById('fAddMaBienThe').value = maBienThe;
        document.getElementById('fAddMaKH').value      = selectKH.value;
        document.getElementById('formAddBienThe').submit();
    }

    // ---- Đính kèm maKH vào mọi form POST ----
    document.querySelectorAll('form').forEach(function(form) {
        try {
            if ((form.method || '').toLowerCase() === 'post') {
                const actionInp = form.querySelector('input[name="action"]');
                if (actionInp && actionInp.value !== 'addKH') {
                    form.addEventListener('submit', function() {
                        let hidden = form.querySelector('input[name="maKH"][type="hidden"]');
                        if (!hidden) {
                            hidden = document.createElement('input');
                            hidden.type = 'hidden'; hidden.name = 'maKH';
                            form.appendChild(hidden);
                        }
                        hidden.value = selectKH.value;
                    });
                }
            }
        } catch(e) {}
    });

    // ---- Gỡ 1 voucher đã áp ----
    function submitRemoveAppliedVoucher(maCode) {
        const f = document.createElement('form');
        f.method = 'POST'; f.action = '${pageContext.request.contextPath}/pos';
        f.innerHTML = '<input type="hidden" name="action" value="removeAppliedVoucher">'
            + '<input type="hidden" name="maCode" value="' + maCode + '">'
            + '<input type="hidden" name="maKH"   value="' + selectKH.value + '">';
        document.body.appendChild(f); f.submit();
    }

    // ---- Hủy tất cả voucher ----
    function submitCancelAllVouchers() {
        const f = document.createElement('form');
        f.method = 'POST'; f.action = '${pageContext.request.contextPath}/pos';
        f.innerHTML = '<input type="hidden" name="action" value="cancelAllVouchers">'
            + '<input type="hidden" name="maKH" value="' + selectKH.value + '">';
        document.body.appendChild(f); f.submit();
    }

    // ---- Áp voucher đơn ----
    function applyVoucherSingle() {
        const maCode = document.getElementById('selectVoucher').value;
        if (!maCode) { alert('Vui lòng chọn voucher'); return; }
        const f = document.createElement('form');
        f.method = 'POST'; f.action = '${pageContext.request.contextPath}/pos';
        f.innerHTML = '<input type="hidden" name="action" value="applyVoucherSingle">'
            + '<input type="hidden" name="maCode" value="' + maCode + '">'
            + '<input type="hidden" name="maKH"   value="' + selectKH.value + '">';
        document.body.appendChild(f); f.submit();
    }

    // ---- Tính tiền thối ----
    const tongPhaiTra = ${tongTienPhaiTra};
    function tinhTienThoi() {
        const khachDua = parseFloat(document.getElementById('tienKhachDua').value) || 0;
        const thoi = khachDua - tongPhaiTra;
        const el = document.getElementById('tienThoi');
        if (thoi < 0) {
            el.textContent = 'Thiếu ' + Math.abs(thoi).toLocaleString('vi-VN') + ' ₫';
            el.style.color = '#dc2626';
        } else {
            el.textContent = thoi.toLocaleString('vi-VN') + ' ₫';
            el.style.color = '#16a34a';
        }
    }

    // ---- Thêm khách hàng mới qua AJAX ----
    function ajaxThemKH() {
        const ten = document.getElementById('newTenKH').value;
        const sdt = document.getElementById('newSdtKH').value;
        if (!ten) { alert('Vui lòng nhập tên khách hàng'); return; }
        const params = new URLSearchParams();
        params.append('action','addKH'); params.append('tenKH',ten); params.append('sdt',sdt);
        fetch('${pageContext.request.contextPath}/pos', {
            method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:params
        }).then(r=>r.json()).then(data=>{
            const newOpt = new Option(data.tenKH + ' - ' + (sdt||''), data.maKH);
            selectKH.add(newOpt);
            selectKH.value = data.maKH;
            originalOptions.push(newOpt);
            bootstrap.Modal.getInstance(document.getElementById('modalThemKH')).hide();
            document.getElementById('newTenKH').value = '';
            document.getElementById('newSdtKH').value = '';
        }).catch(err=>alert('Lỗi: '+err));
    }
</script>
</body>
</html>
