using System;
using MongoDB.Bson.Serialization.Attributes;

namespace Capa_Datos
{
    public class Tbl_producto : IEntity
    {
        [BsonId]
        public int Pro_id { get; set; }

        int IEntity.Id
        {
            get => Pro_id;
            set => Pro_id = value;
        }

        public string Pro_codigo { get; set; }
        public string Pro_nombre { get; set; }
        public int Pro_cantidad { get; set; }
        public decimal Pro_precio { get; set; }
        public string Pro_descripcion { get; set; }
        public string Pro_foto { get; set; }
        public string Pro_estado { get; set; }
        public int? Prov_id { get; set; }
    }
}
