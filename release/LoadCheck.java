// Carrega e liga (link) as classes dadas, sem executá-las: falha se faltar alguma dependência.
// Uso (Java 11+, modo arquivo-fonte): java -cp <jar> release/LoadCheck.java <classe>...
public class LoadCheck {
    public static void main(String[] args) throws Exception {
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        for (String name : args) {
            Class<?> c = Class.forName(name, false, cl);
            c.getDeclaredMethods();
            c.getDeclaredFields();
            System.out.println("LoadCheck: " + name + " OK");
        }
    }
}
