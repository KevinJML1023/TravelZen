
package com.travelzen.controller;

import com.travelzen.config.Conexion;
import jakarta.annotation.PostConstruct;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;

import java.io.Serializable;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@Named
@ViewScoped
public class DashboardBean implements Serializable {

    private int totalUsuarios;
    private int totalClientes;
    private int totalAgentes;
    private int totalVuelos;
    private int totalReservas;
    private int totalPagos;

    private List<TablaInfo> tablas = new ArrayList<>();

    @PostConstruct
    public void inicializar() {
        cargarEstadisticas();
        cargarTablas();
    }

    private int contar(String sql) {
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public void cargarEstadisticas() {

        totalUsuarios = contar(
            "SELECT COUNT(*) FROM usuario"
        );

        totalClientes = contar(
            "SELECT COUNT(*) FROM cliente"
        );

        totalAgentes = contar(
            "SELECT COUNT(*) FROM agente"
        );

        totalVuelos = contar(
            "SELECT COUNT(*) FROM vuelo"
        );

        totalReservas = contar(
            "SELECT COUNT(*) FROM reserva"
        );

        totalPagos = contar(
            "SELECT COUNT(*) FROM pago"
        );
    }

    public void cargarTablas() {

        tablas.clear();

        String sql =
            "SELECT table_name " +
            "FROM information_schema.tables " +
            "WHERE table_schema = DATABASE() " +
            "AND table_type = 'BASE TABLE' " +
            "ORDER BY table_name";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                String nombre = rs.getString("table_name");

                // Los nombres proceden de information_schema.
                // Se escapan los identificadores antes de usarlos.
                String seguro = nombre.replace("`", "``");

                String consulta =
                    "SELECT COUNT(*) FROM `" + seguro + "`";

                try (Statement st = con.createStatement();
                     ResultSet resultado = st.executeQuery(consulta)) {

                    if (resultado.next()) {
                        tablas.add(new TablaInfo(
                            nombre,
                            resultado.getInt(1)
                        ));
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int getTotalTablas() {
        return tablas.size();
    }

    public int getTotalUsuarios() {
        return totalUsuarios;
    }

    public int getTotalClientes() {
        return totalClientes;
    }

    public int getTotalAgentes() {
        return totalAgentes;
    }

    public int getTotalVuelos() {
        return totalVuelos;
    }

    public int getTotalReservas() {
        return totalReservas;
    }

    public int getTotalPagos() {
        return totalPagos;
    }

    public List<TablaInfo> getTablas() {
        return tablas;
    }

    public static class TablaInfo implements Serializable {

        private final String nombre;
        private final int registros;

        public TablaInfo(String nombre, int registros) {
            this.nombre = nombre;
            this.registros = registros;
        }

        public String getNombre() {
            return nombre;
        }

        public int getRegistros() {
            return registros;
        }
    }
}
