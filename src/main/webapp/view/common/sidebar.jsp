<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="d-flex flex-column flex-shrink-0 p-3 text-white"
     style="width: 280px; height: 100vh; position: fixed; top: 0; left: 0; z-index: 1020; background-color: #0f172a; overflow-y: auto;">

    <a href="${pageContext.request.contextPath}/dashboard" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none">
        <img src="${pageContext.request.contextPath}/assets/images/logo-mark.svg"
             alt="Portal.BookStore"
             width="36" height="36"
             class="me-2"
             style="border-radius: 10px; flex-shrink: 0;">
        <span class="d-flex flex-column lh-1">
            <span class="fw-bold" style="font-size: 15px; letter-spacing: -0.02em;">
                Portal<span style="color: #a5b4fc;">.BookStore</span>
            </span>
            <span style="font-size: 10px; font-weight: 500; color: #64748b; letter-spacing: 0.06em; margin-top: 4px;">QUẢN LÝ NHÀ SÁCH</span>
        </span>
    </a>
    <hr style="border-color: #334155;">

    <ul class="nav nav-pills flex-column mb-auto">
        <li class="nav-item mb-1">
            <a href="${pageContext.request.contextPath}/dashboard"
               class="nav-link d-flex align-items-center ${activeMenu == 'dashboard' ? 'text-white' : 'text-white-50 hover-menu'}"
               style="${activeMenu == 'dashboard' ? 'background-color: #4f46e5; border-radius: 8px;' : 'border-radius: 8px;'}">
                <i class="bi bi-grid-1x2-fill me-2"></i> Dashboard
            </a>
        </li>
        <li class="nav-item mb-1">
            <a href="${pageContext.request.contextPath}/pos"
               class="nav-link d-flex align-items-center ${activeMenu == 'pos' ? 'text-white' : 'text-white-50 hover-menu'}"
               style="${activeMenu == 'pos' ? 'background-color: #4f46e5; border-radius: 8px;' : 'border-radius: 8px;'}">
                <i class="bi bi-terminal-fill me-2"></i> Bán hàng (POS)
            </a>
        </li>

        <li class="nav-item mt-4 mb-2">
            <span class="text-uppercase px-3" style="font-size: 11px; font-weight: 700; color: #64748b; letter-spacing: 0.05em;">Vận hành</span>
        </li>
        <li class="nav-item mb-1">
            <a href="${pageContext.request.contextPath}/sach"
               class="nav-link d-flex align-items-center ${activeMenu == 'sach' ? 'text-white' : 'text-white-50 hover-menu'}"
               style="${activeMenu == 'sach' ? 'background-color: #4f46e5; border-radius: 8px;' : 'border-radius: 8px;'}">
                <i class="bi bi-journal-bookmark-fill me-2"></i> Quản lý Sách
            </a>
        </li>
        <li class="nav-item mb-1">
            <a href="${pageContext.request.contextPath}/don-hang"
               class="nav-link d-flex align-items-center ${activeMenu == 'donhang' ? 'text-white' : 'text-white-50 hover-menu'}"
               style="${activeMenu == 'donhang' ? 'background-color: #4f46e5; border-radius: 8px;' : 'border-radius: 8px;'}">
                <i class="bi bi-receipt-cutoff me-2"></i> Đơn hàng / đổi trả
            </a>
        </li>
        <li class="nav-item mb-1">
            <a href="${pageContext.request.contextPath}/khachhang"
               class="nav-link d-flex align-items-center ${activeMenu == 'khachhang' ? 'text-white' : 'text-white-50 hover-menu'}"
               style="${activeMenu == 'khachhang' ? 'background-color: #4f46e5; border-radius: 8px;' : 'border-radius: 8px;'}">
                <i class="bi bi-people-fill me-2"></i> Khách hàng
            </a>
        </li>

        <li class="nav-item mt-4 mb-2">
            <span class="text-uppercase px-3" style="font-size: 11px; font-weight: 700; color: #64748b; letter-spacing: 0.05em;">Danh mục sách</span>
        </li>
        <li class="nav-item mb-1">
            <a href="${pageContext.request.contextPath}/danhmuc"
               class="nav-link d-flex align-items-center ${activeMenu == 'danhmuc' ? 'text-white' : 'text-white-50 hover-menu'}"
               style="${activeMenu == 'danhmuc' ? 'background-color: #4f46e5; border-radius: 8px;' : 'border-radius: 8px;'}">
                <i class="bi bi-tags-fill me-2"></i> Thuộc tính sách
            </a>
        </li>
        <li class="nav-item mb-1 ms-3">
            <a href="${pageContext.request.contextPath}/danhmuc?tab=theloai" class="nav-link text-white-50 hover-menu py-1" style="font-size: 13px; border-radius: 8px;">Thể loại</a>
        </li>
        <li class="nav-item mb-1 ms-3">
            <a href="${pageContext.request.contextPath}/danhmuc?tab=tacgia" class="nav-link text-white-50 hover-menu py-1" style="font-size: 13px; border-radius: 8px;">Tác giả</a>
        </li>
        <li class="nav-item mb-1 ms-3">
            <a href="${pageContext.request.contextPath}/danhmuc?tab=nxb" class="nav-link text-white-50 hover-menu py-1" style="font-size: 13px; border-radius: 8px;">Nhà xuất bản</a>
        </li>
        <li class="nav-item mb-1 ms-3">
            <a href="${pageContext.request.contextPath}/danhmuc?tab=bosach" class="nav-link text-white-50 hover-menu py-1" style="font-size: 13px; border-radius: 8px;">Bộ sách / series</a>
        </li>

        <!-- Đã sửa đường link cho chuẩn với VoucherServlet -->
        <li class="nav-item mb-1">
            <a href="${pageContext.request.contextPath}/voucher/hien-thi"
               class="nav-link d-flex align-items-center ${activeMenu == 'voucher' ? 'text-white' : 'text-white-50 hover-menu'}"
               style="${activeMenu == 'voucher' ? 'background-color: #4f46e5; border-radius: 8px;' : 'border-radius: 8px;'}">
                <i class="bi bi-ticket-perforated-fill me-2"></i> Voucher
            </a>
        </li>

        <li class="nav-item mb-1">
            <a href="${pageContext.request.contextPath}/danhgia"
               class="nav-link d-flex align-items-center ${activeMenu == 'danhgia' ? 'text-white' : 'text-white-50 hover-menu'}"
               style="${activeMenu == 'danhgia' ? 'background-color: #4f46e5; border-radius: 8px;' : 'border-radius: 8px;'}">
                <i class="bi bi-star-half me-2"></i> Đánh giá sách
            </a>
        </li>

        <c:if test="${sessionScope.currentUser.vaiTroNV == 1}">
            <li class="nav-item mt-4 mb-2">
                <span class="text-uppercase px-3" style="font-size: 11px; font-weight: 700; color: #64748b; letter-spacing: 0.05em;">Hệ thống</span>
            </li>
            <li class="nav-item mb-1">
                <a href="${pageContext.request.contextPath}/nhanvien"
                   class="nav-link d-flex align-items-center ${activeMenu == 'nhanvien' ? 'text-white' : 'text-white-50 hover-menu'}"
                   style="${activeMenu == 'nhanvien' ? 'background-color: #4f46e5; border-radius: 8px;' : 'border-radius: 8px;'}">
                    <i class="bi bi-shield-lock-fill me-2"></i> Quản lý Nhân Viên
                </a>
            </li>
            <li class="nav-item mb-1">
                <a href="${pageContext.request.contextPath}/baocao"
                   class="nav-link d-flex align-items-center ${activeMenu == 'baocao' ? 'text-white' : 'text-white-50 hover-menu'}"
                   style="${activeMenu == 'baocao' ? 'background-color: #4f46e5; border-radius: 8px;' : 'border-radius: 8px;'}">
                    <i class="bi bi-bar-chart-line-fill me-2"></i> Báo cáo doanh thu
                </a>
            </li>
        </c:if>
    </ul>

    <hr style="border-color: #334155;">

    <div>
        <div class="d-flex align-items-center text-white">
            <div class="p-1 rounded-circle me-2 d-flex align-items-center justify-content-center" style="background-color: #334155;">
                <i class="bi bi-person-fill fs-5 text-white-50"></i>
            </div>
            <div class="me-auto overflow-hidden">
                <strong class="d-block text-truncate" style="max-width: 150px; font-size: 14px;">${sessionScope.currentUser.tenNV}</strong>
                <span class="badge d-inline-block" style="font-size: 10px; background-color: #1e293b; color: #94a3b8; border: 1px solid #334155;">
                    ${sessionScope.currentUser.vaiTroNV == 1 ? 'Quản trị viên' : 'Nhân viên'}
                </span>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/dashboard?action=logout" class="btn btn-sm w-100 mt-3 text-white-50 border-0 d-flex align-items-center justify-content-center"
           style="background-color: #1e293b; border-radius: 6px; font-size: 13px;">
            <i class="bi bi-box-arrow-left me-2"></i> Đăng xuất
        </a>
    </div>
</div>

<style>
    .hover-menu { border-radius: 8px; transition: all 0.2s ease; }
    .hover-menu:hover { background-color: #1e293b !important; color: #f8fafc !important; }
</style>

<script>
    (function() {
        const INACTIVE_LIMIT = 15 * 60 * 1000;
        let idleTimer;
        function logoutUser() {
            window.location.href = "${pageContext.request.contextPath}/dashboard?action=logout";
        }
        function resetTimer() {
            clearTimeout(idleTimer);
            idleTimer = setTimeout(logoutUser, INACTIVE_LIMIT);
        }
        ['load','mousemove','mousedown','keypress','scroll','touchstart'].forEach(function(evt) {
            window.addEventListener(evt, resetTimer);
        });
    })();
</script>