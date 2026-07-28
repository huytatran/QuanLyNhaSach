<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>${feature.title} - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        .page-shell { margin-left: 280px; margin-top: 60px; }
        .surface { background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; }
        .muted-label { color: #64748b; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; }
        .form-label { color: #475569; font-size: 12.5px; font-weight: 600; }
        .form-control, .form-select { font-size: 13.5px; border-color: #cbd5e1; }
        .btn-primary-book { background: #4f46e5; border-color: #4f46e5; color: #fff; font-size: 13.5px; font-weight: 600; border-radius: 6px; }
        .btn-primary-book:hover { background: #4338ca; border-color: #4338ca; color: #fff; }
        table.table thead th { font-size: 12px; text-transform: uppercase; letter-spacing: 0.04em; color: #64748b; border-bottom: 1px solid #e2e8f0; background-color: #f8fafc; }
        table.table td { font-size: 13.5px; vertical-align: middle; color: #0f172a; }
        .workflow-step { border-left: 3px solid #e2e8f0; padding-left: 14px; }
        .workflow-step.active { border-left-color: #4f46e5; }
    </style>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div class="page-shell p-4">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-start mb-4">
            <div>
                <div class="muted-label mb-2">${feature.owner} - ${feature.status}</div>
                <h4 class="fw-bold mb-1" style="color:#0f172a;">
                    <i class="bi ${feature.icon} me-2" style="color:#4f46e5;"></i>${feature.title}
                </h4>
                <p class="text-muted mb-0" style="font-size:13.5px; max-width: 760px;">${feature.description}</p>
            </div>
            <span class="badge rounded-pill px-3 py-2" style="background:#eef2ff;color:#4338ca;">Giao dien xem truoc</span>
        </div>

        <c:choose>
            <c:when test="${activeMenu == 'khachhang'}">
                <div class="row g-3">
                    <div class="col-lg-4">
                        <div class="surface p-4">
                            <h6 class="fw-bold mb-3">Them khach tai quay</h6>
                            <label class="form-label">Ho ten</label><input class="form-control mb-3" value="Nguyen Van An">
                            <label class="form-label">So dien thoai</label><input class="form-control mb-3" value="0901234567">
                            <label class="form-label">Dia chi lien he</label><textarea class="form-control mb-3" rows="3">Quan 1, TP.HCM</textarea>
                            <button class="btn btn-primary-book w-100"><i class="bi bi-person-plus me-1"></i> Luu khach hang</button>
                        </div>
                    </div>
                    <div class="col-lg-8">
                        <div class="surface">
                            <div class="p-3 d-flex gap-2 border-bottom" style="border-color:#e2e8f0 !important;">
                                <input class="form-control" placeholder="Tim theo ten hoac so dien thoai">
                                <button class="btn btn-outline-secondary" style="font-size:13px;">Tim</button>
                            </div>
                            <table class="table mb-0">
                                <thead><tr><th>Khach hang</th><th>SDT</th><th>Lan mua gan nhat</th><th class="text-end">Tong chi tieu</th><th></th></tr></thead>
                                <tbody>
                                <tr><td>Nguyen Van An</td><td>0901234567</td><td>21/07/2026</td><td class="text-end">1,245,000 d</td><td><button class="btn btn-sm btn-outline-secondary">Chon POS</button></td></tr>
                                <tr><td>Tran Minh Chau</td><td>0912345678</td><td>18/07/2026</td><td class="text-end">680,000 d</td><td><button class="btn btn-sm btn-outline-secondary">Chon POS</button></td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:when>

            <c:when test="${activeMenu == 'donhang'}">
                <div class="row g-3">
                    <div class="col-lg-8">
                        <div class="surface">
                            <div class="p-3 border-bottom" style="border-color:#e2e8f0 !important;"><h6 class="fw-bold mb-0">Lich su don hang</h6></div>
                            <table class="table mb-0">
                                <thead><tr><th>Ma don</th><th>Khach hang</th><th>Ngay lap</th><th>Thanh toan</th><th class="text-end">Tong tien</th><th></th></tr></thead>
                                <tbody>
                                <tr><td>#1024</td><td>Nguyen Van An</td><td>21/07/2026</td><td>Tien mat</td><td class="text-end">245,000 d</td><td class="text-end"><button class="btn btn-sm btn-outline-secondary">In</button> <button class="btn btn-sm btn-outline-danger">Huy</button></td></tr>
                                <tr><td>#1023</td><td>Tran Minh Chau</td><td>20/07/2026</td><td>Chuyen khoan</td><td class="text-end">418,000 d</td><td class="text-end"><button class="btn btn-sm btn-outline-secondary">In</button> <button class="btn btn-sm btn-outline-warning">Doi tra</button></td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="surface p-4">
                            <h6 class="fw-bold mb-3">Quy trinh doi tra</h6>
                            <div class="workflow-step active mb-3"><strong>1. Quet ma serial</strong><div class="text-muted" style="font-size:13px;">Kiem tra SachVatLy co thuoc don hang cua cua hang.</div></div>
                            <div class="workflow-step active mb-3"><strong>2. Chon ly do</strong><div class="text-muted" style="font-size:13px;">Tra sach binh thuong hoac doi sach hong.</div></div>
                            <div class="workflow-step"><strong>3. Cap nhat kho</strong><div class="text-muted" style="font-size:13px;">Hoan trang thai ton kho sau khi xu ly.</div></div>
                        </div>
                    </div>
                </div>
            </c:when>

            <c:when test="${activeMenu == 'voucher'}">
                <div class="row g-3">
                    <div class="col-lg-4">
                        <div class="surface p-4">
                            <h6 class="fw-bold mb-3">Tao voucher</h6>
                            <label class="form-label">Ma voucher</label><input class="form-control mb-3" value="SACHMOI10">
                            <label class="form-label">Kieu giam</label><select class="form-select mb-3"><option>Giam theo phan tram</option><option>Giam tien truc tiep</option></select>
                            <label class="form-label">Gia tri giam</label><input class="form-control mb-3" value="10%">
                            <label class="form-label">Don toi thieu</label><input class="form-control mb-3" value="200,000">
                            <button class="btn btn-primary-book w-100"><i class="bi bi-ticket-perforated me-1"></i> Luu voucher</button>
                        </div>
                    </div>
                    <div class="col-lg-8">
                        <div class="surface">
                            <table class="table mb-0">
                                <thead><tr><th>Ma</th><th>Dieu kien</th><th>Hieu luc</th><th>So lan dung</th><th>Trang thai</th></tr></thead>
                                <tbody>
                                <tr><td>SACHMOI10</td><td>Giam 10%, don tu 200,000 d</td><td>01/07 - 31/07</td><td>42/200</td><td><span class="badge" style="background:#f0fdf4;color:#166534;">Dang chay</span></td></tr>
                                <tr><td>COMBO50K</td><td>Giam 50,000 d cho bo sach</td><td>15/07 - 15/08</td><td>12/100</td><td><span class="badge" style="background:#fffbeb;color:#92400e;">Can theo doi</span></td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:when>

            <c:when test="${activeMenu == 'danhmuc'}">
                <div class="row g-3">
                    <div class="col-md-3"><div class="surface p-3 h-100"><div class="muted-label">The loai</div><h5 class="fw-bold mt-2">28</h5><p class="text-muted mb-0" style="font-size:13px;">Van hoc, kinh te, ky nang, thieu nhi.</p></div></div>
                    <div class="col-md-3"><div class="surface p-3 h-100"><div class="muted-label">Tac gia</div><h5 class="fw-bold mt-2">86</h5><p class="text-muted mb-0" style="font-size:13px;">Gan nhieu tac gia cho mot dau sach.</p></div></div>
                    <div class="col-md-3"><div class="surface p-3 h-100"><div class="muted-label">NXB</div><h5 class="fw-bold mt-2">14</h5><p class="text-muted mb-0" style="font-size:13px;">Thong tin lien he nha xuat ban.</p></div></div>
                    <div class="col-md-3"><div class="surface p-3 h-100"><div class="muted-label">Bo sach</div><h5 class="fw-bold mt-2">9</h5><p class="text-muted mb-0" style="font-size:13px;">Series, tap, phan cua sach.</p></div></div>
                </div>
                <div class="surface mt-3">
                    <table class="table mb-0">
                        <thead><tr><th>Nhom</th><th>Du lieu mau</th><th>Muc dich</th><th></th></tr></thead>
                        <tbody>
                        <tr><td>The loai</td><td>Tieu thuyet, Ky nang song</td><td>Loc sach va bao cao doanh thu theo dong sach</td><td class="text-end"><button class="btn btn-sm btn-outline-secondary">Quan ly</button></td></tr>
                        <tr><td>Tac gia</td><td>Paulo Coelho, Nguyen Nhat Anh</td><td>Hien thi thong tin sach va tim kiem</td><td class="text-end"><button class="btn btn-sm btn-outline-secondary">Quan ly</button></td></tr>
                        <tr><td>Bo sach</td><td>Harry Potter, Dune</td><td>Sap xep sach theo tap/phan</td><td class="text-end"><button class="btn btn-sm btn-outline-secondary">Quan ly</button></td></tr>
                        </tbody>
                    </table>
                </div>
            </c:when>

            <c:otherwise>
                <div class="row g-3">
                    <div class="col-lg-5">
                        <div class="surface p-4">
                            <h6 class="fw-bold mb-3">Them danh gia</h6>
                            <label class="form-label">Khach hang</label><select class="form-select mb-3"><option>Nguyen Van An</option></select>
                            <label class="form-label">Sach</label><select class="form-select mb-3"><option>Nha gia kim</option></select>
                            <label class="form-label">Diem</label><select class="form-select mb-3"><option>5 sao</option><option>4 sao</option><option>3 sao</option></select>
                            <label class="form-label">Nhan xet</label><textarea class="form-control mb-3" rows="3">Sach dep, noi dung de doc.</textarea>
                            <button class="btn btn-primary-book w-100"><i class="bi bi-star me-1"></i> Luu danh gia</button>
                        </div>
                    </div>
                    <div class="col-lg-7">
                        <div class="surface">
                            <table class="table mb-0">
                                <thead><tr><th>Sach</th><th>Diem TB</th><th>Luot</th><th>Danh gia moi</th></tr></thead>
                                <tbody>
                                <tr><td>Nha gia kim</td><td>4.8</td><td>32</td><td>Sach dep, noi dung de doc.</td></tr>
                                <tr><td>Dac nhan tam</td><td>4.6</td><td>18</td><td>Phu hop lam qua tang.</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
