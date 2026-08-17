<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>Quản lý Khách hàng - Portal.BookStore</title>
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
                <h4 class="fw-bold mb-0" style="color:#0f172a;">Quản lý Khách hàng</h4>
                <p class="text-muted mb-0" style="font-size:13px;">Khách hàng mua trực tiếp tại quầy (bán offline, không giao hàng).</p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/khachhang?action=xuatExcel${not empty tuKhoa ? '&q='.concat(tuKhoa) : ''}${not empty trangThaiLoc and trangThaiLoc != '' ? '&trangThai='.concat(trangThaiLoc) : ''}"
                   class="btn text-white fw-semibold shadow-sm"
                   style="background-color:#16a34a;border-radius:8px;font-size:13.5px;padding:10px 18px;"
                   title="Xuất danh sách khách hàng hiện tại ra file Excel">
                    <i class="bi bi-file-earmark-excel me-1"></i> Xuất Excel
                </a>
                <a href="${pageContext.request.contextPath}/khachhang?action=new" class="btn text-white fw-semibold"
                   style="background-color:#4f46e5;border-radius:8px;font-size:13.5px;padding:10px 18px;">
                    <i class="bi bi-person-plus-fill me-1"></i> Thêm khách hàng
                </a>
            </div>
        </div>

        <c:if test="${param.thanhCong == '1'}">
            <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13.5px;">Lưu khách hàng thành công.</div>
        </c:if>
        <c:if test="${param.xoaThanhCong == '1'}">
            <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13.5px;">Đã cập nhật trạng thái ngừng hoạt động cho khách hàng.</div>
        </c:if>
        <c:if test="${not empty param.loiXoa}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">${param.loiXoa}</div>
        </c:if>
        <c:if test="${not empty thongBaoLoi}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">${thongBaoLoi}</div>
        </c:if>

        <div class="card bg-white border mb-3" style="border-color:#e2e8f0;border-radius:10px;">
            <div class="card-body p-3">
                <form method="get" action="${pageContext.request.contextPath}/khachhang" class="d-flex flex-wrap gap-2 align-items-center">
                    <div class="input-group" style="max-width:360px;border:1px solid #cbd5e1;border-radius:6px;overflow:hidden;">
                        <span class="input-group-text bg-white border-0 text-muted"><i class="bi bi-search"></i></span>
                        <input type="text" name="q" value="${tuKhoa}" class="form-control border-0" placeholder="Tìm theo tên hoặc số điện thoại..." style="font-size:13.5px;box-shadow:none;">
                    </div>
                    <select name="trangThai" class="form-select" style="max-width:180px;font-size:13px;border-color:#cbd5e1;border-radius:6px;">
                        <option value=""  ${trangThaiLoc == ''  ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="1" ${trangThaiLoc == '1' ? 'selected' : ''}>Đang hoạt động</option>
                        <option value="0" ${trangThaiLoc == '0' ? 'selected' : ''}>Ngừng hoạt động</option>
                    </select>
                    <button type="submit" class="btn text-white" style="background:#4f46e5;border-radius:6px;font-size:13px;">
                        <i class="bi bi-funnel me-1"></i>Lọc
                    </button>
                    <c:if test="${not empty tuKhoa or (not empty trangThaiLoc and trangThaiLoc != '')}">
                        <a href="${pageContext.request.contextPath}/khachhang" class="btn btn-link text-decoration-none" style="font-size:13px;color:#64748b;">
                            <i class="bi bi-x-circle me-1"></i>Xóa lọc
                        </a>
                    </c:if>
                </form>
            </div>
        </div>

        <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
            <div class="table-responsive">
                <table class="table mb-0">
                    <thead>
                    <tr>
                        <th class="ps-3">Mã</th>
                        <th>Họ tên</th>
                        <th>SĐT</th>
                        <th>Email</th>
                        <th>Địa chỉ mặc định</th>
                        <th class="text-end">Điểm tích lũy</th>
                        <th class="text-center">Trạng thái</th>
                        <th class="text-end pe-3">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="kh" items="${danhSachKH}">
                        <tr>
                            <td class="ps-3 fw-semibold">KH${kh.maKH}</td>
                            <td>${kh.tenKH}</td>
                            <td>${kh.sdt}</td>
                            <td>${kh.email}</td>
                            <td style="max-width:220px;">
                                <c:choose>
                                    <c:when test="${not empty diaChiMacDinhMap[kh.maKH]}">
                                        <span class="text-truncate d-inline-block" style="max-width:220px;font-size:12.5px;color:#475569;">${diaChiMacDinhMap[kh.maKH]}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted" style="font-size:12px;">Chưa có</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end">
                                <span class="badge rounded-pill" style="background:#eef2ff;color:#4338ca;">${kh.diemTichLuy}</span>
                            </td>
                            <td class="text-center">
                                <form method="post" action="${pageContext.request.contextPath}/khachhang" class="d-inline-block toggle-form">
                                    <input type="hidden" name="action" value="toggleTrangThai">
                                    <input type="hidden" name="ma" value="${kh.maKH}">
                                    <input type="hidden" name="page" value="${trangHienTai}">
                                    <input type="hidden" name="q" value="${tuKhoa}">
                                    <input type="hidden" name="trangThai" value="${trangThaiLoc}">
                                    <div class="form-check form-switch d-flex justify-content-center m-0">
                                        <input class="form-check-input toggle-submit" type="checkbox" role="switch"
                                               style="width:2.4em;height:1.3em;cursor:pointer;"
                                            ${kh.trangThai == false ? '' : 'checked'}
                                               title="${kh.trangThai == false ? 'Đang ngừng hoạt động - bấm để kích hoạt lại' : 'Đang hoạt động - bấm để ngừng hoạt động'}">
                                    </div>
                                </form>
                            </td>
                            <td class="text-end pe-3">
                                <a href="${pageContext.request.contextPath}/khachhang?action=edit&ma=${kh.maKH}" class="btn btn-sm btn-outline-secondary me-1" style="border-radius:6px;" title="Sửa / xem địa chỉ">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <button type="button" class="btn btn-sm btn-outline-danger" style="border-radius:6px;" title="Ngừng hoạt động"
                                        onclick="xoaKH(${kh.maKH}, '${kh.tenKH}')">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty danhSachKH}">
                        <tr><td colspan="8" class="text-center text-muted py-5">Không có khách hàng nào phù hợp.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>

            <c:if test="${tongSoTrang > 1}">
                <div class="d-flex justify-content-between align-items-center p-3" style="border-top:1px solid #e2e8f0;">
                    <span class="text-muted" style="font-size:12.5px;">
                        Trang ${trangHienTai}/${tongSoTrang} — tổng ${tongSoKhach} khách hàng
                    </span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0">
                            <c:url var="urlTruoc" value="/khachhang">
                                <c:param name="page" value="${trangHienTai - 1}"/>
                                <c:if test="${not empty tuKhoa}"><c:param name="q" value="${tuKhoa}"/></c:if>
                                <c:if test="${not empty trangThaiLoc and trangThaiLoc != ''}"><c:param name="trangThai" value="${trangThaiLoc}"/></c:if>
                            </c:url>
                            <li class="page-item ${trangHienTai == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="${urlTruoc}">‹ Trước</a>
                            </li>
                            <c:forEach var="i" begin="1" end="${tongSoTrang}">
                                <c:url var="urlTrang" value="/khachhang">
                                    <c:param name="page" value="${i}"/>
                                    <c:if test="${not empty tuKhoa}"><c:param name="q" value="${tuKhoa}"/></c:if>
                                    <c:if test="${not empty trangThaiLoc and trangThaiLoc != ''}"><c:param name="trangThai" value="${trangThaiLoc}"/></c:if>
                                </c:url>
                                <li class="page-item ${i == trangHienTai ? 'active' : ''}">
                                    <a class="page-link" href="${urlTrang}"
                                       style="${i == trangHienTai ? 'background-color:#4f46e5;border-color:#4f46e5;' : 'color:#0f172a;'}">${i}</a>
                                </li>
                            </c:forEach>
                            <c:url var="urlSau" value="/khachhang">
                                <c:param name="page" value="${trangHienTai + 1}"/>
                                <c:if test="${not empty tuKhoa}"><c:param name="q" value="${tuKhoa}"/></c:if>
                                <c:if test="${not empty trangThaiLoc and trangThaiLoc != ''}"><c:param name="trangThai" value="${trangThaiLoc}"/></c:if>
                            </c:url>
                            <li class="page-item ${trangHienTai == tongSoTrang ? 'disabled' : ''}">
                                <a class="page-link" href="${urlSau}">Sau ›</a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </c:if>
        </div>
    </div>
</div>

<form id="formXoa" method="post" action="${pageContext.request.contextPath}/khachhang">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="ma" id="maXoa">
</form>
<script>
    function xoaKH(ma, ten) {
        if (confirm('Ngừng hoạt động khách hàng "' + ten + '"?\nDữ liệu và lịch sử đơn hàng của khách vẫn được giữ nguyên, chỉ ẩn khỏi danh sách đang hoạt động.')) {
            document.getElementById('maXoa').value = ma;
            document.getElementById('formXoa').submit();
        }
    }

    // Tu dong submit form doi trang thai ngay khi bam vao cong tac
    document.querySelectorAll('.toggle-submit').forEach(function (chk) {
        chk.addEventListener('change', function () {
            this.closest('.toggle-form').submit();
        });
    });
</script>
</body>
</html>
