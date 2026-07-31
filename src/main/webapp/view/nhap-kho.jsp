<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>Nhập kho: ${sach.tenSach} - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        label.form-label { font-size: 12.5px; font-weight: 600; color: #475569; }
        .form-control { font-size: 13.5px; border-color: #cbd5e1; border-radius: 6px; }
        .form-control:focus { border-color: #4f46e5; box-shadow: 0 0 0 3px rgba(79,70,229,0.12); }
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
                Nhập kho sách vật lý
            </h4>
            <p class="text-muted" style="font-size: 14px;">Đầu sách: <span class="fw-bold text-dark">${sach.tenSach}</span> (${sach.maSach})</p>
        </div>

        <c:if test="${not empty thongBaoLoi}">
            <div class="alert border-0 mb-4" style="background-color: #fef2f2; color: #991b1b; border-radius: 8px; font-size: 13.5px;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${thongBaoLoi}
            </div>
        </c:if>

        <div class="card bg-white border" style="border-color: #e2e8f0; border-radius: 10px;">
            <div class="card-body p-4">
                <form method="post" action="${pageContext.request.contextPath}/nhap-kho">
                    <input type="hidden" name="maSach" value="${sach.maSach}">

                    <div class="mb-3">
                        <label class="form-label">Danh sách mã Serial *</label>
                        <textarea name="danhSachSerial" class="form-control" rows="10"
                                  placeholder="Nhập mỗi mã Serial trên một dòng hoặc cách nhau bởi dấu phẩy.&#10;VD:&#10;SER001&#10;SER002&#10;SER003" required></textarea>
                        <div class="form-text mt-2">
                            Mỗi dòng tương ứng với 1 cuốn sách vật lý sẽ được thêm vào kho với trạng thái "Có sẵn".
                        </div>
                    </div>

                    <hr class="my-4" style="border-color: #e2e8f0;">

                    <div class="d-flex justify-content-end gap-2">
                        <a href="${pageContext.request.contextPath}/sach" class="btn btn-outline-secondary" style="border-radius: 6px; font-size: 13.5px;">Hủy</a>
                        <button type="submit" class="btn text-white fw-semibold" style="background-color: #10b981; border-radius: 6px; font-size: 13.5px; padding: 8px 22px;">
                            <i class="bi bi-box-seam me-1"></i> Xác nhận nhập kho
                        </button>
                    </div>
                </form>
            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
