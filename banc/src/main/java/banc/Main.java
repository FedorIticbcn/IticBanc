package banc;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.Scanner;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class Main {
    public static void main(String[] args) throws IOException {
        Properties properties = loadConnectionProperties();
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(properties.getProperty("DB_URL"));
        config.setUsername(properties.getProperty("DB_USER"));
        config.setPassword(properties.getProperty("DB_PASSWORD"));
        config.setMaximumPoolSize(Integer.parseInt(properties.getProperty("DB_MAX_POOL", "5")));

        try (HikariDataSource ds = new HikariDataSource(config);
             Connection conn = ds.getConnection();
             Scanner scanner = new Scanner(System.in)) {
            System.out.println("Connectat!");
            System.out.print("Import minim en euros: ");
            double quantitat = Double.parseDouble(scanner.nextLine().trim().replace(',', '.'));
            for (String fila : readStatementsByAmount(conn, quantitat)) {
                System.out.println(fila);
            }

            System.out.println("\nNou client:");
            System.out.print("Nom: ");
            String nom = scanner.nextLine().trim();
            System.out.print("Cognoms: ");
            String cognoms = scanner.nextLine().trim();
            System.out.print("ID fiscal: ");
            String idFiscal = scanner.nextLine().trim();
            List<String> dadesClient = new ArrayList<>(List.of(nom, cognoms, idFiscal));
            if (dadesClient.stream().anyMatch(String::isBlank)) {
                System.out.println("No es permeten camps buits.");
            } else {
                boolean inserit = insertClient(conn, dadesClient);
                System.out.println(inserit ? "Client inserit correctament!" : "El client ja existeix.");
            }
        } catch (SQLException e) {
            System.err.println("Error de base de dades: " + e.getMessage());
        } catch (NumberFormatException e) {
            System.err.println("L'import ha de ser un numero valid.");
        }
    }

    public static List<String> readStatementsByAmount(Connection conn, double quantitat) throws SQLException {
        List<String> resultats = new ArrayList<>();
        String query = "SELECT * FROM statements WHERE import >= ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setDouble(1, quantitat);
            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData meta = rs.getMetaData();
                String header = String.join(";", meta.getColumnName(1), meta.getColumnName(3),
                        meta.getColumnName(8), meta.getColumnName(10));
                resultats.add(header);
                while (rs.next()) {
                    String fila = String.join(";", rs.getString("id_statement"),
                            rs.getString("tipus_moviment"), rs.getString("import"), rs.getString("divisa"));
                    resultats.add(fila);
                }
            }
        }
        return resultats;
    }

    public static boolean clientExists(Connection conn, String idFiscal) throws SQLException {
        String query = "SELECT 1 FROM clients WHERE id_fiscal = ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, idFiscal);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public static boolean insertClient(Connection conn, List<String> dades) throws SQLException {
        if (dades.size() != 3) {
            throw new IllegalArgumentException("Cal indicar nom, cognoms i id_fiscal.");
        }
        boolean originalAutoCommit = conn.getAutoCommit();
        conn.setAutoCommit(false);
        try {
            if (clientExists(conn, dades.get(2))) {
                conn.rollback();
                return false;
            }
            String query = "INSERT INTO clients (nom,cognoms,id_fiscal) VALUES (?,?,?)";
            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, dades.get(0));
                ps.setString(2, dades.get(1));
                ps.setString(3, dades.get(2));
                ps.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (SQLException | RuntimeException e) {
            try {
                conn.rollback();
            } catch (SQLException rollbackError) {
                e.addSuppressed(rollbackError);
            }
            throw e;
        } finally {
            conn.setAutoCommit(originalAutoCommit);
        }
    }

    static Properties loadConnectionProperties() throws IOException {
        Properties properties = new Properties();
        try (InputStream input = Main.class.getResourceAsStream("/conn.properties")) {
            if (input == null) {
                throw new FileNotFoundException("Configuration resource conn.properties was not found");
            }
            properties.load(input);
        }
        return properties;
    }
}
