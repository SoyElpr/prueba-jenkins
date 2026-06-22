using System;
using MongoDB.Bson.Serialization.Attributes;

namespace Capa_Datos
{
    public class Tbl_provedor : IEntity
    {
        [BsonId]
        public int Prov_id { get; set; }

        int IEntity.Id
        {
            get => Prov_id;
            set => Prov_id = value;
        }

        public string Prov_nombre { get; set; }
        public string Prov_estado { get; set; }
    }
}
