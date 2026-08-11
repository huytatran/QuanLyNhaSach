<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Lịch làm việc - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
        .table th { background-color: #f8fafc; color: #475569; font-size: 13px; font-weight: 600; text-align: center; border-bottom: 2px solid #e2e8f0; padding: 12px 8px; }
        .table td { text-align: center; vertical-align: middle; padding: 12px; border-bottom: 1px solid #f1f5f9; }
        .ca-title { font-size: 13px; font-weight: 700; color: #334155; }
        .ca-desc { font-size: 11px; color: #64748b; font-weight: normal; display: block; margin-top: 4px; }
        .badge-nv { font-size: 11.5px; font-weight: 500; padding: 6px 10px; border-radius: 6px; box-shadow: 0 1px 2px rgba(0,0,0,0.05); width: 100%; text-align: center; }
        .date-sub { display: block; font-size: 11px; font-weight: 400; color: #94a3b8; margin-top: 2px; }
    </style>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid">
        <!-- HEADER -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color:#0f172a;">
                    <i class="bi bi-calendar-week text-primary me-2"></i> Lịch làm việc tuần này
                </h4>
                <p id="week-title" class="text-muted mb-0 mt-1" style="font-size: 13px;">Tuần từ 10/08/2026 đến 16/08/2026</p>
            </div>
            <div class="d-flex gap-2">
                <button onclick="changeWeek(-1)" class="btn btn-outline-secondary btn-sm fw-semibold" style="border-radius: 8px; padding: 8px 16px;">
                    <i class="bi bi-chevron-left"></i> Tuần trước
                </button>
                <button onclick="changeWeek(1)" class="btn btn-outline-secondary btn-sm fw-semibold" style="border-radius: 8px; padding: 8px 16px;">
                    Tuần sau <i class="bi bi-chevron-right"></i>
                </button>
                <button onclick="window.print()" class="btn btn-primary btn-sm fw-semibold ms-2 shadow-sm" style="background-color: #4f46e5; border: none; border-radius: 8px; padding: 8px 16px;">
                    <i class="bi bi-printer me-1"></i> Xuất / In lịch
                </button>
            </div>
        </div>

        <!-- BẢNG LỊCH TRỰC -->
        <div class="card bg-white border p-0 shadow-sm overflow-hidden" style="border-radius:12px; border-color:#e2e8f0;">
            <div class="table-responsive">
                <table class="table table-bordered mb-0">
                    <thead>
                    <tr>
                        <th style="width: 12%; background-color: #f1f5f9;">KHUNG GIỜ</th>
                        <th style="width: 12%;">Thứ 2 <span class="date-sub" id="date-col-0">10/08</span></th>
                        <th style="width: 12%;">Thứ 3 <span class="date-sub" id="date-col-1">11/08</span></th>
                        <th style="width: 12%;">Thứ 4 <span class="date-sub" id="date-col-2">12/08</span></th>
                        <th style="width: 12%;">Thứ 5 <span class="date-sub" id="date-col-3">13/08</span></th>
                        <th style="width: 12%;">Thứ 6 <span class="date-sub" id="date-col-4">14/08</span></th>
                        <th style="width: 12%;">Thứ 7 <span class="date-sub" id="date-col-5">15/08</span></th>
                        <th style="width: 12%; color: #ef4444;">Chủ nhật <span class="date-sub" id="date-col-6" style="color: #fca5a5;">16/08</span></th>
                    </tr>
                    </thead>
                    <tbody>
                    <!-- CA 1: 7h - 9h -->
                    <tr>
                        <td style="background-color: #f8fafc;">
                            <span class="ca-title">07:00 - 09:00</span>
                            <span class="ca-desc">Ca Sáng sớm</span>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #e0f2fe; color: #0369a1;">Nguyễn Văn Admin</span>
                                <span class="badge-nv" style="background-color: #e0f2fe; color: #0369a1;">Trần Thị Bình</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #e0f2fe; color: #0369a1;">Nguyễn Văn Admin</span>
                                <span class="badge-nv" style="background-color: #e0f2fe; color: #0369a1;">Trần Thị Bình</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #e0f2fe; color: #0369a1;">Vũ Thị Hạnh</span>
                                <span class="badge-nv" style="background-color: #e0f2fe; color: #0369a1;">Đặng Văn Hùng</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #e0f2fe; color: #0369a1;">Nguyễn Văn Admin</span>
                                <span class="badge-nv" style="background-color: #e0f2fe; color: #0369a1;">Trần Thị Bình</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #e0f2fe; color: #0369a1;">Vũ Thị Hạnh</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #e0f2fe; color: #0369a1;">Đặng Văn Hùng</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #f1f5f9; color: #94a3b8;">Nghỉ / Off</span>
                            </div>
                        </td>
                    </tr>

                    <!-- CA 2: 9h - 11h -->
                    <tr>
                        <td style="background-color: #f8fafc;">
                            <span class="ca-title">09:00 - 11:00</span>
                            <span class="ca-desc">Ca Sáng</span>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Lê Văn Cường</span>
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Phạm Thị Dung</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Lê Văn Cường</span>
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Phạm Thị Dung</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Lý Văn Long</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Nguyễn Thu Hà</span>
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Lý Văn Long</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Lê Văn Cường</span>
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Phạm Thị Dung</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Lý Văn Long</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #ecfdf5; color: #047857;">Nguyễn Thu Hà</span>
                            </div>
                        </td>
                    </tr>

                    <!-- CA 3: 11h - 19h -->
                    <tr>
                        <td style="background-color: #f8fafc;">
                            <span class="ca-title">11:00 - 19:00</span>
                            <span class="ca-desc">Ca Trưa - Tối</span>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Hoàng Văn Đức</span>
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Trần Thị Admin</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Hoàng Văn Đức</span>
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Trần Thị Admin</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Hoàng Văn Đức</span>
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Lê Văn Cường</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Trần Thị Admin</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Hoàng Văn Đức</span>
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Lê Văn Cường</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Hoàng Văn Đức</span>
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Trần Thị Admin</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #fef3c7; color: #b45309;">Trần Thị Admin</span>
                            </div>
                        </td>
                    </tr>

                    <!-- CA 4: 19h - 22h -->
                    <tr>
                        <td style="background-color: #f8fafc;">
                            <span class="ca-title">19:00 - 22:00</span>
                            <span class="ca-desc">Ca Tối</span>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #f3e8ff; color: #7e22ce;">Nguyễn Thu Hà</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #f3e8ff; color: #7e22ce;">Lý Văn Long</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #f3e8ff; color: #7e22ce;">Nguyễn Thu Hà</span>
                                <span class="badge-nv" style="background-color: #f3e8ff; color: #7e22ce;">Nguyễn Văn An</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #f3e8ff; color: #7e22ce;">Lý Văn Long</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #f3e8ff; color: #7e22ce;">Nguyễn Thu Hà</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #f3e8ff; color: #7e22ce;">Nguyễn Văn An</span>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column gap-2">
                                <span class="badge-nv" style="background-color: #f3e8ff; color: #7e22ce;">Nguyễn Văn An</span>
                                <span class="badge-nv" style="background-color: #f3e8ff; color: #7e22ce;">Lý Văn Long</span>
                            </div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<!-- SCRIPT XỬ LÝ CHUYỂN TUẦN VÀ THAY ĐỔI NGÀY THÁNG CÓ XÁO TRỘN LỊCH -->
<script>
    // Biến lưu số tuần đang lệch so với tuần hiện tại (0 là tuần này)
    let currentWeekOffset = 0;

    // Ngày bắt đầu gốc (Thứ 2, ngày 10/08/2026) -> Lưu ý: tháng trong JS đếm từ 0 (7 là tháng 8)
    const baseDate = new Date(2026, 7, 10);

    // Hàm format ngày tháng dạng "dd/MM"
    function formatShortDate(date) {
        let d = date.getDate();
        let m = date.getMonth() + 1;
        return (d < 10 ? '0' + d : d) + '/' + (m < 10 ? '0' + m : m);
    }

    // Hàm format ngày tháng dạng "dd/MM/yyyy"
    function formatFullDate(date) {
        let d = date.getDate();
        let m = date.getMonth() + 1;
        let y = date.getFullYear();
        return (d < 10 ? '0' + d : d) + '/' + (m < 10 ? '0' + m : m) + '/' + y;
    }

    // Hàm xử lý khi bấm nút Tuần trước / Tuần sau
    function changeWeek(direction) {
        if (direction === 1) { // Tiến lên (Tuần sau)
            if (currentWeekOffset >= 4) {
                alert('Tính năng này chỉ cho phép xem trước lịch làm việc tối đa 4 tuần (1 tháng)!');
                return;
            }
            currentWeekOffset++;
        } else { // Lùi lại (Tuần trước)
            if (currentWeekOffset <= -4) {
                alert('Chỉ có thể truy xuất lịch sử làm việc tối đa 4 tuần trước!');
                return;
            }
            currentWeekOffset--;
        }

        // Gọi hàm render lại ngày tháng trên giao diện
        renderDates();

        // Gọi hàm xáo trộn lịch làm việc
        shuffleSchedule();
    }

    // Hàm tự động tính toán và cập nhật ngày tháng vào HTML
    function renderDates() {
        // Tính ngày Thứ 2 của tuần được chọn
        let targetMonday = new Date(baseDate);
        targetMonday.setDate(targetMonday.getDate() + (currentWeekOffset * 7));

        // Tính ngày Chủ nhật của tuần được chọn
        let targetSunday = new Date(targetMonday);
        targetSunday.setDate(targetSunday.getDate() + 6);

        // Cập nhật dòng chữ Tuần từ ngày... đến ngày...
        document.getElementById('week-title').innerText = 'Tuần từ ' + formatFullDate(targetMonday) + ' đến ' + formatFullDate(targetSunday);

        // Cập nhật ngày ở từng cột (Thứ 2 đến Chủ nhật)
        for (let i = 0; i < 7; i++) {
            let colDate = new Date(targetMonday);
            colDate.setDate(colDate.getDate() + i);
            document.getElementById('date-col-' + i).innerText = formatShortDate(colDate);
        }
    }

    // Hàm xáo trộn nhân viên trong các ngày của tuần (Shuffle)
    function shuffleSchedule() {
        // Lấy tất cả các hàng (4 ca làm việc)
        const rows = document.querySelectorAll('tbody tr');

        rows.forEach(row => {
            // Lấy các ô từ Thứ 2 đến Chủ nhật (bỏ qua ô đầu tiên là Khung giờ)
            const cells = Array.from(row.querySelectorAll('td')).slice(1);

            // Thuật toán xáo trộn mảng (Fisher-Yates)
            for (let i = cells.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                // Tráo đổi nội dung HTML (đổi chỗ nhân viên trực)
                const temp = cells[i].innerHTML;
                cells[i].innerHTML = cells[j].innerHTML;
                cells[j].innerHTML = temp;
            }
        });
    }
</script>
</body>
</html>