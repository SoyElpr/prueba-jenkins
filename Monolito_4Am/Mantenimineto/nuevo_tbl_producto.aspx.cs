// nuevo_tbl_producto.aspx.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito_4Am.Mantenimineto
{
    public partial class nuevo_tbl_producto : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarProveedores();
                string idStr = Request.QueryString["id"];
                int prodId;
                if (!string.IsNullOrEmpty(idStr) && int.TryParse(idStr, out prodId))
                {
                    CargarProducto(prodId);
                    lblTitle.InnerText = "Editar Producto";
                }
                else
                {
                    lblTitle.InnerText = "Nuevo Producto";
                }
            }
        }

        private void CargarProveedores()
        {
            var lista = CN_tbl_provedor.Listar();
            ddlProveedor.DataSource = lista;
            ddlProveedor.DataValueField = "prov_id";
            ddlProveedor.DataTextField = "prov_nombre";
            ddlProveedor.DataBind();
            ddlProveedor.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Seleccionar --", ""));
        }

        private void CargarProducto(int prodId)
        {
            var prod = CN_tbl_producto.ObtenerPorId(prodId);
            if (prod != null)
            {
                ViewState["ProdId"] = prodId;
                txtCodigo.Text      = prod.Pro_codigo;
                txtNombre.Text      = prod.Pro_nombre;
                txtDescripcion.Text = prod.Pro_descripcion;
                txtPrecio.Text      = prod.Pro_precio.ToString("F2");
                txtCantidad.Text    = prod.Pro_cantidad.ToString();
                if (prod.Prov_id.HasValue)
                    ddlProveedor.SelectedValue = prod.Prov_id.Value.ToString();

                // Guardar lista de fotos en ViewState para la lógica de eliminación
                if (!string.IsNullOrEmpty(prod.Pro_foto))
                {
                    var rawParts = prod.Pro_foto.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);

                    // Cada elemento del Repeater: string[] { fileName, displayUrl }
                    var items = new List<string[]>();
                    foreach (var p in rawParts)
                    {
                        string t = p.Trim();
                        string url = t.StartsWith("~/") ? t : "~/Uploads/" + t;
                        // fileName es el nombre puro (sin prefijo) para guardar en BD
                        string fileName = t.StartsWith("~/Uploads/") ? t.Substring("~/Uploads/".Length)
                                        : t.StartsWith("~/") ? t.Substring(2)
                                        : t;
                        items.Add(new string[] { fileName, url });
                    }

                    if (items.Count > 0)
                    {
                        ViewState["FotosOriginales"] = prod.Pro_foto; // cadena original completa
                        rptCurrentImages.DataSource = items;
                        rptCurrentImages.DataBind();
                        phCarruselActual.Visible = true;
                    }
                }
            }
            else
            {
                ShowMessage("⚠ Producto no encontrado.", true);
            }
        }

        /// <summary>
        /// Genera el HTML de un item de foto con botón X para el Repeater.
        /// DataItem es string[] { fileName, displayUrl }.
        /// </summary>
        public string BuildPhotoItem(string[] data)
        {
            if (data == null || data.Length < 2) return "";
            string fileName = System.Web.HttpUtility.HtmlEncode(data[0]);
            string url      = ResolveUrl(data[1]);
            string escapedFn = fileName.Replace("'", "\\'");

            return string.Format(
                "<div class='photo-item' id='pi_{0}'>" +
                    "<img src='{1}' onclick=\"openModalEdit('{1}')\" title='{0}' />" +
                    "<button type='button' class='btn-delete-photo' title='Eliminar esta foto' " +
                        "onclick=\"marcarEliminar(this, '{0}')\">&times;</button>" +
                    "<div class='photo-label'>{0}</div>" +
                    "<div class='restore-badge'>Clic &#8635; para restaurar</div>" +
                "</div>",
                escapedFn, url);
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            // Validación básica
            if (string.IsNullOrWhiteSpace(txtCodigo.Text) || string.IsNullOrWhiteSpace(txtNombre.Text))
            {
                ShowMessage("⚠ Código y Nombre son obligatorios.", true);
                return;
            }

            int qty;
            if (!int.TryParse(txtCantidad.Text, out qty))
            {
                ShowMessage("⚠ Cantidad debe ser numérica.", true);
                return;
            }

            decimal price;
            if (!decimal.TryParse(txtPrecio.Text, out price))
            {
                ShowMessage("⚠ Precio debe ser numérico.", true);
                return;
            }

            // Proveedor
            int? provId = null;
            int provTmp;
            if (!string.IsNullOrEmpty(ddlProveedor.SelectedValue) && int.TryParse(ddlProveedor.SelectedValue, out provTmp))
                provId = provTmp;

            // ── Calcular foto final ──────────────────────────────────────────────
            string fotoPath = null;

            bool hayNuevas = fuImagen.HasFiles;
            bool esEdicion = ViewState["ProdId"] != null;

            if (hayNuevas)
            {
                // Subir nuevas imágenes
                var uploadedPaths = new List<string>();
                string uploadsFolder = Server.MapPath("~/Uploads");
                if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

                if (fuImagen.PostedFiles.Count > 5)
                {
                    ShowMessage("⚠ No puedes subir más de 5 imágenes.", true);
                    return;
                }

                foreach (var file in fuImagen.PostedFiles)
                {
                    if (file.ContentLength <= 0) continue;
                    if (file.ContentLength > 3 * 1024 * 1024)
                    {
                        ShowMessage("⚠ La imagen " + file.FileName + " supera 3 MB.", true);
                        return;
                    }
                    string ext = Path.GetExtension(file.FileName).ToLower();
                    if (ext != ".png" && ext != ".jpg" && ext != ".jpeg")
                    {
                        ShowMessage("⚠ Solo .png, .jpg, .jpeg.", true);
                        return;
                    }
                    string newName = Guid.NewGuid().ToString() + ext;
                    file.SaveAs(Path.Combine(uploadsFolder, newName));
                    uploadedPaths.Add(newName);
                }

                if (uploadedPaths.Count > 0)
                    fotoPath = string.Join(";", uploadedPaths);
            }
            else if (esEdicion)
            {
                // Sin nuevas imágenes → mantener fotos existentes menos las eliminadas
                string fotosOriginales = ViewState["FotosOriginales"] as string ?? "";
                string fotosEliminar   = hfFotosEliminar.Value ?? "";

                var toDelete = new HashSet<string>(
                    fotosEliminar.Split(new char[]{';'}, StringSplitOptions.RemoveEmptyEntries),
                    StringComparer.OrdinalIgnoreCase);

                var actuales = fotosOriginales
                    .Split(new char[]{';'}, StringSplitOptions.RemoveEmptyEntries)
                    .Select(f => f.Trim())
                    .ToList();

                // Quitar las marcadas para eliminar
                var restantes = actuales.Where(f =>
                {
                    // Normalizar: quitar prefijo ~/Uploads/ para comparar
                    string bare = f.StartsWith("~/Uploads/") ? f.Substring("~/Uploads/".Length)
                                : f.StartsWith("~/") ? f.Substring(2)
                                : f;
                    return !toDelete.Contains(bare) && !toDelete.Contains(f);
                }).ToList();

                fotoPath = restantes.Count > 0 ? string.Join(";", restantes) : "no_image.png";
            }

            // ── Insertar o Actualizar ────────────────────────────────────────────
            if (esEdicion)
            {
                int prodId = (int)ViewState["ProdId"];
                CN_tbl_producto.Actualizar(prodId,
                    txtCodigo.Text.Trim(),
                    txtNombre.Text.Trim(),
                    qty, price,
                    txtDescripcion.Text.Trim(),
                    fotoPath,   // null solo si no hay nada (no debería pasar)
                    provId, "A");
                ShowMessage("✅ Producto actualizado correctamente.", false);
            }
            else
            {
                int newId = CN_tbl_producto.Insertar(
                    txtCodigo.Text.Trim(),
                    txtNombre.Text.Trim(),
                    qty, price,
                    txtDescripcion.Text.Trim(),
                    fotoPath ?? "no_image.png",
                    provId, "A");
                ShowMessage("✅ Producto creado con ID " + newId + ".", false);
                txtCodigo.Text = txtNombre.Text = txtDescripcion.Text = txtPrecio.Text = txtCantidad.Text = string.Empty;
                ddlProveedor.SelectedIndex = 0;
            }

            string script = "setTimeout(function(){ window.location='listar_tbl_producto.aspx'; }, 1500);";
            ClientScript.RegisterStartupScript(this.GetType(), "redirect", script, true);
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("listar_tbl_producto.aspx");
        }

        private void ShowMessage(string text, bool isError)
        {
            pnlMensaje.Visible = true;
            lblMensaje.Attributes["class"] = isError ? "msg-box error" : "msg-box success";
            lblMensaje.InnerText = text;
        }
    }
}
