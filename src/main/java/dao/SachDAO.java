package dao;

import entity.Sach;
import entity.SachTacGia;
import entity.TacGia;
import org.hibernate.Session;
import org.hibernate.Transaction;
import utils.HibernateConfig;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SachDAO {

    private static final String TRANG_THAI_CO_SAN = "Có sẵn";
    private static final String VAI_TRO_TAC_GIA = "Tác giả";

    public List<Sach> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT DISTINCT s FROM Sach s "
                            + "LEFT JOIN FETCH s.theLoai "
                            + "LEFT JOIN FETCH s.nhaXuatBan "
                            + "LEFT JOIN FETCH s.boSach "
                            + "ORDER BY s.maSach",
                    Sach.class)
                    .getResultList();
        }
    }

    /** Ban co phan trang: trang bat dau tu 1. Sach con hang len truoc, het hang xuong sau. */
    public List<Sach> getAll(int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            // Dung native SQL de ORDER BY ton kho (subquery)
            String sql =
                    "SELECT s.MaSach FROM Sach s " +
                            "LEFT JOIN (SELECT MaSach, COUNT(*) AS TonKho FROM SachVatLy " +
                            "           WHERE TrangThai = N'Có sẵn' GROUP BY MaSach) tk ON s.MaSach = tk.MaSach " +
                            "ORDER BY CASE WHEN ISNULL(tk.TonKho, 0) > 0 THEN 0 ELSE 1 END, s.MaSach " +
                            "OFFSET :offset ROWS FETCH NEXT :limit ROWS ONLY";

            @SuppressWarnings("unchecked")
            List<String> maSachList = session.createNativeQuery(sql, String.class)
                    .setParameter("offset", (trang - 1) * soDongMoiTrang)
                    .setParameter("limit", soDongMoiTrang)
                    .getResultList();

            if (maSachList.isEmpty()) return java.util.Collections.emptyList();

            // Fetch entity day du kem JOIN FETCH
            List<Sach> result = session.createQuery(
                    "SELECT DISTINCT s FROM Sach s " +
                            "LEFT JOIN FETCH s.theLoai " +
                            "LEFT JOIN FETCH s.nhaXuatBan " +
                            "LEFT JOIN FETCH s.boSach " +
                            "WHERE s.maSach IN :maList",
                    Sach.class)
                    .setParameter("maList", maSachList)
                    .getResultList();

            // Giu dung thu tu tu native query
            result.sort(java.util.Comparator.comparingInt(s -> maSachList.indexOf(s.getMaSach())));
            return result;
        }
    }

    public long countAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long c = session.createQuery("SELECT COUNT(s) FROM Sach s", Long.class).uniqueResult();
            return c == null ? 0 : c;
        }
    }

    /**
     * Chi lay sach dang kinh doanh (TrangThai <> false) - dung cho man
     * hinh Ban hang (POS), khong ban sach da bi ngung kinh doanh.
     */
    public List<Sach> getAllDangBan() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT DISTINCT s FROM Sach s "
                            + "LEFT JOIN FETCH s.theLoai "
                            + "LEFT JOIN FETCH s.nhaXuatBan "
                            + "LEFT JOIN FETCH s.boSach "
                            + "WHERE s.trangThai IS NULL OR s.trangThai = true "
                            + "ORDER BY s.maSach",
                    Sach.class)
                    .getResultList();
        }
    }

    /** Ban chi lay sach dang kinh doanh cua search() - dung cho o tim kiem trong POS. */
    public List<Sach> searchDangBan(String tuKhoa) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            return session.createQuery(
                    "SELECT DISTINCT s FROM Sach s "
                            + "LEFT JOIN FETCH s.theLoai "
                            + "LEFT JOIN FETCH s.nhaXuatBan "
                            + "LEFT JOIN FETCH s.boSach "
                            + "WHERE (LOWER(s.maSach) LIKE :q OR LOWER(s.tenSach) LIKE :q) "
                            + "AND (s.trangThai IS NULL OR s.trangThai = true) "
                            + "ORDER BY s.maSach",
                    Sach.class)
                    .setParameter("q", like)
                    .getResultList();
        }
    }

    public List<Sach> search(String tuKhoa) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            return session.createQuery(
                    "SELECT DISTINCT s FROM Sach s "
                            + "LEFT JOIN FETCH s.theLoai "
                            + "LEFT JOIN FETCH s.nhaXuatBan "
                            + "LEFT JOIN FETCH s.boSach "
                            + "WHERE LOWER(s.maSach) LIKE :q OR LOWER(s.tenSach) LIKE :q "
                            + "ORDER BY s.maSach",
                    Sach.class)
                    .setParameter("q", like)
                    .getResultList();
        }
    }

    /** Ban co phan trang: trang bat dau tu 1. Sach con hang len truoc, het hang xuong sau. */
    public List<Sach> search(String tuKhoa, int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";

            String sql =
                    "SELECT s.MaSach FROM Sach s " +
                            "LEFT JOIN (SELECT MaSach, COUNT(*) AS TonKho FROM SachVatLy " +
                            "           WHERE TrangThai = N'Có sẵn' GROUP BY MaSach) tk ON s.MaSach = tk.MaSach " +
                            "WHERE LOWER(s.MaSach) LIKE :q OR LOWER(s.TenSach) LIKE :q " +
                            "ORDER BY CASE WHEN ISNULL(tk.TonKho, 0) > 0 THEN 0 ELSE 1 END, s.MaSach " +
                            "OFFSET :offset ROWS FETCH NEXT :limit ROWS ONLY";

            @SuppressWarnings("unchecked")
            List<String> maSachList = session.createNativeQuery(sql, String.class)
                    .setParameter("q", like)
                    .setParameter("offset", (trang - 1) * soDongMoiTrang)
                    .setParameter("limit", soDongMoiTrang)
                    .getResultList();

            if (maSachList.isEmpty()) return java.util.Collections.emptyList();

            List<Sach> result = session.createQuery(
                    "SELECT DISTINCT s FROM Sach s " +
                            "LEFT JOIN FETCH s.theLoai " +
                            "LEFT JOIN FETCH s.nhaXuatBan " +
                            "LEFT JOIN FETCH s.boSach " +
                            "WHERE s.maSach IN :maList",
                    Sach.class)
                    .setParameter("maList", maSachList)
                    .getResultList();

            result.sort(java.util.Comparator.comparingInt(s -> maSachList.indexOf(s.getMaSach())));
            return result;
        }
    }

    public long countSearch(String tuKhoa) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            Long c = session.createQuery(
                    "SELECT COUNT(DISTINCT s) FROM Sach s WHERE LOWER(s.maSach) LIKE :q OR LOWER(s.tenSach) LIKE :q",
                    Long.class)
                    .setParameter("q", like)
                    .uniqueResult();
            return c == null ? 0 : c;
        }
    }

    // ================================================================
    // Cac method co loc theo trangThai (null = tat ca, true = kinh doanh, false = ngung)
    // ================================================================

    /**
     * Lay danh sach co phan trang + loc trangThai.
     * trangThai = null  -> lay tat ca
     * trangThai = true  -> chi lay sach dang kinh doanh
     * trangThai = false -> chi lay sach ngung kinh doanh
     */
    public List<Sach> getAllByTrangThai(Boolean trangThai, int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String whereClause = buildTrangThaiWhere(trangThai, null);
            String sql =
                    "SELECT s.MaSach FROM Sach s " +
                    "LEFT JOIN (SELECT MaSach, COUNT(*) AS TonKho FROM SachVatLy " +
                    "           WHERE TrangThai = N'Có sẵn' GROUP BY MaSach) tk ON s.MaSach = tk.MaSach " +
                    whereClause +
                    "ORDER BY CASE WHEN ISNULL(tk.TonKho, 0) > 0 THEN 0 ELSE 1 END, s.MaSach " +
                    "OFFSET :offset ROWS FETCH NEXT :limit ROWS ONLY";

            @SuppressWarnings("unchecked")
            List<String> maSachList = session.createNativeQuery(sql, String.class)
                    .setParameter("offset", (trang - 1) * soDongMoiTrang)
                    .setParameter("limit", soDongMoiTrang)
                    .getResultList();

            if (maSachList.isEmpty()) return java.util.Collections.emptyList();

            List<Sach> result = session.createQuery(
                    "SELECT DISTINCT s FROM Sach s " +
                    "LEFT JOIN FETCH s.theLoai LEFT JOIN FETCH s.nhaXuatBan LEFT JOIN FETCH s.boSach " +
                    "WHERE s.maSach IN :maList",
                    Sach.class)
                    .setParameter("maList", maSachList)
                    .getResultList();

            result.sort(java.util.Comparator.comparingInt(s -> maSachList.indexOf(s.getMaSach())));
            return result;
        }
    }

    public long countAllByTrangThai(Boolean trangThai) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(s) FROM Sach s" + buildTrangThaiWhereHql(trangThai, null);
            Long c = session.createQuery(hql, Long.class).uniqueResult();
            return c == null ? 0 : c;
        }
    }

    /** Tim kiem + loc trangThai, co phan trang. */
    public List<Sach> searchByTrangThai(String tuKhoa, Boolean trangThai, int trang, int soDongMoiTrang) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            String whereClause = buildTrangThaiWhere(trangThai, "q");
            String sql =
                    "SELECT s.MaSach FROM Sach s " +
                    "LEFT JOIN (SELECT MaSach, COUNT(*) AS TonKho FROM SachVatLy " +
                    "           WHERE TrangThai = N'Có sẵn' GROUP BY MaSach) tk ON s.MaSach = tk.MaSach " +
                    whereClause +
                    "ORDER BY CASE WHEN ISNULL(tk.TonKho, 0) > 0 THEN 0 ELSE 1 END, s.MaSach " +
                    "OFFSET :offset ROWS FETCH NEXT :limit ROWS ONLY";

            @SuppressWarnings("unchecked")
            List<String> maSachList = session.createNativeQuery(sql, String.class)
                    .setParameter("q", like)
                    .setParameter("offset", (trang - 1) * soDongMoiTrang)
                    .setParameter("limit", soDongMoiTrang)
                    .getResultList();

            if (maSachList.isEmpty()) return java.util.Collections.emptyList();

            List<Sach> result = session.createQuery(
                    "SELECT DISTINCT s FROM Sach s " +
                    "LEFT JOIN FETCH s.theLoai LEFT JOIN FETCH s.nhaXuatBan LEFT JOIN FETCH s.boSach " +
                    "WHERE s.maSach IN :maList",
                    Sach.class)
                    .setParameter("maList", maSachList)
                    .getResultList();

            result.sort(java.util.Comparator.comparingInt(s -> maSachList.indexOf(s.getMaSach())));
            return result;
        }
    }

    public long countSearchByTrangThai(String tuKhoa, Boolean trangThai) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String like = "%" + tuKhoa.toLowerCase() + "%";
            String hql = "SELECT COUNT(DISTINCT s) FROM Sach s" + buildTrangThaiWhereHql(trangThai, "q");
            Long c = session.createQuery(hql, Long.class)
                    .setParameter("q", like)
                    .uniqueResult();
            return c == null ? 0 : c;
        }
    }

    /**
     * Tao menh de WHERE cho native SQL.
     * qParam != null -> them dieu kien tim kiem theo tu khoa.
     */
    private String buildTrangThaiWhere(Boolean trangThai, String qParam) {
        StringBuilder sb = new StringBuilder("WHERE ");
        if (qParam != null) {
            sb.append("(LOWER(s.MaSach) LIKE :").append(qParam)
              .append(" OR LOWER(s.TenSach) LIKE :").append(qParam).append(") ");
        }
        if (trangThai != null) {
            if (qParam != null) sb.append("AND ");
            if (Boolean.TRUE.equals(trangThai)) {
                sb.append("(s.TrangThai IS NULL OR s.TrangThai = 1) ");
            } else {
                sb.append("s.TrangThai = 0 ");
            }
        } else if (qParam == null) {
            // Khong co dieu kien gi, bo WHERE
            return "";
        }
        return sb.toString();
    }

    /** Tao menh de WHERE cho HQL. */
    private String buildTrangThaiWhereHql(Boolean trangThai, String qParam) {
        StringBuilder sb = new StringBuilder();
        boolean hasWhere = false;
        if (qParam != null) {
            sb.append(" WHERE (LOWER(s.maSach) LIKE :").append(qParam)
              .append(" OR LOWER(s.tenSach) LIKE :").append(qParam).append(")");
            hasWhere = true;
        }
        if (trangThai != null) {
            sb.append(hasWhere ? " AND " : " WHERE ");
            if (Boolean.TRUE.equals(trangThai)) {
                sb.append("(s.trangThai IS NULL OR s.trangThai = true)");
            } else {
                sb.append("s.trangThai = false");
            }
        }
        return sb.toString();
    }

    public Sach getById(String maSach) {
        if (maSach == null || maSach.isBlank()) {
            return null;
        }
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT s FROM Sach s "
                            + "LEFT JOIN FETCH s.theLoai "
                            + "LEFT JOIN FETCH s.nhaXuatBan "
                            + "LEFT JOIN FETCH s.boSach "
                            + "WHERE s.maSach = :ma",
                    Sach.class)
                    .setParameter("ma", maSach.trim())
                    .uniqueResult();
        }
    }

    /**
     * Dem so cuon SachVatLy trang thai "Có sẵn" theo tung MaSach.
     */
    public Map<String, Long> getTonKhoMap() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<Object[]> rows = session.createQuery(
                    "SELECT sv.sach.maSach, COUNT(sv.maSerial) "
                            + "FROM SachVatLy sv "
                            + "WHERE sv.trangThai = :tt "
                            + "GROUP BY sv.sach.maSach",
                    Object[].class)
                    .setParameter("tt", TRANG_THAI_CO_SAN)
                    .getResultList();

            Map<String, Long> map = new HashMap<>();
            for (Object[] row : rows) {
                map.put((String) row[0], (Long) row[1]);
            }
            return map;
        }
    }

    public TacGia getTacGiaChinh(String maSach) {
        if (maSach == null || maSach.isBlank()) {
            return null;
        }
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<TacGia> list = session.createQuery(
                    "SELECT st.tacGia FROM SachTacGia st "
                            + "WHERE st.sach.maSach = :ma "
                            + "ORDER BY st.vaiTroTG",
                    TacGia.class)
                    .setParameter("ma", maSach.trim())
                    .setMaxResults(1)
                    .getResultList();
            return list.isEmpty() ? null : list.get(0);
        }
    }

    /**
     * @return false neu ma sach da ton tai
     */
    public boolean insert(Sach sach, Integer maTacGia) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            if (session.get(Sach.class, sach.getMaSach()) != null) {
                return false;
            }
            tx = session.beginTransaction();
            if (sach.getTrangThai() == null) sach.setTrangThai(true); // mac dinh: dang kinh doanh
            session.persist(sach);
            if (maTacGia != null) {
                luuTacGiaChinh(session, sach.getMaSach(), maTacGia);
            }
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) {
                tx.rollback();
            }
            throw e;
        }
    }

    public void update(Sach sach, Integer maTacGia) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();

            // Load entity từ DB để Hibernate không cố resolve lazy collection
            Sach old = session.get(Sach.class, sach.getMaSach());
            if (old == null) throw new IllegalArgumentException("Không tìm thấy sách.");

            // Copy các field cần cập nhật từ form vào entity đang được quản lý
            old.setTenSach(sach.getTenSach());
            old.setNamXB(sach.getNamXB());
            old.setGiaBan(sach.getGiaBan());
            old.setTheLoai(sach.getTheLoai());
            old.setNhaXuatBan(sach.getNhaXuatBan());
            old.setBoSach(sach.getBoSach());
            old.setSoPhan(sach.getSoPhan());
            old.setAnhBia(sach.getAnhBia()); // null = xóa ảnh, có giá trị = cập nhật ảnh
            if (sach.getTrangThai() != null) old.setTrangThai(sach.getTrangThai());

            session.merge(old);

            // Xóa liên kết tác giả cũ rồi gán lại
            session.createMutationQuery("DELETE FROM SachTacGia st WHERE st.sach.maSach = :ma")
                    .setParameter("ma", sach.getMaSach())
                    .executeUpdate();
            if (maTacGia != null) {
                luuTacGiaChinh(session, sach.getMaSach(), maTacGia);
            }
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Dung cho nut "Xoa" tren giao dien: KHONG xoa cung ban ghi nua (se
     * loi vi pham khoa ngoai FK_CTDH_Sach neu sach da tung ban) - chi
     * cap nhat TrangThai = false (ngung kinh doanh). Sach se bi an khoi
     * man Ban hang (POS) nhung lich su don hang cu van hien dung ten sach.
     */
    public void ngungKinhDoanh(String maSach) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            Sach sach = session.get(Sach.class, maSach.trim());
            if (sach == null) throw new IllegalArgumentException("Không tìm thấy sách.");
            sach.setTrangThai(false);
            session.merge(sach);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /** Lay toan bo sach (khong phan trang) theo bo loc - dung cho xuat Excel. */
    public List<Sach> getAllForExport(String tuKhoa, Boolean trangThai) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            boolean coTimKiem = (tuKhoa != null && !tuKhoa.trim().isEmpty());
            String like = coTimKiem ? "%" + tuKhoa.trim().toLowerCase() + "%" : null;

            StringBuilder hql = new StringBuilder(
                    "SELECT DISTINCT s FROM Sach s " +
                    "LEFT JOIN FETCH s.theLoai " +
                    "LEFT JOIN FETCH s.nhaXuatBan " +
                    "LEFT JOIN FETCH s.boSach");

            boolean hasWhere = false;
            if (coTimKiem) {
                hql.append(" WHERE (LOWER(s.maSach) LIKE :q OR LOWER(s.tenSach) LIKE :q)");
                hasWhere = true;
            }
            if (trangThai != null) {
                hql.append(hasWhere ? " AND " : " WHERE ");
                if (Boolean.TRUE.equals(trangThai)) {
                    hql.append("(s.trangThai IS NULL OR s.trangThai = true)");
                } else {
                    hql.append("s.trangThai = false");
                }
            }
            hql.append(" ORDER BY s.maSach");

            var query = session.createQuery(hql.toString(), Sach.class);
            if (coTimKiem) query.setParameter("q", like);
            return query.getResultList();
        }
    }
    public void doiTrangThai(String maSach) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            Sach sach = session.get(Sach.class, maSach.trim());
            if (sach == null) throw new IllegalArgumentException("Không tìm thấy sách.");
            sach.setTrangThai(!Boolean.TRUE.equals(sach.getTrangThai()));
            session.merge(sach);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    /**
     * Chi xoa khi chua co ban ghi SachVatLy nao (theo nghiep vu SachServlet).
     * @return false neu khong xoa duoc
     */
    public boolean delete(String maSach) {
        if (maSach == null || maSach.isBlank()) {
            return false;
        }
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long soVatLy = session.createQuery(
                    "SELECT COUNT(sv) FROM SachVatLy sv WHERE sv.sach.maSach = :ma",
                    Long.class)
                    .setParameter("ma", maSach.trim())
                    .uniqueResult();
            if (soVatLy != null && soVatLy > 0) {
                return false;
            }

            Sach sach = session.get(Sach.class, maSach.trim());
            if (sach == null) {
                return false;
            }

            tx = session.beginTransaction();
            session.createMutationQuery("DELETE FROM SachTacGia st WHERE st.sach.maSach = :ma")
                    .setParameter("ma", maSach.trim())
                    .executeUpdate();
            session.createMutationQuery("DELETE FROM DanhGia dg WHERE dg.sach.maSach = :ma")
                    .setParameter("ma", maSach.trim())
                    .executeUpdate();
            session.remove(sach);
            tx.commit();
            return true;
        } catch (RuntimeException e) {
            if (tx != null) {
                tx.rollback();
            }
            throw e;
        }
    }

    private void luuTacGiaChinh(Session session, String maSach, Integer maTacGia) {
        Sach sachRef = session.getReference(Sach.class, maSach);
        TacGia tacGiaRef = session.getReference(TacGia.class, maTacGia);
        SachTacGia st = new SachTacGia();
        st.setSach(sachRef);
        st.setTacGia(tacGiaRef);
        st.setVaiTroTG(VAI_TRO_TAC_GIA);
        session.persist(st);
    }
}