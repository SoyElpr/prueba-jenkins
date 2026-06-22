// nuevo_tbl_proveedor.aspx.cs
using System;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito_4Am.Mantenimineto
{
    public partial class nuevo_tbl_proveedor : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Determine if we are editing an existing provider
                string idStr = Request.QueryString["id"];
                if (!string.IsNullOrEmpty(idStr) && int.TryParse(idStr, out int provId))
                {
                    LoadProvider(provId);
                    lblTitle.InnerText = "Editar Proveedor";
                }
                else
                {
                    lblTitle.InnerText = "Nuevo Proveedor";
                }
            }
        }

        private void LoadProvider(int provId)
        {
            var provider = CN_tbl_provedor.ObtenerPorId(provId);
            if (provider != null)
            {
                txtNombre.Text = provider.Prov_nombre;
                // prov_telefono and prov_email are not in the database schema, so we leave their text boxes blank or ignore them.
            }
            else
            {
                ShowMessage("Proveedor no encontrado.", true);
            }
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            string nombre = txtNombre.Text.Trim();
            if (string.IsNullOrEmpty(nombre))
            {
                ShowMessage("Por favor ingrese el nombre del proveedor.", true);
                return;
            }

            try
            {
                string idStr = Request.QueryString["id"];
                if (!string.IsNullOrEmpty(idStr) && int.TryParse(idStr, out int provId))
                {
                    // Edit existing provider
                    CN_tbl_provedor.Actualizar(provId, nombre, "A");
                    CN_Auditoria.Log(null, $"Proveedor actualizado ID={provId}, Nombre={nombre}", "Proveedor");
                }
                else
                {
                    // Create new provider
                    int newId = CN_tbl_provedor.Insertar(nombre, "A");
                    CN_Auditoria.Log(null, $"Proveedor creado ID={newId}, Nombre={nombre}", "Proveedor");
                }

                Response.Redirect("listar_tbl_proveedor.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Error al guardar el proveedor: " + ex.Message, true);
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("listar_tbl_proveedor.aspx");
        }

        private void ShowMessage(string text, bool isError)
        {
            pnlMensaje.Visible = true;
            lblMensaje.Attributes["class"] = isError ? "msg-box error" : "msg-box success";
            lblMensaje.InnerText = text;
        }
    }
}
