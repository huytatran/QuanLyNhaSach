<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>${dangSua ? 'Sửa sách' : 'Thêm sách'} - Portal.BookStore</title>
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
            <a href="${pageContext.request.contextPath}/sach" class="text-decoration-none" style="font-size: 13px; color: #64748b;">
                <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách sách
            </a>
            <h4 class="fw-bold mt-2 mb-0" style="color: #0f172a;">
                ${dangSua ? 'Sửa thông tin sách' : 'Thêm sách mới'}
            </h4>
        </div>

        <c:if test="${not empty thongBaoLoi}">
            <div class="alert border-0 mb-4" style="background-color: #fef2f2; color: #991b1b; border-radius: 8px; font-size: 13.5px;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${thongBaoLoi}
            </div>
        </c:if>

        <div class="card bg-white border" style="border-color: #e2e8f0; border-radius: 10px;">
            <div class="card-body p-4">
                <form method="post" action="${pageContext.request.contextPath}/sach">
                    <input type="hidden" name="mode" value="${dangSua ? 'sua' : 'them'}">
                    <input type="hidden" name="action" value="save">

                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label">Mã sách *</label>
                            <input type="text" name="maSach" value="${sach.maSach}" class="form-control"
                                   placeholder="VD: S011" required
                                   <c:if test="${dangSua}">readonly</c:if>>
                        </div>
                        <div class="col-md-8">
                            <label class="form-label">Tên sách *</label>
                            <input type="text" name="tenSach" value="${sach.tenSach}" class="form-control" placeholder="Nhập tên sách" required>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Năm xuất bản</label>
                            <input type="number" name="namXB" value="${sach.namXB}" class="form-control" placeholder="VD: 2020">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Giá bán (₫) *</label>
                            <input type="number" step="1000" min="0" name="giaBan" value="${sach.giaBan}" class="form-control" placeholder="VD: 75000" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Thể loại *</label>
                            <select name="maTL" class="form-select" required>
                                <option value="">-- Chọn thể loại --</option>
                                <c:forEach var="tl" items="${dsTheLoai}">
                                    <option value="${tl.maTL}" ${sach.theLoai.maTL == tl.maTL ? 'selected' : ''}>${tl.tenTL}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Nhà xuất bản *</label>
                            <select name="maNXB" class="form-select" required>
                                <option value="">-- Chọn nhà xuất bản --</option>
                                <c:forEach var="nxb" items="${dsNXB}">
                                    <option value="${nxb.maNXB}" ${sach.nhaXuatBan.maNXB == nxb.maNXB ? 'selected' : ''}>${nxb.tenNXB}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Tác giả chính</label>
                            <select name="maTacGia" class="form-select">
                                <option value="">-- Không chọn --</option>
                                <c:forEach var="tg" items="${dsTacGia}">
                                    <option value="${tg.maTG}" ${not empty tacGiaChinh and tacGiaChinh.maTG == tg.maTG ? 'selected' : ''}>${tg.tenTG}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-8">
                            <label class="form-label">Bộ sách (nếu có)</label>
                            <select name="maBoSach" id="selectBoSach" class="form-select">
                                <option value="">-- Sách độc lập, không thuộc bộ --</option>
                                <c:forEach var="bs" items="${dsBoSach}">
                                    <option value="${bs.maBoSach}" ${sach.boSach.maBoSach == bs.maBoSach ? 'selected' : ''}>${bs.tenBoSach}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Số phần trong bộ</label>
                            <input type="number" min="1" name="soPhan" id="inputSoPhan" value="${sach.soPhan}" class="form-control" placeholder="VD: 1"
                                   <c:if test="${empty sach.boSach}">disabled</c:if>>
                        </div>
                    </div>

                    <hr class="my-4" style="border-color: #e2e8f0;">

                    <div class="d-flex justify-content-end gap-2">
                        <a href="${pageContext.request.contextPath}/sach" class="btn btn-outline-secondary" style="border-radius: 6px; font-size: 13.5px;">Hủy</a>
                        <button type="submit" class="btn text-white fw-semibold" style="background-color: #4f46e5; border-radius: 6px; font-size: 13.5px; padding: 8px 22px;">
                            <i class="bi bi-check-lg me-1"></i> Lưu sách
                        </button>
                    </div>
                </form>
            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Chi cho nhap "So phan" khi da chon 1 Bo Sach cu the
    const selectBoSach = document.getElementById('selectBoSach');
    const inputSoPhan = document.getElementById('inputSoPhan');
    selectBoSach.addEventListener('change', function () {
        inputSoPhan.disabled = (this.value === '');
        if (this.value === '') inputSoPhan.value = '';
    });
</script>
</body>
</html>
