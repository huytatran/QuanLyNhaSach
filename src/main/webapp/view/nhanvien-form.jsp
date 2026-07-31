<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>${dangSua ? 'Sửa nhân viên' : 'Thêm nhân viên'} - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        label.form-label { font-size: 12.5px; font-weight: 600; color: #475569; }
        .form-control, .form-select { font-size: 13.5px; border-color: #cbd5e1; border-radius: 6px; }
    </style>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid" style="max-width:720px;">
        <div class="mb-4">
            <a href="${pageContext.request.contextPath}/nhanvien" class="text-decoration-none" style="font-size:13px;color:#64748b;">
                <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
            </a>
            <h4 class="fw-bold mt-2 mb-0" style="color:#0f172a;">${dangSua ? 'Sửa nhân viên' : 'Thêm nhân viên mới'}</h4>
        </div>

        <c:if test="${not empty thongBaoLoi}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">${thongBaoLoi}</div>
        </c:if>

        <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:10px;">
            <div class="card-body p-4">
                <form method="post" action="${pageContext.request.contextPath}/nhanvien">
                    <input type="hidden" name="mode" value="${dangSua ? 'sua' : 'them'}">
                    <input type="hidden" name="maNV" value="${nhanVien.maNV}">

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Họ tên *</label>
                            <input type="text" name="tenNV" value="${nhanVien.tenNV}" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">SĐT</label>
                            <input type="text" name="sdt" value="${nhanVien.sdt}" class="form-control">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" value="${nhanVien.email}" class="form-control">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Vai trò *</label>
                            <select name="vaiTroNV" class="form-select" required>
                                <option value="0" ${nhanVien.vaiTroNV != 1 ? 'selected' : ''}>Nhân viên</option>
                                <option value="1" ${nhanVien.vaiTroNV == 1 ? 'selected' : ''}>Admin</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Địa chỉ</label>
                            <input type="text" name="diaChi" value="${nhanVien.diaChi}" class="form-control">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Tài khoản *</label>
                            <input type="text" name="taiKhoan" value="${nhanVien.taiKhoan}" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Mật khẩu ${dangSua ? '(để trống nếu giữ nguyên)' : '*'}</label>
                            <input type="password" name="matKhau" class="form-control" ${dangSua ? '' : 'required'}>
                        </div>
                    </div>

                    <hr class="my-4" style="border-color:#e2e8f0;">
                    <div class="d-flex justify-content-end gap-2">
                        <a href="${pageContext.request.contextPath}/nhanvien" class="btn btn-outline-secondary" style="border-radius:6px;">Hủy</a>
                        <button type="submit" class="btn text-white fw-semibold" style="background:#4f46e5;border-radius:6px;">
                            <i class="bi bi-check-lg me-1"></i> Lưu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
</body>
</html>
