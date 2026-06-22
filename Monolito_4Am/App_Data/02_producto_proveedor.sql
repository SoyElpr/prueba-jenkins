-- ============================================
-- REQUERIMIENTOS DE PRODUCTOS Y PROVEEDORES
-- Ejecutar en Monolito4am (localhost\MSSQLSERVER01)
-- ============================================

-- 1) Insertar Tipo de Usuario "Proveedor"
IF NOT EXISTS (SELECT 1 FROM tbl_tipo_usuario WHERE tsus_nombre = 'Proveedor')
BEGIN
    INSERT INTO tbl_tipo_usuario (tsus_nombre, tusu_estado) VALUES ('Proveedor', 'A');
END;

-- 2) Registrar un usuario de pruebas con rol Proveedor
-- Cedula: 1234567890, Contrasena: 123456
IF NOT EXISTS (SELECT 1 FROM tbl_usuario WHERE usu_cedula = '1234567890')
BEGIN
    DECLARE @tusu_id INT;
    SELECT @tusu_id = tusu_id FROM tbl_tipo_usuario WHERE tsus_nombre = 'Proveedor';

    INSERT INTO tbl_usuario (
        usu_cedula, usu_nombres, usu_apellidos, usu_celular, usu_correo,
        usu_nick, usu_contraseña, usu_estado, tusu_id, usu_fecha_creacion,
        usu_totp_activo
    )
    VALUES (
        '1234567890', 'Proveedor', 'Externo', '0999999999', 'proveedor@test.com',
        'proveedor', dbo.encriptacon('123456'), 'A', @tusu_id, GETDATE(), 'N'
    );
END;

-- 3) Eliminar llaves foraneas y tablas anteriores de producto/proveedor si existen
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_producto_provedor')
    ALTER TABLE tbl_producto DROP CONSTRAINT FK_producto_provedor;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_producto')
    DROP TABLE tbl_producto;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_provedor')
    DROP TABLE tbl_provedor;

-- 4) Crear tabla de Proveedores (tbl_provedor)
CREATE TABLE tbl_provedor (
    prov_id     INT IDENTITY(1,1) PRIMARY KEY,
    prov_nombre VARCHAR(100) NOT NULL,
    prov_estado CHAR(1) NOT NULL DEFAULT 'A'
);

-- 5) Crear tabla de Productos (tbl_producto)
-- Usamos pro_foto como VARCHAR para manejar la imagen a nivel de ruta (path)
CREATE TABLE tbl_producto (
    pro_id          INT IDENTITY(1,1) PRIMARY KEY,
    pro_codigo      VARCHAR(50) NULL,
    pro_nombre      VARCHAR(100) NOT NULL,
    pro_cantidad    INT NOT NULL DEFAULT 0,
    pro_precio      DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    pro_descripcion VARCHAR(MAX) NULL,
    pro_foto        VARCHAR(250) NULL,
    pro_estado      CHAR(1) NOT NULL DEFAULT 'A',
    prov_id         INT NULL,
    CONSTRAINT FK_producto_provedor FOREIGN KEY (prov_id) REFERENCES tbl_provedor(prov_id) ON DELETE SET NULL
);

-- 6) Eliminar la funcion ListarProductosOrdenados si ya existe
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ListarProductosOrdenados') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.ListarProductosOrdenados;
GO

-- 7) Crear funcion de base de datos para listar productos ordenados (aparece arriba)
CREATE FUNCTION dbo.ListarProductosOrdenados()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT 
        p.pro_id,
        p.pro_codigo,
        p.pro_nombre,
        p.pro_cantidad,
        p.pro_precio,
        p.pro_descripcion,
        p.pro_foto,
        p.pro_estado,
        p.prov_id,
        COALESCE(pr.prov_nombre, 'Sin Proveedor') AS prov_nombre
    FROM tbl_producto p
    LEFT JOIN tbl_provedor pr ON p.prov_id = pr.prov_id
    ORDER BY p.pro_id DESC
);
GO

-- 8) Eliminar el disparador trg_producto_insert si ya existe
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_producto_insert')
    DROP TRIGGER trg_producto_insert;
GO

-- 9) Crear disparador (Trigger) para loguear las inserciones automatica
CREATE TRIGGER trg_producto_insert
ON tbl_producto
AFTER INSERT
AS
BEGIN
    INSERT INTO tbl_auditoria (usu_id, audi_accion, audi_modulo, audi_ip, audi_fecha)
    SELECT NULL, 'Producto Creado: ' + i.pro_nombre, 'Inventario', '127.0.0.1', GETDATE()
    FROM inserted i;
END;
GO

-- 10) Insertar algunos registros semilla para pruebas
INSERT INTO tbl_provedor (prov_nombre, prov_estado) VALUES ('Distribuidora Fenix', 'A');
INSERT INTO tbl_provedor (prov_nombre, prov_estado) VALUES ('Importadora del Sur', 'A');

DECLARE @p1 INT, @p2 INT;
SELECT @p1 = prov_id FROM tbl_provedor WHERE prov_nombre = 'Distribuidora Fenix';
SELECT @p2 = prov_id FROM tbl_provedor WHERE prov_nombre = 'Importadora del Sur';

INSERT INTO tbl_producto (pro_codigo, pro_nombre, pro_cantidad, pro_precio, pro_descripcion, pro_foto, pro_estado, prov_id)
VALUES ('78610012', 'Paracetamol 500mg', 100, 1.50, 'Caja de 20 tabletas analgesicas', '~/Uploads/paracetamol.jpg', 'A', @p1);

INSERT INTO tbl_producto (pro_codigo, pro_nombre, pro_cantidad, pro_precio, pro_descripcion, pro_foto, pro_estado, prov_id)
VALUES ('78610015', 'Ibuprofeno 400mg', 150, 2.20, 'Caja de 10 tabletas antiinflamatorias', '~/Uploads/ibuprofeno.jpg', 'A', @p2);

PRINT 'Base de datos configurada con exito.';
