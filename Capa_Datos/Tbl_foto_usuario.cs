using System;
using System.Data.Linq;
using MongoDB.Bson.Serialization.Attributes;

namespace Capa_Datos
{
    public class Tbl_foto_usuario : IEntity
    {
        [BsonId]
        public int Foto_id { get; set; }

        int IEntity.Id
        {
            get => Foto_id;
            set => Foto_id = value;
        }

        public int Usu_id { get; set; }

        [BsonIgnore]
        public Binary Foto_datos
        {
            get => _foto_datosBytes != null ? new Binary(_foto_datosBytes) : null;
            set => _foto_datosBytes = value?.ToArray();
        }

        [BsonElement("Foto_datos")]
        public byte[] _foto_datosBytes { get; set; }

        public string Foto_nombre { get; set; }
        public string Foto_tipo { get; set; }
        public string Foto_principal { get; set; }
        public DateTime? Foto_fecha { get; set; }
    }
}
