<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>Thuộc tính sách - Portal.BookStore</title>
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
        .tab-pill { padding: 8px 16px; border-radius: 20px; font-size: 13px; font-weight: 600; text-decoration: none; }
        .tab-pill.active { background: #4f46e5; color: #fff; }
        .tab-pill:not(.active) { background: #f1f5f9; color: #475569; }
        .tab-pill:not(.active):hover { background: #e2e8f0; color: #334155; }
    </style>
</head>
<body>
<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div class="page-shell p-4">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-start mb-4">
            <div>
                <div class="muted-label mb-2">Danh mục - Nền dữ liệu</div>
                <h4 class="fw-bold mb-1" style="color:#0f172a;">
                    <i class="bi bi-tags-fill me-2" style="color:#4f46e5;"></i>Thuộc tính sách
                </h4>
                <p class="text-muted mb-0" style="font-size:13.5px;">Quản lý thể loại, tác giả, nhà xuất bản, bộ sách và thông tin phân loại sách.</p>
            </div>
        </div>

        <!-- 4 the so lieu tong quan - du lieu that -->
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="surface p-3 h-100">
                    <div class="muted-label">Thể loại</div>
                    <h5 class="fw-bold mt-2">${soTheLoai}</h5>
                    <p class="text-muted mb-0" style="font-size:13px;">Văn học, kinh tế, kỹ năng, thiếu nhi.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="surface p-3 h-100">
                    <div class="muted-label">Tác giả</div>
                    <h5 class="fw-bold mt-2">${soTacGia}</h5>
                    <p class="text-muted mb-0" style="font-size:13px;">Gán nhiều tác giả cho một đầu sách.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="surface p-3 h-100">
                    <div class="muted-label">NXB</div>
                    <h5 class="fw-bold mt-2">${soNXB}</h5>
                    <p class="text-muted mb-0" style="font-size:13px;">Thông tin liên hệ nhà xuất bản.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="surface p-3 h-100">
                    <div class="muted-label">Bộ sách</div>
                    <h5 class="fw-bold mt-2">${soBoSach}</h5>
                    <p class="text-muted mb-0" style="font-size:13px;">Series, tập, phần của sách.</p>
                </div>
            </div>
        </div>

        <!-- Tab dieu huong -->
        <div class="d-flex gap-2 mb-3">
            <a href="${pageContext.request.contextPath}/danhmuc?tab=theloai" class="tab-pill ${tab == 'theloai' ? 'active' : ''}">Thể loại</a>
            <a href="${pageContext.request.contextPath}/danhmuc?tab=tacgia" class="tab-pill ${tab == 'tacgia' ? 'active' : ''}">Tác giả</a>
            <a href="${pageContext.request.contextPath}/danhmuc?tab=nxb" class="tab-pill ${tab == 'nxb' ? 'active' : ''}">Nhà xuất bản</a>
            <a href="${pageContext.request.contextPath}/danhmuc?tab=bosach" class="tab-pill ${tab == 'bosach' ? 'active' : ''}">Bộ sách / series</a>
        </div>

        <c:if test="${param.thanhCong == '1'}">
            <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13.5px;">Lưu thành công.</div>
        </c:if>
        <c:if test="${param.xoaThanhCong == '1'}">
            <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13.5px;">Xóa thành công.</div>
        </c:if>
        <c:if test="${not empty param.loiXoa}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">${param.loiXoa}</div>
        </c:if>
        <c:if test="${not empty param.loi}">
            <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13.5px;">${param.loi}</div>
        </c:if>

        <c:if test="${tab == 'theloai'}">
            <div class="d-flex justify-content-end mb-3">
                <button type="button" class="btn btn-primary-book" data-bs-toggle="modal" data-bs-target="#modalTheLoai"
                        onclick="moModalThem()">
                    <i class="bi bi-plus-lg me-1"></i> Thêm thể loại
                </button>
            </div>

            <div class="surface">
                <table class="table mb-0">
                    <thead>
                    <tr>
                        <th class="ps-3" style="width:80px;">Mã</th>
                        <th>Tên thể loại</th>
                        <th class="text-end">Số đầu sách</th>
                        <th class="text-end pe-3" style="width:120px;">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="tl" items="${danhSachTheLoai}">
                        <c:set var="soSach" value="${empty soSachTheoTL[tl.maTL] ? 0 : soSachTheoTL[tl.maTL]}" />
                        <tr>
                            <td class="ps-3 fw-semibold">TL${tl.maTL}</td>
                            <td>${tl.tenTL}</td>
                            <td class="text-end">
                                <span class="badge rounded-pill" style="background:#eef2ff;color:#4338ca;">${soSach} sách</span>
                            </td>
                            <td class="text-end pe-3">
                                <button type="button" class="btn btn-sm btn-outline-secondary me-1" style="border-radius:6px;" title="Sửa"
                                        data-bs-toggle="modal" data-bs-target="#modalTheLoai"
                                        onclick="moModalSua(${tl.maTL}, '${tl.tenTL}')">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-danger" style="border-radius:6px;" title="Xóa"
                                        onclick="xacNhanXoa(${tl.maTL}, '${tl.tenTL}', ${soSach})">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty danhSachTheLoai}">
                        <tr><td colspan="4" class="text-center text-muted py-5">Chưa có thể loại nào.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </c:if>

        <c:if test="${tab == 'tacgia'}">
            <div class="d-flex justify-content-end mb-3">
                <button type="button" class="btn btn-primary-book" data-bs-toggle="modal" data-bs-target="#modalTacGia"
                        onclick="moModalThemTG()">
                    <i class="bi bi-plus-lg me-1"></i> Thêm tác giả
                </button>
            </div>

            <div class="surface">
                <table class="table mb-0">
                    <thead>
                    <tr>
                        <th class="ps-3" style="width:80px;">Mã</th>
                        <th>Tên tác giả</th>
                        <th>Tiểu sử</th>
                        <th class="text-end">Số đầu sách</th>
                        <th class="text-end pe-3" style="width:120px;">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="tg" items="${danhSachTacGia}">
                        <c:set var="soSach" value="${empty soSachTheoTG[tg.maTG] ? 0 : soSachTheoTG[tg.maTG]}" />
                        <tr>
                            <td class="ps-3 fw-semibold">TG${tg.maTG}</td>
                            <td>${tg.tenTG}</td>
                            <td class="text-muted" style="font-size:13px;">${tg.tieuSu}</td>
                            <td class="text-end">
                                <span class="badge rounded-pill" style="background:#eef2ff;color:#4338ca;">${soSach} sách</span>
                            </td>
                            <td class="text-end pe-3">
                                <button type="button" class="btn btn-sm btn-outline-secondary me-1" style="border-radius:6px;" title="Sửa"
                                        data-bs-toggle="modal" data-bs-target="#modalTacGia"
                                        onclick="moModalSuaTG(${tg.maTG}, '${tg.tenTG}', '${tg.tieuSu}')">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-danger" style="border-radius:6px;" title="Xóa"
                                        onclick="xacNhanXoaTG(${tg.maTG}, '${tg.tenTG}', ${soSach})">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty danhSachTacGia}">
                        <tr><td colspan="5" class="text-center text-muted py-5">Chưa có tác giả nào.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </c:if>

        <c:if test="${tab == 'nxb'}">
            <div class="d-flex justify-content-end mb-3">
                <button type="button" class="btn btn-primary-book" data-bs-toggle="modal" data-bs-target="#modalNXB"
                        onclick="moModalThemNXB()">
                    <i class="bi bi-plus-lg me-1"></i> Thêm nhà xuất bản
                </button>
            </div>

            <div class="surface">
                <table class="table mb-0">
                    <thead>
                    <tr>
                        <th class="ps-3" style="width:80px;">Mã</th>
                        <th>Tên nhà xuất bản</th>
                        <th>Số điện thoại</th>
                        <th>Địa chỉ</th>
                        <th class="text-end">Số đầu sách</th>
                        <th class="text-end pe-3" style="width:120px;">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="nxb" items="${danhSachNXB}">
                        <c:set var="soSach" value="${empty soSachTheoNXB[nxb.maNXB] ? 0 : soSachTheoNXB[nxb.maNXB]}" />
                        <tr>
                            <td class="ps-3 fw-semibold">NXB${nxb.maNXB}</td>
                            <td>${nxb.tenNXB}</td>
                            <td>${nxb.sdt}</td>
                            <td class="text-muted" style="font-size:13px;">${nxb.diaChi}</td>
                            <td class="text-end">
                                <span class="badge rounded-pill" style="background:#eef2ff;color:#4338ca;">${soSach} sách</span>
                            </td>
                            <td class="text-end pe-3">
                                <button type="button" class="btn btn-sm btn-outline-secondary me-1" style="border-radius:6px;" title="Sửa"
                                        data-bs-toggle="modal" data-bs-target="#modalNXB"
                                        onclick="moModalSuaNXB(${nxb.maNXB}, '${nxb.tenNXB}', '${nxb.sdt}', '${nxb.diaChi}')">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-danger" style="border-radius:6px;" title="Xóa"
                                        onclick="xacNhanXoaNXB(${nxb.maNXB}, '${nxb.tenNXB}', ${soSach})">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty danhSachNXB}">
                        <tr><td colspan="6" class="text-center text-muted py-5">Chưa có nhà xuất bản nào.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </c:if>

        <c:if test="${tab == 'bosach'}">
            <div class="d-flex justify-content-end mb-3">
                <button type="button" class="btn btn-primary-book" data-bs-toggle="modal" data-bs-target="#modalBoSach"
                        onclick="moModalThemBS()">
                    <i class="bi bi-plus-lg me-1"></i> Thêm bộ sách
                </button>
            </div>

            <div class="surface">
                <table class="table mb-0">
                    <thead>
                    <tr>
                        <th class="ps-3" style="width:80px;">Mã</th>
                        <th>Tên bộ sách</th>
                        <th>Mô tả</th>
                        <th class="text-end">Số đầu sách</th>
                        <th class="text-end pe-3" style="width:120px;">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="bs" items="${danhSachBoSach}">
                        <c:set var="soSach" value="${empty soSachTheoBoSach[bs.maBoSach] ? 0 : soSachTheoBoSach[bs.maBoSach]}" />
                        <tr>
                            <td class="ps-3 fw-semibold">BS${bs.maBoSach}</td>
                            <td>${bs.tenBoSach}</td>
                            <td class="text-muted" style="font-size:13px;">${bs.moTa}</td>
                            <td class="text-end">
                                <span class="badge rounded-pill" style="background:#eef2ff;color:#4338ca;">${soSach} sách</span>
                            </td>
                            <td class="text-end pe-3">
                                <button type="button" class="btn btn-sm btn-outline-secondary me-1" style="border-radius:6px;" title="Sửa"
                                        data-bs-toggle="modal" data-bs-target="#modalBoSach"
                                        onclick="moModalSuaBS(${bs.maBoSach}, '${bs.tenBoSach}', '${bs.moTa}')">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-danger" style="border-radius:6px;" title="Xóa"
                                        onclick="xacNhanXoaBS(${bs.maBoSach}, '${bs.tenBoSach}', ${soSach})">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty danhSachBoSach}">
                        <tr><td colspan="5" class="text-center text-muted py-5">Chưa có bộ sách nào.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>
</div>

<!-- Modal them/sua the loai -->
<div class="modal fade" id="modalTheLoai" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/danhmuc">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="tab" value="theloai">
                <input type="hidden" name="mode" id="fMode" value="them">
                <input type="hidden" name="maTL" id="fMaTL" value="">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold" id="modalTieuDe">Thêm thể loại</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <label class="form-label">Tên thể loại *</label>
                    <input type="text" name="tenTL" id="fTenTL" class="form-control" placeholder="VD: Trinh thám" required>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" style="font-size:13.5px;border-radius:6px;">Hủy</button>
                    <button type="submit" class="btn btn-primary-book">Lưu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal them/sua tac gia -->
<div class="modal fade" id="modalTacGia" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/danhmuc">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="tab" value="tacgia">
                <input type="hidden" name="mode" id="fModeTG" value="them">
                <input type="hidden" name="maTG" id="fMaTG" value="">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold" id="modalTieuDeTG">Thêm tác giả</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <label class="form-label">Tên tác giả *</label>
                    <input type="text" name="tenTG" id="fTenTG" class="form-control mb-3" placeholder="VD: Nguyễn Nhật Ánh" required>
                    <label class="form-label">Tiểu sử</label>
                    <textarea name="tieuSu" id="fTieuSu" class="form-control" rows="3" placeholder="Vài dòng giới thiệu về tác giả"></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" style="font-size:13.5px;border-radius:6px;">Hủy</button>
                    <button type="submit" class="btn btn-primary-book">Lưu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal them/sua nha xuat ban -->
<div class="modal fade" id="modalNXB" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/danhmuc">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="tab" value="nxb">
                <input type="hidden" name="mode" id="fModeNXB" value="them">
                <input type="hidden" name="maNXB" id="fMaNXB" value="">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold" id="modalTieuDeNXB">Thêm nhà xuất bản</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <label class="form-label">Tên nhà xuất bản *</label>
                    <input type="text" name="tenNXB" id="fTenNXB" class="form-control mb-3" placeholder="VD: NXB Trẻ" required>
                    <label class="form-label">Số điện thoại</label>
                    <input type="text" name="sdt" id="fSdt" class="form-control mb-3" placeholder="VD: 028 3999 9999">
                    <label class="form-label">Địa chỉ</label>
                    <input type="text" name="diaChi" id="fDiaChi" class="form-control" placeholder="Địa chỉ liên hệ">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" style="font-size:13.5px;border-radius:6px;">Hủy</button>
                    <button type="submit" class="btn btn-primary-book">Lưu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal them/sua bo sach -->
<div class="modal fade" id="modalBoSach" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/danhmuc">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="tab" value="bosach">
                <input type="hidden" name="mode" id="fModeBS" value="them">
                <input type="hidden" name="maBoSach" id="fMaBoSach" value="">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold" id="modalTieuDeBS">Thêm bộ sách</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <label class="form-label">Tên bộ sách *</label>
                    <input type="text" name="tenBoSach" id="fTenBoSach" class="form-control mb-3" placeholder="VD: Kính Vạn Hoa" required>
                    <label class="form-label">Mô tả</label>
                    <textarea name="moTa" id="fMoTa" class="form-control" rows="3" placeholder="Mô tả ngắn về bộ sách / series"></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" style="font-size:13.5px;border-radius:6px;">Hủy</button>
                    <button type="submit" class="btn btn-primary-book">Lưu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Form an phuc vu xoa -->
<form id="formXoaTL" method="post" action="${pageContext.request.contextPath}/danhmuc">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="tab" value="theloai">
    <input type="hidden" name="ma" id="maTLXoa">
</form>

<form id="formXoaTG" method="post" action="${pageContext.request.contextPath}/danhmuc">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="tab" value="tacgia">
    <input type="hidden" name="ma" id="maTGXoa">
</form>

<form id="formXoaNXB" method="post" action="${pageContext.request.contextPath}/danhmuc">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="tab" value="nxb">
    <input type="hidden" name="ma" id="maNXBXoa">
</form>

<form id="formXoaBS" method="post" action="${pageContext.request.contextPath}/danhmuc">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="tab" value="bosach">
    <input type="hidden" name="ma" id="maBSXoa">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ===== The loai =====
    function moModalThem() {
        document.getElementById('modalTieuDe').textContent = 'Thêm thể loại';
        document.getElementById('fMode').value = 'them';
        document.getElementById('fMaTL').value = '';
        document.getElementById('fTenTL').value = '';
    }

    function moModalSua(maTL, tenTL) {
        document.getElementById('modalTieuDe').textContent = 'Sửa thể loại';
        document.getElementById('fMode').value = 'sua';
        document.getElementById('fMaTL').value = maTL;
        document.getElementById('fTenTL').value = tenTL;
    }

    function xacNhanXoa(maTL, tenTL, soSach) {
        if (soSach > 0) {
            alert('Không thể xóa "' + tenTL + '" vì đang có ' + soSach + ' đầu sách thuộc thể loại này.');
            return;
        }
        if (confirm('Xóa thể loại "' + tenTL + '"?')) {
            document.getElementById('maTLXoa').value = maTL;
            document.getElementById('formXoaTL').submit();
        }
    }

    // ===== Tac gia =====
    function moModalThemTG() {
        document.getElementById('modalTieuDeTG').textContent = 'Thêm tác giả';
        document.getElementById('fModeTG').value = 'them';
        document.getElementById('fMaTG').value = '';
        document.getElementById('fTenTG').value = '';
        document.getElementById('fTieuSu').value = '';
    }

    function moModalSuaTG(maTG, tenTG, tieuSu) {
        document.getElementById('modalTieuDeTG').textContent = 'Sửa tác giả';
        document.getElementById('fModeTG').value = 'sua';
        document.getElementById('fMaTG').value = maTG;
        document.getElementById('fTenTG').value = tenTG;
        document.getElementById('fTieuSu').value = tieuSu === 'null' ? '' : tieuSu;
    }

    function xacNhanXoaTG(maTG, tenTG, soSach) {
        if (soSach > 0) {
            alert('Không thể xóa "' + tenTG + '" vì đang có ' + soSach + ' đầu sách của tác giả này.');
            return;
        }
        if (confirm('Xóa tác giả "' + tenTG + '"?')) {
            document.getElementById('maTGXoa').value = maTG;
            document.getElementById('formXoaTG').submit();
        }
    }

    // ===== Nha xuat ban =====
    function moModalThemNXB() {
        document.getElementById('modalTieuDeNXB').textContent = 'Thêm nhà xuất bản';
        document.getElementById('fModeNXB').value = 'them';
        document.getElementById('fMaNXB').value = '';
        document.getElementById('fTenNXB').value = '';
        document.getElementById('fSdt').value = '';
        document.getElementById('fDiaChi').value = '';
    }

    function moModalSuaNXB(maNXB, tenNXB, sdt, diaChi) {
        document.getElementById('modalTieuDeNXB').textContent = 'Sửa nhà xuất bản';
        document.getElementById('fModeNXB').value = 'sua';
        document.getElementById('fMaNXB').value = maNXB;
        document.getElementById('fTenNXB').value = tenNXB;
        document.getElementById('fSdt').value = sdt === 'null' ? '' : sdt;
        document.getElementById('fDiaChi').value = diaChi === 'null' ? '' : diaChi;
    }

    function xacNhanXoaNXB(maNXB, tenNXB, soSach) {
        if (soSach > 0) {
            alert('Không thể xóa "' + tenNXB + '" vì đang có ' + soSach + ' đầu sách của nhà xuất bản này.');
            return;
        }
        if (confirm('Xóa nhà xuất bản "' + tenNXB + '"?')) {
            document.getElementById('maNXBXoa').value = maNXB;
            document.getElementById('formXoaNXB').submit();
        }
    }

    // ===== Bo sach =====
    function moModalThemBS() {
        document.getElementById('modalTieuDeBS').textContent = 'Thêm bộ sách';
        document.getElementById('fModeBS').value = 'them';
        document.getElementById('fMaBoSach').value = '';
        document.getElementById('fTenBoSach').value = '';
        document.getElementById('fMoTa').value = '';
    }

    function moModalSuaBS(maBoSach, tenBoSach, moTa) {
        document.getElementById('modalTieuDeBS').textContent = 'Sửa bộ sách';
        document.getElementById('fModeBS').value = 'sua';
        document.getElementById('fMaBoSach').value = maBoSach;
        document.getElementById('fTenBoSach').value = tenBoSach;
        document.getElementById('fMoTa').value = moTa === 'null' ? '' : moTa;
    }

    function xacNhanXoaBS(maBoSach, tenBoSach, soSach) {
        if (soSach > 0) {
            alert('Không thể xóa "' + tenBoSach + '" vì đang có ' + soSach + ' đầu sách thuộc bộ sách này.');
            return;
        }
        if (confirm('Xóa bộ sách "' + tenBoSach + '"?')) {
            document.getElementById('maBSXoa').value = maBoSach;
            document.getElementById('formXoaBS').submit();
        }
    }
</script>
</body>
</html>
