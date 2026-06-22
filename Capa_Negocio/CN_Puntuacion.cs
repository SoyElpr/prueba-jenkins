using System;
using System.Data;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_Puntuacion
    {
        private static string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["conexion"].ConnectionString;
        }

        public static void RegistrarPuntuacion(int usuId, int puntos, int rondasGanadas)
        {
            if (puntos < 0) return;

            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var nueva = new Tbl_puntuacion
                {
                    Usu_id = usuId,
                    Punt_valor = puntos,
                    Punt_rondas = rondasGanadas,
                    Punt_fecha = DateTime.Now
                };
                db.Tbl_puntuacion.InsertOnSubmit(nueva);
                db.SubmitChanges();
            }
        }

        public static DataTable ObtenerMejoresPuntajes()
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var query = (from p in db.Tbl_puntuacion
                             join u in db.Tbl_usuario on p.Usu_id equals u.Usu_id
                             orderby p.Punt_valor descending, p.Punt_fecha descending
                             select new
                             {
                                 usu_nick = u.Usu_nick,
                                 punt_valor = p.Punt_valor,
                                 punt_rondas = p.Punt_rondas,
                                 punt_fecha = p.Punt_fecha
                             }).Take(10);
                return CN_tbl_usuario.ToDataTable(query.ToList());
            }
        }

        public static DataTable ObtenerPuntajesUsuario(int usuId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var query = from p in db.Tbl_puntuacion
                            where p.Usu_id == usuId
                            orderby p.Punt_fecha descending
                            select new
                            {
                                punt_valor = p.Punt_valor,
                                punt_rondas = p.Punt_rondas,
                                punt_fecha = p.Punt_fecha
                             };
                return CN_tbl_usuario.ToDataTable(query.ToList());
            }
        }
    }
}
