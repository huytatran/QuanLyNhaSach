package utils;

import entity.*;
import org.hibernate.SessionFactory;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cfg.Configuration;
import org.hibernate.cfg.Environment;
import org.hibernate.service.ServiceRegistry;

import java.util.Properties;

public class HibernateConfig {
    private static final SessionFactory FACTORY;

    static {
        Configuration conf = new Configuration();

        Properties properties = new Properties();
        properties.put(Environment.DIALECT, "org.hibernate.dialect.SQLServer2016Dialect");
        properties.put(Environment.DRIVER, "com.microsoft.sqlserver.jdbc.SQLServerDriver");
        properties.put(Environment.URL, "jdbc:sqlserver://localhost:1433;databaseName=QuanLyNhaSach;encrypt=true;trustServerCertificate=true;");
        properties.put(Environment.USER, "sa");
        properties.put(Environment.PASS, "123456");
        properties.put(Environment.SHOW_SQL, "true");

        /*
            - Khai báo cho Hibernate biết các Class nào trong Java sẽ được ánh xạ xuống database
            - Khi ứng dụng chạy, Hibernate sẽ quét các class xxx1 và xxx2 (thường có annotation @Entity) để quản lý chúng.
        */
        conf.addAnnotatedClass(TheLoai.class);
        conf.addAnnotatedClass(NhaXuatBan.class);
        conf.addAnnotatedClass(TacGia.class);
        conf.addAnnotatedClass(BoSach.class);
        conf.addAnnotatedClass(NhanVien.class);
        conf.addAnnotatedClass(KhachHang.class);
        conf.addAnnotatedClass(Sach.class);
        conf.addAnnotatedClass(SachVatLy.class);
        conf.addAnnotatedClass(SachTacGia.class); // Chỉ khai báo SachTacGia, KHÔNG khai báo SachTacGiaId
        conf.addAnnotatedClass(DonHang.class);
        conf.addAnnotatedClass(ChiTietDonHang.class);
        conf.addAnnotatedClass(Voucher.class);
        conf.addAnnotatedClass(DiaChiKhachHang.class);
        conf.addAnnotatedClass(DanhGia.class);
        conf.setProperties(properties);
        ServiceRegistry registry = new StandardServiceRegistryBuilder()
                .applySettings(conf.getProperties()).build();
        //dùng Configuration và ServiceRegistry để "đúc" ra FACTORY- một đối tượng SessionFactory
        FACTORY = conf.buildSessionFactory(registry);

    }

    public static SessionFactory getFACTORY() {
        return FACTORY;
    }

    public static void main(String[] args) {
        System.out.println(getFACTORY());
    }

}
