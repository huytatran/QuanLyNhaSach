package utils;

import entity.*;
import org.hibernate.SessionFactory;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cfg.Configuration;
import org.hibernate.cfg.Environment;
import org.hibernate.service.ServiceRegistry;

import java.util.Properties;

/**
 * Central Hibernate configuration.
 *
 * <p>Connection values can be supplied either as JVM properties (for example
 * {@code -Ddb.password=...}) or environment variables ({@code DB_PASSWORD}).
 * JVM properties take precedence.</p>
 */
public final class HibernateConfig {
    private static final SessionFactory FACTORY = buildSessionFactory();

    private HibernateConfig() {
    }

    private static SessionFactory buildSessionFactory() {
        Configuration configuration = new Configuration();
        Properties properties = new Properties();

        properties.put(Environment.DRIVER, "com.microsoft.sqlserver.jdbc.SQLServerDriver");
        properties.put(Environment.URL, value("db.url", "DB_URL",
                "jdbc:sqlserver://localhost:1433;databaseName=QuanLyNhaSach;encrypt=true;trustServerCertificate=true;"));
        properties.put(Environment.USER, value("db.user", "DB_USER", "sa"));
        properties.put(Environment.PASS, value("db.password", "DB_PASSWORD", "bao11022007"));
        properties.put(Environment.SHOW_SQL, value("hibernate.show_sql", "HIBERNATE_SHOW_SQL", "false"));
        properties.put(Environment.FORMAT_SQL, value("hibernate.format_sql", "HIBERNATE_FORMAT_SQL", "true"));

        configuration.setProperties(properties);
        addAnnotatedClasses(configuration);

        ServiceRegistry registry = new StandardServiceRegistryBuilder()
                .applySettings(configuration.getProperties())
                .build();
        return configuration.buildSessionFactory(registry);
    }

    private static String value(String propertyName, String environmentName, String defaultValue) {
        String value = System.getProperty(propertyName);
        if (value == null || value.isBlank()) {
            value = System.getenv(environmentName);
        }
        return value == null || value.isBlank() ? defaultValue : value;
    }

    private static void addAnnotatedClasses(Configuration configuration) {
        configuration.addAnnotatedClass(TheLoai.class);
        configuration.addAnnotatedClass(NhaXuatBan.class);
        configuration.addAnnotatedClass(TacGia.class);
        configuration.addAnnotatedClass(BoSach.class);
        configuration.addAnnotatedClass(NhanVien.class);
        configuration.addAnnotatedClass(KhachHang.class);
        configuration.addAnnotatedClass(Sach.class);
        configuration.addAnnotatedClass(SachVatLy.class);
        configuration.addAnnotatedClass(SachTacGia.class);
        configuration.addAnnotatedClass(DonHang.class);
        configuration.addAnnotatedClass(ChiTietDonHang.class);
        configuration.addAnnotatedClass(Voucher.class);
        configuration.addAnnotatedClass(DiaChiKhachHang.class);
        configuration.addAnnotatedClass(DanhGia.class);
    }

    public static SessionFactory getFACTORY() {
        return FACTORY;
    }

    public static void close() {
        if (!FACTORY.isClosed()) {
            FACTORY.close();
        }
    }
}
