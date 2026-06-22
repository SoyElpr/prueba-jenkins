using System;
using MongoDB.Bson.Serialization.Attributes;

namespace Capa_Datos
{
    public class Tbl_auditoria : IEntity
    {
        [BsonId]
        public int Audi_id { get; set; }

        int IEntity.Id
        {
            get => Audi_id;
            set => Audi_id = value;
        }

        public int? Usu_id { get; set; }
        public string Audi_accion { get; set; }
        public string Audi_modulo { get; set; }
        public string Audi_ip { get; set; }
        public DateTime? Audi_fecha { get; set; }
    }
}
