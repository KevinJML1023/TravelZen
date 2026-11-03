-- =====================================================
-- TRAVELZEN
-- SISTEMA WEB PARA LA GESTION OPERATIVA DE UNA
-- AGENCIA DE VIAJES INTERNACIONAL
-- BASE DE DATOS: travelzen_db
-- MYSQL 8
-- =====================================================

CREATE DATABASE IF NOT EXISTS travelzen_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE travelzen_db;

-- =====================================================
-- MODULO 1: USUARIOS Y SEGURIDAD
-- =====================================================

CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    estado BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(25),
    estado ENUM('ACTIVO','INACTIVO','BLOQUEADO')
        DEFAULT 'ACTIVO',
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso DATETIME NULL,

    CONSTRAINT fk_usuario_rol
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
) ENGINE=InnoDB;

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY,
    pasaporte VARCHAR(40) UNIQUE,
    nacionalidad VARCHAR(80),
    fecha_nacimiento DATE,
    direccion VARCHAR(200),

    FOREIGN KEY (id_cliente)
    REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

CREATE TABLE administrador (
    id_administrador INT PRIMARY KEY,
    codigo_administrador VARCHAR(30) UNIQUE,
    nivel_acceso VARCHAR(50),

    FOREIGN KEY (id_administrador)
    REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

CREATE TABLE sucursal (
    id_sucursal INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    ciudad VARCHAR(100),
    telefono VARCHAR(25),
    correo VARCHAR(150),
    estado BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE agente (
    id_agente INT PRIMARY KEY,
    codigo_agente VARCHAR(30) NOT NULL UNIQUE,
    especialidad VARCHAR(100),
    fecha_contratacion DATE,
    estado_laboral ENUM('ACTIVO','INACTIVO')
        DEFAULT 'ACTIVO',

    FOREIGN KEY (id_agente)
    REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

CREATE TABLE agente_sucursal (
    id_agente_sucursal INT AUTO_INCREMENT PRIMARY KEY,
    id_agente INT NOT NULL,
    id_sucursal INT NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_fin DATE NULL,

    FOREIGN KEY (id_agente) REFERENCES agente(id_agente),
    FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),

    UNIQUE (id_agente, id_sucursal, fecha_asignacion)
) ENGINE=InnoDB;

-- =====================================================
-- MODULO 2: GEOGRAFIA Y VUELOS
-- =====================================================

CREATE TABLE pais (
    id_pais INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo_iso VARCHAR(3) UNIQUE,
    continente VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE ciudad (
    id_ciudad INT AUTO_INCREMENT PRIMARY KEY,
    id_pais INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    zona_horaria VARCHAR(60),

    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
) ENGINE=InnoDB;

CREATE TABLE aeropuerto (
    id_aeropuerto INT AUTO_INCREMENT PRIMARY KEY,
    id_ciudad INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    codigo_iata CHAR(3) UNIQUE,
    codigo_icao CHAR(4),
    direccion VARCHAR(200),

    FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad)
) ENGINE=InnoDB;

CREATE TABLE aerolinea (
    id_aerolinea INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    codigo_iata VARCHAR(3),
    pais_origen VARCHAR(80),
    sitio_web VARCHAR(200),
    estado BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE avion (
    id_avion INT AUTO_INCREMENT PRIMARY KEY,
    id_aerolinea INT NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    matricula VARCHAR(30) NOT NULL UNIQUE,
    capacidad INT NOT NULL,
    estado ENUM('OPERATIVO','MANTENIMIENTO','FUERA_SERVICIO')
        DEFAULT 'OPERATIVO',

    FOREIGN KEY (id_aerolinea)
    REFERENCES aerolinea(id_aerolinea),

    CHECK (capacidad > 0)
) ENGINE=InnoDB;

CREATE TABLE asiento (
    id_asiento INT AUTO_INCREMENT PRIMARY KEY,
    id_avion INT NOT NULL,
    numero_asiento VARCHAR(10) NOT NULL,
    clase ENUM('ECONOMICA','EJECUTIVA','PRIMERA')
        DEFAULT 'ECONOMICA',
    estado BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (id_avion) REFERENCES avion(id_avion),
    UNIQUE (id_avion, numero_asiento)
) ENGINE=InnoDB;

CREATE TABLE vuelo (
    id_vuelo INT AUTO_INCREMENT PRIMARY KEY,
    id_aerolinea INT NOT NULL,
    id_avion INT NOT NULL,
    id_aeropuerto_origen INT NOT NULL,
    id_aeropuerto_destino INT NOT NULL,
    numero_vuelo VARCHAR(20) NOT NULL,
    fecha_salida DATETIME NOT NULL,
    fecha_llegada DATETIME NOT NULL,
    precio DECIMAL(12,2) NOT NULL,
    estado ENUM('PROGRAMADO','CONFIRMADO',
                'CANCELADO','FINALIZADO')
        DEFAULT 'PROGRAMADO',

    FOREIGN KEY (id_aerolinea) REFERENCES aerolinea(id_aerolinea),
    FOREIGN KEY (id_avion) REFERENCES avion(id_avion),
    FOREIGN KEY (id_aeropuerto_origen)
        REFERENCES aeropuerto(id_aeropuerto),
    FOREIGN KEY (id_aeropuerto_destino)
        REFERENCES aeropuerto(id_aeropuerto),

    CHECK (id_aeropuerto_origen <> id_aeropuerto_destino),
    CHECK (fecha_llegada > fecha_salida),
    CHECK (precio >= 0)
) ENGINE=InnoDB;

-- =====================================================
-- MODULO 3: PASAJEROS
-- =====================================================

CREATE TABLE pasajero (
    id_pasajero INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    nacionalidad VARCHAR(80),
    sexo VARCHAR(20),
    correo VARCHAR(150),
    telefono VARCHAR(25)
) ENGINE=InnoDB;

CREATE TABLE documento_viajero (
    id_documento INT AUTO_INCREMENT PRIMARY KEY,
    id_pasajero INT NOT NULL,
    tipo_documento ENUM('PASAPORTE','CI','OTRO')
        NOT NULL,
    numero_documento VARCHAR(50) NOT NULL,
    pais_emision VARCHAR(80),
    fecha_emision DATE,
    fecha_vencimiento DATE,

    FOREIGN KEY (id_pasajero) REFERENCES pasajero(id_pasajero),
    UNIQUE (tipo_documento, numero_documento)
) ENGINE=InnoDB;

CREATE TABLE contacto_emergencia (
    id_contacto INT AUTO_INCREMENT PRIMARY KEY,
    id_pasajero INT NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    parentesco VARCHAR(50),
    telefono VARCHAR(25) NOT NULL,
    correo VARCHAR(150),

    FOREIGN KEY (id_pasajero) REFERENCES pasajero(id_pasajero)
) ENGINE=InnoDB;

-- =====================================================
-- MODULO 4: RESERVAS
-- =====================================================

CREATE TABLE reserva (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    codigo_reserva VARCHAR(30) NOT NULL UNIQUE,
    id_cliente INT NOT NULL,
    id_agente INT NOT NULL,
    id_sucursal INT,
    fecha_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_salida DATE NOT NULL,
    fecha_regreso DATE,
    cantidad_personas INT NOT NULL,
    monto_total DECIMAL(12,2) NOT NULL,
    estado ENUM('PENDIENTE','CONFIRMADA',
                'CANCELADA','FINALIZADA')
        DEFAULT 'PENDIENTE',
    observaciones TEXT,

    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_agente) REFERENCES agente(id_agente),
    FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),

    CHECK (cantidad_personas > 0),
    CHECK (monto_total >= 0)
) ENGINE=InnoDB;

CREATE TABLE reserva_pasajero (
    id_reserva_pasajero INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_pasajero INT NOT NULL,
    es_titular BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
    FOREIGN KEY (id_pasajero) REFERENCES pasajero(id_pasajero),

    UNIQUE (id_reserva, id_pasajero)
) ENGINE=InnoDB;

CREATE TABLE reserva_vuelo (
    id_reserva_vuelo INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_vuelo INT NOT NULL,
    id_asiento INT,
    id_pasajero INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
    FOREIGN KEY (id_vuelo) REFERENCES vuelo(id_vuelo),
    FOREIGN KEY (id_asiento) REFERENCES asiento(id_asiento),
    FOREIGN KEY (id_pasajero) REFERENCES pasajero(id_pasajero),

    UNIQUE (id_reserva, id_vuelo, id_pasajero),
    CHECK (precio_unitario >= 0)
) ENGINE=InnoDB;

CREATE TABLE historial_reserva (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_usuario INT NOT NULL,
    estado_anterior VARCHAR(30),
    estado_nuevo VARCHAR(30) NOT NULL,
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    observacion TEXT,

    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

CREATE TABLE cotizacion (
    id_cotizacion INT AUTO_INCREMENT PRIMARY KEY,
    codigo_cotizacion VARCHAR(30) NOT NULL UNIQUE,
    id_cliente INT NOT NULL,
    id_agente INT NOT NULL,
    fecha_emision DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento DATE,
    monto_estimado DECIMAL(12,2) NOT NULL,
    estado ENUM('PENDIENTE','ACEPTADA','RECHAZADA','VENCIDA')
        DEFAULT 'PENDIENTE',

    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_agente) REFERENCES agente(id_agente)
) ENGINE=InnoDB;

CREATE TABLE cotizacion_vuelo (
    id_cotizacion_vuelo INT AUTO_INCREMENT PRIMARY KEY,
    id_cotizacion INT NOT NULL,
    id_vuelo INT NOT NULL,
    precio_propuesto DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (id_cotizacion) REFERENCES cotizacion(id_cotizacion),
    FOREIGN KEY (id_vuelo) REFERENCES vuelo(id_vuelo)
) ENGINE=InnoDB;

-- =====================================================
-- MODULO 5: PAGOS Y COMPROBANTES
-- =====================================================

CREATE TABLE metodo_pago (
    id_metodo_pago INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    estado BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    referencia_pago VARCHAR(100),
    estado ENUM('PENDIENTE','APROBADO','RECHAZADO','ANULADO')
        DEFAULT 'PENDIENTE',

    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
    FOREIGN KEY (id_metodo_pago) REFERENCES metodo_pago(id_metodo_pago),

    CHECK (monto > 0)
) ENGINE=InnoDB;

CREATE TABLE reembolso (
    id_reembolso INT AUTO_INCREMENT PRIMARY KEY,
    id_pago INT NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion DATETIME,
    motivo TEXT NOT NULL,
    estado ENUM('SOLICITADO','APROBADO','RECHAZADO','PROCESADO')
        DEFAULT 'SOLICITADO',

    FOREIGN KEY (id_pago) REFERENCES pago(id_pago),
    CHECK (monto > 0)
) ENGINE=InnoDB;

CREATE TABLE comprobante (
    id_comprobante INT AUTO_INCREMENT PRIMARY KEY,
    id_pago INT NOT NULL UNIQUE,
    id_agente INT NOT NULL,
    numero_comprobante VARCHAR(40) NOT NULL UNIQUE,
    fecha_emision DATETIME DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(12,2) NOT NULL,
    impuesto DECIMAL(12,2) DEFAULT 0,
    total DECIMAL(12,2) NOT NULL,
    concepto VARCHAR(250) NOT NULL,
    estado ENUM('EMITIDO','ANULADO') DEFAULT 'EMITIDO',

    FOREIGN KEY (id_pago) REFERENCES pago(id_pago),
    FOREIGN KEY (id_agente) REFERENCES agente(id_agente),

    CHECK (subtotal >= 0),
    CHECK (impuesto >= 0),
    CHECK (total >= 0)
) ENGINE=InnoDB;

CREATE TABLE detalle_comprobante (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_comprobante INT NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (id_comprobante)
    REFERENCES comprobante(id_comprobante),

    CHECK (cantidad > 0),
    CHECK (precio_unitario >= 0),
    CHECK (subtotal >= 0)
) ENGINE=InnoDB;

-- =====================================================
-- MODULO 6: SERVICIOS Y PROMOCIONES
-- =====================================================

CREATE TABLE servicio_adicional (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(12,2) NOT NULL,
    estado BOOLEAN DEFAULT TRUE,

    CHECK (precio >= 0)
) ENGINE=InnoDB;

CREATE TABLE reserva_servicio (
    id_reserva_servicio INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_servicio INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_aplicado DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
    FOREIGN KEY (id_servicio)
    REFERENCES servicio_adicional(id_servicio),

    CHECK (cantidad > 0),
    CHECK (precio_aplicado >= 0)
) ENGINE=InnoDB;

CREATE TABLE promocion (
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(40) NOT NULL UNIQUE,
    descripcion TEXT,
    tipo_descuento ENUM('PORCENTAJE','MONTO_FIJO') NOT NULL,
    valor_descuento DECIMAL(12,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado BOOLEAN DEFAULT TRUE,

    CHECK (valor_descuento > 0),
    CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

CREATE TABLE reserva_promocion (
    id_reserva_promocion INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_promocion INT NOT NULL,
    descuento_aplicado DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
    FOREIGN KEY (id_promocion)
    REFERENCES promocion(id_promocion),

    UNIQUE (id_reserva, id_promocion),
    CHECK (descuento_aplicado >= 0)
) ENGINE=InnoDB;

-- =====================================================
-- MODULO 7: NOTIFICACIONES Y AUDITORIA
-- =====================================================

CREATE TABLE notificacion (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo VARCHAR(40),
    fecha_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    leida BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

CREATE TABLE auditoria (
    id_auditoria BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    accion VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(100),
    id_registro VARCHAR(50),
    detalle TEXT,
    fecha_evento DATETIME DEFAULT CURRENT_TIMESTAMP,
    direccion_ip VARCHAR(45),

    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

-- =====================================================
-- FIN DEL MODELO: 34 TABLAS
-- =====================================================
