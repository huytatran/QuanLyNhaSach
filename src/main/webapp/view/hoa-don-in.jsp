<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<html>
<head>
    <title>Hóa đơn bán hàng - #${donHang.maDH}</title>
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
    <button onclick="window.print()">In hóa đơn này</button>
</div>

<h3>HÓA ĐƠN BÁN HÀNG</h3>
<div class="subtitle">Portal.BookStore &nbsp;•&nbsp; Số hóa đơn: #${donHang.maDH}</div>

<table class="info">
    <tr>
        <td style="width:50%;">
            <strong>Thời gian lập:</strong><br>
            <fmt:parseDate value="${donHang.ngayLap}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDT" type="both" />
            <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedDT}" /><br>
            <strong>Thanh toán:</strong> ${donHang.phuongThucThanhToan}
        </td>
        <td>
            <strong>Khách hàng:</strong> ${donHang.khachHang.tenKH}<br>
            <strong>Nhân viên bán:</strong> ${donHang.nhanVien.tenNV}
        </td>
    </tr>
</table>

<table class="items" style="margin-top:16px;">
    <thead>
    <tr>
        <th>Sách</th>
        <th class="text-center">SL</th>
        <th class="text-right">Đơn giá</th>
        <th class="text-right">Thành tiền</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach var="ct" items="${donHang.chiTietDonHangs}">
        <tr>
            <td>${ct.sach.tenSach}</td>
            <td class="text-center">${ct.soLuong}</td>
            <td class="text-right"><fmt:formatNumber value="${ct.donGia}" pattern="#,##0"/> ₫</td>
            <td class="text-right"><fmt:formatNumber value="${ct.soLuong * ct.donGia}" pattern="#,##0"/> ₫</td>
        </tr>
    </c:forEach>
    </tbody>
    <tfoot>
    <tr class="tong">
        <td colspan="3" class="text-right">TỔNG CỘNG:</td>
        <td class="text-right"><fmt:formatNumber value="${donHang.tongTien}" pattern="#,##0"/> ₫</td>
    </tr>
    </tfoot>
</table>

<table class="sign">
    <tr>
        <td style="width:50%;">Khách hàng<br>(Ký, ghi rõ họ tên)</td>
        <td style="width:50%;">Nhân viên bán hàng<br>(Ký, ghi rõ họ tên)</td>
    </tr>
</table>
</body>
</html>
