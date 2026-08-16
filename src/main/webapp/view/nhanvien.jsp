<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>Quản lý Nhân viên - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        table.table thead th { font-size: 12px; text-transform: uppercase; letter-spacing: 0.04em; color: #64748b; border-bottom: 1px solid #e2e8f0; background-color: #f8fafc; }
        table.table td { font-size: 13.5px; vertical-align: middle; color: #0f172a; }
    </style>
    <!-- Thư viện SheetJS dùng để xuất file Excel -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color:#0f172a;">Quản lý Nhân viên</h4>
                <p class="text-muted mb-0" style="font-size:13px;">Chỉ Admin mới truy cập được trang này.</p>
            </div>

            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/nhanvien?action=new" class="btn text-white fw-semibold shadow-sm"
                   style="background-color:#4f46e5;border-radius:8px;font-size:13.5px;padding:10px 18px;">
                    <i class="bi bi-plus-lg me-1"></i> Thêm nhân viên
                </a>
            </div>
        </div>

        <c:if test="${param.thanhCong == '1'}">
            <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13.5px;">Lưu nhân viên thành công.</div>
        </c:if>
        <c:if test="${param.xoaThanhCong == '1'}">
            <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13.5px;">Đã cập nhật trạng thái nhân viên thành Nghỉ làm.</div>
        </c:if>
        <c:if test="${not empty param.loiXoa}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">${param.loiXoa}</div>
        </c:if>
        <c:if test="${not empty thongBaoLoi}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">${thongBaoLoi}</div>
        </c:if>

        <div class="card bg-white border mb-3 p-3 shadow-sm" style="border-color:#e2e8f0;border-radius:12px;">
            <!-- THANH CÔNG CỤ: TÌM KIẾM, LỌC & XUẤT EXCEL -->
            <form id="filterForm" onsubmit="apDungLoc(event)" class="d-flex justify-content-between align-items-center mb-0 w-100">

                <!-- Ô Tìm kiếm -->
                <div class="input-group input-group-sm" style="width: 280px;">
                    <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                    <input type="text" id="searchNV" class="form-control border-start-0 ps-0" placeholder="Tìm tên / tài khoản / SĐT..." onkeyup="apDungLoc()">
                </div>

                <!-- Nhóm nút bên phải -->
                <div class="d-flex gap-2">

                    <!-- Nút Bộ lọc Dropdown -->
                    <div class="dropdown">
                        <button class="btn btn-sm fw-semibold text-white dropdown-toggle shadow-sm" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false" style="background-color: #0d6efd; border: none; border-radius: 6px; padding: 6px 14px;">
                            <i class="bi bi-funnel"></i> Bộ lọc
                        </button>
                        <div class="dropdown-menu dropdown-menu-end p-3 shadow" style="width: 260px; border-radius: 12px; border: 1px solid #e2e8f0; margin-top: 8px;">
                            <h6 class="dropdown-header px-0 text-dark fw-bold mb-2" style="font-size: 13px;">Lọc Nhân Viên</h6>

                            <!-- ĐÃ THÊM MỤC CHỌN TÊN TỰ ĐỘNG LẤY TỪ LIST BẰNG JSTL -->
                            <div class="mb-3">
                                <label class="form-label text-muted mb-1" style="font-size: 12px;">Tên nhân viên</label>
                                <select id="filterName" class="form-select form-select-sm">
                                    <option value="">Tất cả nhân viên</option>
                                    <c:forEach var="nvItem" items="${danhSachNV}">
                                        <option value="${nvItem.tenNV}">${nvItem.tenNV}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label text-muted mb-1" style="font-size: 12px;">Vai trò</label>
                                <select id="filterRole" class="form-select form-select-sm">
                                    <option value="">Tất cả vai trò</option>
                                    <option value="Admin">Admin</option>
                                    <option value="Nhân viên">Nhân viên</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label text-muted mb-1" style="font-size: 12px;">Trạng thái</label>
                                <select id="filterStatus" class="form-select form-select-sm">
                                    <option value="">Tất cả trạng thái</option>
                                    <option value="Đang làm">Đang làm</option>
                                    <option value="Nghỉ làm">Nghỉ làm</option>
                                </select>
                            </div>

                            <div class="d-flex justify-content-end gap-2 mt-2">
                                <button type="button" class="btn btn-sm btn-light" onclick="xoaLoc()" style="border-radius: 6px;">Xóa lọc</button>
                                <button type="submit" class="btn btn-sm btn-primary" style="background-color: #4f46e5; border: none; border-radius: 6px;">Áp dụng</button>
                            </div>
                        </div>
                    </div>

                    <!-- Nút Xuất Excel -->
                    <button type="button" onclick="xuatExcel()" class="btn btn-sm fw-semibold text-white shadow-sm" style="background-color: #10b981; border: none; border-radius: 6px; padding: 6px 14px;">
                        <i class="bi bi-file-earmark-excel me-1"></i> Xuất Excel
                    </button>
                </div>
            </form>
        </div>

        <div class="card bg-white border" style="border-color:#e2e8f0;border-radius:12px; overflow: hidden;">
            <div class="table-responsive">
                <table class="table mb-0" id="bangNhanVien">
                    <thead>
                    <tr>
                        <th class="ps-3">Mã</th>
                        <th>Họ tên</th>
                        <th>Tài khoản</th>
                        <th>SĐT</th>
                        <th>Email</th>
                        <th>Vai trò</th>
                        <th class="text-center">Trạng thái</th>
                        <th class="text-end pe-3 no-export">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="nv" items="${danhSachNV}">
                        <tr class="nv-row">
                            <td class="ps-3 fw-semibold nv-text">NV${nv.maNV}</td>
                            <!-- Gắn thêm class nv-name để Javascript biết lấy tên từ ô này đi so sánh -->
                            <td class="nv-text nv-name">${nv.tenNV}</td>
                            <td class="nv-text">${nv.taiKhoan}</td>
                            <td class="nv-text">${nv.sdt}</td>
                            <td class="nv-text">${nv.email}</td>
                            <td class="nv-role">
                                <c:choose>
                                    <c:when test="${nv.vaiTroNV == 1}"><span class="badge rounded-pill" style="background:#eef2ff;color:#4338ca;">Admin</span></c:when>
                                    <c:otherwise><span class="badge rounded-pill" style="background:#f1f5f9;color:#475569;">Nhân viên</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <div class="d-flex flex-column align-items-center gap-1">
                                    <c:choose>
                                        <c:when test="${nv.trangThai == false}">
                                            <span class="badge rounded-pill nv-status-text" style="background:#fef2f2;color:#991b1b;">Nghỉ làm</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge rounded-pill nv-status-text" style="background:#f0fdf4;color:#166534;">Đang làm</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <!-- Nút toggle bị ẩn khi xuất Excel nhờ script bên dưới -->
                                    <form method="post" action="${pageContext.request.contextPath}/nhanvien" class="d-inline-block toggle-form m-0 form-toggle-export">
                                        <input type="hidden" name="action" value="toggleTrangThai">
                                        <input type="hidden" name="ma" value="${nv.maNV}">
                                        <div class="form-check form-switch d-flex justify-content-center m-0">
                                            <input class="form-check-input toggle-submit" type="checkbox" role="switch"
                                                   style="width:2.4em;height:1.3em;cursor:pointer;"
                                                    ${nv.trangThai == false ? '' : 'checked'}
                                                   title="${nv.trangThai == false ? 'Nghỉ làm - bấm để chuyển Đang làm' : 'Đang làm - bấm để chuyển Nghỉ làm'}">
                                        </div>
                                    </form>
                                </div>
                            </td>
                            <td class="text-end pe-3 no-export">
                                <a href="${pageContext.request.contextPath}/nhanvien?action=edit&ma=${nv.maNV}" class="btn btn-sm btn-outline-secondary me-1" style="border-radius:6px;"><i class="bi bi-pencil"></i></a>
                                <button type="button" class="btn btn-sm btn-outline-danger" style="border-radius:6px;"
                                        title="Chuyển sang Nghỉ làm"
                                        onclick="xoaNV(${nv.maNV}, '${nv.tenNV}')"><i class="bi bi-trash"></i></button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty danhSachNV}">
                        <tr id="noDataRow"><td colspan="8" class="text-center text-muted py-5">Không có nhân viên.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<form id="formXoa" method="post" action="${pageContext.request.contextPath}/nhanvien">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="ma" id="maXoa">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // 1. Script Xóa NV và Toggle Trạng thái
    function xoaNV(ma, ten) {
        if (confirm('Chuyển nhân viên "' + ten + '" sang Nghỉ làm?\nKhông xóa dữ liệu, chỉ cập nhật trạng thái.')) {
            document.getElementById('maXoa').value = ma;
            document.getElementById('formXoa').submit();
        }
    }

    document.querySelectorAll('.toggle-submit').forEach(function (chk) {
        chk.addEventListener('change', function () {
            this.closest('.toggle-form').submit();
        });
    });

    // 2. Script Bộ Lọc (Frontend)
    function apDungLoc(event) {
        if(event) event.preventDefault();

        const searchKeyword = document.getElementById('searchNV').value.toLowerCase().trim();
        const nameFilter = document.getElementById('filterName').value.toLowerCase().trim(); // Lấy giá trị tên
        const roleFilter = document.getElementById('filterRole').value;
        const statusFilter = document.getElementById('filterStatus').value;

        const rows = document.querySelectorAll('.nv-row');

        rows.forEach(row => {
            // Lấy toàn bộ text của dòng để tìm kiếm nhanh
            let rowText = "";
            row.querySelectorAll('.nv-text').forEach(td => rowText += td.innerText.toLowerCase() + " ");

            // Lấy dữ liệu từng cột cụ thể
            const nameText = row.querySelector('.nv-name').innerText.toLowerCase().trim();
            const roleText = row.querySelector('.nv-role').innerText.trim();
            const statusText = row.querySelector('.nv-status-text').innerText.trim();

            // So sánh
            let isMatchSearch = searchKeyword === "" || rowText.includes(searchKeyword);
            let isMatchName = nameFilter === "" || nameText === nameFilter;
            let isMatchRole = roleFilter === "" || roleText === roleFilter;
            let isMatchStatus = statusFilter === "" || statusText === statusFilter;

            // Nếu khớp tất cả điều kiện thì hiện, sai thì ẩn
            if (isMatchSearch && isMatchName && isMatchRole && isMatchStatus) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });

        // Tự động ẩn dropdown khi bấm Áp dụng
        if(event) {
            const dropdownEl = document.querySelector('.dropdown-toggle');
            const dropdownInstance = bootstrap.Dropdown.getInstance(dropdownEl);
            if(dropdownInstance) dropdownInstance.hide();
        }
    }

    function xoaLoc() {
        document.getElementById('searchNV').value = '';
        document.getElementById('filterName').value = ''; // Reset bộ lọc tên
        document.getElementById('filterRole').value = '';
        document.getElementById('filterStatus').value = '';
        apDungLoc();
    }

    // 3. Script Xuất file Excel (Đã dọn dẹp form toggle)
    function xuatExcel() {
        var bangDuLieu = document.getElementById('bangNhanVien');
        var bangClone = bangDuLieu.cloneNode(true);

        var rows = bangClone.rows;
        for (var i = 0; i < rows.length; i++) {
            // Xóa cột Thao tác (cột cuối)
            rows[i].deleteCell(-1);

            // Tìm và xóa cái công tắc toggle để Excel chỉ lấy chữ "Đang làm" / "Nghỉ làm"
            let formsToKill = rows[i].querySelectorAll('.form-toggle-export');
            formsToKill.forEach(f => f.remove());
        }

        var wb = XLSX.utils.table_to_book(bangClone, {sheet: "DanhSachNhanVien"});
        var ngayHomNay = new Date();
        var tenFile = "DanhSachNhanVien_" + ngayHomNay.getDate() + "_" + (ngayHomNay.getMonth()+1) + ".xlsx";
        XLSX.writeFile(wb, tenFile);
    }
</script>
</body>
</html>