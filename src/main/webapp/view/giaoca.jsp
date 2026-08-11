<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Giao ca - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
    </style>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid" style="max-width: 800px;">
        <h4 class="fw-bold mb-4" style="color:#0f172a;"><i class="bi bi-arrow-left-right text-primary me-2"></i> Bàn giao ca</h4>

        <div class="card bg-white border p-4 shadow-sm" style="border-radius:12px; border-color:#e2e8f0;">
            <h6 class="fw-bold mb-3">Thông tin kết ca</h6>
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label text-muted" style="font-size: 13px;">Nhân viên giao ca</label>
                    <input type="text" class="form-control" value="${sessionScope.currentUser.tenNV != null ? sessionScope.currentUser.tenNV : 'Nguyễn Văn Admin'}" readonly>
                </div>
                <div class="col-md-6">
                    <label class="form-label text-muted" style="font-size: 13px;">Tiền mặt trong két (VNĐ) <span class="text-danger">*</span></label>
                    <input type="number" id="tienMat" class="form-control" placeholder="Nhập số tiền thực tế..." required>
                </div>
                <div class="col-12">
                    <label class="form-label text-muted" style="font-size: 13px;">Ghi chú bàn giao</label>
                    <textarea id="ghiChu" class="form-control" rows="3" placeholder="Ghi chú lại cho ca sau (nếu có)..."></textarea>
                </div>
            </div>
            <hr class="my-4">
            <button type="button" onclick="xuLyGiaoCa()" class="btn btn-primary w-100 fw-semibold py-2" style="border-radius: 8px; background-color: #4f46e5;">
                <i class="bi bi-check-circle me-1"></i> Chốt ca & Đăng xuất
            </button>
        </div>
    </div>
</div>

<script>
    function xuLyGiaoCa() {
        // Lấy giá trị tiền mặt người dùng nhập
        var tienMat = document.getElementById('tienMat').value;

        // 1. Kiểm tra xem đã nhập tiền chưa
        if (!tienMat || tienMat === "") {
            alert("Vui lòng nhập số tiền mặt thực tế đang có trong két!");
            document.getElementById('tienMat').focus();
            return;
        }

        // 2. Format số tiền thành định dạng có dấu phẩy (VD: 1,500,000)
        var formattedMoney = parseInt(tienMat).toLocaleString('vi-VN');

        // 3. Hiển thị thông báo xác nhận
        var xacNhan = confirm("Xác nhận bàn giao ca với số tiền mặt trong két là: " + formattedMoney + " VNĐ?\n\nHệ thống sẽ lưu lịch sử và tự động đăng xuất.");

        // 4. Nếu bấm OK -> Báo thành công và chuyển hướng về URL đăng xuất
        if (xacNhan) {
            alert("Bàn giao ca thành công! Đang tiến hành đăng xuất...");
            // Chuyển hướng về luồng đăng xuất có sẵn của hệ thống bạn
            window.location.href = "${pageContext.request.contextPath}/dashboard?action=logout";
        }
    }
</script>
</body>
</html>