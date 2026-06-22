<%@ Page Language="C#" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="Capa_Negocio" %>
<%@ Import Namespace="Capa_Datos" %>
<%@ Import Namespace="MongoDB.Driver" %>

<!DOCTYPE html>
<html>
<head><title>Inicializar Base de Datos MongoDB</title></head>
<body>
    <form id="form1" runat="server">
        <div>
            <h2>Inicializando MongoDB...</h2>
            <asp:Label ID="lblResultado" runat="server" Font-Bold="true" />
        </div>
    </form>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            string connString = ConfigurationManager.ConnectionStrings["conexion"].ConnectionString;
            var sb = new System.Text.StringBuilder();
            try
            {
                var url = new MongoUrl(connString);
                var client = new MongoClient(url);
                var database = client.GetDatabase(url.DatabaseName ?? "Monolito4am");

                // ── Tipos de usuario semilla ─────────────────────────────
                var tiposCol = database.GetCollection<Tbl_tipo_usuario>("tbl_tipo_usuario");
                if (tiposCol.CountDocuments(Builders<Tbl_tipo_usuario>.Filter.Empty) == 0)
                {
                    tiposCol.InsertMany(new[]
                    {
                        new Tbl_tipo_usuario { Tusu_id = 1, Tsus_nombre = "Proveedor",      Tusu_estado = "A" },
                        new Tbl_tipo_usuario { Tusu_id = 2, Tsus_nombre = "Usuario",        Tusu_estado = "A" },
                        new Tbl_tipo_usuario { Tusu_id = 3, Tsus_nombre = "Administrador",  Tusu_estado = "A" }
                    });
                    sb.AppendLine("✅ Tipos de usuario creados.<br/>");
                }
                else
                {
                    sb.AppendLine("ℹ️ Tipos de usuario ya existen.<br/>");
                }

                // ── Usuario Administrador semilla ────────────────────────
                var usuCol = database.GetCollection<Tbl_usuario>("tbl_usuario");
                if (usuCol.CountDocuments(Builders<Tbl_usuario>.Filter.Eq(u => u.Usu_cedula, "0000000001")) == 0)
                {
                    byte[] passBytes = EncryptionHelper.Encrypt("admin123");
                    int nextId = 1;
                    var highestUsu = usuCol.Find(Builders<Tbl_usuario>.Filter.Empty)
                        .Sort(Builders<Tbl_usuario>.Sort.Descending("_id")).Limit(1).FirstOrDefault();
                    if (highestUsu != null) nextId = highestUsu.Usu_id + 1;

                    var admin = new Tbl_usuario
                    {
                        Usu_id              = nextId,
                        Usu_cedula          = "0000000001",
                        Usu_nombres         = "Administrador",
                        Usu_apellidos       = "Sistema",
                        Usu_celular         = "0000000000",
                        Usu_correo          = "admin@monolito.com",
                        Usu_nick            = "admin",
                        _usu_contraseñaBytes = passBytes,
                        Usu_estado          = "A",
                        Tusu_id             = 3,
                        Usu_intentos        = 0,
                        Usu_fecha_creacion  = DateTime.Now,
                        Usu_totp_activo     = "N"
                    };
                    usuCol.InsertOne(admin);
                    sb.AppendLine("✅ Usuario Administrador creado (cedula: 0000000001, password: admin123).<br/>");
                }
                else
                {
                    sb.AppendLine("ℹ️ Usuario Administrador ya existe.<br/>");
                }

                // ── Usuario Proveedor semilla ────────────────────────
                if (usuCol.CountDocuments(Builders<Tbl_usuario>.Filter.Eq(u => u.Usu_cedula, "1234567890")) == 0)
                {
                    byte[] passBytes = EncryptionHelper.Encrypt("1234");
                    int nextId = 2;
                    var highestUsu = usuCol.Find(Builders<Tbl_usuario>.Filter.Empty)
                        .Sort(Builders<Tbl_usuario>.Sort.Descending("_id")).Limit(1).FirstOrDefault();
                    if (highestUsu != null) nextId = highestUsu.Usu_id + 1;

                    var provUsu = new Tbl_usuario
                    {
                        Usu_id              = nextId,
                        Usu_cedula          = "1234567890",
                        Usu_nombres         = "Usuario",
                        Usu_apellidos       = "Proveedor",
                        Usu_celular         = "0999999999",
                        Usu_correo          = "proveedor@monolito.com",
                        Usu_nick            = "proveedor",
                        _usu_contraseñaBytes = passBytes,
                        Usu_estado          = "A",
                        Tusu_id             = 1, // 1 es Proveedor en la tabla tipos
                        Usu_intentos        = 0,
                        Usu_fecha_creacion  = DateTime.Now,
                        Usu_totp_activo     = "N"
                    };
                    usuCol.InsertOne(provUsu);
                    sb.AppendLine("✅ Usuario Proveedor creado (cedula: 1234567890, password: 1234).<br/>");
                }
                else
                {
                    sb.AppendLine("ℹ️ Usuario Proveedor ya existe.<br/>");
                }

                // ── Proveedores semilla ──────────────────────────────────
                var provCol = database.GetCollection<Tbl_provedor>("tbl_provedor");
                if (provCol.CountDocuments(Builders<Tbl_provedor>.Filter.Empty) == 0)
                {
                    provCol.InsertMany(new[]
                    {
                        new Tbl_provedor { Prov_id = 1, Prov_nombre = "Distribuidora Fenix",  Prov_estado = "A" },
                        new Tbl_provedor { Prov_id = 2, Prov_nombre = "Importadora del Sur",   Prov_estado = "A" }
                    });
                    sb.AppendLine("✅ Proveedores semilla creados.<br/>");
                }
                else
                {
                    sb.AppendLine("ℹ️ Proveedores ya existen.<br/>");
                }

                // ── Productos semilla ────────────────────────────────────
                var prodCol = database.GetCollection<Tbl_producto>("tbl_producto");
                if (prodCol.CountDocuments(Builders<Tbl_producto>.Filter.Empty) == 0)
                {
                    prodCol.InsertMany(new[]
                    {
                        new Tbl_producto
                        {
                            Pro_id = 1, Pro_codigo = "78610012", Pro_nombre = "Paracetamol 500mg",
                            Pro_cantidad = 100, Pro_precio = 1.50m,
                            Pro_descripcion = "Caja de 20 tabletas analgesicas",
                            Pro_foto = "no_image.png", Pro_estado = "A", Prov_id = 1
                        },
                        new Tbl_producto
                        {
                            Pro_id = 2, Pro_codigo = "78610015", Pro_nombre = "Ibuprofeno 400mg",
                            Pro_cantidad = 150, Pro_precio = 2.20m,
                            Pro_descripcion = "Caja de 10 tabletas antiinflamatorias",
                            Pro_foto = "no_image.png", Pro_estado = "A", Prov_id = 2
                        }
                    });
                    sb.AppendLine("✅ Productos semilla creados.<br/>");
                }
                else
                {
                    sb.AppendLine("ℹ️ Productos ya existen.<br/>");
                }

                // ── Desbloquear todos los usuarios ───────────────────────
                var updateDef = Builders<Tbl_usuario>.Update
                    .Set(u => u.Usu_estado, "A")
                    .Set(u => u.Usu_intentos, 0);
                var unlockResult = usuCol.UpdateMany(Builders<Tbl_usuario>.Filter.Empty, updateDef);
                sb.AppendLine($"✅ {unlockResult.ModifiedCount} usuario(s) desbloqueado(s).<br/>");

                lblResultado.Text = "<strong style='color:green'>✅ MongoDB inicializado correctamente.</strong><br/>" + sb.ToString();
            }
            catch (Exception ex)
            {
                lblResultado.Text = "<strong style='color:red'>❌ Error: " + ex.Message + "</strong><br/>" + ex.StackTrace;
            }
        }
    </script>
</body>
</html>
