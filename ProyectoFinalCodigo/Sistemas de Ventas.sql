
--   PLATAFORMA DE VENTAS ONLINE - BASE DE DATOS FINAL


DROP DATABASE IF EXISTS plataforma_ventas;
CREATE DATABASE plataforma_ventas;
USE plataforma_ventas;

-- ------------------------------------------------------
--                   TABLA CLIENTES
-- ------------------------------------------------------

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    direccion VARCHAR(100),
    fecha_registro DATE NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1
);

CREATE INDEX idx_clientes_apellido ON clientes(apellido);

-- ------------------------------------------------------
--                   TABLA PRODUCTOS
-- ------------------------------------------------------

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    fecha_alta DATE NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1
);

CREATE INDEX idx_productos_categoria ON productos(categoria);

-- ------------------------------------------------------
--                    TABLA ORDENES
-- ------------------------------------------------------

CREATE TABLE ordenes (
    id_orden INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_orden DATETIME NOT NULL,
    estado ENUM('PENDIENTE','PAGADA','CANCELADA') NOT NULL,

    FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_ordenes_cliente ON ordenes(id_cliente);

-- ------------------------------------------------------
--                TABLA DETALLE_ORDEN
-- ------------------------------------------------------

CREATE TABLE detalle_orden (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_orden)
        REFERENCES ordenes(id_orden)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_detalle_producto ON detalle_orden(id_producto);

-- ------------------------------------------------------
--                   DATOS INICIALES
-- ------------------------------------------------------

INSERT INTO clientes(nombre, apellido, email, telefono, direccion, fecha_registro) VALUES
('Juan','Pérez','juan.p@gmail.com','1122334455','Calle 1','2024-01-10'),
('María','López','maria.l@gmail.com','1199988877','Calle 2','2024-01-13'),
('Carlos','Martínez','cmartinez@gmail.com','1155667788','Calle 3','2024-01-15'),
('Ana','Gómez','ana.g@gmail.com','1144122233','Calle 4','2024-01-20'),
('Sofía','Torres','sofia.t@gmail.com','1177712345','Calle 5','2024-01-22'),
('Nicolás','Suárez','nico.suarez@gmail.com','1133698745','Calle 6','2024-01-25'),
('Lucía','Fernández','lucia.f@gmail.com','1100332255','Calle 7','2024-01-29'),
('Mateo','Barrera','mateo.b@gmail.com','1122987766','Calle 8','2024-02-01'),
('Valentina','Díaz','valen.dz@gmail.com','1166554433','Calle 9','2024-02-05'),
('Pedro','Rivas','pedro.r@gmail.com','1199112288','Calle 10','2024-02-10');

INSERT INTO productos(nombre, categoria, precio, stock, fecha_alta) VALUES
('Mouse Logitech M185','Periféricos',6500,150,'2024-01-15'),
('Teclado Redragon K552','Periféricos',18000,80,'2024-01-16'),
('Monitor Samsung 24"','Monitores',120000,40,'2024-01-18'),
('Silla Gamer Cougar','Muebles',150000,20,'2024-01-19'),
('Notebook Lenovo i5','Computadoras',450000,15,'2024-01-20'),
('Auriculares JBL Tune 510','Audio',25000,60,'2024-01-22'),
('Parlante JBL Flip 5','Audio',70000,25,'2024-01-23'),
('Pendrive Kingston 64GB','Almacenamiento',8000,200,'2024-01-25'),
('SSD Kingston 480GB','Almacenamiento',30000,50,'2024-01-26'),
('RTX 4060 MSI','Placas de Video',520000,10,'2024-01-28');


-- ------------------------------------------------------
--                        TRIGGER
-- ------------------------------------------------------

DELIMITER //

-- VALIDACIÓN DE STOCK
DROP TRIGGER IF EXISTS tr_detalle_orden_validaciones//
CREATE TRIGGER tr_detalle_orden_validaciones
BEFORE INSERT ON detalle_orden
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;

    SELECT stock INTO v_stock
    FROM productos
    WHERE id_producto = NEW.id_producto;

    IF NEW.cantidad > v_stock THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock insuficiente para el producto';
    END IF;
END//

DELIMITER ;


-- ------------------------------------------------------
--                PROCEDIMIENTOS CRUD
-- ------------------------------------------------------

DELIMITER //

-- AGREGAR PRODUCTO
DROP PROCEDURE IF EXISTS agregar_producto//
CREATE PROCEDURE agregar_producto(IN p_nombre VARCHAR(100), IN p_categoria VARCHAR(50), IN p_precio DECIMAL(10,2), IN p_stock INT)
BEGIN
    INSERT INTO productos(nombre, categoria, precio, stock, fecha_alta)
    VALUES(p_nombre, p_categoria, p_precio, p_stock, CURDATE());
END//

-- VER PRODUCTOS
DROP PROCEDURE IF EXISTS ver_productos//
CREATE PROCEDURE ver_productos()
BEGIN
    SELECT * FROM productos WHERE activo = 1;
END//

-- ACTUALIZAR PRODUCTO
DROP PROCEDURE IF EXISTS actualizar_producto//
CREATE PROCEDURE actualizar_producto(IN p_id INT, IN p_precio DECIMAL(10,2), IN p_stock INT)
BEGIN
    UPDATE productos SET precio = p_precio, stock = p_stock WHERE id_producto = p_id;
END//

-- ELIMINAR PRODUCTO
DROP PROCEDURE IF EXISTS eliminar_producto//
CREATE PROCEDURE eliminar_producto(IN p_id INT)
BEGIN
    UPDATE productos SET activo = 0 WHERE id_producto = p_id;
END//

-- BUSCAR PRODUCTO
DROP PROCEDURE IF EXISTS buscar_producto//
CREATE PROCEDURE buscar_producto(IN p_texto VARCHAR(50))
BEGIN
    SELECT * FROM productos
    WHERE nombre LIKE CONCAT('%', p_texto, '%');
END//


-- ------------------------------------------------------
--                   CLIENTES
-- ------------------------------------------------------

DROP PROCEDURE IF EXISTS agregar_cliente//
CREATE PROCEDURE agregar_cliente(IN p_nombre VARCHAR(50), IN p_apellido VARCHAR(50),
                                 IN p_email VARCHAR(100), IN p_tel VARCHAR(20), IN p_dir VARCHAR(100))
BEGIN
    INSERT INTO clientes(nombre, apellido, email, telefono, direccion, fecha_registro)
    VALUES(p_nombre, p_apellido, p_email, p_tel, p_dir, CURDATE());
END//

DROP PROCEDURE IF EXISTS ver_clientes//
CREATE PROCEDURE ver_clientes()
BEGIN
    SELECT * FROM clientes WHERE activo = 1;
END//

DROP PROCEDURE IF EXISTS actualizar_cliente//
CREATE PROCEDURE actualizar_cliente(IN p_id INT, IN p_tel VARCHAR(20), IN p_dir VARCHAR(100))
BEGIN
    UPDATE clientes SET telefono = p_tel, direccion = p_dir WHERE id_cliente = p_id;
END//

DROP PROCEDURE IF EXISTS buscar_cliente//
CREATE PROCEDURE buscar_cliente(IN p_texto VARCHAR(50))
BEGIN
    SELECT *
    FROM clientes
    WHERE nombre LIKE CONCAT('%', p_texto, '%')
       OR apellido LIKE CONCAT('%', p_texto, '%');
END//


-- ------------------------------------------------------
--                ÓRDENES POR CLIENTE
-- ------------------------------------------------------

DROP PROCEDURE IF EXISTS ordenes_por_cliente//
CREATE PROCEDURE ordenes_por_cliente(IN p_idCliente INT)
BEGIN
    SELECT 
        o.id_orden,
        o.fecha_orden,
        o.estado,
        d.id_producto,
        d.cantidad,
        d.subtotal
    FROM ordenes o
    INNER JOIN detalle_orden d ON o.id_orden = d.id_orden
    WHERE o.id_cliente = p_idCliente;
END//


-- ------------------------------------------------------
--      GENERACIÓN AUTOMÁTICA DE ÓRDENES 
-- ------------------------------------------------------

DROP PROCEDURE IF EXISTS generar_ordenes//
CREATE PROCEDURE generar_ordenes()
BEGIN
    DECLARE v_idCliente INT;
    DECLARE v_idProducto INT;
    DECLARE v_stock INT;
    DECLARE v_cantidad INT;
    DECLARE fin BOOLEAN DEFAULT FALSE;

    DECLARE ClientesCursor CURSOR FOR
        SELECT id_cliente FROM clientes;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = TRUE;

    OPEN ClientesCursor;

    loop_clientes: LOOP
        FETCH ClientesCursor INTO v_idCliente;
        IF fin THEN LEAVE loop_clientes; END IF;

        SET @i = 1;
        WHILE @i <= 10 DO

            SELECT id_producto, stock INTO v_idProducto, v_stock
            FROM productos
            WHERE stock > 0
            ORDER BY RAND()
            LIMIT 1;

            IF v_stock IS NULL THEN LEAVE loop_clientes; END IF;

            SET v_cantidad = FLOOR(1 + RAND() * 3);
            IF v_cantidad > v_stock THEN SET v_cantidad = v_stock; END IF;

            INSERT INTO ordenes(id_cliente, fecha_orden, estado)
            VALUES (v_idCliente, NOW(), 'PAGADA');

            SET @idNuevaOrden = LAST_INSERT_ID();

            INSERT INTO detalle_orden(id_orden, id_producto, cantidad, precio_unitario, subtotal)
            SELECT 
                @idNuevaOrden,
                p.id_producto,
                v_cantidad,
                p.precio,
                p.precio * v_cantidad
            FROM productos p
            WHERE p.id_producto = v_idProducto;

            UPDATE productos
            SET stock = stock - v_cantidad
            WHERE id_producto = v_idProducto;

            SET @i = @i + 1;
        END WHILE;
    END LOOP;

    CLOSE ClientesCursor;
END//


-- ------------------------------------------------------
--              PRODUCTO MÁS VENDIDO
-- ------------------------------------------------------

DROP PROCEDURE IF EXISTS producto_mas_vendido//
CREATE PROCEDURE producto_mas_vendido()
BEGIN
    IF (SELECT COUNT(*) FROM detalle_orden) = 0 THEN
        SELECT 'No hay ventas registradas' AS mensaje;
    ELSE
        SELECT 
            p.id_producto,
            p.nombre,
            SUM(d.cantidad) AS total_vendido
        FROM detalle_orden d
        INNER JOIN productos p ON p.id_producto = d.id_producto
        GROUP BY p.id_producto, p.nombre
        ORDER BY total_vendido DESC
        LIMIT 1;
    END IF;
END//


-- ------------------------------------------------------
--             BÚSQUEDAS AVANZADAS
-- ------------------------------------------------------

DROP PROCEDURE IF EXISTS clientes_con_filtro//
CREATE PROCEDURE clientes_con_filtro(IN p_texto VARCHAR(50))
BEGIN
    SELECT * 
    FROM clientes
    WHERE nombre LIKE CONCAT('%', p_texto, '%')
       OR apellido LIKE CONCAT('%', p_texto, '%')
       OR email LIKE CONCAT('%', p_texto, '%');
END//

DROP PROCEDURE IF EXISTS productos_con_filtro//
CREATE PROCEDURE productos_con_filtro(IN p_texto VARCHAR(50))
BEGIN
    SELECT * 
    FROM productos
    WHERE nombre LIKE CONCAT('%', p_texto, '%')
       OR categoria LIKE CONCAT('%', p_texto, '%');
END//

-- ------------------------------------------------------
--      PROCEDIMIENTOS DE COMPRA REAL
-- ------------------------------------------------------

-- CREAR ORDEN (PENDIENTE)
DROP PROCEDURE IF EXISTS crear_orden//
CREATE PROCEDURE crear_orden(IN p_idCliente INT)
BEGIN
    INSERT INTO ordenes(id_cliente, fecha_orden, estado)
    VALUES(p_idCliente, NOW(), 'PENDIENTE');

    SELECT LAST_INSERT_ID() AS nueva_orden;
END//

-- AGREGAR ÍTEM A ORDEN
DROP PROCEDURE IF EXISTS agregar_item_orden//
CREATE PROCEDURE agregar_item_orden(
    IN p_idOrden INT,
    IN p_idProducto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);

    SELECT precio INTO v_precio
    FROM productos
    WHERE id_producto = p_idProducto;

    INSERT INTO detalle_orden(id_orden, id_producto, cantidad, precio_unitario, subtotal)
    VALUES(p_idOrden, p_idProducto, p_cantidad, v_precio, v_precio * p_cantidad);

    UPDATE productos
    SET stock = stock - p_cantidad
    WHERE id_producto = p_idProducto;
END//

-- CONFIRMAR ORDEN
DROP PROCEDURE IF EXISTS confirmar_orden//
CREATE PROCEDURE confirmar_orden(IN p_idOrden INT)
BEGIN
    UPDATE ordenes
    SET estado = 'PAGADA'
    WHERE id_orden = p_idOrden;
END//

DELIMITER ;
