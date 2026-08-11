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

        <%-- Alert box (hiện lỗi / thành công qua JS) --%>
        <div id="alertBox" class="alert border-0 mb-3" style="display:none;border-radius:8px;font-size:13.5px;"></div>

        <div class="row g-3">
            <%-- ===== CỘT TRÁI: Danh sách sản phẩm ===== --%>
            <div class="col-lg-7">
                <div class="card bg-white border mb-3" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="card-body p-3">
                        <div class="d-flex gap-2">
                            <input type="text" id="searchInput" value="${tuKhoa}" class="form-control"
                                   placeholder="Tìm mã / tên sách..." style="font-size:13.5px;max-width:320px;">
                            <button class="btn btn-outline-secondary" onclick="searchSach()" style="font-size:13px;border-radius:6px;">Tìm</button>
                        </div>
                    </div>
                </div>
                <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
                    <div class="table-responsive" style="max-height:560px;overflow:auto;">
                        <table class="table mb-0" id="sachTable">
                            <thead><tr>
                                <th class="ps-3"></th>
                                <th>Mã</th>
                                <th>Tên sách</th>
                                <th>Biến thể / Giá</th>
                                <th class="text-center">Tồn</th>
                                <th></th>
                            </tr></thead>
                            <tbody id="sachTableBody">
                            <c:forEach var="s" items="${danhSachSach}">
                                <c:set var="ton" value="${empty tonKhoMap[s.maSach] ? 0 : tonKhoMap[s.maSach]}"/>
                                <c:set var="dsBT" value="${bienTheMap[s.maSach]}"/>
                                <tr>
                                    <td class="ps-3" style="width:44px;">
                                        <div style="width:34px;height:44px;background:#f1f5f9;border-radius:5px;border:1px solid #e2e8f0;overflow:hidden;display:flex;align-items:center;justify-content:center;">
                                            <c:choose>
                                                <c:when test="${not empty s.anhBia}">
                                                    <img src="${s.anhBia}" alt="${s.tenSach}" style="width:100%;height:100%;object-fit:cover;"
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
                                                <select id="bt_${s.maSach}" class="form-select form-select-sm" style="font-size:12.5px;">
                                                    <c:forEach var="bt" items="${dsBT}">
                                                        <option value="${bt.maBienThe}" data-gia="${bt.giaBienThe}">${bt.tenHienThi}</option>
                                                    </c:forEach>
                                                </select>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="font-size:13px;"><fmt:formatNumber value="${s.giaBan}" pattern="#,##0"/> ₫</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">${ton}</td>
                                    <td class="text-end pe-3">
                                        <c:choose>
                                            <c:when test="${not empty dsBT}">
                                                <button class="btn btn-sm text-white" style="background:#4f46e5;border-radius:6px;"
                                                        onclick="addToCart('${s.maSach}', document.getElementById('bt_${s.maSach}').value)"
                                                    ${ton == 0 ? 'disabled' : ''}>
                                                    <i class="bi bi-cart-plus"></i>
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn btn-sm text-white" style="background:#4f46e5;border-radius:6px;"
                                                        onclick="addToCart('${s.maSach}', '')"
                                                    ${ton == 0 ? 'disabled' : ''}>
                                                    <i class="bi bi-cart-plus"></i>
                                                </button>
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
                            <button class="btn btn-link btn-sm text-danger text-decoration-none" style="font-size:12.5px;"
                                    onclick="clearCart()">Xóa giỏ</button>
                        </div>

                        <%-- Giỏ hàng - render bằng JS --%>
                        <div id="cartItems">
                            <c:choose>
                                <c:when test="${empty chiTietGio}">
                                    <p class="text-muted text-center py-4" style="font-size:13.5px;" id="emptyCartMsg">Chưa có sách trong giỏ.</p>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="item" items="${chiTietGio}">
                                        <c:set var="itemKey" value="${item.maSach}|${empty item.maBienThe ? 0 : item.maBienThe}"/>
                                        <div class="border-bottom py-2 cart-item-row" data-key="${itemKey}" style="border-color:#e2e8f0 !important;">
                                            <div class="d-flex gap-2 align-items-start">
                                                <div style="flex-shrink:0;width:60px;height:80px;background:#f1f5f9;border-radius:6px;border:1px solid #e2e8f0;overflow:hidden;display:flex;align-items:center;justify-content:center;">
                                                    <c:choose>
                                                        <c:when test="${not empty item.anhBia}">
                                                            <img src="${item.anhBia}" alt="${item.tenSach}" style="width:100%;height:100%;object-fit:cover;"
                                                                 onerror="this.parentElement.innerHTML='<i class=\'bi bi-book\' style=\'color:#94a3b8;font-size:20px;\'></i>'"/>
                                                        </c:when>
                                                        <c:otherwise><i class="bi bi-book" style="color:#94a3b8;font-size:20px;"></i></c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="flex-grow-1 overflow-hidden">
                                                    <div class="fw-semibold text-truncate" style="font-size:13px;">${item.tenSach}</div>
                                                    <c:if test="${not empty item.tenBienThe}">
                                                        <div style="font-size:11px;color:#7c3aed;margin-bottom:1px;"><i class="bi bi-tag-fill me-1"></i>${item.tenBienThe}</div>
                                                    </c:if>
                                                    <div class="text-muted" style="font-size:12px;"><fmt:formatNumber value="${item.donGia}" pattern="#,##0"/> ₫ / cuốn</div>
                                                    <div class="d-flex align-items-center gap-1 mt-1">
                                                        <input type="number" value="${item.soLuong}" min="1"
                                                               class="form-control form-control-sm qty-input" style="width:58px;font-size:12px;"
                                                               data-key="${itemKey}"
                                                               onchange="updateQty('${itemKey}', this.value)">
                                                        <button class="btn btn-sm btn-outline-danger" style="font-size:11px;padding:2px 7px;"
                                                                onclick="removeFromCart('${itemKey}')"><i class="bi bi-trash"></i></button>
                                                    </div>
                                                </div>
                                                <div class="text-end fw-semibold" style="font-size:13px;white-space:nowrap;flex-shrink:0;">
                                                    <fmt:formatNumber value="${item.thanhTien}" pattern="#,##0"/> ₫
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <%-- Tổng tiền --%>
                        <div id="summarySection">
                            <div class="d-flex justify-content-between mt-3 mb-1">
                                <span class="fw-semibold">Tổng tiền hàng</span>
                                <span class="fw-bold" id="lblTongTienGio"><fmt:formatNumber value="${tongTienGio}" pattern="#,##0"/> ₫</span>
                            </div>
                            <div class="d-flex justify-content-between mb-2" id="rowGiam" style="${soTienGiam == 0 ? 'display:none!important;' : ''}">
                                <span class="fw-semibold text-danger">Tổng giảm</span>
                                <span class="fw-bold text-danger" id="lblSoTienGiam">-<fmt:formatNumber value="${soTienGiam}" pattern="#,##0"/> ₫</span>
                            </div>
                            <div class="d-flex justify-content-between mt-2 mb-3 pt-2 border-top">
                                <span class="fw-bold fs-6">Khách phải trả</span>
                                <span class="fw-bold fs-5" style="color:#4f46e5;" id="lblTongPhaiTra"><fmt:formatNumber value="${tongTienPhaiTra}" pattern="#,##0"/> ₫</span>
                            </div>
                        </div>

                        <%-- Khu vực thanh toán --%>
                        <div class="mb-2">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <label class="form-label mb-0" style="font-size:12.5px;font-weight:600;color:#475569;">Khách hàng *</label>
                                <button type="button" class="btn btn-sm btn-link text-decoration-none p-0" style="font-size:12px;"
                                        data-bs-toggle="modal" data-bs-target="#modalThemKH">
                                    <i class="bi bi-plus-circle me-1"></i>Thêm mới
                                </button>
                            </div>
                            <select id="selectKhachHang" class="form-select" style="font-size:13.5px;">
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
                                <span id="lblKhachType" class="badge" style="font-size:11px;display:none;"></span>
                            </div>
                            <div id="appliedVoucherList" class="mb-2" style="display:none;">
                                <div class="p-2" style="background:#f8fafc;border-radius:6px;border:1px solid #e2e8f0;">
                                    <p class="mb-1" style="font-size:11.5px;color:#64748b;font-weight:600;">Voucher đã áp:</p>
                                    <div id="appliedVoucherItems"></div>
                                </div>
                            </div>
                            <div class="d-flex gap-2" id="voucherApplyRow">
                                <select id="selectVoucher" class="form-select" style="font-size:13.5px;">
                                    <option value="">-- Chọn mã voucher --</option>
                                    <c:forEach var="v" items="${dsVoucher}">
                                        <option value="${v.maCode}">
                                            ${v.maCode} -
                                            <c:choose>
                                                <c:when test="${v.loaiGiam == 1}">Giảm ${v.giaTri.intValue()}%</c:when>
                                                <c:otherwise>Giảm <fmt:formatNumber value="${v.giaTri}" pattern="#,##0"/>đ</c:otherwise>
                                            </c:choose>
                                            (đơn từ <fmt:formatNumber value="${v.giaTriDonToiThieu}" pattern="#,##0"/>đ)
                                        </option>
                                    </c:forEach>
                                </select>
                                <button type="button" id="btnApplyVoucher" onclick="applyVoucher()" class="btn btn-outline-primary btn-sm px-3">Áp dụng</button>
                                <button type="button" id="btnCancelVouchers" onclick="cancelAllVouchers()" class="btn btn-outline-danger btn-sm px-3" style="display:none;">Hủy tất cả</button>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label mb-1" style="font-size:12.5px;font-weight:600;color:#475569;">Thanh toán</label>
                            <select id="selectPhuongThuc" class="form-select" style="font-size:13.5px;">
                                <option>Tiền mặt</option><option>Chuyển khoản</option><option>Thẻ</option>
                            </select>
                        </div>

                        <%-- Tiền khách đưa & Tiền thối --%>
                        <div class="mb-3 p-2 rounded-3" style="background:#f8fafc;border:1px solid #e2e8f0;">
                            <div class="d-flex gap-2 align-items-center mb-2">
                                <label style="font-size:12.5px;font-weight:600;color:#475569;white-space:nowrap;min-width:90px;">Khách đưa (₫)</label>
                                <input type="number" id="tienKhachDua" class="form-control form-control-sm"
                                       min="0" step="1000" placeholder="0" oninput="tinhTienThoi()" style="font-size:13px;">
                            </div>
                            <div class="d-flex justify-content-between align-items-center">
                                <span style="font-size:12.5px;font-weight:600;color:#475569;">Tiền thối</span>
                                <span id="tienThoi" class="fw-bold" style="font-size:15px;color:#16a34a;">0 ₫</span>
                            </div>
                        </div>

                        <button type="button" id="btnCheckout" onclick="checkout()"
                                class="btn w-100 text-white fw-semibold" style="background:#4f46e5;border-radius:8px;"
                            ${empty chiTietGio ? 'disabled' : ''}>
                            <i class="bi bi-bag-check me-1"></i> Thanh toán
                        </button>

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
                <button type="button" onclick="themKhachHang()" class="btn btn-sm w-100 text-white"
                        style="background:#4f46e5;border-radius:6px;">Lưu và chọn</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    /* ===== Khởi tạo trạng thái từ server-side ===== */
    const CTX = '${pageContext.request.contextPath}';
    let currentTongPhaiTra = ${tongTienPhaiTra};

    /* Khởi tạo appliedVouchers từ server */
    let appliedVouchers = [
        <c:forEach var="vc" items="${appliedVouchers}" varStatus="vs">
            "${vc}"<c:if test="${!vs.last}">,</c:if>
        </c:forEach>
    ];

    /* ===== Alert helper ===== */
    function showAlert(msg, type) {
        const el = document.getElementById('alertBox');
        el.className = 'alert border-0 mb-3';
        el.style.display = 'block';
        if (type === 'success') { el.style.background='#f0fdf4'; el.style.color='#166534'; }
        else { el.style.background='#fef2f2'; el.style.color='#991b1b'; }
        el.innerHTML = (type==='success'
            ? '<i class="bi bi-check-circle-fill me-2"></i>'
            : '<i class="bi bi-exclamation-triangle-fill me-2"></i>') + escHtml(msg);
        setTimeout(()=>{ el.style.display='none'; }, 5000);
    }

    function escHtml(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    /* ===== Lọc khách hàng nhanh ===== */
    const tkInput = document.getElementById('tkKhachHang');
    const selectKH = document.getElementById('selectKhachHang');
    const originalOptions = Array.from(selectKH.options);
    tkInput.addEventListener('input', function () {
        const val = this.value.toLowerCase().trim();
        selectKH.innerHTML = '';
        originalOptions.forEach(opt => {
            if (opt.text.toLowerCase().includes(val) || opt.value === '') selectKH.add(opt.cloneNode(true));
        });
    });

    /* ===== Tiền thối ===== */
    function tinhTienThoi() {
        const khachDua = parseFloat(document.getElementById('tienKhachDua').value) || 0;
        const thoi = khachDua - currentTongPhaiTra;
        const el = document.getElementById('tienThoi');
        if (thoi < 0) { el.textContent = 'Thiếu ' + Math.abs(thoi).toLocaleString('vi-VN') + ' ₫'; el.style.color = '#dc2626'; }
        else { el.textContent = thoi.toLocaleString('vi-VN') + ' ₫'; el.style.color = '#16a34a'; }
    }

    /* ===== Format số tiền ===== */
    function fmtMoney(n) {
        return Math.round(n).toLocaleString('vi-VN') + ' ₫';
    }

    /* ===== Gọi AJAX tới /pos ===== */
    function posPost(params) {
        params.append('maKH', selectKH.value);
        return fetch(CTX + '/pos', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params
        }).then(r => r.json());
    }

    /* ===== Render giỏ hàng ===== */
    function renderCart(cart) {
        const container = document.getElementById('cartItems');
        if (!cart || cart.length === 0) {
            container.innerHTML = '<p class="text-muted text-center py-4" style="font-size:13.5px;">Chưa có sách trong giỏ.</p>';
            document.getElementById('btnCheckout').disabled = true;
            return;
        }
        document.getElementById('btnCheckout').disabled = false;
        let html = '';
        cart.forEach(item => {
            html += `<div class="border-bottom py-2 cart-item-row" data-key="${escHtml(item.key)}" style="border-color:#e2e8f0 !important;">
                <div class="d-flex gap-2 align-items-start">
                    <div style="flex-shrink:0;width:60px;height:80px;background:#f1f5f9;border-radius:6px;border:1px solid #e2e8f0;overflow:hidden;display:flex;align-items:center;justify-content:center;">
                        ${item.anhBia
                            ? `<img src="${escHtml(item.anhBia)}" alt="${escHtml(item.tenSach)}" style="width:100%;height:100%;object-fit:cover;" onerror="this.parentElement.innerHTML='<i class=\\'bi bi-book\\' style=\\'color:#94a3b8;font-size:20px;\\'></i>'">`
                            : '<i class="bi bi-book" style="color:#94a3b8;font-size:20px;"></i>'}
                    </div>
                    <div class="flex-grow-1 overflow-hidden">
                        <div class="fw-semibold text-truncate" style="font-size:13px;">${escHtml(item.tenSach)}</div>
                        ${item.tenBienThe ? `<div style="font-size:11px;color:#7c3aed;margin-bottom:1px;"><i class="bi bi-tag-fill me-1"></i>${escHtml(item.tenBienThe)}</div>` : ''}
                        <div class="text-muted" style="font-size:12px;">${fmtMoney(item.donGia)} / cuốn</div>
                        <div class="d-flex align-items-center gap-1 mt-1">
                            <input type="number" value="${item.soLuong}" min="1"
                                   class="form-control form-control-sm" style="width:58px;font-size:12px;"
                                   onchange="updateQty('${escHtml(item.key)}', this.value)">
                            <button class="btn btn-sm btn-outline-danger" style="font-size:11px;padding:2px 7px;"
                                    onclick="removeFromCart('${escHtml(item.key)}')"><i class="bi bi-trash"></i></button>
                        </div>
                    </div>
                    <div class="text-end fw-semibold" style="font-size:13px;white-space:nowrap;flex-shrink:0;">${fmtMoney(item.thanhTien)}</div>
                </div>
            </div>`;
        });
        container.innerHTML = html;
    }

    /* ===== Render summary ===== */
    function renderSummary(summary) {
        currentTongPhaiTra = summary.tongTienPhaiTra;
        document.getElementById('lblTongTienGio').textContent = fmtMoney(summary.tongTienGio);
        const rowGiam = document.getElementById('rowGiam');
        if (summary.soTienGiam > 0) {
            rowGiam.style.removeProperty('display');
            document.getElementById('lblSoTienGiam').textContent = '-' + fmtMoney(summary.soTienGiam);
        } else {
            rowGiam.style.display = 'none';
        }
        document.getElementById('lblTongPhaiTra').textContent = fmtMoney(summary.tongTienPhaiTra);

        // Applied vouchers
        appliedVouchers = summary.appliedVouchers || [];
        const listDiv = document.getElementById('appliedVoucherList');
        const itemsDiv = document.getElementById('appliedVoucherItems');
        if (appliedVouchers.length > 0) {
            listDiv.style.display = '';
            document.getElementById('btnCancelVouchers').style.display = '';
            itemsDiv.innerHTML = appliedVouchers.map(vc =>
                `<div class="d-flex justify-content-between align-items-center mb-1">
                    <span style="font-size:12px;">${escHtml(vc)}</span>
                    <button class="btn btn-sm btn-link p-0 text-danger" style="font-size:11px;text-decoration:none;"
                            onclick="removeVoucher('${escHtml(vc)}')"><i class="bi bi-x-lg"></i></button>
                </div>`
            ).join('');
        } else {
            listDiv.style.display = 'none';
            document.getElementById('btnCancelVouchers').style.display = 'none';
        }
        const btnApply = document.getElementById('btnApplyVoucher');
        const selVoucher = document.getElementById('selectVoucher');
        if (appliedVouchers.length >= 2) {
            btnApply.disabled = true; selVoucher.disabled = true;
        } else {
            btnApply.disabled = false; selVoucher.disabled = false;
        }
        tinhTienThoi();
    }

    /* ===== AJAX Actions ===== */

    function addToCart(maSach, maBienThe) {
        const p = new URLSearchParams();
        p.append('action', 'add');
        p.append('ma', maSach);
        if (maBienThe) p.append('maBienThe', maBienThe);
        posPost(p).then(data => {
            if (data.ok) { renderCart(data.cart); renderSummary(data.summary); }
            else showAlert(data.message, 'error');
        }).catch(e => showAlert('Lỗi kết nối: ' + e, 'error'));
    }

    function removeFromCart(key) {
        const p = new URLSearchParams();
        p.append('action', 'remove');
        p.append('key', key);
        posPost(p).then(data => {
            if (data.ok) { renderCart(data.cart); renderSummary(data.summary); }
            else showAlert(data.message, 'error');
        }).catch(e => showAlert('Lỗi kết nối: ' + e, 'error'));
    }

    function updateQty(key, qty) {
        const p = new URLSearchParams();
        p.append('action', 'update');
        p.append('key', key);
        p.append('soLuong', qty);
        posPost(p).then(data => {
            if (data.ok) { renderCart(data.cart); renderSummary(data.summary); }
            else showAlert(data.message, 'error');
        }).catch(e => showAlert('Lỗi kết nối: ' + e, 'error'));
    }

    function clearCart() {
        if (!confirm('Xóa toàn bộ giỏ hàng?')) return;
        const p = new URLSearchParams();
        p.append('action', 'clear');
        posPost(p).then(data => {
            if (data.ok) { renderCart(data.cart); renderSummary(data.summary); }
            else showAlert(data.message, 'error');
        }).catch(e => showAlert('Lỗi kết nối: ' + e, 'error'));
    }

    function applyVoucher() {
        const maCode = document.getElementById('selectVoucher').value;
        if (!maCode) { showAlert('Vui lòng chọn voucher', 'error'); return; }
        const p = new URLSearchParams();
        p.append('action', 'applyVoucherSingle');
        p.append('maCode', maCode);
        posPost(p).then(data => {
            if (data.ok) { renderCart(data.cart); renderSummary(data.summary); }
            else showAlert(data.message, 'error');
        }).catch(e => showAlert('Lỗi kết nối: ' + e, 'error'));
    }

    function removeVoucher(maCode) {
        const p = new URLSearchParams();
        p.append('action', 'removeAppliedVoucher');
        p.append('maCode', maCode);
        posPost(p).then(data => {
            if (data.ok) { renderCart(data.cart); renderSummary(data.summary); }
            else showAlert(data.message, 'error');
        }).catch(e => showAlert('Lỗi kết nối: ' + e, 'error'));
    }

    function cancelAllVouchers() {
        const p = new URLSearchParams();
        p.append('action', 'cancelAllVouchers');
        posPost(p).then(data => {
            if (data.ok) { renderCart(data.cart); renderSummary(data.summary); }
            else showAlert(data.message, 'error');
        }).catch(e => showAlert('Lỗi kết nối: ' + e, 'error'));
    }

    function checkout() {
        const maKH = selectKH.value;
        if (!maKH) { showAlert('Vui lòng chọn khách hàng.', 'error'); return; }
        const p = new URLSearchParams();
        p.append('action', 'checkout');
        p.append('maKH', maKH);
        p.append('phuongThuc', document.getElementById('selectPhuongThuc').value);
        posPost(p).then(data => {
            if (data.ok) {
                showAlert('Tạo đơn hàng #' + data.maDH + ' thành công.', 'success');
                renderCart([]);
                renderSummary({ tongTienGio: 0, soTienGiam: 0, tongTienPhaiTra: 0, appliedVouchers: [] });
                document.getElementById('tienKhachDua').value = '';
                selectKH.value = '';
            } else showAlert(data.message, 'error');
        }).catch(e => showAlert('Lỗi kết nối: ' + e, 'error'));
    }

    /* ===== Tìm kiếm sách AJAX ===== */
    function searchSach() {
        const q = document.getElementById('searchInput').value.trim();
        fetch(CTX + '/pos?q=' + encodeURIComponent(q), {
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        }).then(r => r.json()).then(data => {
            if (!data.ok) { showAlert(data.message || 'Lỗi tìm kiếm', 'error'); return; }
            const tbody = document.getElementById('sachTableBody');
            if (!data.sachs || data.sachs.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Không tìm thấy sách nào.</td></tr>';
                return;
            }
            let html = '';
            data.sachs.forEach(s => {
                const ton = s.ton || 0;
                const hasBT = s.bienThes && s.bienThes.length > 0;
                const selectId = 'bt_' + s.maSach;
                let giaHtml = '';
                if (hasBT) {
                    giaHtml = `<select id="${escHtml(selectId)}" class="form-select form-select-sm" style="font-size:12.5px;">`;
                    s.bienThes.forEach(bt => {
                        giaHtml += `<option value="${bt.maBienThe}" data-gia="${bt.giaBienThe}">${escHtml(bt.tenHienThi)}</option>`;
                    });
                    giaHtml += '</select>';
                } else {
                    giaHtml = `<span style="font-size:13px;">${Math.round(s.giaBan).toLocaleString('vi-VN')} ₫</span>`;
                }
                const addCall = hasBT
                    ? `addToCart('${escHtml(s.maSach)}', document.getElementById('${escHtml(selectId)}').value)`
                    : `addToCart('${escHtml(s.maSach)}', '')`;
                const anhHtml = s.anhBia
                    ? `<img src="${escHtml(s.anhBia)}" alt="${escHtml(s.tenSach)}" style="width:100%;height:100%;object-fit:cover;" onerror="this.parentElement.innerHTML='<i class=\\'bi bi-book\\' style=\\'color:#94a3b8;font-size:14px;\\'></i>'">`
                    : '<i class="bi bi-book" style="color:#94a3b8;font-size:14px;"></i>';
                html += `<tr>
                    <td class="ps-3" style="width:44px;">
                        <div style="width:34px;height:44px;background:#f1f5f9;border-radius:5px;border:1px solid #e2e8f0;overflow:hidden;display:flex;align-items:center;justify-content:center;">${anhHtml}</div>
                    </td>
                    <td class="fw-semibold">${escHtml(s.maSach)}</td>
                    <td>${escHtml(s.tenSach)}</td>
                    <td style="min-width:220px;">${giaHtml}</td>
                    <td class="text-center">${ton}</td>
                    <td class="text-end pe-3">
                        <button class="btn btn-sm text-white" style="background:#4f46e5;border-radius:6px;"
                                onclick="${addCall}" ${ton === 0 ? 'disabled' : ''}>
                            <i class="bi bi-cart-plus"></i>
                        </button>
                    </td>
                </tr>`;
            });
            tbody.innerHTML = html;
        }).catch(e => showAlert('Lỗi tìm kiếm: ' + e, 'error'));
    }

    /* Enter key trong ô tìm kiếm */
    document.getElementById('searchInput').addEventListener('keydown', function(e) {
        if (e.key === 'Enter') { e.preventDefault(); searchSach(); }
    });

    /* ===== Thêm khách hàng mới ===== */
    function themKhachHang() {
        const ten = document.getElementById('newTenKH').value.trim();
        const sdt = document.getElementById('newSdtKH').value.trim();
        if (!ten) { showAlert('Vui lòng nhập tên khách hàng', 'error'); return; }
        const p = new URLSearchParams();
        p.append('action', 'addKH');
        p.append('tenKH', ten);
        p.append('sdt', sdt);
        fetch(CTX + '/pos', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: p
        }).then(r => r.json()).then(data => {
            if (data.ok) {
                const label = data.tenKH + ' - ' + (data.sdt || '');
                const newOpt = new Option(label, data.maKH);
                selectKH.add(newOpt);
                originalOptions.push(newOpt.cloneNode(true));
                selectKH.value = data.maKH;
                bootstrap.Modal.getInstance(document.getElementById('modalThemKH')).hide();
                document.getElementById('newTenKH').value = '';
                document.getElementById('newSdtKH').value = '';
                showAlert('Đã thêm khách hàng: ' + data.tenKH, 'success');
            } else showAlert(data.message || 'Lỗi thêm khách hàng', 'error');
        }).catch(e => showAlert('Lỗi: ' + e, 'error'));
    }

    /* Khởi tạo summary từ server khi load trang */
    renderSummary({
        tongTienGio: ${tongTienGio},
        soTienGiam: ${soTienGiam},
        tongTienPhaiTra: ${tongTienPhaiTra},
        appliedVouchers: appliedVouchers
    });
</script>
</body>
</html>
