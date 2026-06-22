using System;
using System.Collections.Generic;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_tipo_usuario
    {
        private static string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["conexion"].ConnectionString;
        }

        public static List<Tbl_tipo_usuario> Listar()
        {
            using (DataClasses1DataContext db = new DataClasses1DataContext(GetConnectionString()))
            {
                var query = from tu in db.Tbl_tipo_usuario
                            where tu.Tusu_estado == "A"
                            select tu;
                return query.ToList();
            }
        }
    }
}
