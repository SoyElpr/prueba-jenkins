using System;
using MongoDB.Bson.Serialization.Attributes;

namespace Capa_Datos
{
    public class Tbl_tipo_usuario : IEntity
    {
        [BsonId]
        public int Tusu_id { get; set; }

        int IEntity.Id
        {
            get => Tusu_id;
            set => Tusu_id = value;
        }

        public string Tsus_nombre { get; set; }
        public string Tusu_estado { get; set; }
    }
}
