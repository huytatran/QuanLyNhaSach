<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>Phiếu <c:if test="${lichSu.loaiGiaoDich == 'DOI'}">đổi hàng</c:if><c:if test="${lichSu.loaiGiaoDich == 'TRA'}">trả hàng</c:if> - #${lichSu.maDoiTra}</title>
    <style>
        body { font-family: "Segoe UI", Arial, sans-serif; color:#000; max-width: 640px; margin: 24px auto; padding: 0 16px; }
        h3 { text-align:center; margin-bottom:2px; }
        .subtitle { text-align:center; font-size:13px; color:#444; margin-bottom:20px; }
        table { width:100%; border-collapse: collapse; font-size:14px; }
        .info td { padding:4px 0; vertical-align:top; }
        .items th, .items td { border-bottom:1px solid #ddd; padding:6px 4px; text-align:left; }
        .items thead th { border-bottom:2px solid #000; }
        .text-right { text-align:right; }
        .text-center { text-align:center; }
        .tong { border-top:2px solid #000; font-weight:bold; }
        .sign { margin-top:60px; }
        .sign td { text-align:center; }
        .no-print { text-align:center; margin-bottom:20px; }
        @media print { .no-print { display:none; } }
    </style>
</head>
<body onload="window.print()">
<div class="no-print">
    <button onclick="window.print()">In phiếu này</button>
</div>

<h3>
    <c:if test="${lichSu.loaiGiaoDich == 'DOI'}">PHIẾU ĐỔI HÀNG</c:if>
    <c:if test="${lichSu.loaiGiaoDich == 'TRA'}">PHIẾU TRẢ HÀNG</c:if>
</h3>
<div class="subtitle">Portal.BookStore &nbsp;•&nbsp; Số phiếu: #${lichSu.maDoiTra} &nbsp;•&nbsp; Thuộc đơn hàng #${lichSu.donHang.maDH}</div>

<table class="info">
    <tr>
        <td style="width:50%;">
            <strong>Thời gian lập phiếu:</strong><br>
            <fmt:parseDate value="${lichSu.ngayThucHien}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedLS" type="both" />
            <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedLS}" />
        </td>
        <td>
            <strong>Khách hàng:</strong> ${lichSu.donHang.khachHang.tenKH}<br>
            <strong>Nhân viên xử lý:</strong> ${lichSu.donHang.nhanVien.tenNV}
        </td>
    </tr>
</table>

<table class="items" style="margin-top:16px;">
    <thead>
    <tr>
        <th>Nội dung</th>
        <th class="text-center">Số lượng</th>
        <th class="text-right">Đơn giá</th>
        <th class="text-right">Thành tiền</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <td>Trả lại: ${lichSu.chiTietCu.sach.tenSach}</td>
        <td class="text-center">${lichSu.soLuongTra}</td>
        <td class="text-right"><fmt:formatNumber value="${lichSu.chiTietCu.donGia}" pattern="#,##0"/> ₫</td>
        <td class="text-right">-<fmt:formatNumber value="${lichSu.soLuongTra * lichSu.chiTietCu.donGia}" pattern="#,##0"/> ₫</td>
    </tr>
    <c:if test="${lichSu.loaiGiaoDich == 'DOI'}">
        <tr>
            <td>Nhận thêm: ${lichSu.sachMoi.tenSach}</td>
            <td class="text-center">${lichSu.soLuongMoi}</td>
            <td class="text-right"><fmt:formatNumber value="${lichSu.sachMoi.giaBan}" pattern="#,##0"/> ₫</td>
            <td class="text-right"><fmt:formatNumber value="${lichSu.soLuongMoi * lichSu.sachMoi.giaBan}" pattern="#,##0"/> ₫</td>
        </tr>
    </c:if>
    </tbody>
    <tfoot>
    <tr class="tong">
        <td colspan="3" class="text-right">
            <c:if test="${lichSu.chenhLechTien < 0}">SỐ TIỀN HOÀN LẠI KHÁCH:</c:if>
            <c:if test="${lichSu.chenhLechTien >= 0}">SỐ TIỀN KHÁCH TRẢ THÊM:</c:if>
        </td>
        <td class="text-right"><fmt:formatNumber value="${lichSu.chenhLechTien < 0 ? -lichSu.chenhLechTien : lichSu.chenhLechTien}" pattern="#,##0"/> ₫</td>
    </tr>
    </tfoot>
</table>

<c:if test="${not empty lichSu.lyDo}">
    <p style="margin-top:14px; font-size:13.5px;"><strong>Lý do:</strong> ${lichSu.lyDo}</p>
</c:if>

<table class="sign">
    <tr>
        <td style="width:50%;">Khách hàng<br>(Ký, ghi rõ họ tên)</td>
        <td style="width:50%;">Nhân viên xử lý<br>(Ký, ghi rõ họ tên)</td>
    </tr>
</table>
</body>
</html>
