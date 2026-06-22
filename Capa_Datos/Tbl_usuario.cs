using System;
using System.Data.Linq;
using MongoDB.Bson.Serialization.Attributes;

namespace Capa_Datos
{
    public class Tbl_usuario : IEntity
    {
        [BsonId]
        public int Usu_id { get; set; }

        int IEntity.Id
        {
            get => Usu_id;
            set => Usu_id = value;
        }

        public string Usu_cedula { get; set; }
        public string Usu_nombres { get; set; }
        public string Usu_apellidos { get; set; }
        public string Usu_direccion { get; set; }
        public string Usu_celular { get; set; }
        public string Usu_correo { get; set; }
        public DateTime? Usu_fecha_creacion { get; set; }
        public DateTime? Usu_fecha_cumple { get; set; }
        public string Usu_nick { get; set; }

        [BsonIgnore]
        public Binary Usu_contraseñA
        {
            get => _usu_contraseñaBytes != null ? new Binary(_usu_contraseñaBytes) : null;
            set => _usu_contraseñaBytes = value?.ToArray();
        }

        [BsonElement("Usu_contraseñA")]
        public byte[] _usu_contraseñaBytes { get; set; }

        public int? Usu_intentos { get; set; }
        public string Usu_estado { get; set; }
        public int? Tusu_id { get; set; }
        public string Usu_codigo_OTP { get; set; }

        [BsonIgnore]
        public Binary Usu_foto
        {
            get => _usu_fotoBytes != null ? new Binary(_usu_fotoBytes) : null;
            set => _usu_fotoBytes = value?.ToArray();
        }

        [BsonElement("Usu_foto")]
        public byte[] _usu_fotoBytes { get; set; }

        public DateTime? Usu_fecha_ultimo_intetno { get; set; }
        public DateTime? Usu_fecha_ultimo_intento { get; set; }
        public string Usu_clave_temp { get; set; }
        public DateTime? Usu_clave_expira { get; set; }
        public string Usu_totp_secret { get; set; }
        public string Usu_totp_activo { get; set; }
    }
}
