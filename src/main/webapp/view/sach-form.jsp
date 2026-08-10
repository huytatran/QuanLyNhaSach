<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>${dangSua ? 'Sửa sách' : 'Thêm sách'} - Portal.BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        label.form-label { font-size: 12.5px; font-weight: 600; color: #475569; }
        .form-control, .form-select { font-size: 13.5px; border-color: #cbd5e1; border-radius: 6px; }
        .form-control:focus, .form-select:focus { border-color: #4f46e5; box-shadow: 0 0 0 3px rgba(79,70,229,0.12); }
    </style>
</head>
<body>

<jsp:include page="common/sidebar.jsp" />
<jsp:include page="common/topbar.jsp" />

<div style="margin-left: 280px; margin-top: 60px;" class="p-4">
    <div class="container-fluid" style="max-width: 760px;">

        <div class="mb-4">
            <a href="${pageContext.request.contextPath}/sach" class="text-decoration-none" style="font-size: 13px; color: #64748b;">
                <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách sách
            </a>
            <h4 class="fw-bold mt-2 mb-0" style="color: #0f172a;">
                ${dangSua ? 'Sửa thông tin sách' : 'Thêm sách mới'}
            </h4>
        </div>

        <c:if test="${not empty thongBaoLoi}">
            <div class="alert border-0 mb-4" style="background-color: #fef2f2; color: #991b1b; border-radius: 8px; font-size: 13.5px;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${thongBaoLoi}
            </div>
        </c:if>

        <div class="card bg-white border" style="border-color: #e2e8f0; border-radius: 10px;">
            <div class="card-body p-4">
                <form method="post" action="${pageContext.request.contextPath}/sach" enctype="multipart/form-data">
                    <input type="hidden" name="mode" value="${dangSua ? 'sua' : 'them'}">
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="anhBiaHienTai" value="${sach.anhBia}">

                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label">Mã sách *</label>
                            <input type="text" name="maSach" value="${sach.maSach}" class="form-control"
                                   placeholder="VD: S011" required
                                   <c:if test="${dangSua}">readonly</c:if>>
                        </div>
                        <div class="col-md-8">
                            <label class="form-label">Tên sách *</label>
                            <input type="text" name="tenSach" value="${sach.tenSach}" class="form-control" placeholder="Nhập tên sách" required>
                        </div>

                        <div class="col-12">
                            <label class="form-label">
                                Ảnh bìa
                                <i class="bi bi-info-circle text-muted" title="Chọn file từ máy hoặc dán URL ảnh có sẵn"></i>
                            </label>
                            <div class="d-flex align-items-start gap-3">
                                <img id="previewAnhBia"
                                     src="${not empty sach.anhBia ? sach.anhBia : ''}"
                                     style="width:70px;height:92px;object-fit:cover;border-radius:8px;border:1px solid #e2e8f0;background:#f1f5f9;flex-shrink:0;${empty sach.anhBia ? 'display:none;' : ''}" />
                                <div class="flex-grow-1">
                                    <div class="form-text mb-1" style="font-size:12px;">Chọn file từ máy</div>
                                    <input type="file" name="anhBiaFile" id="inputAnhBia" accept="image/png,image/jpeg,image/webp" class="form-control">
                                    <div class="form-text mt-1" style="font-size:12px;">Hoặc dán URL ảnh</div>
                                    <div class="d-flex gap-2 mt-1">
                                        <input type="text" name="anhBiaUrl" id="inputAnhBiaUrl" value="" class="form-control form-control-sm" placeholder="https://...">
                                        <button type="button" id="btnApDungUrl" class="btn btn-outline-secondary btn-sm" style="flex-shrink:0;white-space:nowrap;">Áp dụng</button>
                                    </div>
                                    <div class="form-text mt-1" style="font-size:12px;">Ảnh JPG/PNG/WEBP, tối đa 3MB. File sẽ được ưu tiên nếu chọn cả hai. Bỏ trống cả hai nếu không muốn đổi ảnh.</div>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Ảnh bìa</label>
                            <div class="mb-2 text-center" id="previewContainer"
                                 style="${not empty sach.anhBia ? '' : 'display:none'}">
                                <img id="imgPreview"
                                     src="${not empty sach.anhBia ? sach.anhBia : ''}"
                                     alt="Ảnh bìa"
                                     style="width:80px;height:105px;object-fit:cover;border-radius:8px;border:1px solid #e2e8f0;"
                                     onerror="this.closest('#previewContainer').style.display='none'">
                            </div>
                            <label class="form-label mb-1" style="font-size:11.5px;color:#64748b;">① Chọn file từ máy</label>
                            <input type="file" name="anhBiaFile" id="anhBiaFile"
                                   accept="image/*" class="form-control form-control-sm mb-2"
                                   onchange="previewAnhFile(this)">
                            <label class="form-label mb-1" style="font-size:11.5px;color:#64748b;">② Hoặc dán URL ảnh</label>
                            <div class="d-flex gap-1">
                                <input type="text" id="anhBiaUrlInput" class="form-control form-control-sm"
                                       placeholder="https://..."
                                       value="${sach.anhBia}"
                                       oninput="previewAnhUrl(this.value)">
                                <button type="button" class="btn btn-sm btn-outline-secondary"
                                        style="white-space:nowrap;font-size:11px;"
                                        onclick="apDungUrl()">Áp dụng</button>
                            </div>
                            <input type="hidden" name="anhBia" id="anhBiaHidden" value="${sach.anhBia}">
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Năm xuất bản</label>
                            <input type="number" name="namXB" value="${sach.namXB}" class="form-control" placeholder="VD: 2020">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Giá bán (₫) *</label>
                            <input type="number" step="1000" min="0" name="giaBan" value="${sach.giaBan}" class="form-control" placeholder="VD: 75000" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Thể loại *</label>
                            <div class="d-flex gap-1">
                                <select id="selectMaTL" name="maTL" class="form-select" required>
                                    <option value="">-- Chọn thể loại --</option>
                                    <c:forEach var="tl" items="${dsTheLoai}">
                                        <option value="${tl.maTL}" ${sach.theLoai.maTL == tl.maTL ? 'selected' : ''}>${tl.tenTL}</option>
                                    </c:forEach>
                                </select>
                                <button type="button" title="Thêm thể loại mới"
                                        onclick="moQuickAdd('theloai','Thêm thể loại mới','Tên thể loại','selectMaTL')"
                                        style="flex-shrink:0;width:36px;height:36px;border:1px solid #cbd5e1;border-radius:6px;background:#f8fafc;color:#4f46e5;font-size:16px;display:flex;align-items:center;justify-content:center;cursor:pointer;">
                                    <i class="bi bi-plus-lg"></i>
                                </button>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Nhà xuất bản *</label>
                            <div class="d-flex gap-1">
                                <select id="selectMaNXB" name="maNXB" class="form-select" required>
                                    <option value="">-- Chọn nhà xuất bản --</option>
                                    <c:forEach var="nxb" items="${dsNXB}">
                                        <option value="${nxb.maNXB}" ${sach.nhaXuatBan.maNXB == nxb.maNXB ? 'selected' : ''}>${nxb.tenNXB}</option>
                                    </c:forEach>
                                </select>
                                <button type="button" title="Thêm nhà xuất bản mới"
                                        onclick="moQuickAdd('nxb','Thêm nhà xuất bản mới','Tên nhà xuất bản','selectMaNXB')"
                                        style="flex-shrink:0;width:36px;height:36px;border:1px solid #cbd5e1;border-radius:6px;background:#f8fafc;color:#4f46e5;font-size:16px;display:flex;align-items:center;justify-content:center;cursor:pointer;">
                                    <i class="bi bi-plus-lg"></i>
                                </button>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Tác giả chính</label>
                            <div class="d-flex gap-1">
                                <select id="selectMaTacGia" name="maTacGia" class="form-select">
                                    <option value="">-- Không chọn --</option>
                                    <c:forEach var="tg" items="${dsTacGia}">
                                        <option value="${tg.maTG}" ${not empty tacGiaChinh and tacGiaChinh.maTG == tg.maTG ? 'selected' : ''}>${tg.tenTG}</option>
                                    </c:forEach>
                                </select>
                                <button type="button" title="Thêm tác giả mới"
                                        onclick="moQuickAdd('tacgia','Thêm tác giả mới','Tên tác giả','selectMaTacGia')"
                                        style="flex-shrink:0;width:36px;height:36px;border:1px solid #cbd5e1;border-radius:6px;background:#f8fafc;color:#4f46e5;font-size:16px;display:flex;align-items:center;justify-content:center;cursor:pointer;">
                                    <i class="bi bi-plus-lg"></i>
                                </button>
                            </div>
                        </div>

                        <div class="col-md-8">
                            <label class="form-label">Bộ sách (nếu có)</label>
                            <select name="maBoSach" id="selectBoSach" class="form-select">
                                <option value="">-- Sách độc lập, không thuộc bộ --</option>
                                <c:forEach var="bs" items="${dsBoSach}">
                                    <option value="${bs.maBoSach}" ${sach.boSach.maBoSach == bs.maBoSach ? 'selected' : ''}>${bs.tenBoSach}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Số phần trong bộ</label>
                            <input type="number" min="1" name="soPhan" id="inputSoPhan" value="${sach.soPhan}" class="form-control" placeholder="VD: 1"
                                   <c:if test="${empty sach.boSach}">disabled</c:if>>
                        </div>
                    </div>

                    <hr class="my-4" style="border-color: #e2e8f0;">

                    <div class="d-flex justify-content-end gap-2">
                        <a href="${pageContext.request.contextPath}/sach" class="btn btn-outline-secondary" style="border-radius: 6px; font-size: 13.5px;">Hủy</a>
                        <button type="submit" class="btn text-white fw-semibold" style="background-color: #4f46e5; border-radius: 6px; font-size: 13.5px; padding: 8px 22px;">
                            <i class="bi bi-check-lg me-1"></i> Lưu sách
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- ===== Biến thể sách ===== -->
        <div class="card bg-white border mt-4" style="border-color: #e2e8f0; border-radius: 10px;">
            <div class="card-body p-4">
                <h6 class="fw-bold mb-1" style="color:#0f172a;">Biến thể sách</h6>
                <p class="text-muted mb-3" style="font-size:12.5px;">
                    Cùng 1 đầu sách nhưng có nhiều phiên bản khác nhau (bìa, ngôn ngữ...), mỗi biến thể có mã và giá bán riêng.
                </p>

                <%-- Thông báo lỗi / thành công (chỉ có khi đang SỬA) --%>
                <c:if test="${not empty param.loiBienThe}">
                    <div class="alert border-0 mb-3" style="background:#fef2f2;color:#991b1b;border-radius:8px;font-size:13px;">${param.loiBienThe}</div>
                </c:if>
                <c:if test="${not empty param.luuBienThe}">
                    <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13px;">Đã lưu biến thể.</div>
                </c:if>
                <c:if test="${not empty param.xoaBienThe}">
                    <div class="alert border-0 mb-3" style="background:#f0fdf4;color:#166534;border-radius:8px;font-size:13px;">Đã xóa biến thể.</div>
                </c:if>

                <%-- ---- MODE SỬA: hiển thị bảng biến thể đã lưu ---- --%>
                <c:if test="${dangSua}">
                    <c:if test="${not empty dsBienThe}">
                        <div class="table-responsive mb-3">
                            <table class="table table-sm mb-0">
                                <thead>
                                <tr style="font-size:11px;text-transform:uppercase;color:#64748b;">
                                    <th>Mã biến thể</th><th>Bìa</th><th>Ngôn ngữ</th>
                                    <th class="text-end">Giá bán</th>
                                    <th class="text-center">Trạng thái</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="bt" items="${dsBienThe}">
                                    <tr style="font-size:13px;">
                                        <td class="fw-semibold">${bt.maBienTheCode}</td>
                                        <td>${empty bt.biaSach ? '—' : bt.biaSach}</td>
                                        <td>${empty bt.ngonNgu ? '—' : bt.ngonNgu}</td>
                                        <td class="text-end"><fmt:formatNumber value="${bt.giaBienThe}" pattern="#,##0"/> ₫</td>
                                        <td class="text-center">
                                            <form method="post" action="${pageContext.request.contextPath}/sach" class="d-inline-block">
                                                <input type="hidden" name="action" value="toggleBienThe">
                                                <input type="hidden" name="maSach" value="${sach.maSach}">
                                                <input type="hidden" name="maBienThe" value="${bt.maBienThe}">
                                                <div class="form-check form-switch d-flex justify-content-center m-0">
                                                    <input class="form-check-input" type="checkbox" role="switch" onchange="this.form.submit()"
                                                           style="width:2.2em;height:1.2em;cursor:pointer;"
                                                        ${bt.trangThai == false ? '' : 'checked'}
                                                           title="${bt.trangThai == false ? 'Ngừng bán — bấm để bán lại' : 'Đang bán — bấm để ngừng bán'}">
                                                </div>
                                            </form>
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-outline-secondary" style="border-radius:6px;"
                                                    onclick="moSuaBienThe(${bt.maBienThe},'${bt.biaSach}','${bt.ngonNgu}','${bt.maBienTheCode}',${bt.giaBienThe})">
                                                <i class="bi bi-pencil"></i>
                                            </button>
                                            <form method="post" action="${pageContext.request.contextPath}/sach" class="d-inline"
                                                  onsubmit="return confirm('Xóa biến thể \'${bt.maBienTheCode}\'?');">
                                                <input type="hidden" name="action" value="xoaBienThe">
                                                <input type="hidden" name="maSach" value="${sach.maSach}">
                                                <input type="hidden" name="maBienThe" value="${bt.maBienThe}">
                                                <button type="submit" class="btn btn-sm btn-outline-danger" style="border-radius:6px;"><i class="bi bi-trash"></i></button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:if>
                    <c:if test="${empty dsBienThe}">
                        <p class="text-muted mb-3" style="font-size:13px;">Sách này chưa có biến thể nào — bán theo giá gốc.</p>
                    </c:if>

                    <hr style="border-color:#e2e8f0;">

                    <%-- Form thêm / sửa biến thể (POST riêng) --%>
                    <form method="post" action="${pageContext.request.contextPath}/sach" id="formBienThe" class="row g-2 align-items-end">
                        <input type="hidden" name="action"    id="actionBienThe" value="themBienThe">
                        <input type="hidden" name="maSach"    value="${sach.maSach}">
                        <input type="hidden" name="maBienThe" id="fMaBienThe"    value="">
                        <div class="col-md-3">
                            <label class="form-label">Bìa</label>
                            <select name="loaiBia" id="fLoaiBia" class="form-select">
                                <option value="">-- Không chọn --</option>
                                <option value="Bìa cứng">Bìa cứng</option>
                                <option value="Bìa mềm">Bìa mềm</option>
                                <option value="Bìa da">Bìa da</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Ngôn ngữ</label>
                            <select name="ngonNgu" id="fNgonNgu" class="form-select">
                                <option value="">-- Không chọn --</option>
                                <option value="Tiếng Việt">Tiếng Việt</option>
                                <option value="Tiếng Anh">Tiếng Anh</option>
                                <option value="Song ngữ Anh-Việt">Song ngữ Anh-Việt</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Mã biến thể *</label>
                            <input type="text" name="maBienTheCode" id="fMaBienTheCode" class="form-control" placeholder="VD: ${sach.maSach}-BC-VI" required>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Giá (₫) *</label>
                            <input type="number" step="1000" min="0" name="giaBanBienThe" id="fGiaBanBienThe" class="form-control" placeholder="VD: 95000" required>
                        </div>
                        <div class="col-md-1">
                            <button type="submit" class="btn btn-outline-primary w-100" id="btnBienThe" style="border-radius:6px;" title="Lưu">
                                <i class="bi bi-plus-lg"></i>
                            </button>
                        </div>
                    </form>
                </c:if>

                <%-- ---- MODE THÊM MỚI: bảng dynamic bằng JS, submit cùng form sách ---- --%>
                <c:if test="${not dangSua}">
                    <div id="bienTheMoiList" class="mb-3"></div>
                    <div class="row g-2 align-items-end" id="formThemBienTheMoi">
                        <div class="col-md-3">
                            <label class="form-label">Bìa</label>
                            <select id="newBia" class="form-select">
                                <option value="">-- Không chọn --</option>
                                <option value="Bìa cứng">Bìa cứng</option>
                                <option value="Bìa mềm">Bìa mềm</option>
                                <option value="Bìa da">Bìa da</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Ngôn ngữ</label>
                            <select id="newNgonNgu" class="form-select">
                                <option value="">-- Không chọn --</option>
                                <option value="Tiếng Việt">Tiếng Việt</option>
                                <option value="Tiếng Anh">Tiếng Anh</option>
                                <option value="Song ngữ Anh-Việt">Song ngữ Anh-Việt</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Mã biến thể *</label>
                            <input type="text" id="newMaCode" class="form-control" placeholder="VD: S011-BC-VI">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Giá (₫) *</label>
                            <input type="number" step="1000" min="0" id="newGia" class="form-control" placeholder="VD: 95000">
                        </div>
                        <div class="col-md-1">
                            <button type="button" onclick="themDongBienThe()"
                                    class="btn btn-outline-primary w-100" style="border-radius:6px;" title="Thêm dòng">
                                <i class="bi bi-plus-lg"></i>
                            </button>
                        </div>
                    </div>
                    <p class="text-muted mt-2 mb-0" style="font-size:11.5px;">
                        <i class="bi bi-info-circle me-1"></i>Thêm dòng rồi bấm "Lưu sách" — biến thể sẽ được lưu cùng lúc.
                    </p>
                </c:if>

            </div>
        </div>

    </div>
</div>

<!-- Mini-modal thêm nhanh (đặt TRƯỚC <script> để các phần tử #qaBtn, #qaInput...
     đã có sẵn trong DOM khi script bên dưới chạy - script chạy đồng bộ ngay khi
     trình duyệt đọc tới thẻ <script>, không đợi phần HTML phía sau nó) -->
<div class="modal fade" id="quickAddModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:380px;">
        <div class="modal-content" style="border-radius:12px;border:none;box-shadow:0 8px 32px rgba(15,23,42,.15);">
            <div class="modal-header border-0 pb-1">
                <h6 class="modal-title fw-bold" id="qaModalTitle" style="color:#0f172a;font-size:14.5px;"></h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body pt-2">
                <label class="form-label" id="qaInputLabel"></label>
                <input type="text" id="qaInput" class="form-control" autocomplete="off">
                <div id="qaError" style="font-size:12.5px;color:#dc2626;margin-top:6px;display:none;"></div>
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal" style="border-radius:6px;">Hủy</button>
                <button type="button" class="btn btn-sm text-white fw-semibold" id="qaBtn"
                        style="background:#4f46e5;border-radius:6px;min-width:90px;">
                    <span id="qaBtnText"><i class="bi bi-plus-lg me-1"></i>Thêm</span>
                    <span id="qaBtnSpinner" class="spinner-border spinner-border-sm" style="display:none;"></span>
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Chi cho nhap "So phan" khi da chon 1 Bo Sach cu the
    const selectBoSach = document.getElementById('selectBoSach');
    const inputSoPhan = document.getElementById('inputSoPhan');
    selectBoSach.addEventListener('change', function () {
        inputSoPhan.disabled = (this.value === '');
        if (this.value === '') inputSoPhan.value = '';
    });

    // Chuyen form Bien the giua che do "them" va "sua"
    function moSuaBienThe(maBienThe, loaiBia, ngonNgu, maCode, giaBan) {
        document.getElementById('actionBienThe').value = 'suaBienThe';
        document.getElementById('fMaBienThe').value = maBienThe;
        document.getElementById('fLoaiBia').value = loaiBia || '';
        document.getElementById('fNgonNgu').value = ngonNgu || '';
        document.getElementById('fMaBienTheCode').value = maCode;
        document.getElementById('fGiaBanBienThe').value = giaBan;
        document.getElementById('btnBienThe').innerHTML = '<i class="bi bi-check-lg"></i>';
        document.getElementById('fMaBienTheCode').scrollIntoView({behavior:'smooth', block:'center'});
    }

    // Preview ảnh khi chọn file từ máy
    function previewAnhFile(input) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                showPreview(e.target.result);
                document.getElementById('anhBiaUrlInput').value = '';
                document.getElementById('anhBiaHidden').value = '';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    // Preview khi nhập URL
    function previewAnhUrl(url) {
        if (url && url.startsWith('http')) showPreview(url);
    }

    // Áp dụng URL vào hidden field
    function apDungUrl() {
        const url = document.getElementById('anhBiaUrlInput').value.trim();
        if (!url) return;
        document.getElementById('anhBiaHidden').value = url;
        document.getElementById('anhBiaFile').value = '';
        showPreview(url);
    }

    function showPreview(src) {
        const container = document.getElementById('previewContainer');
        const img = document.getElementById('imgPreview');
        img.src = src;
        container.style.display = '';
        img.onerror = function() { container.style.display = 'none'; };
    }

    // ---- Biến thể động khi THÊM MỚI sách ----
    let _btRows = []; // [{bia, ngonNgu, maCode, gia}]

    function themDongBienThe() {
        const bia     = document.getElementById('newBia').value.trim();
        const ngonNgu = document.getElementById('newNgonNgu').value.trim();
        const maCode  = document.getElementById('newMaCode').value.trim();
        const gia     = document.getElementById('newGia').value.trim();

        if (!maCode) { alert('Vui lòng nhập mã biến thể.'); return; }
        if (!gia || isNaN(gia) || Number(gia) < 0) { alert('Vui lòng nhập giá hợp lệ.'); return; }
        if (_btRows.find(r => r.maCode === maCode)) { alert('Mã biến thể "' + maCode + '" đã có trong danh sách.'); return; }

        _btRows.push({ bia, ngonNgu, maCode, gia });
        renderBienTheMoi();

        // Reset input
        document.getElementById('newBia').value     = '';
        document.getElementById('newNgonNgu').value = '';
        document.getElementById('newMaCode').value  = '';
        document.getElementById('newGia').value     = '';
        document.getElementById('newMaCode').focus();
    }

    function xoaDongBienThe(idx) {
        _btRows.splice(idx, 1);
        renderBienTheMoi();
    }

    function renderBienTheMoi() {
        const container = document.getElementById('bienTheMoiList');
        // Xoa hidden fields cu
        document.querySelectorAll('.bt-hidden').forEach(el => el.remove());
        const sachForm = document.querySelector('form[action$="/sach"]');

        if (_btRows.length === 0) {
            container.innerHTML = '';
            return;
        }

        let html = '<div class="table-responsive mb-2"><table class="table table-sm mb-0">';
        html += '<thead><tr style="font-size:11px;text-transform:uppercase;color:#64748b;">'
            + '<th>Mã biến thể</th><th>Bìa</th><th>Ngôn ngữ</th>'
            + '<th class="text-end">Giá (₫)</th><th></th></tr></thead><tbody>';

        _btRows.forEach(function(row, i) {
            const giaFmt = Number(row.gia).toLocaleString('vi-VN');
            html += '<tr style="font-size:13px;">'
                + '<td class="fw-semibold">' + escHtml(row.maCode) + '</td>'
                + '<td>' + (row.bia || '—') + '</td>'
                + '<td>' + (row.ngonNgu || '—') + '</td>'
                + '<td class="text-end">' + giaFmt + ' ₫</td>'
                + '<td class="text-end"><button type="button" class="btn btn-sm btn-outline-danger" style="border-radius:6px;" onclick="xoaDongBienThe(' + i + ')">'
                + '<i class="bi bi-trash"></i></button></td></tr>';

            // Thêm hidden fields vào form chính
            ['btBia', 'btNgonNgu', 'btMaCode', 'btGia'].forEach(function(name) {
                const val = name === 'btBia' ? row.bia
                    : name === 'btNgonNgu' ? row.ngonNgu
                        : name === 'btMaCode' ? row.maCode
                            : row.gia;
                const inp = document.createElement('input');
                inp.type = 'hidden'; inp.name = name; inp.value = val || '';
                inp.className = 'bt-hidden';
                sachForm.appendChild(inp);
            });
        });

        html += '</tbody></table></div>';
        container.innerHTML = html;
    }

    function escHtml(s) {
        return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    // ---- Xem truoc anh bia truoc khi upload ----
    document.getElementById('inputAnhBia').addEventListener('change', function (e) {
        const file = e.target.files[0];
        const img = document.getElementById('previewAnhBia');
        if (!file) return;
        if (file.size > 3 * 1024 * 1024) {
            alert('Ảnh vượt quá 3MB, vui lòng chọn ảnh khác.');
            e.target.value = '';
            return;
        }
        document.getElementById('inputAnhBiaUrl').value = ''; // uu tien file, xoa URL da nhap (neu co)
        img.src = URL.createObjectURL(file);
        img.style.display = '';
    });

    // ---- Xem truoc anh bia tu URL ----
    document.getElementById('btnApDungUrl').addEventListener('click', function () {
        const url = document.getElementById('inputAnhBiaUrl').value.trim();
        if (!url) return;
        if (!/^https?:\/\//i.test(url)) {
            alert('URL ảnh không hợp lệ, cần bắt đầu bằng http:// hoặc https://');
            return;
        }
        document.getElementById('inputAnhBia').value = ''; // dung URL thi bo chon file (neu co)
        const img = document.getElementById('previewAnhBia');
        img.onerror = function () { alert('Không tải được ảnh từ URL này, vui lòng kiểm tra lại.'); };
        img.src = url;
        img.style.display = '';
    });

    // ---- Quick-add modal ----
    // Khoi tao modal kieu "lazy" (chi tao khi thuc su can dung) vi phan tu
    // #quickAddModal nam SAU the <script> nay trong HTML - neu khoi tao
    // ngay luc script chay thi getElementById se tra ve null va bootstrap
    // se bao loi, khien toan bo script phia duoi (bao gom cac addEventListener)
    // khong duoc thuc thi.
    let _qaLoai = '', _qaSelectId = '';
    let _qaModal = null;
    function getQaModal() {
        if (!_qaModal) {
            _qaModal = new bootstrap.Modal(document.getElementById('quickAddModal'));
        }
        return _qaModal;
    }

    function moQuickAdd(loai, tieuDe, nhanInput, selectId) {
        _qaLoai     = loai;
        _qaSelectId = selectId;
        document.getElementById('qaModalTitle').textContent  = tieuDe;
        document.getElementById('qaInputLabel').textContent  = nhanInput + ' *';
        document.getElementById('qaInput').placeholder       = 'Nhập ' + nhanInput.toLowerCase() + '...';
        document.getElementById('qaInput').value             = '';
        document.getElementById('qaError').style.display     = 'none';
        document.getElementById('qaError').textContent       = '';
        setQaLoading(false);
        getQaModal().show();
        document.getElementById('quickAddModal').addEventListener('shown.bs.modal', function focusOnce() {
            document.getElementById('qaInput').focus();
            document.getElementById('quickAddModal').removeEventListener('shown.bs.modal', focusOnce);
        });
    }

    function setQaLoading(on) {
        document.getElementById('qaBtn').disabled             = on;
        document.getElementById('qaBtnText').style.display    = on ? 'none' : '';
        document.getElementById('qaBtnSpinner').style.display = on ? 'inline-block' : 'none';
    }

    document.getElementById('qaBtn').addEventListener('click', function () {
        const ten = document.getElementById('qaInput').value.trim();
        const errEl = document.getElementById('qaError');
        if (!ten) { errEl.textContent = 'Vui lòng nhập tên.'; errEl.style.display = ''; return; }
        errEl.style.display = 'none';
        setQaLoading(true);

        const params = new URLSearchParams();
        params.append('action', 'quickAdd');
        params.append('loai',   _qaLoai);
        params.append('ten',    ten);

        fetch('${pageContext.request.contextPath}/danhmuc', {
            method:  'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body:    params.toString()
        })
            .then(r => r.json())
            .then(data => {
                setQaLoading(false);
                if (data.ok) {
                    const sel = document.getElementById(_qaSelectId);
                    const opt = new Option(data.ten, data.id, true, true);
                    sel.add(opt);
                    sel.value = data.id;
                    sel.dispatchEvent(new Event('change'));
                    getQaModal().hide();
                } else {
                    errEl.textContent  = data.loi || 'Có lỗi xảy ra.';
                    errEl.style.display = '';
                }
            })
            .catch(() => {
                setQaLoading(false);
                errEl.textContent  = 'Không thể kết nối máy chủ.';
                errEl.style.display = '';
            });
    });

    document.getElementById('qaInput').addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); document.getElementById('qaBtn').click(); }
    });
</script>
</body>
</html>
