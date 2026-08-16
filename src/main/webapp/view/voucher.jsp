<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="java.util.List" %>
<%@ page import="entity.Voucher" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý Voucher - Portal Work</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        .content-wrapper { margin-left: 280px; margin-top: 60px; padding: 30px; }
        .card-custom { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
        .form-label { font-size: 13px; font-weight: 500; color: #475569; margin-bottom: 6px; }
        .form-control, .form-select { border-radius: 8px; border: 1px solid #cbd5e1; font-size: 14px; padding: 10px 12px; }
        .btn-primary-custom { background-color: #4f46e5; color: white; border: none; border-radius: 8px; padding: 10px; font-weight: 600; width: 100%; transition: 0.2s;}
        .btn-primary-custom:hover { background-color: #4338ca; }
        .table-custom th { color: #64748b; font-size: 11px; font-weight: 700; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; padding-bottom: 12px; }
        .table-custom td { padding: 16px 8px; font-size: 14px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
        .badge-active { background-color: #dcfce7; color: #166534; padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 600;}
        .badge-warning { background-color: #fef9c3; color: #854d0e; padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 600;}
        .badge-expired { background-color: #fee2e2; color: #991b1b; padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 600;}
    </style>
    <!-- Thư viện SheetJS dùng để xuất file Excel -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
</head>
<body>

<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div class="content-wrapper">
    <div class="mb-4">
        <span class="text-uppercase" style="font-size: 11px; font-weight: 700; color: #64748b; letter-spacing: 0.05em;">NV4 - Tích hợp POS</span>
        <h3 class="fw-bold mt-1" style="color: #0f172a;"><i class="bi bi-ticket-perforated-fill me-2" style="color: #4f46e5;"></i> Voucher giảm giá</h3>
        <p class="text-muted mb-0" style="font-size: 14px;">Tạo mã giảm giá, điều kiện áp dụng và tính SoTienGiam ngay trên màn hình POS.</p>
    </div>

    <div class="row g-4">
        <!-- FORM TẠO VOUCHER -->
        <div class="col-lg-4">
            <div class="card-custom p-4">
                <h6 class="fw-bold mb-4" style="color: #0f172a;">Tạo voucher</h6>
                <form action="${pageContext.request.contextPath}/voucher/them" method="POST">
                    <div class="mb-3">
                        <label class="form-label">Mã voucher</label>
                        <input type="text" class="form-control" name="maCode" placeholder="VD: SACHMOI10" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Kiểu giảm</label>
                        <select class="form-select" name="loaiGiam" id="kieuGiam">
                            <option value="1">Giảm theo phần trăm (%)</option>
                            <option value="2">Giảm tiền mặt (đ)</option>
                        </select>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label">Giá trị giảm</label>
                            <input type="number" step="0.01" class="form-control" name="giaTri" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Giảm tối đa</label>
                            <input type="number" step="0.01" class="form-control" name="giaGiamToiDa" id="giamToiDa" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Đơn tối thiểu</label>
                        <input type="number" step="0.01" class="form-control" name="giaTriDonToiThieu" required>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label">Hiệu lực từ</label>
                            <input type="datetime-local" class="form-control" name="ngayBatDau" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Đến ngày</label>
                            <input type="datetime-local" class="form-control" name="ngayKetThuc" required>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label">Số lượng mã</label>
                        <input type="number" class="form-control" name="soLuongToiDa" required>
                    </div>
                    <button type="submit" class="btn-primary-custom"><i class="bi bi-floppy-fill me-2"></i> Lưu voucher</button>
                </form>
            </div>
        </div>

        <!-- DANH SÁCH VOUCHER & BỘ LỌC -->
        <div class="col-lg-8">
            <div class="card-custom p-4 h-100 d-flex flex-column">

                <!-- THANH CÔNG CỤ: TÌM KIẾM, LỌC (Gửi về Server) & XUẤT EXCEL -->
                <form action="${pageContext.request.contextPath}/voucher/hien-thi" method="GET" class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom w-100">

                    <!-- Ô Tìm kiếm nhanh -->
                    <div class="input-group input-group-sm" style="width: 250px;">
                        <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                        <!-- Thêm name="searchCode" và value để giữ text -->
                        <input type="text" name="searchCode" class="form-control border-start-0 ps-0" placeholder="Tìm mã voucher..." value="${param.searchCode}">
                    </div>

                    <!-- Nhóm nút bên phải -->
                    <div class="d-flex gap-2">

                        <!-- Nút Bộ lọc Dropdown -->
                        <div class="dropdown">
                            <button class="btn btn-sm fw-semibold text-white dropdown-toggle shadow-sm" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false" style="background-color: #0d6efd; border: none; border-radius: 6px;">
                                <i class="bi bi-funnel"></i> Bộ lọc
                            </button>
                            <div class="dropdown-menu dropdown-menu-end p-3 shadow" style="width: 260px; border-radius: 12px; border: 1px solid #e2e8f0; margin-top: 8px;">
                                <h6 class="dropdown-header px-0 text-dark fw-bold mb-2" style="font-size: 13px;">Lọc Voucher</h6>

                                <div class="mb-3">
                                    <label class="form-label text-muted mb-1" style="font-size: 12px;">Mã voucher</label>
                                    <select name="filterCodeDropdown" class="form-select form-select-sm">
                                        <option value="">Tất cả mã</option>
                                        <!-- Dùng listAllVoucher từ Java gửi sang để show full mã -->
                                        <c:forEach var="vItem" items="${listAllVoucher}">
                                            <option value="${vItem.maCode}" ${param.filterCodeDropdown == vItem.maCode ? 'selected' : ''}>${vItem.maCode}</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label text-muted mb-1" style="font-size: 12px;">Trạng thái</label>
                                    <select name="filterStatus" class="form-select form-select-sm">
                                        <option value="">Tất cả trạng thái</option>
                                        <option value="Đang chạy" ${param.filterStatus == 'Đang chạy' ? 'selected' : ''}>Đang chạy</option>
                                        <option value="Sắp diễn ra" ${param.filterStatus == 'Sắp diễn ra' ? 'selected' : ''}>Sắp diễn ra</option>
                                        <option value="Đã kết thúc" ${param.filterStatus == 'Đã kết thúc' ? 'selected' : ''}>Đã kết thúc (Bao gồm Hết lượt)</option>
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label text-muted mb-1" style="font-size: 12px;">Ngày hiệu lực</label>
                                    <input type="date" name="filterDate" class="form-control form-control-sm" value="${param.filterDate}">
                                </div>

                                <div class="d-flex justify-content-end gap-2 mt-2">
                                    <!-- Nút Xóa lọc trỏ thẳng về link trống -->
                                    <a href="${pageContext.request.contextPath}/voucher/hien-thi" class="btn btn-sm btn-light" style="border-radius: 6px;">Xóa lọc</a>
                                    <!-- Nút Áp dụng gọi Submit Form -->
                                    <button type="submit" class="btn btn-sm btn-primary" style="background-color: #4f46e5; border: none; border-radius: 6px;">Áp dụng</button>
                                </div>
                            </div>
                        </div>

                        <!-- Nút Xuất Excel -->
                        <button type="button" onclick="xuatExcel()" class="btn btn-sm fw-semibold text-white shadow-sm" style="background-color: #10b981; border: none; border-radius: 6px;">
                            <i class="bi bi-file-earmark-excel me-1"></i> Xuất Excel
                        </button>
                    </div>
                </form>

                <div class="table-responsive">
                    <table class="table table-custom table-borderless w-100 mb-0" id="bangVoucher">
                        <thead>
                        <tr>
                            <th>MÃ VOUCHER</th>
                            <th>ĐIỀU KIỆN</th>
                            <th>HIỆU LỰC</th>
                            <th>SỐ LẦN DÙNG</th>
                            <th>TRẠNG THÁI</th>
                            <th class="text-center no-export">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<Voucher> list = (List<Voucher>) request.getAttribute("listVoucher");
                            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM");
                            LocalDateTime now = LocalDateTime.now();
                            if (list != null && !list.isEmpty()) {
                                for (Voucher v : list) {
                                    String giaTri = v.getGiaTri().stripTrailingZeros().toPlainString();
                                    String donToiThieu = v.getGiaTriDonToiThieu().stripTrailingZeros().toPlainString();
                                    String dieuKien = v.getLoaiGiam() == 1 ? "Giảm " + giaTri + "%, đơn từ " + donToiThieu + " đ" : "Giảm " + giaTri + " đ, đơn từ " + donToiThieu + " đ";

                                    String badgeClass = "badge-active";
                                    String trangThai = "Đang chạy";
                                    if (v.getDaSuDung() >= v.getSoLuongToiDa()) { badgeClass = "badge-expired"; trangThai = "Hết lượt"; }
                                    else if (now.isAfter(v.getNgayKetThuc())) { badgeClass = "badge-expired"; trangThai = "Đã kết thúc"; }
                                    else if (now.isBefore(v.getNgayBatDau())) { badgeClass = "badge-warning"; trangThai = "Sắp diễn ra"; }
                        %>
                        <tr class="voucher-row">
                            <td class="fw-bold voucher-code" style="color: #0f172a;"><%= v.getMaCode() %></td>
                            <td><%= dieuKien %></td>
                            <td class="voucher-date"><%= v.getNgayBatDau().format(dtf) %> - <%= v.getNgayKetThuc().format(dtf) %></td>
                            <td style="color: #64748b;"><%= v.getDaSuDung() %>/<%= v.getSoLuongToiDa() %></td>
                            <td><span class="<%= badgeClass %> voucher-status"><%= trangThai %></span></td>
                            <td class="text-center no-export">
                                <a href="${pageContext.request.contextPath}/voucher/het-han?ma=<%= v.getMaVoucher() %>"
                                   class="text-danger"
                                   title="Chuyển thành hết hạn"
                                   onclick="return confirm('Bạn có chắc muốn kết thúc sớm voucher này không?');">
                                    <i class="bi bi-trash fs-5"></i>
                                </a>
                            </td>
                        </tr>
                        <% }} else { %>
                        <tr id="noDataRow">
                            <td colspan="6" class="text-center text-muted py-4">Chưa có voucher nào.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Thanh phân trang (Đã Update để giữ nguyên bộ lọc khi sang trang) -->
                <nav aria-label="Page navigation" class="mt-auto pt-3">
                    <ul class="pagination justify-content-center mb-0">
                        <c:if test="${totalPages > 0}">
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/voucher/hien-thi?page=${i}&searchCode=${param.searchCode}&filterCodeDropdown=${param.filterCodeDropdown}&filterStatus=${param.filterStatus}&filterDate=${param.filterDate}">${i}</a>
                                </li>
                            </c:forEach>
                        </c:if>
                    </ul>
                </nav>

            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // 1. Script Khóa/Mở Giảm Tối Đa
    document.addEventListener('DOMContentLoaded', function() {
        const kieuGiam = document.getElementById('kieuGiam');
        const giamToiDa = document.getElementById('giamToiDa');

        function xuLyHienThiGiamToiDa() {
            if (kieuGiam.value === '2') { // Giảm tiền mặt
                giamToiDa.disabled = true;
                giamToiDa.value = '';
                giamToiDa.style.backgroundColor = '#f1f5f9';
                giamToiDa.placeholder = 'Không áp dụng';
                giamToiDa.removeAttribute('required');
            }
            else if (kieuGiam.value === '1') { // Giảm phần trăm
                giamToiDa.disabled = false;
                giamToiDa.style.backgroundColor = '#ffffff';
                giamToiDa.placeholder = '';
                giamToiDa.setAttribute('required', 'required');
            }
        }
        if (kieuGiam && giamToiDa) {
            xuLyHienThiGiamToiDa();
            kieuGiam.addEventListener('change', xuLyHienThiGiamToiDa);
        }
    });

    // 2. Script Xuất file Excel
    function xuatExcel() {
        var bangDuLieu = document.getElementById('bangVoucher');
        var bangClone = bangDuLieu.cloneNode(true);

        var rows = bangClone.rows;
        for (var i = 0; i < rows.length; i++) {
            rows[i].deleteCell(-1);
        }

        var wb = XLSX.utils.table_to_book(bangClone, {sheet: "DanhSachVoucher"});
        var ngayHomNay = new Date();
        var tenFile = "DanhSachVoucher_" + ngayHomNay.getDate() + "_" + (ngayHomNay.getMonth()+1) + ".xlsx";
        XLSX.writeFile(wb, tenFile);
    }
</script>
</body>
</html>