using System;
using System.Data;
using System.Web;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace Monolito_4Am.Dashboard
{
    public partial class Usuario : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usu_id"] == null || Session["autenticado"] == null)
            { Response.Redirect("~/Seguridad/login.aspx"); return; }

            if (!IsPostBack)
            {
                int    usuId    = (int)Session["usu_id"];
                string nombres  = Session["usu_nombres"]?.ToString()  ?? "";
                string nick     = Session["usu_nick"]?.ToString()      ?? "";

                lblUserNick.Text = nick;
                lblNombres.Text  = nombres;

                imgAvatar.ImageUrl     = $"~/Handlers/FotoHandler.ashx?usu_id={usuId}";
                imgFotoPerfil.ImageUrl = $"~/Handlers/FotoHandler.ashx?usu_id={usuId}";

                CargarEstadisticas(usuId);
                CargarGaleria(usuId);
            }
        }

        private void CargarEstadisticas(int usuId)
        {
            try
            {
                rptLeaderboard.DataSource = CN_Puntuacion.ObtenerMejoresPuntajes();
                rptLeaderboard.DataBind();

                rptMisPuntajes.DataSource = CN_Puntuacion.ObtenerPuntajesUsuario(usuId);
                rptMisPuntajes.DataBind();
            }
            catch { /* Ignorar si no hay datos */ }
        }

        private void CargarGaleria(int usuId)
        {
            DataTable dt = CN_tbl_foto_usuario.ListarFotos(usuId);
            // Filtrar solo las que NO son principales para la galería
            DataView dv = new DataView(dt);
            dv.RowFilter = "foto_principal = 'N'";
            rptGaleria.DataSource = dv;
            rptGaleria.DataBind();
        }

        protected void btnSubirGaleria_Click(object sender, EventArgs e)
        {
            if (fupGaleria.HasFiles)
            {
                try
                {
                    int usuId = (int)Session["usu_id"];
                    int subidos = 0;
                    string error = "";

                    // Limite de 5 fotos en galeria
                    DataTable actual = CN_tbl_foto_usuario.ListarFotos(usuId);
                    int conteoGaleria = actual.Select("foto_principal = 'N'").Length;

                    foreach (HttpPostedFile file in fupGaleria.PostedFiles)
                    {
                        if (conteoGaleria + subidos >= 5) { error = "Máximo 5 fotos en galería."; break; }

                        string ext = System.IO.Path.GetExtension(file.FileName).ToLower();
                        string[] permitidos = { ".jpg", ".jpeg", ".png" };
                        if (!Array.Exists(permitidos, ex => ex == ext)) continue;
                        if (file.ContentLength > 2 * 1024 * 1024) continue;

                        byte[] data = new byte[file.ContentLength];
                        file.InputStream.Read(data, 0, file.ContentLength);

                        CN_tbl_foto_usuario.AgregarFoto(usuId, data, file.FileName, file.ContentType, false);
                        subidos++;
                    }

                    CargarGaleria(usuId);
                    MostrarMensajePerfil(subidos > 0 ? $"✅ {subidos} fotos añadidas." : "⚠ No se subieron fotos (formato o tamaño inválido). " + error, subidos == 0);
                }
                catch (Exception ex) { MostrarMensajePerfil("❌ Error: " + ex.Message, true); }
            }
        }

        protected void btnEliminarFoto_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int fotoId = int.Parse(btn.CommandArgument);
            CN_tbl_foto_usuario.EliminarFoto(fotoId);
            CargarGaleria((int)Session["usu_id"]);
            MostrarMensajePerfil("🗑 Foto eliminada.", false);
        }

        protected void btnPrevNuevoFoto_Click(object sender, EventArgs e)
        {
            if (fupNuevoFoto.HasFile)
            {
                // VALIDACIONES
                string ext = System.IO.Path.GetExtension(fupNuevoFoto.FileName).ToLower();
                string[] permitidos = { ".jpg", ".jpeg", ".png", ".gif" };
                if (!Array.Exists(permitidos, ex => ex == ext))
                {
                    MostrarMensajePerfil("⚠ Formato no válido. Use: JPG, PNG o GIF.", true);
                    return;
                }
                if (fupNuevoFoto.PostedFile.ContentLength > 2 * 1024 * 1024)
                {
                    MostrarMensajePerfil("⚠ La imagen es muy pesada. Máximo 2 MB.", true);
                    return;
                }

                byte[] datos = fupNuevoFoto.FileBytes;
                Session["FotoPreview"]       = datos;
                Session["FotoPreviewNombre"] = fupNuevoFoto.FileName;
                Session["FotoPreviewTipo"]   = fupNuevoFoto.PostedFile.ContentType;

                string base64 = Convert.ToBase64String(datos);
                string mime   = fupNuevoFoto.PostedFile.ContentType;
                imgNuevoFotoPreview.ImageUrl = "data:" + mime + ";base64," + base64;
                imgNuevoFotoPreview.Visible  = true;
                pnlMsgPerfil.Visible = false;
                secPerfil.Style["display"]   = "block";
            }
        }

        protected void btnSubirFoto_Click(object sender, EventArgs e)
        {
            try
            {
                int    usuId = (int)Session["usu_id"];
                byte[] datos = null;
                string nom   = "";
                string tipo  = "";

                if (fupNuevoFoto.HasFile)
                {
                    // VALIDACIONES (doble check)
                    string ext = System.IO.Path.GetExtension(fupNuevoFoto.FileName).ToLower();
                    if (fupNuevoFoto.PostedFile.ContentLength > 2 * 1024 * 1024)
                    {
                        MostrarMensajePerfil("⚠ La imagen es muy pesada. Máximo 2 MB.", true);
                        return;
                    }

                    datos = fupNuevoFoto.FileBytes;
                    nom   = fupNuevoFoto.FileName;
                    tipo  = fupNuevoFoto.PostedFile.ContentType;
                }
                else
                {
                    datos = Session["FotoPreview"] as byte[];
                    nom   = Session["FotoPreviewNombre"] as string;
                    tipo  = Session["FotoPreviewTipo"] as string;
                }

                if (datos == null)
                {
                    MostrarMensajePerfil("⚠ Seleccione una imagen primero.", true);
                    return;
                }

                CN_tbl_foto_usuario.AgregarFoto(usuId, datos, nom, tipo, true);

                Session.Remove("FotoPreview");
                Session.Remove("FotoPreviewNombre");
                Session.Remove("FotoPreviewTipo");
                
                imgFotoPerfil.ImageUrl = $"~/Handlers/FotoHandler.ashx?usu_id={usuId}&t={DateTime.Now.Ticks}";
                imgAvatar.ImageUrl     = imgFotoPerfil.ImageUrl;
                imgNuevoFotoPreview.Visible = false;
                
                MostrarMensajePerfil("✅ Foto actualizada correctamente.", false);
            }
            catch (Exception ex)
            {
                MostrarMensajePerfil("❌ Error: " + ex.Message, true);
            }
        }

        private void MostrarMensajePerfil(string texto, bool esError)
        {
            secPerfil.Style["display"] = "block";
            pnlMsgPerfil.Visible  = true;
            pnlMsgPerfil.CssClass = esError ? "error" : "success";
            lblMsgPerfil.Text     = texto;
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("~/Seguridad/login.aspx?msg=logout");
        }
    }
}
