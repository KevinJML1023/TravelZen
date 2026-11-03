
package com.travelzen.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {

    private static final String URL =
        "jdbc:mysql://localhost:3306/travelzen_db"
        + "?useSSL=false"
        + "&serverTimezone=UTC"
        + "&allowPublicKeyRetrieval=true";

    private static final String USER = "root";

    // Configuracion local predeterminada de XAMPP.
    // Si configuraste una contrasena, reemplaza este valor.
    private static final String PASSWORD = "";

    public static Connection conectar() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            return DriverManager.getConnection(
                URL,
                USER,
                PASSWORD
            );

        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "No se encontro el controlador MySQL", e
            );
        }
    }
}
