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
        .qty-badge { font-size: 11px; }
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

        <c:if test="${not empty param.message}">
            <div class="alert alert-info alert-dismissible fade show no-print" role="alert">
                ${param.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

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
                        <th class="text-end">Thành tiền</th>
                        <th class="text-center">Còn lại</th>
                        <th class="text-center pe-4 no-print">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="ct" items="${donHang.chiTietDonHangs}">
                        <c:set var="conLaiObj" value="${soLuongConLaiMap[ct.maCTDH]}" />
                        <c:set var="conLai" value="${empty conLaiObj ? 0 : conLaiObj}" />
                        <tr>
                            <td class="ps-4">
                                <div class="fw-semibold">${ct.sach.tenSach}</div>
                                <div class="text-muted" style="font-size:12px;">Mã: ${ct.sach.maSach}</div>
                            </td>
                            <td class="text-center">${ct.soLuong}</td>
                            <td class="text-end"><fmt:formatNumber value="${ct.donGia}" pattern="#,##0"/> ₫</td>
                            <%-- Thanh tien = So luong * Don gia --%>
                            <td class="text-end fw-bold"><fmt:formatNumber value="${ct.soLuong * ct.donGia}" pattern="#,##0"/> ₫</td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${conLai == ct.soLuong}">
                                        <span class="text-muted">${conLai}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-warning-subtle text-warning-emphasis qty-badge">${conLai}/${ct.soLuong}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center pe-4 no-print">
                                <c:choose>
                                    <c:when test="${conLai > 0}">
                                        <button type="button" class="btn btn-sm btn-outline-warning" style="border-radius:6px;"
                                                data-bs-toggle="modal" data-bs-target="#traModal${ct.maCTDH}">
                                            <i class="bi bi-arrow-return-left"></i> Trả
                                        </button>
                                        <button type="button" class="btn btn-sm btn-outline-primary" style="border-radius:6px;"
                                                data-bs-toggle="modal" data-bs-target="#doiModal${ct.maCTDH}">
                                            <i class="bi bi-arrow-left-right"></i> Đổi
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary-subtle text-secondary qty-badge">Đã xử lý hết</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>

                        <%-- Modal tra hang: tra tung mon, so luong toi da la con lai --%>
                        <div class="modal fade no-print" id="traModal${ct.maCTDH}" tabindex="-1">
                            <div class="modal-dialog">
                                <form method="post" action="${pageContext.request.contextPath}/don-hang"
                                      onsubmit="return confirm('Xác nhận trả hàng? Sách sẽ được hoàn lại tồn kho.');">
                                    <input type="hidden" name="action" value="tra">
                                    <input type="hidden" name="maDH" value="${donHang.maDH}">
                                    <input type="hidden" name="maCTDH" value="${ct.maCTDH}">
                                    <input type="hidden" name="tenSach" value="${ct.sach.tenSach}">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h6 class="modal-title">Trả hàng: ${ct.sach.tenSach}</h6>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <label class="form-label" style="font-size:13px;">Số lượng trả (tối đa ${conLai})</label>
                                            <input type="number" name="soLuong" class="form-control" min="1" max="${conLai}" value="1" required>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                                            <button type="submit" class="btn btn-warning btn-sm">Xác nhận trả</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <%-- Modal doi hang: chi cho phep chon sach co gia >= gia dong hien tai --%>
                        <div class="modal fade no-print" id="doiModal${ct.maCTDH}" tabindex="-1">
                            <div class="modal-dialog">
                                <form method="post" action="${pageContext.request.contextPath}/don-hang"
                                      onsubmit="return confirm('Xác nhận đổi hàng? Sách cũ sẽ được hoàn lại tồn kho.');">
                                    <input type="hidden" name="action" value="doi">
                                    <input type="hidden" name="maDH" value="${donHang.maDH}">
                                    <input type="hidden" name="maCTDH" value="${ct.maCTDH}">
                                    <input type="hidden" name="tenSach" value="${ct.sach.tenSach}">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h6 class="modal-title">Đổi hàng: ${ct.sach.tenSach}</h6>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <label class="form-label" style="font-size:13px;">Số lượng đổi (tối đa ${conLai})</label>
                                            <input type="number" name="soLuong" class="form-control mb-3" min="1" max="${conLai}" value="1" required>

                                            <label class="form-label" style="font-size:13px;">Đổi sang sách (chỉ hiện sách giá ≥ ${ct.donGia})</label>
                                            <select name="maSachMoi" class="form-select" required>
                                                <option value="" disabled selected>-- Chọn sách --</option>
                                                <c:forEach var="s" items="${danhSachSachDangBan}">
                                                    <c:if test="${s.giaBan >= ct.donGia && s.maSach != ct.sach.maSach}">
                                                        <option value="${s.maSach}">
                                                            ${s.tenSach} — <fmt:formatNumber value="${s.giaBan}" pattern="#,##0"/> ₫
                                                        </option>
                                                    </c:if>
                                                </c:forEach>
                                            </select>
                                            <div class="form-text">Nếu sách mới có giá cao hơn, khách cần trả thêm phần chênh lệch.</div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                                            <button type="submit" class="btn btn-primary btn-sm">Xác nhận đổi</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                    </tbody>
                    <tfoot>
                    <tr class="table-light">
                        <td colspan="3" class="text-end fw-bold py-3">TỔNG CỘNG:</td>
                        <td class="text-end fw-bold py-3" style="font-size:18px; color:#4f46e5;">
                            <fmt:formatNumber value="${donHang.tongTien - donHang.soTienGiam}" pattern="#,##0"/> ₫
                        </td>
                        <td colspan="2" class="no-print"></td>
                    </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>
</div>

<%-- Moi: banner + phieu in doi/tra ngay sau khi thao tac thanh cong (khong luu DB,
     chi tao lai tu tham so redirect, dua cho khach 1 lan). --%>
<c:if test="${param.in == '1'}">
    <div class="container-fluid no-print" style="max-width: 900px; margin-left: 280px;">
        <div class="alert alert-success d-flex justify-content-between align-items-center">
            <span>Thao tác đổi/trả đã hoàn tất.</span>
            <button type="button" class="btn btn-sm btn-success" onclick="inPhieuDoiTra()">
                <i class="bi bi-printer me-1"></i> In phiếu đổi/trả
            </button>
        </div>
    </div>
    <script>
        function inPhieuDoiTra() {
            var loai = "${param.loai}";
            var tenSach = "${param.tenSach}";
            var soLuong = "${param.soLuong}";
            var maDH = "${donHang.maDH}";
            var khachHang = "${donHang.khachHang.tenKH}";
            var now = new Date().toLocaleString('vi-VN');
            var tieuDe = loai === 'TRA' ? 'PHIẾU TRẢ HÀNG' : 'PHIẾU ĐỔI HÀNG';
            var noiDung = loai === 'TRA'
                ? ('Trả <b>' + soLuong + '</b> cuốn: <b>' + tenSach + '</b>')
                : ('Đổi <b>' + soLuong + '</b> cuốn: <b>' + tenSach + '</b>' +
                   '<br>(khách trả thêm phần chênh lệch nếu sách mới giá cao hơn)');

            var w = window.open('', '_blank', 'width=420,height=560');
            w.document.write(
                '<html><head><meta charset="UTF-8"><title>' + tieuDe + '</title>' +
                '<style>body{font-family:Arial,sans-serif;padding:24px;color:#0f172a;}' +
                'h3{margin-bottom:4px;} .muted{color:#64748b;font-size:12px;margin-bottom:16px;}' +
                'table{width:100%;border-collapse:collapse;margin-top:12px;}' +
                'td{padding:6px 0;font-size:14px;border-bottom:1px solid #e2e8f0;}' +
                '.label{color:#64748b;width:40%;}</style></head><body>' +
                '<h3>' + tieuDe + '</h3>' +
                '<div class="muted">Đơn hàng #' + maDH + ' — ' + now + '</div>' +
                '<table>' +
                '<tr><td class="label">Khách hàng</td><td>' + khachHang + '</td></tr>' +
                '<tr><td class="label">Nội dung</td><td>' + noiDung + '</td></tr>' +
                '</table>' +
                '<p style="margin-top:24px;font-size:12px;color:#64748b;">Cảm ơn quý khách.</p>' +
                '</body></html>'
            );
            w.document.close();
            w.focus();
            w.print();
        }
        // Thu tu dong mo phieu ngay; neu bi trinh duyet chan popup thi nguoi dung
        // van co the bam nut "In phiếu đổi/trả" phia tren.
        try { inPhieuDoiTra(); } catch (e) {}
    </script>
</c:if>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
