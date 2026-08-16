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
                <i class="bi bi-clock-history me-1"></i> <span id="textCaHienTai">Đang tải giờ...</span>
            </span>
        </div>

        <div class="row g-4">
            <!-- CỘT TRÁI: CHECKLIST -->
            <div class="col-md-7">
                <div class="card bg-white border p-4 shadow-sm h-100" style="border-radius:12px; border-color:#e2e8f0;">
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

            <!-- CỘT PHẢI: THÔNG TIN BÀN GIAO -->
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
                    <!-- NÚT NÀY ĐÃ ĐƯỢC ĐỔI THÀNH GỌI HÀM MỞ MODAL XÁC MINH -->
                    <button type="button" onclick="kiemTraVaMoXacMinh()" class="btn btn-primary w-100 fw-semibold py-2" style="border-radius: 8px; background-color: #4f46e5;">
                        <i class="bi bi-box-arrow-right me-2"></i> Xác nhận & Đăng xuất
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ============================================== -->
<!-- MODAL POPUP: XÁC MINH TÀI KHOẢN NGƯỜI NHẬN CA -->
<!-- ============================================== -->
<div class="modal fade" id="modalXacMinh" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content" style="border-radius: 12px; border: none; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
            <div class="modal-header border-0 pb-0">
                <h6 class="modal-title fw-bold" style="color: #0f172a;"><i class="bi bi-shield-lock text-primary me-2"></i>Xác minh người nhận ca</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body pt-3">
                <p class="text-muted mb-3" style="font-size: 13px;">
                    Nhân viên <strong id="tenNguoiNhanXacMinh" class="text-primary"></strong> vui lòng đăng nhập để xác nhận bàn giao.
                </p>

                <!-- VÙNG HIỂN THỊ LỖI KHI SAI MẬT KHẨU -->
                <div id="loiXacMinh" class="alert alert-danger py-2 px-3 mb-3" style="display: none; font-size: 12px; border-radius: 6px; padding: 8px;"></div>

                <div class="mb-3">
                    <label class="form-label text-muted fw-bold mb-1" style="font-size: 12px;">Tài khoản</label>
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-light"><i class="bi bi-person text-muted"></i></span>
                        <input type="text" id="usernameAuth" class="form-control" placeholder="Nhập tài khoản...">
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label text-muted fw-bold mb-1" style="font-size: 12px;">Mật khẩu</label>
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-light"><i class="bi bi-key text-muted"></i></span>
                        <input type="password" id="passwordAuth" class="form-control" placeholder="Nhập mật khẩu...">
                    </div>
                </div>

                <button type="button" id="btnChotCa" onclick="hoanTatGiaoCa()" class="btn btn-primary w-100 fw-semibold" style="border-radius: 6px; background-color: #4f46e5; padding: 8px 0;">
                    <i class="bi bi-check2-circle me-1"></i> Xác minh & Chốt ca
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 1. TỰ ĐỘNG BẮT CA LÀM VIỆC THEO GIỜ HỆ THỐNG
    document.addEventListener('DOMContentLoaded', function() {
        const hour = new Date().getHours();
        let caText = "Ngoài giờ làm việc";
        if (hour >= 7 && hour < 9) { caText = "07:00 - 09:00 (Ca Sáng sớm)"; }
        else if (hour >= 9 && hour < 11) { caText = "09:00 - 11:00 (Ca Sáng)"; }
        else if (hour >= 11 && hour < 19) { caText = "11:00 - 19:00 (Ca Trưa - Tối)"; }
        else if (hour >= 19 && hour < 22) { caText = "19:00 - 22:00 (Ca Tối)"; }
        document.getElementById('textCaHienTai').innerText = "Ca hiện tại: " + caText;
    });

    // 2. KIỂM TRA FORM VÀ MỞ MODAL XÁC MINH
    function kiemTraVaMoXacMinh() {
        const selectNguoiNhan = document.getElementById('nguoiNhanCa');
        const nguoiNhan = selectNguoiNhan.value;
        const checkboxes = document.querySelectorAll('.form-check-input');

        // Bắt lỗi chưa chọn người nhận ca
        if (!nguoiNhan) {
            alert("Vui lòng chọn Nhân viên nhận ca tiếp theo trước khi xác nhận!");
            selectNguoiNhan.focus();
            return;
        }

        // Cảnh báo nếu chưa check hết checklist
        let checkedCount = 0;
        checkboxes.forEach(cb => { if (cb.checked) checkedCount++; });
        if (checkedCount < checkboxes.length) {
            const xacNhanChecklist = confirm("Bạn chưa hoàn thành toàn bộ Checklist cuối ca. Vẫn muốn tiếp tục bàn giao?");
            if (!xacNhanChecklist) return;
        }

        // Lấy tên nhân viên vừa chọn và điền vào Modal
        const tenHienThi = selectNguoiNhan.options[selectNguoiNhan.selectedIndex].text;
        document.getElementById('tenNguoiNhanXacMinh').innerText = tenHienThi;

        // Reset trắng form nhập trong Modal
        document.getElementById('usernameAuth').value = '';
        document.getElementById('passwordAuth').value = '';
        document.getElementById('loiXacMinh').style.display = 'none';

        // Hiển thị Modal
        var myModal = new bootstrap.Modal(document.getElementById('modalXacMinh'));
        myModal.show();
    }

    // 3. HÀM GỬI AJAX VỀ JAVA ĐỂ KIỂM TRA MẬT KHẨU BẰNG FETCH
    function hoanTatGiaoCa() {
        const user = document.getElementById('usernameAuth').value.trim();
        const pass = document.getElementById('passwordAuth').value.trim();
        const divLoi = document.getElementById('loiXacMinh');

        if (user === "" || pass === "") {
            divLoi.innerText = "Vui lòng nhập tài khoản và mật khẩu!";
            divLoi.style.display = 'block';
            return;
        }

        // Đổi nút thành trạng thái đang tải
        const btn = document.getElementById('btnChotCa');
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Đang kiểm tra...';
        btn.disabled = true;

        // Gọi API (AJAX) về Servlet Dashboard (Trang chủ) để kiểm tra vì nó thường chứa logic đăng nhập
        fetch('${pageContext.request.contextPath}/giaoca?action=xacMinh', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                'username': user,
                'password': pass
            })
        })
        .then(response => response.text())
        .then(result => {
            btn.innerHTML = '<i class="bi bi-check2-circle me-1"></i> Xác minh & Chốt ca';
            btn.disabled = false;

            if (result.trim() === "SUCCESS") {
                alert("Xác minh thành công! Đã lưu nhật ký bàn giao ca.\nHệ thống sẽ tự động đăng xuất.");
                // Chuyển về trang đăng nhập
                window.location.href = "${pageContext.request.contextPath}/dashboard?action=logout";
            } else {
                divLoi.innerText = "Sai tài khoản hoặc mật khẩu! Vui lòng thử lại.";
                divLoi.style.display = 'block';
            }
        })
        .catch(error => {
            console.error('Error:', error);
            btn.innerHTML = '<i class="bi bi-check2-circle me-1"></i> Xác minh & Chốt ca';
            btn.disabled = false;
            divLoi.innerText = "Lỗi kết nối đến máy chủ! Vui lòng thử lại sau.";
            divLoi.style.display = 'block';
        });
    }
</script>
</body>
</html>