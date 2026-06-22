using System;
using System.Web;
using Capa_Negocio;

namespace Monolito_4Am.Handlers
{
    public class FotoHandler : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public bool IsReusable => false;

        public void ProcessRequest(HttpContext ctx)
        {
            byte[] datos = null;

            string mode   = ctx.Request.QueryString["mode"];
            string fotoId = ctx.Request.QueryString["foto_id"];
            string usuId  = ctx.Request.QueryString["usu_id"];

            if (mode == "preview")
            {
                // Previsualización temporal guardada en Session
                datos = ctx.Session["FotoPreview"] as byte[];
            }
            else if (!string.IsNullOrEmpty(fotoId) && int.TryParse(fotoId, out int fid))
            {
                datos = CN_tbl_foto_usuario.ObtenerFotoPorId(fid);
            }
            else if (!string.IsNullOrEmpty(usuId) && int.TryParse(usuId, out int uid))
            {
                datos = CN_tbl_foto_usuario.ObtenerFotoPrincipal(uid);
            }

            if (datos != null && datos.Length > 0)
            {
                ctx.Response.ContentType = DetectarMime(datos);
                ctx.Response.Cache.SetCacheability(HttpCacheability.Private);
                ctx.Response.Cache.SetExpires(DateTime.Now.AddMinutes(30));
                ctx.Response.BinaryWrite(datos);
            }
            else
            {
                // Imagen de placeholder (1x1 px transparente PNG)
                byte[] placeholder = Convert.FromBase64String(
                    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==");
                ctx.Response.ContentType = "image/png";
                ctx.Response.BinaryWrite(placeholder);
            }
        }

        private string DetectarMime(byte[] datos)
        {
            if (datos.Length >= 4)
            {
                // PNG
                if (datos[0] == 0x89 && datos[1] == 0x50) return "image/png";
                // JPEG
                if (datos[0] == 0xFF && datos[1] == 0xD8) return "image/jpeg";
                // GIF
                if (datos[0] == 0x47 && datos[1] == 0x49) return "image/gif";
                // WebP
                if (datos[0] == 0x52 && datos[1] == 0x49) return "image/webp";
            }
            return "image/jpeg";
        }
    }
}
