<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Giao ca - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
        .checklist-item { padding: 10px 15px; border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 8px; transition: all 0.2s; background: #fff; }
        .checklist-item:hover { border-color: #cbd5e1; background: #f8fafc; cursor: pointer; }
        .form-check-input:checked { background-color: #10b981; border-color: #10b981; }
        .stat-box { background: #f1f5f9; border-radius: 8px; padding: 15px; text-align: center; }
        .stat-value { font-size: 20px; font-weight: 700; color: #0f172a; margin-bottom: 2px; }
        .stat-label { font-size: 11px; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; }
    </style>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid" style="max-width: 850px;">
        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color:#0f172a;"><i class="bi bi-arrow-left-right text-primary me-2"></i> Bàn giao ca làm việc</h4>
                <p class="text-muted mb-0 mt-1" style="font-size: 13.5px;">Hoàn tất các thủ tục dưới đây trước khi kết thúc ca trực.</p>
            </div>
            <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2" style="font-size: 13px;">
                <i class="bi bi-clock-history me-1"></i> Ca hiện tại: 07:00 - 13:00
            </span>
        </div>

        <div class="row g-4">
            <!-- CỘT TRÁI: CHECKLIST & THỐNG KÊ -->
            <div class="col-md-7">
                <!-- Thống kê nhanh -->
                <div class="card bg-white border p-3 shadow-sm mb-4" style="border-radius:12px; border-color:#e2e8f0;">
                    <h6 class="fw-bold mb-3" style="font-size: 14px;">Tổng quan ca trực</h6>
                    <div class="row g-2">
                        <div class="col-4">
                            <div class="stat-box">
                                <div class="stat-value text-primary">12</div>
                                <div class="stat-label">Đơn hàng</div>
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="stat-box">
                                <div class="stat-value text-success">38</div>
                                <div class="stat-label">Sách đã bán</div>
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="stat-box">
                                <div class="stat-value text-warning">01</div>
                                <div class="stat-label">Đổi trả</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Checklist -->
                <div class="card bg-white border p-4 shadow-sm" style="border-radius:12px; border-color:#e2e8f0;">
                    <h6 class="fw-bold mb-1" style="font-size: 14px;">Checklist cuối ca</h6>
                    <p class="text-muted mb-3" style="font-size: 12px;">Đánh dấu các công việc đã hoàn thành</p>

                    <label class="checklist-item d-flex align-items-center">
                        <input class="form-check-input me-3 mt-0" type="checkbox" style="width: 1.2em; height: 1.2em;">
                        <span style="font-size: 13.5px; color: #334155;">Đã vệ sinh, sắp xếp lại quầy thu ngân & kệ sách</span>
                    </label>
                    <label class="checklist-item d-flex align-items-center">
                        <input class="form-check-input me-3 mt-0" type="checkbox" style="width: 1.2em; height: 1.2em;">
                        <span style="font-size: 13.5px; color: #334155;">Đã kiểm tra và tắt các thiết bị điện không cần thiết</span>
                    </label>
                    <label class="checklist-item d-flex align-items-center">
                        <input class="form-check-input me-3 mt-0" type="checkbox" style="width: 1.2em; height: 1.2em;">
                        <span style="font-size: 13.5px; color: #334155;">Đã bàn giao đầy đủ máy POS, máy quét mã vạch</span>
                    </label>
                    <label class="checklist-item d-flex align-items-center mb-0">
                        <input class="form-check-input me-3 mt-0" type="checkbox" style="width: 1.2em; height: 1.2em;">
                        <span style="font-size: 13.5px; color: #334155;">Hệ thống phần mềm không báo lỗi tồn kho</span>
                    </label>
                </div>
            </div>

            <!-- CỘT PHẢI: THÔNG TIN BÀN GIAO & NÚT CHỐT -->
            <div class="col-md-5">
                <div class="card bg-white border p-4 shadow-sm h-100 d-flex flex-column" style="border-radius:12px; border-color:#e2e8f0;">
                    <h6 class="fw-bold mb-3" style="font-size: 14px;">Chi tiết bàn giao</h6>

                    <div class="mb-3">
                        <label class="form-label text-muted" style="font-size: 12px; font-weight: 600;">Người giao ca</label>
                        <input type="text" class="form-control form-control-sm bg-light" value="${sessionScope.currentUser.tenNV != null ? sessionScope.currentUser.tenNV : 'Nguyễn Văn Admin'}" readonly>
                    </div>

                    <div class="mb-3">
                        <label class="form-label text-muted" style="font-size: 12px; font-weight: 600;">Nhân viên nhận ca tiếp theo <span class="text-danger">*</span></label>
                        <select id="nguoiNhanCa" class="form-select form-select-sm">
                            <option value="">-- Chọn nhân viên nhận ca --</option>
                            <option value="Trần Thị Bình">Trần Thị Bình</option>
                            <option value="Lê Văn Cường">Lê Văn Cường</option>
                            <option value="Phạm Thị Dung">Phạm Thị Dung</option>
                            <option value="Lý Văn Long">Lý Văn Long</option>
                        </select>
                    </div>

                    <div class="mb-auto">
                        <label class="form-label text-muted" style="font-size: 12px; font-weight: 600;">Ghi chú bàn giao (Công việc tồn đọng...)</label>
                        <textarea id="ghiChu" class="form-control form-control-sm" rows="5" placeholder="Ví dụ: Đơn hàng mã #1024 khách hẹn chiều ra lấy, nhớ giao sách cho khách..."></textarea>
                    </div>

                    <hr class="my-4">
                    <button type="button" onclick="xuLyGiaoCa()" class="btn btn-primary w-100 fw-semibold py-2" style="border-radius: 8px; background-color: #4f46e5;">
                        <i class="bi bi-box-arrow-right me-2"></i> Xác nhận & Đăng xuất
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function xuLyGiaoCa() {
        const nguoiNhan = document.getElementById('nguoiNhanCa').value;
        const checkboxes = document.querySelectorAll('.form-check-input');

        // Kiểm tra xem đã chọn người nhận ca chưa
        if (!nguoiNhan) {
            alert("Vui lòng chọn Nhân viên nhận ca tiếp theo!");
            document.getElementById('nguoiNhanCa').focus();
            return;
        }

        // Đếm số lượng checklist đã check
        let checkedCount = 0;
        checkboxes.forEach(cb => {
            if (cb.checked) checkedCount++;
        });

        // Nhắc nhở nếu chưa check đủ checklist
        if (checkedCount < checkboxes.length) {
            const xacNhanChecklist = confirm("Bạn chưa hoàn thành toàn bộ Checklist cuối ca. Vẫn muốn tiếp tục bàn giao?");
            if (!xacNhanChecklist) return;
        }

        // Báo thành công và Đăng xuất
        alert("Bàn giao ca cho " + nguoiNhan + " thành công! Hệ thống sẽ tự động đăng xuất.");
        window.location.href = "${pageContext.request.contextPath}/dashboard?action=logout";
    }
</script>
</body>
</html>