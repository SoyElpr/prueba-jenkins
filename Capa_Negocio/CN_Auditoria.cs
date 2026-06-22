using System;
using System.Data;
using System.Linq;
using System.Web;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_Auditoria
    {
        private static string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["conexion"].ConnectionString;
        }

        public static void Log(int? usuId, string accion, string modulo)
        {
            string ip = HttpContext.Current?.Request?.UserHostAddress ?? "0.0.0.0";

            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var log = new Tbl_auditoria
                {
                    Usu_id = usuId,
                    Audi_accion = accion,
                    Audi_modulo = modulo,
                    Audi_ip = ip,
                    Audi_fecha = DateTime.Now
                };
                db.Tbl_auditoria.InsertOnSubmit(log);
                db.SubmitChanges();
            }
        }

        public static DataTable ListarLogs()
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var query = (from a in db.Tbl_auditoria
                             join u in db.Tbl_usuario on a.Usu_id equals u.Usu_id into joined
                             from subU in joined.DefaultIfEmpty()
                             orderby a.Audi_fecha descending
                             select new
                             {
                                 audi_id = a.Audi_id,
                                 usu_nick = subU != null ? subU.Usu_nick : "Sistema",
                                 audi_accion = a.Audi_accion,
                                 audi_modulo = a.Audi_modulo,
                                 audi_ip = a.Audi_ip,
                                 audi_fecha = a.Audi_fecha
                             }).Take(50);
                return CN_tbl_usuario.ToDataTable(query.ToList());
            }
        }
    }
}
