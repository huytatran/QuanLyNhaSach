package utils;

import entity.ChiTietDonHang;
import entity.DonHang;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.time.format.DateTimeFormatter;
import java.util.Properties;

/**
 * Moi: gui hoa don qua email cho khach hang (nut "Gui hoa don qua email" trong
 * trang chi tiet don hang).
 *
 * QUAN TRONG: can dien SMTP_USER / SMTP_PASSWORD ben duoi truoc khi dung (vi du
 * dung Gmail thi bat "App Password" trong tai khoan Google roi dan vao day, KHONG
 * dung mat khau dang nhap Gmail binh thuong). Co the doi SMTP_HOST/SMTP_PORT neu
 * dung nha cung cap email khac (Outlook, mail truong, ...).
 */
public class MailUtil {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SMTP_USER = "TEN_TAI_KHOAN@gmail.com";     // TODO: dien email dung de gui
    private static final String SMTP_PASSWORD = "MAT_KHAU_UNG_DUNG";       // TODO: dien App Password (16 ky tu)
    private static final String TEN_CUA_HANG = "Nhà Sách QuanLyNhaSach";

    public static void guiHoaDon(DonHang dh) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SMTP_USER, false));
        message.setRecipients(Message.RecipientType.TO,
                InternetAddress.parse(dh.getKhachHang().getEmail()));
        message.setSubject("Hóa đơn đơn hàng #" + dh.getMaDH() + " - " + TEN_CUA_HANG);
        message.setContent(taoNoiDungHtml(dh), "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private static String taoNoiDungHtml(DonHang dh) {
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        StringBuilder sb = new StringBuilder();
        sb.append("<div style='font-family:Arial,sans-serif;font-size:14px;color:#1e293b;'>");
        sb.append("<h2 style='margin-bottom:4px;'>").append(TEN_CUA_HANG).append("</h2>");
        sb.append("<p style='color:#64748b;margin-top:0;'>Hóa đơn bán hàng</p>");
        sb.append("<p><b>Mã đơn:</b> #").append(dh.getMaDH()).append("<br>");
        sb.append("<b>Thời gian:</b> ").append(dh.getNgayLap() == null ? "" : dh.getNgayLap().format(dtf)).append("<br>");
        sb.append("<b>Khách hàng:</b> ").append(dh.getKhachHang() == null ? "" : dh.getKhachHang().getTenKH()).append("</p>");

        sb.append("<table style='border-collapse:collapse;width:100%;margin-top:10px;'>");
        sb.append("<tr style='background:#f1f5f9;'>")
                .append("<th style='text-align:left;padding:6px;border:1px solid #e2e8f0;'>Sách</th>")
                .append("<th style='text-align:center;padding:6px;border:1px solid #e2e8f0;'>SL</th>")
                .append("<th style='text-align:right;padding:6px;border:1px solid #e2e8f0;'>Đơn giá</th>")
                .append("<th style='text-align:right;padding:6px;border:1px solid #e2e8f0;'>Thành tiền</th>")
                .append("</tr>");

        if (dh.getChiTietDonHangs() != null) {
            for (ChiTietDonHang ct : dh.getChiTietDonHangs()) {
                java.math.BigDecimal thanhTien = ct.getDonGia().multiply(java.math.BigDecimal.valueOf(ct.getSoLuong()));
                sb.append("<tr>")
                        .append("<td style='padding:6px;border:1px solid #e2e8f0;'>").append(ct.getSach() == null ? "" : ct.getSach().getTenSach()).append("</td>")
                        .append("<td style='text-align:center;padding:6px;border:1px solid #e2e8f0;'>").append(ct.getSoLuong()).append("</td>")
                        .append("<td style='text-align:right;padding:6px;border:1px solid #e2e8f0;'>").append(ct.getDonGia().toPlainString()).append(" đ</td>")
                        .append("<td style='text-align:right;padding:6px;border:1px solid #e2e8f0;'>").append(thanhTien.toPlainString()).append(" đ</td>")
                        .append("</tr>");
            }
        }
        sb.append("</table>");

        sb.append("<p style='margin-top:12px;text-align:right;font-size:16px;'>")
                .append("<b>Tổng tiền: ").append(dh.getTongTien() == null ? "0" : dh.getTongTien().toPlainString()).append(" đ</b></p>");

        sb.append("<p style='color:#94a3b8;font-size:12px;margin-top:20px;'>Cảm ơn quý khách đã mua hàng!</p>");
        sb.append("</div>");
        return sb.toString();
    }
}