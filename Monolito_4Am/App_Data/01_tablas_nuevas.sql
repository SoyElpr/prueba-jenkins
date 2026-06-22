-- ============================================
-- MÓDULO DE SEGURIDAD - Script de BD
-- Ejecutar en Monolito4am (LocalDB)
-- ============================================

-- 1) Tabla de fotos múltiples
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_foto_usuario')
BEGIN
    CREATE TABLE tbl_foto_usuario (
        foto_id        INT IDENTITY(1,1) PRIMARY KEY,
        usu_id         INT           NOT NULL,
        foto_datos     VARBINARY(MAX) NOT NULL,
        foto_nombre    VARCHAR(200)  NULL,
        foto_tipo      VARCHAR(50)   NULL,
        foto_principal CHAR(1)       DEFAULT 'N',
        foto_fecha     DATETIME      DEFAULT GETDATE(),
        CONSTRAINT FK_foto_usu FOREIGN KEY (usu_id) REFERENCES tbl_usuario(usu_id)
    );
    PRINT 'Tabla tbl_foto_usuario creada.';
END
ELSE PRINT 'tbl_foto_usuario ya existe.';

-- 2) Columnas adicionales en tbl_usuario
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('tbl_usuario') AND name='usu_clave_temp')
    ALTER TABLE tbl_usuario ADD usu_clave_temp   VARCHAR(20)  NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('tbl_usuario') AND name='usu_clave_expira')
    ALTER TABLE tbl_usuario ADD usu_clave_expira DATETIME     NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('tbl_usuario') AND name='usu_totp_secret')
    ALTER TABLE tbl_usuario ADD usu_totp_secret  VARCHAR(64)  NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('tbl_usuario') AND name='usu_totp_activo')
    ALTER TABLE tbl_usuario ADD usu_totp_activo  CHAR(1)      DEFAULT 'N' NULL;

PRINT 'Columnas de seguridad verificadas.';

-- 3) Tipos de usuario base
IF NOT EXISTS (SELECT 1 FROM tbl_tipo_usuario WHERE tsus_nombre = 'Administrador')
    INSERT INTO tbl_tipo_usuario (tsus_nombre, tusu_estado) VALUES ('Administrador', 'A');

IF NOT EXISTS (SELECT 1 FROM tbl_tipo_usuario WHERE tsus_nombre = 'Usuario')
    INSERT INTO tbl_tipo_usuario (tsus_nombre, tusu_estado) VALUES ('Usuario', 'A');

PRINT 'Script completado correctamente.';
