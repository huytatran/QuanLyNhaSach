<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>Quản lý Sách - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        table.table thead th { font-size: 12px; text-transform: uppercase; letter-spacing: 0.04em; color: #64748b; border-bottom: 1px solid #e2e8f0; background-color: #f8fafc; }
        table.table td { font-size: 13.5px; vertical-align: middle; color: #0f172a; }
        .badge-ton-het { background-color: #fef2f2; color: #991b1b; }
        .badge-ton-thap { background-color: #fffbeb; color: #92400e; }
        .badge-ton-du { background-color: #f0fdf4; color: #166534; }
    </style>
</head>
<body>

<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color: #0f172a;">Quản lý Sách</h4>
                <p class="text-muted mb-0" style="font-size: 13px;">Danh sách đầu sách và tồn kho hiện tại.</p>
            </div>
            <a href="${pageContext.request.contextPath}/sach?action=new" class="btn text-white fw-semibold"
               style="background-color: #4f46e5; border-radius: 8px; font-size: 13.5px; padding: 10px 18px;">
                <i class="bi bi-plus-lg me-1"></i> Thêm sách mới
            </a>
        </div>

        <c:if test="${param.thanhCong == '1'}">
            <div class="alert border-0 mb-4" style="background-color: #f0fdf4; color: #166534; border-radius: 8px; font-size: 13.5px;">
                <i class="bi bi-check-circle-fill me-2"></i>Lưu thông tin sách thành công.
            </div>
        </c:if>
        <c:if test="${param.nhapKhoThanhCong == '1'}">
            <div class="alert border-0 mb-4" style="background-color: #f0fdf4; color: #166534; border-radius: 8px; font-size: 13.5px;">
                <i class="bi bi-box-seam-fill me-2"></i>Đã nhập kho thành công.
            </div>
        </c:if>
        <c:if test="${param.xoaThanhCong == '1'}">
            <div class="alert border-0 mb-4" style="background-color: #f0fdf4; color: #166534; border-radius: 8px; font-size: 13.5px;">
                <i class="bi bi-check-circle-fill me-2"></i>Xóa sách thành công.
            </div>
        </c:if>
        <c:if test="${not empty param.loiXoa}">
            <div class="alert border-0 mb-4" style="background-color: #fef2f2; color: #991b1b; border-radius: 8px; font-size: 13.5px;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${param.loiXoa}
            </div>
        </c:if>

        <div class="card bg-white border mb-3" style="border-color: #e2e8f0; border-radius: 10px;">
            <div class="card-body p-3">
                <form method="get" action="${pageContext.request.contextPath}/sach" class="d-flex gap-2">
                    <div class="input-group" style="max-width: 360px; border: 1px solid #cbd5e1; border-radius: 6px; overflow: hidden;">
                        <span class="input-group-text bg-white border-0 text-muted"><i class="bi bi-search"></i></span>
                        <input type="text" name="q" value="${tuKhoa}" class="form-control border-0" placeholder="Tìm theo tên hoặc mã sách..." style="font-size: 13.5px; box-shadow: none;">
                    </div>
                    <button type="submit" class="btn btn-outline-secondary" style="border-radius: 6px; font-size: 13px;">Tìm</button>
                    <c:if test="${not empty tuKhoa}">
                        <a href="${pageContext.request.contextPath}/sach" class="btn btn-link text-decoration-none" style="font-size: 13px;">Xóa lọc</a>
                    </c:if>
                </form>
            </div>
        </div>

        <div class="card bg-white border" style="border-color: #e2e8f0; border-radius: 10px;">
            <div class="table-responsive">
                <table class="table mb-0">
                    <thead>
                    <tr>
                        <th class="ps-3">Mã sách</th>
                        <th>Tên sách</th>
                        <th>Thể loại</th>
                        <th>Nhà xuất bản</th>
                        <th>Năm XB</th>
                        <th class="text-end">Giá bán</th>
                        <th class="text-center">Tồn kho</th>
                        <th class="text-end pe-3">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="s" items="${danhSachSach}">
                        <c:set var="ton" value="${empty tonKhoMap[s.maSach] ? 0 : tonKhoMap[s.maSach]}" />
                        <tr>
                            <td class="ps-3"><span class="fw-semibold">${s.maSach}</span></td>
                            <td>
                                    ${s.tenSach}
                                <c:if test="${not empty s.boSach}">
                                    <span class="badge rounded-pill" style="background-color:#eef2ff;color:#4338ca;font-size:10.5px;font-weight:600;">
                                        ${s.boSach.tenBoSach} <c:if test="${not empty s.soPhan}"> · #${s.soPhan}</c:if>
                                    </span>
                                </c:if>
                            </td>
                            <td>${s.theLoai.tenTL}</td>
                            <td>${s.nhaXuatBan.tenNXB}</td>
                            <td>${s.namXB}</td>
                            <td class="text-end"><fmt:formatNumber value="${s.giaBan}" pattern="#,##0"/> ₫</td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${ton == 0}">
                                        <span class="badge badge-ton-het rounded-pill px-2 py-1">Hết hàng</span>
                                    </c:when>
                                    <c:when test="${ton lt 5}">
                                        <span class="badge badge-ton-thap rounded-pill px-2 py-1">${ton} cuốn</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-ton-du rounded-pill px-2 py-1">${ton} cuốn</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end pe-3">
                                <a href="${pageContext.request.contextPath}/nhap-kho?maSach=${s.maSach}"
                                   class="btn btn-sm btn-outline-success me-1" style="border-radius: 6px;" title="Nhập kho">
                                    <i class="bi bi-box-seam"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/sach?action=edit&ma=${s.maSach}"
                                   class="btn btn-sm btn-outline-secondary me-1" style="border-radius: 6px;" title="Sửa">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <button type="button" class="btn btn-sm btn-outline-danger" style="border-radius: 6px;" title="Xóa"
                                        onclick="xacNhanXoa('${s.maSach}', '${s.tenSach}')">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty danhSachSach}">
                        <tr>
                            <td colspan="8" class="text-center text-muted py-5" style="font-size: 13.5px;">
                                <i class="bi bi-inbox fs-3 d-block mb-2"></i>
                                Không có dữ liệu sách nào phù hợp.
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<!-- Form ẩn phục vụ xóa -->
<form id="formXoa" method="post" action="${pageContext.request.contextPath}/sach">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="ma" id="maSachXoa">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function xacNhanXoa(maSach, tenSach) {
        if (confirm('Xóa sách "' + tenSach + '" (' + maSach + ')?\nChỉ xóa được nếu sách chưa từng nhập kho hoặc bán ra.')) {
            document.getElementById('maSachXoa').value = maSach;
            document.getElementById('formXoa').submit();
        }
    }
</script>
</body>
</html>
