using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_provedor
    {
        private static string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["conexion"].ConnectionString;
        }

        public static List<Tbl_provedor> Listar()
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                return db.Tbl_provedor.Where(p => p.Prov_estado == "A").ToList();
            }
        }

        public static DataTable ListarDataTable()
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var query = from p in db.Tbl_provedor
                            orderby p.Prov_nombre
                            select new
                            {
                                p.Prov_id,
                                p.Prov_nombre,
                                p.Prov_estado
                            };
                return CN_tbl_usuario.ToDataTable(query.ToList());
            }
        }

        public static Tbl_provedor ObtenerPorId(int provId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                return db.Tbl_provedor.FirstOrDefault(p => p.Prov_id == provId);
            }
        }

        public static int Insertar(string nombre, string estado = "A")
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var p = new Tbl_provedor
                {
                    Prov_nombre = nombre,
                    Prov_estado = string.IsNullOrEmpty(estado) ? "A" : estado
                };
                db.Tbl_provedor.InsertOnSubmit(p);
                db.SubmitChanges();
                return p.Prov_id;
            }
        }

        public static void Actualizar(int provId, string nombre, string estado)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var p = db.Tbl_provedor.FirstOrDefault(x => x.Prov_id == provId);
                if (p != null)
                {
                    p.Prov_nombre = nombre;
                    p.Prov_estado = string.IsNullOrEmpty(estado) ? "A" : estado;
                    db.SubmitChanges();
                }
            }
        }

        public static void Eliminar(int provId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var p = db.Tbl_provedor.FirstOrDefault(x => x.Prov_id == provId);
                if (p != null)
                {
                    db.Tbl_provedor.DeleteOnSubmit(p);
                    db.SubmitChanges();
                }
            }
        }
    }
}
