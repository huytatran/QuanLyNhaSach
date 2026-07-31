package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Servlet serve ảnh bìa sách từ thư mục ngoài webapp.
 * URL: /book-images/S001.jpg
 * File thực tế: D:/DoAn_NhomDuAn1/uploads/books/S001.jpg
 */
@WebServlet("/book-images/*")
public class ImageServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "D:/DoAn_NhomDuAn1/uploads/books";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy tên file từ URL: /book-images/S001.jpg → S001.jpg
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Bảo vệ path traversal
        String fileName = Paths.get(pathInfo).getFileName().toString();
        Path filePath = Paths.get(UPLOAD_DIR, fileName);

        if (!Files.exists(filePath) || !Files.isReadable(filePath)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Xác định content type theo extension
        String contentType = getServletContext().getMimeType(fileName);
        if (contentType == null) contentType = "image/jpeg";

        response.setContentType(contentType);
        response.setContentLengthLong(Files.size(filePath));

        // Ghi file ra response
        try (OutputStream out = response.getOutputStream()) {
            Files.copy(filePath, out);
        }
    }
}
