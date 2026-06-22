using System;
using System.Data;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_foto_usuario
    {
        private static string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["conexion"].ConnectionString;
        }

        public static int AgregarFoto(int usuId, byte[] datos, string nombre,
                                      string tipo, bool esPrincipal)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                if (esPrincipal)
                {
                    // Desmarcar foto principal actual
                    var fotos = db.Tbl_foto_usuario.Where(f => f.Usu_id == usuId);
                    foreach (var f in fotos)
                    {
                        f.Foto_principal = "N";
                    }
                    db.SubmitChanges();
                }

                var nueva = new Tbl_foto_usuario
                {
                    Usu_id = usuId,
                    Foto_datos = new System.Data.Linq.Binary(datos),
                    Foto_nombre = nombre,
                    Foto_tipo = tipo,
                    Foto_principal = esPrincipal ? "S" : "N",
                    Foto_fecha = DateTime.Now
                };

                db.Tbl_foto_usuario.InsertOnSubmit(nueva);
                db.SubmitChanges();
                return nueva.Foto_id;
            }
        }

        public static byte[] ObtenerFotoPrincipal(int usuId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var foto = db.Tbl_foto_usuario
                             .Where(f => f.Usu_id == usuId)
                             .OrderByDescending(f => f.Foto_principal == "S")
                             .ThenBy(f => f.Foto_fecha)
                             .FirstOrDefault();
                return foto?.Foto_datos?.ToArray();
            }
        }

        public static byte[] ObtenerFotoPorId(int fotoId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var foto = db.Tbl_foto_usuario.FirstOrDefault(f => f.Foto_id == fotoId);
                return foto?.Foto_datos?.ToArray();
            }
        }

        public static DataTable ListarFotos(int usuId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var query = from f in db.Tbl_foto_usuario
                            where f.Usu_id == usuId
                            orderby f.Foto_fecha descending
                            select new
                            {
                                f.Foto_id,
                                f.Foto_nombre,
                                f.Foto_tipo,
                                f.Foto_principal,
                                f.Foto_fecha
                            };
                return CN_tbl_usuario.ToDataTable(query.ToList());
            }
        }

        public static void EliminarFoto(int fotoId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var foto = db.Tbl_foto_usuario.FirstOrDefault(f => f.Foto_id == fotoId);
                if (foto != null)
                {
                    db.Tbl_foto_usuario.DeleteOnSubmit(foto);
                    db.SubmitChanges();
                }
            }
        }

        public static void SetPrincipal(int fotoId, int usuId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var fotos = db.Tbl_foto_usuario.Where(f => f.Usu_id == usuId);
                foreach (var f in fotos)
                {
                    f.Foto_principal = (f.Foto_id == fotoId) ? "S" : "N";
                }
                db.SubmitChanges();
            }
        }
    }
}
