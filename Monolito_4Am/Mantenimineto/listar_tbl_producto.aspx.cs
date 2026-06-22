using Capa_Negocio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace Monolito_4Am.Mantenimineto
{
    public partial class listar_tbl_producto : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarDatos();
            }
        }

        protected void btnAgregar_Click(object sender, EventArgs e)
        {
            Response.Redirect("agregar_tbl_producto.aspx");
        }

        protected void btnEditar_Click(object sender, EventArgs e)
        {
         
        }

        protected void btnEliminar_Click(object sender, EventArgs e)
        {
            
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            CargarDatos();
        }

        protected void btnNuevo_Click(object sender, EventArgs e)
        {
            Response.Redirect("nuevo_tbl_producto.aspx");
        }

        private void CargarDatos()
        {
            string termino = txtBuscar?.Text?.Trim() ?? string.Empty;
            string campo = ddlFiltro?.SelectedValue ?? "nombre";
            var dt = string.IsNullOrEmpty(termino) ? CN_tbl_producto.ListarTodos() : CN_tbl_producto.Buscar(termino, campo);
            gvProductos.DataSource = dt;
            gvProductos.DataBind();
        }

        protected void gvProductos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProductos.PageIndex = e.NewPageIndex;
            CargarDatos();
        }

        protected void gvProductos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "Editar")
            {
                Response.Redirect($"nuevo_tbl_producto.aspx?id={id}");
            }
            else if (e.CommandName == "Eliminar")
            {
                CN_tbl_producto.Eliminar(id);
                CargarDatos();
            }
        }

        protected void ddlFiltro_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarDatos();
        }

        protected void txtBuscar_TextChanged(object sender, EventArgs e)
        {
            CargarDatos();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = string.Empty;
            ddlFiltro.SelectedIndex = 0;
            CargarDatos();
        }


        public string GetFirstImage(object proFoto)
        {
            string foto = proFoto as string;
            if (string.IsNullOrEmpty(foto)) return "~/Uploads/no_image.png";
            var parts = foto.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 0) return "~/Uploads/no_image.png";
            string first = parts[0].Trim();
            return first.StartsWith("~/") ? first : "~/Uploads/" + first;
        }


        public string BuildPhotoStrip(object proFoto, object proId)
        {
            string foto = proFoto as string;
            if (string.IsNullOrEmpty(foto))
            {
                // Sin imagen: icono placeholder clicable
                string ph = ResolveUrl("~/Uploads/no_image.png");
                string phJs = $"openModal(['{ph}'],0); return false;";
                return $"<img src='{ph}' class='photo-thumb' onclick=\"{phJs}\" title='Sin imagen' />";
            }

            var parts = foto.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);
            var urls = new List<string>();
            foreach (var p in parts)
            {
                string t = p.Trim();
                string url = t.StartsWith("~/") ? ResolveUrl(t) : ResolveUrl("~/Uploads/" + t);
                urls.Add(url);
            }

            if (urls.Count == 0)
            {
                string ph = ResolveUrl("~/Uploads/no_image.png");
                return $"<img src='{ph}' class='photo-thumb' onclick=\"openModal(['{ph}'],0); return false;\" title='Sin imagen' />";
            }

            // Armar JSON array de URLs para el JS modal
            string jsArray = "['" + string.Join("','", urls) + "']";

            var sb = new System.Text.StringBuilder();
            int showCount = Math.Min(3, urls.Count); // mostrar máx 3 thumbs

            for (int i = 0; i < showCount; i++)
            {
                string u = urls[i];
                int capturedIndex = i;
                sb.Append($"<img src='{u}' class='photo-thumb' onclick=\"openModal({jsArray},{capturedIndex}); return false;\" title='Foto {i + 1} de {urls.Count}' />");
            }

            if (urls.Count > 3)
            {
                int extra = urls.Count - 3;
                sb.Append($"<span class='photo-count-badge' onclick=\"openModal({jsArray},3); return false;\">+{extra} más</span>");
            }

            return sb.ToString();
        }

        protected void btnExportarExcel_Click(object sender, EventArgs e)
        {
            try
            {
                byte[] bytes = CN_tbl_producto.ExportarExcel();
                string fileName = string.Format("productos_{0:yyyyMMdd_HHmmss}.xls", DateTime.Now);
                Response.Clear();
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                Response.AddHeader("Content-Length", bytes.Length.ToString());
                Response.BinaryWrite(bytes);
                Response.Flush();
                Response.End();
            }
            catch (Exception ex)
            {
                // Muestra el error en la etiqueta de info sin interrumpir la página
                lblInfo.Text = "❌ Error al exportar: " + ex.Message;
            }
        }
    }
}