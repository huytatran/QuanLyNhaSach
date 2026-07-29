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
        .badge-trangthai { font-size: 12px; font-weight: 600; padding: 5px 12px; border-radius: 999px; }
        .badge-da-giao { background: #e0f2fe; color: #0369a1; }
        .badge-da-tra { background: #fee2e2; color: #b91c1c; }
        .badge-doi-tra-mot-phan { background: #fef3c7; color: #b45309; }
        .badge-loai-gd { font-size: 11px; font-weight: 700; padding: 3px 9px; border-radius: 6px; }
        .badge-loai-tra { background: #fee2e2; color: #b91c1c; }
        .badge-loai-doi { background: #ede9fe; color: #6d28d9; }
    </style>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid" style="max-width: 900px;">

        <div class="mb-4">
            <a href="${pageContext.request.contextPath}/don-hang" class="text-decoration-none text-muted" style="font-size: 13px;">
                <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
            </a>
            <div class="d-flex align-items-center justify-content-between mt-2">
                <div>
                    <h4 class="fw-bold mb-1" style="color:#0f172a;">Chi tiết đơn hàng #${donHang.maDH}</h4>
                    <c:choose>
                        <c:when test="${donHang.trangThai == 2}">
                            <span class="badge-trangthai badge-da-tra">Đã trả toàn bộ</span>
                        </c:when>
                        <c:when test="${donHang.trangThai == 3}">
                            <span class="badge-trangthai badge-doi-tra-mot-phan">Đổi/trả một phần</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge-trangthai badge-da-giao">Đã giao</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <a href="${pageContext.request.contextPath}/don-hang?action=in-hoa-don&ma=${donHang.maDH}"
                   target="_blank" class="btn btn-primary">
                    <i class="bi bi-printer me-1"></i> In hóa đơn
                </a>
            </div>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert alert-info alert-dismissible fade show" role="alert">
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

        <%-- Bang hien thi danh sach cac san pham trong don hang, kem thao tac tra/doi tung dong --%>
        <div class="card bg-white border mb-4" style="border-radius:12px;">
            <div class="table-responsive">
                <table class="table mb-0">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4">Sách</th>
                        <th class="text-center">Số lượng</th>
                        <th class="text-center">Đã trả</th>
                        <th class="text-end">Đơn giá</th>
                        <th class="text-end">Thành tiền</th>
                        <th class="text-center pe-4">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="ct" items="${donHang.chiTietDonHangs}">
                        <c:set var="daTra" value="${empty ct.soLuongDaTra ? 0 : ct.soLuongDaTra}" />
                        <c:set var="conLai" value="${ct.soLuong - daTra}" />
                        <tr>
                            <td class="ps-4">
                                <div class="fw-semibold">${ct.sach.tenSach}</div>
                                <div class="text-muted" style="font-size:12px;">Mã: ${ct.sach.maSach}</div>
                            </td>
                            <td class="text-center">${ct.soLuong}</td>
                            <td class="text-center">
                                <c:if test="${daTra > 0}"><span class="text-danger fw-semibold">${daTra}</span></c:if>
                                <c:if test="${daTra == 0}">-</c:if>
                            </td>
                            <td class="text-end"><fmt:formatNumber value="${ct.donGia}" pattern="#,##0"/> ₫</td>
                            <td class="text-end fw-bold"><fmt:formatNumber value="${ct.soLuong * ct.donGia}" pattern="#,##0"/> ₫</td>
                            <td class="text-center pe-4">
                                <c:if test="${conLai > 0}">
                                    <button type="button" class="btn btn-sm btn-outline-warning mb-1" style="border-radius:6px;"
                                            data-bs-toggle="modal" data-bs-target="#traModal-${ct.maCTDH}">
                                        <i class="bi bi-arrow-return-left me-1"></i> Trả
                                    </button>
                                    <button type="button" class="btn btn-sm btn-outline-primary mb-1" style="border-radius:6px;"
                                            data-bs-toggle="modal" data-bs-target="#doiModal-${ct.maCTDH}">
                                        <i class="bi bi-arrow-repeat me-1"></i> Đổi
                                    </button>
                                </c:if>
                                <c:if test="${conLai == 0}">
                                    <span class="text-muted" style="font-size:12px;">Đã trả hết</span>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                    <tfoot>
                    <tr class="table-light">
                        <td colspan="4" class="text-end fw-bold py-3">TỔNG CỘNG:</td>
                        <td class="text-end fw-bold py-3" style="font-size:18px; color:#4f46e5;">
                            <fmt:formatNumber value="${donHang.tongTien}" pattern="#,##0"/> ₫
                        </td>
                        <td></td>
                    </tr>
                    </tfoot>
                </table>
            </div>
        </div>

        <%-- Lich su doi/tra cua don hang --%>
        <div class="card bg-white border" style="border-radius:12px;">
            <div class="card-header bg-white fw-bold" style="border-radius:12px 12px 0 0;">Lịch sử đổi / trả</div>
            <div class="table-responsive">
                <table class="table mb-0">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4">Loại</th>
                        <th>Thời gian</th>
                        <th>Sách trả</th>
                        <th>Sách nhận thêm</th>
                        <th class="text-end">Chênh lệch</th>
                        <th class="text-center pe-4">Phiếu</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="ls" items="${lichSuDoiTra}">
                        <tr>
                            <td class="ps-4">
                                <c:if test="${ls.loaiGiaoDich == 'TRA'}"><span class="badge-loai-gd badge-loai-tra">TRẢ</span></c:if>
                                <c:if test="${ls.loaiGiaoDich == 'DOI'}"><span class="badge-loai-gd badge-loai-doi">ĐỔI</span></c:if>
                            </td>
                            <td>
                                <fmt:parseDate value="${ls.ngayThucHien}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedLS" type="both" />
                                <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedLS}" />
                            </td>
                            <td>${ls.chiTietCu.sach.tenSach} <span class="text-muted">(x${ls.soLuongTra})</span></td>
                            <td>
                                <c:if test="${ls.loaiGiaoDich == 'DOI'}">${ls.sachMoi.tenSach} <span class="text-muted">(x${ls.soLuongMoi})</span></c:if>
                                <c:if test="${ls.loaiGiaoDich == 'TRA'}">-</c:if>
                            </td>
                            <td class="text-end fw-semibold ${ls.chenhLechTien < 0 ? 'text-danger' : 'text-success'}">
                                <fmt:formatNumber value="${ls.chenhLechTien}" pattern="#,##0"/> ₫
                            </td>
                            <td class="text-center pe-4">
                                <a href="${pageContext.request.contextPath}/don-hang?action=in-phieu&maDoiTra=${ls.maDoiTra}"
                                   target="_blank" class="btn btn-sm btn-outline-secondary" style="border-radius:6px;">
                                    <i class="bi bi-printer me-1"></i> In phiếu
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty lichSuDoiTra}">
                        <tr><td colspan="6" class="text-center text-muted py-4">Chưa có lần đổi/trả nào.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<%-- Modal Tra hang va Doi hang cho tung dong san pham --%>
<c:forEach var="ct" items="${donHang.chiTietDonHangs}">
    <c:set var="daTra2" value="${empty ct.soLuongDaTra ? 0 : ct.soLuongDaTra}" />
    <c:set var="conLai2" value="${ct.soLuong - daTra2}" />

    <%-- Modal TRA HANG --%>
    <div class="modal fade" id="traModal-${ct.maCTDH}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <form method="post" action="${pageContext.request.contextPath}/don-hang" class="modal-content">
                <input type="hidden" name="action" value="tra">
                <input type="hidden" name="maCTDH" value="${ct.maCTDH}">
                <input type="hidden" name="maDH" value="${donHang.maDH}">
                <div class="modal-header">
                    <h5 class="modal-title">Trả hàng: ${ct.sach.tenSach}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted" style="font-size:13px;">Số lượng còn có thể trả: <strong>${conLai2}</strong> cuốn.</p>
                    <div class="mb-3">
                        <label class="form-label">Số lượng trả</label>
                        <input type="number" class="form-control" name="soLuong" min="1" max="${conLai2}" value="1" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Lý do (không bắt buộc)</label>
                        <textarea class="form-control" name="lyDo" rows="2"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-warning">Xác nhận trả hàng</button>
                </div>
            </form>
        </div>
    </div>

    <%-- Modal DOI HANG --%>
    <div class="modal fade" id="doiModal-${ct.maCTDH}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <form method="post" action="${pageContext.request.contextPath}/don-hang" class="modal-content">
                <input type="hidden" name="action" value="doi">
                <input type="hidden" name="maCTDH" value="${ct.maCTDH}">
                <input type="hidden" name="maDH" value="${donHang.maDH}">
                <div class="modal-header">
                    <h5 class="modal-title">Đổi hàng: ${ct.sach.tenSach}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted" style="font-size:13px;">Số lượng còn có thể đổi: <strong>${conLai2}</strong> cuốn.</p>
                    <div class="mb-3">
                        <label class="form-label">Số lượng trả lại (sách cũ)</label>
                        <input type="number" class="form-control" name="soLuongTra" min="1" max="${conLai2}" value="1" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Đổi sang sách</label>
                        <c:set var="soSachPhuHop" value="0" />
                        <select class="form-select" name="maSachMoi" ${empty sachCoTheDoi ? 'disabled' : ''} required>
                            <c:forEach var="s" items="${sachCoTheDoi}">
                                <c:if test="${s.giaBan >= ct.donGia}">
                                    <c:set var="soSachPhuHop" value="${soSachPhuHop + 1}" />
                                    <option value="${s.maSach}">${s.tenSach} - <fmt:formatNumber value="${s.giaBan}" pattern="#,##0"/> ₫</option>
                                </c:if>
                            </c:forEach>
                        </select>
                        <div class="form-text" style="font-size:12px;">
                            Chỉ hiển thị sách có giá bán ≥ giá sách đang đổi (<fmt:formatNumber value="${ct.donGia}" pattern="#,##0"/> ₫).
                        </div>
                        <c:if test="${soSachPhuHop == 0}">
                            <div class="text-danger mt-1" style="font-size:12.5px;">
                                Hiện không có sách nào đủ điều kiện (giá bằng hoặc cao hơn) để đổi sang. Vui lòng dùng chức năng "Trả" thay thế.
                            </div>
                        </c:if>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Số lượng sách mới</label>
                        <input type="number" class="form-control" name="soLuongMoi" min="1" value="1" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Lý do (không bắt buộc)</label>
                        <textarea class="form-control" name="lyDo" rows="2"></textarea>
                    </div>
                    <div class="alert alert-secondary" style="font-size:12.5px;">
                        Chỉ được đổi sang sách có giá bằng hoặc cao hơn giá sách gốc. Chênh lệch tiền (thu thêm hoặc hoàn lại khách) sẽ được hệ thống tự tính sau khi xác nhận.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary" ${soSachPhuHop == 0 ? 'disabled' : ''}>Xác nhận đổi hàng</button>
                </div>
            </form>
        </div>
    </div>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
