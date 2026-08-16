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
        .badge-nv { font-size: 11.5px; font-weight: 500; padding: 6px 10px; border-radius: 6px; box-shadow: 0 1px 2px rgba(0,0,0,0.05); width: 100%; text-align: center; transition: all 0.2s; }
        .date-sub { display: block; font-size: 11px; font-weight: 400; color: #94a3b8; margin-top: 2px; }

        /* Hiệu ứng làm mờ khi bị lọc nhân viên */
        .dimmed { opacity: 0.15; filter: grayscale(100%); }
    </style>
    <!-- Thư viện SheetJS dùng để xuất file Excel -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid">
        <!-- HEADER VÀ CÁC NÚT CÔNG CỤ -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color:#0f172a;">
                    <i class="bi bi-calendar-week text-primary me-2"></i> Lịch làm việc tuần này
                </h4>
                <p id="week-title" class="text-muted mb-0 mt-1" style="font-size: 13px;">Tuần từ 10/08/2026 đến 16/08/2026</p>
            </div>
            <div class="d-flex gap-2 align-items-center">

                <!-- NÚT BỘ LỌC ĐÃ ĐƯỢC GỘP GỌN GÀNG -->
                <div class="dropdown">
                    <button class="btn btn-sm fw-semibold text-white dropdown-toggle shadow-sm" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false" style="background-color: #0d6efd; border: none; border-radius: 6px; padding: 6px 14px;">
                        <i class="bi bi-funnel"></i> Bộ lọc
                    </button>
                    <div class="dropdown-menu dropdown-menu-end p-3 shadow" style="width: 280px; border-radius: 12px; border: 1px solid #e2e8f0; margin-top: 8px;">
                        <h6 class="dropdown-header px-0 text-dark fw-bold mb-2" style="font-size: 13px;">Công cụ tìm kiếm & lọc</h6>

                        <!-- ĐÃ ĐỔI TỪ Ô NHẬP CHỮ SANG Ô CHỌN CÓ SẴN (SELECT) -->
                        <div class="mb-3">
                            <label class="form-label text-muted mb-1" style="font-size: 12px;">Chọn nhân viên (Làm mờ ca khác)</label>
                            <select id="searchNV" class="form-select form-select-sm">
                                <option value="">-- Tất cả nhân viên --</option>
                                <option value="Nguyễn Văn Admin">Nguyễn Văn Admin</option>
                                <option value="Trần Thị Admin">Trần Thị Admin</option>
                                <option value="Nguyễn Văn An">Nguyễn Văn An</option>
                                <option value="Trần Thị Bình">Trần Thị Bình</option>
                                <option value="Lê Văn Cường">Lê Văn Cường</option>
                                <option value="Phạm Thị Dung">Phạm Thị Dung</option>
                                <option value="Hoàng Văn Đức">Hoàng Văn Đức</option>
                                <option value="Vũ Thị Hạnh">Vũ Thị Hạnh</option>
                                <option value="Đặng Văn Hùng">Đặng Văn Hùng</option>
                                <option value="Nguyễn Thu Hà">Nguyễn Thu Hà</option>
                                <option value="Lý Văn Long">Lý Văn Long</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label text-muted mb-1" style="font-size: 12px;">Chuyển nhanh đến ngày</label>
                            <input type="date" id="locNgay" class="form-control form-control-sm">
                        </div>

                        <div class="d-flex justify-content-end gap-2 mt-2">
                            <button type="button" class="btn btn-sm btn-light" onclick="xoaLocLich()" style="border-radius: 6px;">Xóa lọc</button>
                            <button type="button" class="btn btn-sm btn-primary" onclick="apDungLocLich(event)" style="background-color: #4f46e5; border: none; border-radius: 6px;">Áp dụng</button>
                        </div>
                    </div>
                </div>

                <button onclick="changeWeek(-1)" class="btn btn-outline-secondary btn-sm fw-semibold ms-1" style="border-radius: 8px; padding: 6px 12px;">
                    <i class="bi bi-chevron-left"></i> Tuần trước
                </button>
                <button onclick="changeWeek(1)" class="btn btn-outline-secondary btn-sm fw-semibold" style="border-radius: 8px; padding: 6px 12px;">
                    Tuần sau <i class="bi bi-chevron-right"></i>
                </button>

                <button data-bs-toggle="modal" data-bs-target="#modalSwap" class="btn btn-success btn-sm fw-semibold ms-2 shadow-sm" style="border-radius: 8px; padding: 6px 12px;">
                    <i class="bi bi-arrow-left-right me-1"></i> Đổi ca
                </button>

                <button onclick="xuatExcelLich()" class="btn btn-primary btn-sm fw-semibold ms-1 shadow-sm" style="background-color: #10b981; border: none; border-radius: 8px; padding: 6px 12px;">
                    <i class="bi bi-file-earmark-excel me-1"></i> Xuất Excel
                </button>
            </div>
        </div>

        <!-- BẢNG LỊCH TRỰC -->
        <div class="card bg-white border p-0 shadow-sm overflow-hidden" style="border-radius:12px; border-color:#e2e8f0;">
            <div class="table-responsive">
                <table class="table table-bordered mb-0" id="lichTable">
                    <thead>
                    <tr>
                        <th style="width: 12%; background-color: #f1f5f9;">KHUNG GIỜ</th>
                        <th style="width: 12%;">Thứ 2 <span class="date-sub" id="date-col-1">10/08</span></th>
                        <th style="width: 12%;">Thứ 3 <span class="date-sub" id="date-col-2">11/08</span></th>
                        <th style="width: 12%;">Thứ 4 <span class="date-sub" id="date-col-3">12/08</span></th>
                        <th style="width: 12%;">Thứ 5 <span class="date-sub" id="date-col-4">13/08</span></th>
                        <th style="width: 12%;">Thứ 6 <span class="date-sub" id="date-col-5">14/08</span></th>
                        <th style="width: 12%;">Thứ 7 <span class="date-sub" id="date-col-6">15/08</span></th>
                        <th style="width: 12%; color: #ef4444;">Chủ nhật <span class="date-sub" id="date-col-7" style="color: #fca5a5;">16/08</span></th>
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

        <!-- KHU VỰC NHẬT KÝ ĐỔI CA -->
        <div class="card bg-white border mt-4 p-0 shadow-sm" style="border-radius:12px; border-color:#e2e8f0;">
            <div class="card-header bg-white border-bottom py-3" style="border-radius: 12px 12px 0 0;">
                <h6 class="fw-bold mb-0" style="color:#0f172a;"><i class="bi bi-journal-text text-primary me-2"></i>Nhật ký ghi chú & Đổi ca</h6>
            </div>
            <div class="card-body p-3" id="nhatKyGhiChu" style="max-height: 200px; overflow-y: auto; font-size: 13.5px;">
                <div class="text-muted fst-italic text-center py-2" id="emptyLog">Chưa có ghi chú đổi ca nào trong tuần này.</div>
            </div>
        </div>

    </div>
</div>

<!-- MODAL POPUP: CHỨC NĂNG TRÁO ĐỔI CA -->
<div class="modal fade" id="modalSwap" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 12px; border: none;">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" style="color: #0f172a;"><i class="bi bi-arrow-left-right text-success me-2"></i>Chức năng tráo đổi ca</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p class="text-muted" style="font-size: 13px;">Chọn ngày và nhân viên để hệ thống đổi giờ làm việc cho nhau.</p>

                <div class="mb-3">
                    <label class="form-label text-muted fw-bold mb-1" style="font-size: 12px;">Ngày cần đổi ca</label>
                    <select id="swapDay" class="form-select">
                        <option value="1">Thứ 2</option>
                        <option value="2">Thứ 3</option>
                        <option value="3">Thứ 4</option>
                        <option value="4">Thứ 5</option>
                        <option value="5">Thứ 6</option>
                        <option value="6">Thứ 7</option>
                        <option value="7">Chủ nhật</option>
                    </select>
                </div>

                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <label class="form-label text-muted fw-bold mb-1" style="font-size: 12px;">Nhân viên 1</label>
                        <select id="swapNv1" class="form-select">
                            <option value="Nguyễn Văn Admin">Nguyễn Văn Admin</option>
                            <option value="Trần Thị Admin">Trần Thị Admin</option>
                            <option value="Nguyễn Văn An">Nguyễn Văn An</option>
                            <option value="Trần Thị Bình">Trần Thị Bình</option>
                            <option value="Lê Văn Cường">Lê Văn Cường</option>
                            <option value="Phạm Thị Dung">Phạm Thị Dung</option>
                            <option value="Hoàng Văn Đức">Hoàng Văn Đức</option>
                            <option value="Vũ Thị Hạnh">Vũ Thị Hạnh</option>
                            <option value="Đặng Văn Hùng">Đặng Văn Hùng</option>
                            <option value="Nguyễn Thu Hà">Nguyễn Thu Hà</option>
                            <option value="Lý Văn Long">Lý Văn Long</option>
                        </select>
                    </div>
                    <div class="col-6">
                        <label class="form-label text-muted fw-bold mb-1" style="font-size: 12px;">Nhân viên 2</label>
                        <select id="swapNv2" class="form-select">
                            <option value="Lê Văn Cường">Lê Văn Cường</option>
                            <option value="Nguyễn Văn Admin">Nguyễn Văn Admin</option>
                            <option value="Trần Thị Admin">Trần Thị Admin</option>
                            <option value="Nguyễn Văn An">Nguyễn Văn An</option>
                            <option value="Trần Thị Bình">Trần Thị Bình</option>
                            <option value="Phạm Thị Dung">Phạm Thị Dung</option>
                            <option value="Hoàng Văn Đức">Hoàng Văn Đức</option>
                            <option value="Vũ Thị Hạnh">Vũ Thị Hạnh</option>
                            <option value="Đặng Văn Hùng">Đặng Văn Hùng</option>
                            <option value="Nguyễn Thu Hà">Nguyễn Thu Hà</option>
                            <option value="Lý Văn Long">Lý Văn Long</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="form-label text-muted fw-bold mb-1" style="font-size: 12px;">Lý do đổi ca (Bắt buộc)</label>
                    <textarea id="swapReason" class="form-control" rows="2" placeholder="Ví dụ: Đổi ca do đi khám bệnh..."></textarea>
                </div>

            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" style="border-radius: 6px;">Hủy</button>
                <button type="button" class="btn btn-success px-4" onclick="xacNhanDoiCa()" style="border-radius: 6px;">
                    <i class="bi bi-check2-circle me-1"></i> Xác nhận đổi
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    let currentWeekOffset = 0;
    const baseDate = new Date(2026, 7, 10); // 10/08/2026 là Thứ 2

    function formatShortDate(date) {
        let d = date.getDate();
        let m = date.getMonth() + 1;
        return (d < 10 ? '0' + d : d) + '/' + (m < 10 ? '0' + m : m);
    }

    function formatFullDate(date) {
        let d = date.getDate();
        let m = date.getMonth() + 1;
        let y = date.getFullYear();
        return (d < 10 ? '0' + d : d) + '/' + (m < 10 ? '0' + m : m) + '/' + y;
    }

    // Hàm render lịch
    function renderWeek() {
        let targetMonday = new Date(baseDate);
        targetMonday.setDate(targetMonday.getDate() + (currentWeekOffset * 7));

        let targetSunday = new Date(targetMonday);
        targetSunday.setDate(targetSunday.getDate() + 6);

        document.getElementById('week-title').innerText = 'Tuần từ ' + formatFullDate(targetMonday) + ' đến ' + formatFullDate(targetSunday);

        for (let i = 1; i <= 7; i++) {
            let colDate = new Date(targetMonday);
            colDate.setDate(colDate.getDate() + (i - 1));
            document.getElementById('date-col-' + i).innerText = formatShortDate(colDate);
        }
    }

    // Xử lý nút bấm Tuần trước / sau
    function changeWeek(direction) {
        if (direction === 1) {
            if (currentWeekOffset >= 4) {
                alert('Tính năng này chỉ cho phép xem trước lịch làm việc tối đa 4 tuần tới!');
                return;
            }
            currentWeekOffset++;
        } else {
            if (currentWeekOffset <= -4) {
                alert('Chỉ có thể truy xuất lịch sử làm việc tối đa 4 tuần trước!');
                return;
            }
            currentWeekOffset--;
        }
        renderWeek();
    }

    // --- SCRIPT BỘ LỌC ĐÃ ĐƯỢC GỘP LẠI VÀO NÚT "ÁP DỤNG" ---
    function apDungLocLich(event) {
        if (event) event.preventDefault();

        // 1. XỬ LÝ LỌC NHẢY CÓC THEO NGÀY
        const inputDateVal = document.getElementById('locNgay').value;
        if (inputDateVal) {
            const selectedDate = new Date(inputDateVal);
            const diffTime = selectedDate.getTime() - baseDate.getTime();
            const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
            let targetWeekOffset = Math.floor(diffDays / 7);

            if (targetWeekOffset < -4 || targetWeekOffset > 4) {
                alert("Vượt quá giới hạn!\nBạn chỉ có thể xem lịch trong phạm vi 4 tuần trước và sau tuần hiện tại.");
                document.getElementById('locNgay').value = "";
            } else {
                currentWeekOffset = targetWeekOffset;
                renderWeek();
            }
        }

        // 2. TÌM KIẾM NHÂN VIÊN (TỪ DROP DOWN) VÀ HIỆU ỨNG LÀM MỜ
        const keyword = document.getElementById('searchNV').value.toLowerCase().trim();
        const badges = document.querySelectorAll('.badge-nv');

        badges.forEach(badge => {
            const tenNhanVien = badge.innerText.toLowerCase();
            if (keyword === "") {
                badge.classList.remove('dimmed');
            } else {
                if (tenNhanVien.includes(keyword)) {
                    badge.classList.remove('dimmed');
                } else {
                    badge.classList.add('dimmed');
                }
            }
        });

        // 3. Tự động đóng dropdown sau khi bấm Áp dụng
        if (event) {
            const dropdownEl = document.querySelector('.dropdown-toggle');
            const dropdownInstance = bootstrap.Dropdown.getInstance(dropdownEl);
            if (dropdownInstance) dropdownInstance.hide();
        }
    }

    function xoaLocLich() {
        // Xóa dữ liệu các ô nhập
        document.getElementById('searchNV').value = '';
        document.getElementById('locNgay').value = '';

        // Xóa hiệu ứng làm mờ
        const badges = document.querySelectorAll('.badge-nv');
        badges.forEach(badge => badge.classList.remove('dimmed'));
    }

    // XUẤT EXCEL BẢNG LỊCH TRỰC
    function xuatExcelLich() {
        var bangDuLieu = document.getElementById('lichTable');
        var bangClone = bangDuLieu.cloneNode(true);

        var cells = bangClone.getElementsByTagName('td');
        for(let i = 0; i < cells.length; i++) {
            let text = cells[i].innerText.replace(/\n+/g, ', ').trim();
            if(text.endsWith(', ')) text = text.slice(0, -2);
            cells[i].innerText = text;
        }

        var wb = XLSX.utils.table_to_book(bangClone, {sheet: "LichLamViec"});
        var ngayHomNay = new Date();
        var tenFile = "LichLamViec_TuanNay_" + ngayHomNay.getDate() + "_" + (ngayHomNay.getMonth()+1) + ".xlsx";
        XLSX.writeFile(wb, tenFile);
    }

    // HÀM XỬ LÝ ĐỔI CA
    function xacNhanDoiCa() {
        const daySelect = document.getElementById('swapDay');
        const colIndex = parseInt(daySelect.value);
        const dayName = daySelect.options[daySelect.selectedIndex].text;

        const nv1 = document.getElementById('swapNv1').value;
        const nv2 = document.getElementById('swapNv2').value;
        const reason = document.getElementById('swapReason').value.trim();

        if (nv1 === nv2) {
            alert("Vui lòng chọn 2 nhân viên khác nhau để tráo đổi ca!");
            return;
        }

        if (!reason) {
            alert("Vui lòng nhập lý do đổi ca để lưu nhật ký!");
            document.getElementById('swapReason').focus();
            return;
        }

        const rows = document.querySelectorAll('#lichTable tbody tr');
        let node1 = null;
        let node2 = null;

        rows.forEach(row => {
            const td = row.querySelectorAll('td')[colIndex];
            const badges = td.querySelectorAll('.badge-nv');

            badges.forEach(b => {
                if(b.innerText.trim() === nv1) node1 = b;
                if(b.innerText.trim() === nv2) node2 = b;
            });
        });

        if (node1 && node2) {
            const tempText = node1.innerText;
            node1.innerText = node2.innerText;
            node2.innerText = tempText;

            const tempBg = node1.style.backgroundColor;
            const tempColor = node1.style.color;

            node1.style.backgroundColor = node2.style.backgroundColor;
            node1.style.color = node2.style.color;

            node2.style.backgroundColor = tempBg;
            node2.style.color = tempColor;

            const logContainer = document.getElementById('nhatKyGhiChu');
            const emptyLog = document.getElementById('emptyLog');
            if (emptyLog) emptyLog.style.display = 'none';

            const now = new Date();
            const timeStr = formatShortDate(now) + ' ' + (now.getHours() < 10 ? '0' : '') + now.getHours() + ':' + (now.getMinutes() < 10 ? '0' : '') + now.getMinutes();

            const logEntry = document.createElement('div');
            logEntry.className = 'mb-2 pb-2 border-bottom';
            logEntry.innerHTML =
                '<div class="d-flex justify-content-between align-items-center mb-1">' +
                '<strong style="color: #4f46e5;">[<i class="bi bi-clock me-1"></i>' + timeStr + ']</strong>' +
                '<span class="badge bg-light text-dark border">Đổi ca ' + dayName + '</span>' +
                '</div>' +
                '<div class="ps-2" style="border-left: 2px solid #cbd5e1;">' +
                '<b class="text-dark">' + nv1 + '</b> <i class="bi bi-arrow-left-right mx-1 text-muted"></i> <b class="text-dark">' + nv2 + '</b><br>' +
                '<span class="text-muted"><i class="bi bi-chat-left-text me-1"></i>Lý do: ' + reason + '</span>' +
                '</div>';

            logContainer.prepend(logEntry);

            alert("Đổi ca thành công! Hệ thống đã ghi nhận lại lịch sử.");
            document.getElementById('swapReason').value = '';

            const modalEl = document.getElementById('modalSwap');
            const modalInstance = bootstrap.Modal.getInstance(modalEl);
            modalInstance.hide();

            xoaLocLich();
        } else {
            alert("Đổi ca thất bại!\nMột trong hai (hoặc cả hai) nhân viên này không có ca trực trong ngày bạn đã chọn.");
        }
    }
</script>
</body>
</html>