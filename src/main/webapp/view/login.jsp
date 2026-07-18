<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>Đăng nhập hệ thống - Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f1f5f9; /* Nền xám tinh tươm */
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }
    </style>
</head>
<body class="d-flex align-items-center justify-content-center" style="height: 100vh;">

<div class="card border-0 shadow-sm" style="width: 420px; border-radius: 12px; background-color: #ffffff; border: 1px solid #e2e8f0 !important;">
    <div class="card-body p-5">
        <div class="text-center mb-4">
            <div class="d-inline-flex p-3 rounded-circle mb-2" style="background-color: #f1f5f9; color: #475569;">
                <i class="bi bi-shield-lock-fill" style="font-size: 2rem;"></i>
            </div>
            <h4 class="fw-bold mt-2" style="color: #0f172a; letter-spacing: -0.02em;">Đăng nhập Hệ thống</h4>
            <p class="text-muted" style="font-size: 13px;">Cổng thông tin nội bộ dành cho nhân viên</p>
        </div>

        <c:if test="${not empty requestScope.errorMessage}">
            <div class="alert alert-danger d-flex align-items-center py-2 border-0" role="alert" style="background-color: #fef2f2; color: #991b1b; border-radius: 6px;">
                <i class="bi bi-exclamation-triangle-fill me-2" style="font-size: 14px;"></i>
                <div style="font-size: 13px;">${requestScope.errorMessage}</div>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="POST">
            <div class="mb-3">
                <label class="form-label small fw-bold" style="color: #475569;">TÊN ĐĂNG NHẬP</label>
                <div class="input-group" style="border: 1px solid #cbd5e1; border-radius: 6px; overflow: hidden;">
                    <span class="input-group-text bg-white border-0 text-muted"><i class="bi bi-person"></i></span>
                    <input type="text" name="username" class="form-control border-0" required placeholder="Tài khoản của bạn" style="font-size: 14px; box-shadow: none;">
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label small fw-bold" style="color: #475569;">MẬT KHẨU</label>
                <div class="input-group" style="border: 1px solid #cbd5e1; border-radius: 6px; overflow: hidden;">
                    <span class="input-group-text bg-white border-0 text-muted"><i class="bi bi-key"></i></span>
                    <input type="password" name="password" class="form-control border-0" required placeholder="Mật khẩu" style="font-size: 14px; box-shadow: none;">
                </div>
            </div>

            <button type="submit" class="btn text-white w-100 fw-semibold py-2" style="background-color: #4f46e5; border-radius: 6px; font-size: 14px; transition: 0.2s;">
                Xác nhận đăng nhập
            </button>
            <p class="text-muted text-center mt-3 mb-0" style="font-size: 12px;">
                Tài khoản mẫu DB: <strong>admin</strong> / <strong>123456</strong>
            </p>
        </form>
    </div>
</div>

</body>
</html>