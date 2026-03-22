CREATE DATABASE paquexpress_db;
USE paquexpress_db;

-- =========================
-- TABLA: usuarios
-- =========================
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- va encriptada (bcrypt)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- TABLA: paquetes
-- =========================
CREATE TABLE paquetes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    direccion VARCHAR(255) NOT NULL,
    descripcion TEXT,
    estado ENUM('pendiente', 'entregado') DEFAULT 'pendiente',
    usuario_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON DELETE SET NULL
);

-- =========================
-- TABLA: entregas
-- =========================
CREATE TABLE entregas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paquete_id INT NOT NULL,
    foto_ruta VARCHAR(255) NOT NULL, --  la ruta de la imagen
    latitud DECIMAL(10,8) NOT NULL,
    longitud DECIMAL(11,8) NOT NULL,
    fecha_entrega TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (paquete_id) REFERENCES paquetes(id)
        ON DELETE CASCADE
);
