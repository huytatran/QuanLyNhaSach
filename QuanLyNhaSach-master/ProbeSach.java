import dao.SachDAO;
import entity.Sach;
import java.util.List;
import java.util.Map;
public class ProbeSach {
  public static void main(String[] args) {
    try {
      SachDAO dao = new SachDAO();
      List<Sach> all = dao.getAll();
      Map ton = dao.getTonKhoMap();
      System.out.println("SO_SACH=" + all.size());
      System.out.println("TON_KEYS=" + ton.size());
      for (int i = 0; i < Math.min(5, all.size()); i++) {
        Sach s = all.get(i);
        System.out.println(s.getMaSach() + " | " + s.getTenSach()
          + " | TL=" + (s.getTheLoai()!=null?s.getTheLoai().getTenTL():"null")
          + " | ton=" + ton.getOrDefault(s.getMaSach(), 0L));
      }
    } catch (Throwable t) {
      System.out.println("FAIL=" + t);
      t.printStackTrace(System.out);
    }
  }
}