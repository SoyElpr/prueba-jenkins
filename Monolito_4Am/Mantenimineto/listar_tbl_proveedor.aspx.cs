// listar_tbl_proveedor.aspx.cs
using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace Monolito_4Am.Mantenimineto
{
    public partial class listar_tbl_proveedor : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindGrid();
        }

        private void BindGrid()
        {
            var lista = CN_tbl_provedor.Listar();
            gvProveedores.DataSource = lista;
            gvProveedores.DataBind();
        }

        protected void gvProveedores_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProveedores.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        protected void gvProveedores_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int provId = Convert.ToInt32(e.CommandArgument);
            switch (e.CommandName)
            {
                case "Editar":
                    // Redirect to edit page (to be implemented)
                    Response.Redirect($"nuevo_tbl_proveedor.aspx?id={provId}");
                    break;
                case "Eliminar":
                    // Hard delete
                    CN_tbl_provedor.Eliminar(provId);
                    // Log deletion (optional)
                    CN_Auditoria.Log(null, $"Proveedor eliminado ID={provId}", "Proveedor");
                    BindGrid();
                    break;
            }
        }

        protected void btnNuevo_Click(object sender, EventArgs e)
        {
            // Redirect to a page for adding new provider (to be implemented)
            Response.Redirect("nuevo_tbl_proveedor.aspx");
        }
    }
}
