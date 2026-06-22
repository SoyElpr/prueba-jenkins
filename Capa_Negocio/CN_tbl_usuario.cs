using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_usuario
    {
        private const int MAX_INTENTOS = 3;

        public enum ResultadoLogin { Exitoso, CredencialesInvalidas, UsuarioBloqueado, UsuarioInactivo }

        public class InfoLogin
        {
            public ResultadoLogin Resultado;
            public int UsuId;
            public string Nombres;
            public string Apellidos;
            public string Nick;
            public string Correo;
            public string Celular;
            public int TipoUsuId;
            public string TipoUsuNombre;
            public bool TotpActivo;
            public string TotpSecret;
            public int IntentosRestantes;
        }

        private static string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["conexion"].ConnectionString;
        }

        // --- LOGIN ---
        public static InfoLogin Login(string cedula, string password)
        {
            InfoLogin info = new InfoLogin();

            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var usu = db.Tbl_usuario.FirstOrDefault(u => u.Usu_cedula == cedula);
                if (usu == null)
                {
                    info.Resultado = ResultadoLogin.CredencialesInvalidas;
                    return info;
                }

                string estado = usu.Usu_estado?.ToString().Trim() ?? "";
                if (estado == "B")
                {
                    info.UsuId = usu.Usu_id;
                    info.Resultado = ResultadoLogin.UsuarioBloqueado;
                    return info;
                }
                if (estado != "A")
                {
                    info.Resultado = ResultadoLogin.UsuarioInactivo;
                    return info;
                }

                // Validar contraseña
                bool esPasswordValido = usu._usu_contraseñaBytes != null &&
                    EncryptionHelper.Decrypt(usu._usu_contraseñaBytes) == password;
                if (!esPasswordValido)
                {
                    usu.Usu_intentos = (usu.Usu_intentos ?? 0) + 1;
                    usu.Usu_fecha_ultimo_intento = DateTime.Now;
                    if (usu.Usu_intentos >= MAX_INTENTOS)
                    {
                        usu.Usu_estado = "B";
                    }
                    db.SubmitChanges();

                    info.IntentosRestantes = Math.Max(0, MAX_INTENTOS - (usu.Usu_intentos ?? 0));
                    info.UsuId = usu.Usu_id;
                    info.Resultado = ResultadoLogin.CredencialesInvalidas;
                    return info;
                }

                // Login exitoso, resetear intentos
                usu.Usu_intentos = 0;
                db.SubmitChanges();

                var tipo = db.Tbl_tipo_usuario.FirstOrDefault(t => t.Tusu_id == usu.Tusu_id);

                info.Resultado = ResultadoLogin.Exitoso;
                info.UsuId = usu.Usu_id;
                info.Nombres = usu.Usu_nombres;
                info.Apellidos = usu.Usu_apellidos;
                info.Nick = usu.Usu_nick;
                info.Correo = usu.Usu_correo;
                info.Celular = usu.Usu_celular;
                info.TipoUsuId = usu.Tusu_id ?? 0;
                info.TipoUsuNombre = tipo?.Tsus_nombre ?? "";

                string totpAct = usu.Usu_totp_activo?.ToString().Trim() ?? "N";
                info.TotpActivo = (totpAct == "S");
                info.TotpSecret = DecryptSecret(usu.Usu_totp_secret, db);

                return info;
            }
        }

        public static string GenerarClaveTemp(string cedula)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var usu = db.Tbl_usuario.FirstOrDefault(u => u.Usu_cedula == cedula);
                if (usu == null) return null;

                string chars = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
                Random rng = new Random();
                System.Text.StringBuilder clave = new System.Text.StringBuilder();
                for (int i = 0; i < 8; i++)
                {
                    clave.Append(chars[rng.Next(chars.Length)]);
                }

                string claveStr = clave.ToString();
                usu.Usu_clave_temp = claveStr;
                usu.Usu_clave_expira = DateTime.Now.AddMinutes(15);
                db.SubmitChanges();

                return claveStr;
            }
        }

        public static bool ValidarClaveTemp(string cedula, string clave)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                return db.Tbl_usuario.Any(u => u.Usu_cedula == cedula && u.Usu_clave_temp == clave && u.Usu_clave_expira > DateTime.Now);
            }
        }

        public static void CambiarPassword(string cedula, string nuevaPass)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var usu = db.Tbl_usuario.FirstOrDefault(u => u.Usu_cedula == cedula);
                if (usu != null)
                {
                    usu._usu_contraseñaBytes = EncryptionHelper.Encrypt(nuevaPass);
                    usu.Usu_clave_temp = null;
                    usu.Usu_clave_expira = null;
                    db.SubmitChanges();
                }
            }
        }

        public static void DesbloquearUsuario(int usuId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var usu = db.Tbl_usuario.FirstOrDefault(u => u.Usu_id == usuId);
                if (usu != null)
                {
                    usu.Usu_estado = "A";
                    usu.Usu_intentos = 0;
                    db.SubmitChanges();
                }
            }
        }

        public static void GuardarSecretoTOTP(int usuId, string secret)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var usu = db.Tbl_usuario.FirstOrDefault(u => u.Usu_id == usuId);
                if (usu != null)
                {
                    usu.Usu_totp_secret = EncryptSecret(secret, db);
                    usu.Usu_totp_activo = "S";
                    db.SubmitChanges();
                }
            }
        }

        public static string ObtenerSecretoTOTP(int usuId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var usu = db.Tbl_usuario.FirstOrDefault(u => u.Usu_id == usuId);
                return usu != null ? DecryptSecret(usu.Usu_totp_secret, db) : null;
            }
        }

        // --- LISTADOS ---
        public static DataTable ListarBloqueados()
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var query = from u in db.Tbl_usuario
                            join t in db.Tbl_tipo_usuario on u.Tusu_id equals t.Tusu_id
                            where u.Usu_estado == "B"
                            orderby u.Usu_fecha_ultimo_intento descending
                            select new
                            {
                                u.Usu_id,
                                u.Usu_cedula,
                                u.Usu_nombres,
                                u.Usu_apellidos,
                                u.Usu_correo,
                                u.Usu_nick,
                                u.Usu_intentos,
                                u.Usu_fecha_ultimo_intento,
                                tipo = t.Tsus_nombre
                            };
                return ToDataTable(query.ToList());
            }
        }

        public static DataTable ListarTodos()
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var query = from u in db.Tbl_usuario
                            join t in db.Tbl_tipo_usuario on u.Tusu_id equals t.Tusu_id
                            orderby u.Usu_nombres
                            select new
                            {
                                u.Usu_id,
                                u.Usu_cedula,
                                u.Usu_nombres,
                                u.Usu_apellidos,
                                u.Usu_correo,
                                u.Usu_nick,
                                u.Usu_estado,
                                u.Usu_intentos,
                                tipo = t.Tsus_nombre
                            };
                return ToDataTable(query.ToList());
            }
        }

        // --- REGISTRO ---
        public static int RegistrarUsuario(string cedula, string nombres, string apellidos,
            string celular, string correo, string nick, string password,
            DateTime fechaCumple, int tipoUsuario)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var usu = new Tbl_usuario
                {
                    Usu_cedula = cedula,
                    Usu_nombres = nombres,
                    Usu_apellidos = apellidos,
                    Usu_celular = celular,
                    Usu_correo = correo,
                    Usu_nick = nick,
                    _usu_contraseñaBytes = EncryptionHelper.Encrypt(password),
                    Usu_fecha_cumple = fechaCumple,
                    Tusu_id = tipoUsuario,
                    Usu_estado = "A",
                    Usu_intentos = 0,
                    Usu_fecha_creacion = DateTime.Now
                };
                db.Tbl_usuario.InsertOnSubmit(usu);
                db.SubmitChanges();
                return usu.Usu_id;
            }
        }

        public static DataRow ObtenerPorId(int usuId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var u = db.Tbl_usuario.FirstOrDefault(x => x.Usu_id == usuId);
                if (u == null) return null;

                var dt = new DataTable();
                dt.Columns.Add("usu_id", typeof(int));
                dt.Columns.Add("usu_cedula", typeof(string));
                dt.Columns.Add("usu_nombres", typeof(string));
                dt.Columns.Add("usu_apellidos", typeof(string));
                dt.Columns.Add("usu_correo", typeof(string));
                dt.Columns.Add("usu_nick", typeof(string));
                dt.Columns.Add("usu_estado", typeof(char));
                dt.Columns.Add("decrypted_secret", typeof(string));

                dt.Rows.Add(u.Usu_id, u.Usu_cedula, u.Usu_nombres, u.Usu_apellidos, u.Usu_correo, u.Usu_nick, u.Usu_estado, DecryptSecret(u.Usu_totp_secret, db));
                return dt.Rows[0];
            }
        }

        public static void ActualizarUsuario(int usuId, string cedula, string nombres, string apellidos, string correo)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var usu = db.Tbl_usuario.FirstOrDefault(u => u.Usu_id == usuId);
                if (usu != null)
                {
                    usu.Usu_cedula = cedula;
                    usu.Usu_nombres = nombres;
                    usu.Usu_apellidos = apellidos;
                    usu.Usu_correo = correo;
                    db.SubmitChanges();
                }
            }
        }

        public static void CambiarEstado(int usuId, string estado)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var usu = db.Tbl_usuario.FirstOrDefault(u => u.Usu_id == usuId);
                if (usu != null && estado.Length > 0)
                {
                    usu.Usu_estado = estado[0].ToString();
                    db.SubmitChanges();
                }
            }
        }

        // --- HELPERS PARA HEX-BINARY Y DATATABLE ---
        private static byte[] StringToByteArray(string hex)
        {
            if (string.IsNullOrEmpty(hex)) return null;
            if (hex.StartsWith("0x", StringComparison.OrdinalIgnoreCase))
                hex = hex.Substring(2);
            if (hex.Length % 2 != 0)
                hex = "0" + hex;
            int NumberChars = hex.Length;
            byte[] bytes = new byte[NumberChars / 2];
            for (int i = 0; i < NumberChars; i += 2)
                bytes[i / 2] = Convert.ToByte(hex.Substring(i, 2), 16);
            return bytes;
        }

        private static string DecryptSecret(string secretHex, DataClasses1DataContext db)
        {
            if (string.IsNullOrEmpty(secretHex)) return null;
            // If stored as plain base32 (new records), return directly
            // If stored as hex-encoded AES ciphertext, decrypt it
            if (secretHex.StartsWith("0x", StringComparison.OrdinalIgnoreCase))
            {
                byte[] bytes = StringToByteArray(secretHex);
                return EncryptionHelper.Decrypt(bytes);
            }
            return secretHex;
        }

        private static string EncryptSecret(string plainText, DataClasses1DataContext db)
        {
            if (string.IsNullOrEmpty(plainText)) return null;
            byte[] encrypted = EncryptionHelper.Encrypt(plainText);
            return "0x" + BitConverter.ToString(encrypted).Replace("-", "");
        }

        public static DataTable ToDataTable<T>(IEnumerable<T> items)
        {
            DataTable dataTable = new DataTable(typeof(T).Name);
            var properties = typeof(T).GetProperties(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance);
            foreach (var prop in properties)
            {
                var type = prop.PropertyType;
                if (type.IsGenericType && type.GetGenericTypeDefinition() == typeof(Nullable<>))
                {
                    type = Nullable.GetUnderlyingType(type);
                }
                dataTable.Columns.Add(prop.Name, type);
            }
            foreach (var item in items)
            {
                var values = new object[properties.Length];
                for (int i = 0; i < properties.Length; i++)
                {
                    values[i] = properties[i].GetValue(item, null) ?? DBNull.Value;
                }
                dataTable.Rows.Add(values);
            }
            return dataTable;
        }
    }
}
