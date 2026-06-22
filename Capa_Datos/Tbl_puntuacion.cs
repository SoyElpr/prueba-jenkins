using System;
using MongoDB.Bson.Serialization.Attributes;

namespace Capa_Datos
{
    public class Tbl_puntuacion : IEntity
    {
        [BsonId]
        public int Punt_id { get; set; }

        int IEntity.Id
        {
            get => Punt_id;
            set => Punt_id = value;
        }

        public int Usu_id { get; set; }
        public int Punt_valor { get; set; }
        public int Punt_rondas { get; set; }
        public DateTime? Punt_fecha { get; set; }
    }
}
