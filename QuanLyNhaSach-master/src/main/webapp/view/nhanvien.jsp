<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>Quản lý Nhân viên - Portal.BookStore</title>
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
                <h4 class="fw-bold mb-0" style="color:#0f172a;">Quản lý Nhân viên</h4>
                <p class="text-muted mb-0" style="font-size:13px;">Chỉ Admin mới truy cập được trang này.</p>
            </div>
            <a href="${pageContext.request.contextPath}/nhanvien?action=new" class="btn text-white fw-semibold"
               style="background-color:#4f46e5;border-radius:8px;font-size:13.5px;padding:10px 18px;">
                <i class="bi bi-plus-lg me-1"></i> Thêm nhân viên
            </a>
        </div>

        <c:if test="${param.thanhCong == '1'}">
            <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13.5px;">Lưu nhân viên thành công.</div>
        </c:if>
        <c:if test="${param.xoaThanhCong == '1'}">
            <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13.5px;">Xóa nhân viên thành công.</div>
        </c:if>
        <c:if test="${not empty param.loiXoa}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">${param.loiXoa}</div>
        </c:if>
        <c:if test="${not empty thongBaoLoi}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">${thongBaoLoi}</div>
        </c:if>

        <div class="card bg-white border mb-3" style="border-color:#e2e8f0;border-radius:10px;">
            <div class="card-body p-3">
                <form method="get" class="d-flex gap-2">
                    <input type="text" name="q" value="${tuKhoa}" class="form-control" placeholder="Tìm tên / tài khoản / SĐT..." style="max-width:360px;font-size:13.5px;">
                    <button class="btn btn-outline-secondary" style="font-size:13px;border-radius:6px;">Tìm</button>
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
                        <th>Tài khoản</th>
                        <th>SĐT</th>
                        <th>Email</th>
                        <th>Vai trò</th>
                        <th class="text-end pe-3">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="nv" items="${danhSachNV}">
                        <tr>
                            <td class="ps-3 fw-semibold">NV${nv.maNV}</td>
                            <td>${nv.tenNV}</td>
                            <td>${nv.taiKhoan}</td>
                            <td>${nv.sdt}</td>
                            <td>${nv.email}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${nv.vaiTroNV == 1}"><span class="badge rounded-pill" style="background:#eef2ff;color:#4338ca;">Admin</span></c:when>
                                    <c:otherwise><span class="badge rounded-pill" style="background:#f1f5f9;color:#475569;">Nhân viên</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end pe-3">
                                <a href="${pageContext.request.contextPath}/nhanvien?action=edit&ma=${nv.maNV}" class="btn btn-sm btn-outline-secondary me-1" style="border-radius:6px;"><i class="bi bi-pencil"></i></a>
                                <button type="button" class="btn btn-sm btn-outline-danger" style="border-radius:6px;"
                                        onclick="xoaNV(${nv.maNV}, '${nv.tenNV}')"><i class="bi bi-trash"></i></button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty danhSachNV}">
                        <tr><td colspan="7" class="text-center text-muted py-5">Không có nhân viên.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<form id="formXoa" method="post" action="${pageContext.request.contextPath}/nhanvien">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="ma" id="maXoa">
</form>
<script>
    function xoaNV(ma, ten) {
        if (confirm('Xóa nhân viên "' + ten + '"?')) {
            document.getElementById('maXoa').value = ma;
            document.getElementById('formXoa').submit();
        }
    }
</script>
</body>
</html>
