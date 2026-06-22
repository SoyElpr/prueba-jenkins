using System;
using System.Data;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace Monolito_4Am.Dashboard
{
    public partial class Admin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usu_id"] == null || Session["autenticado"] == null)
            { Response.Redirect("~/Seguridad/login.aspx"); return; }

            int tipoId = Session["tusu_id"] != null ? (int)Session["tusu_id"] : 0;
            if (tipoId != 3) // Perfil Admin
            { Response.Redirect("~/Dashboard/Usuario.aspx"); return; }

            if (!IsPostBack)
            {
                CargarDatos();
            }
        }

        void CargarDatos()
        {
            try {
                DataTable todos = CN_tbl_usuario.ListarTodos();
                DataTable bloqueados = CN_tbl_usuario.ListarBloqueados();
                DataTable logs = CN_Auditoria.ListarLogs();

                gvBloqueados.DataSource = bloqueados;
                gvBloqueados.DataBind();

                gvTodos.DataSource = todos;
                gvTodos.DataBind();

                gvLogs.DataSource = logs;
                gvLogs.DataBind();

                // Actualizar Contadores Reales
                lblTotalUsers.Text = todos.Rows.Count.ToString();
                lblLockedUsers.Text = bloqueados.Rows.Count.ToString();
                
                // Contar acciones de hoy
                int hoy = 0;
                string fechaHoy = DateTime.Now.ToString("yyyy-MM-dd");
                foreach (DataRow dr in logs.Rows)
                {
                    if (Convert.ToDateTime(dr["audi_fecha"]).ToString("yyyy-MM-dd") == fechaHoy)
                        hoy++;
                }
                lblTodayActions.Text = hoy.ToString();

            } catch { }
        }

        protected void btnRefreshUsers_Click(object sender, EventArgs e)
        {
            CargarDatos();
        }

        protected void btnRefreshLogs_Click(object sender, EventArgs e)
        {
            CargarDatos();
        }

        protected void btnDesbloquear_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            int usuId = int.Parse(btn.CommandArgument);
            CN_tbl_usuario.DesbloquearUsuario(usuId);
            CN_Auditoria.Log((int)Session["usu_id"], "Re-activó al usuario bloqueado ID: " + usuId, "Admin");
            CargarDatos();
        }

        protected void btnToggleStatus_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string[] args = btn.CommandArgument.Split('|');
            int usuId = int.Parse(args[0]);
            string estadoActual = args[1];
            string nuevoEstado = (estadoActual == "A") ? "I" : "A";

            CN_tbl_usuario.CambiarEstado(usuId, nuevoEstado);
            CN_Auditoria.Log((int)Session["usu_id"], $"Cambió estado de usuario ID {usuId} a {nuevoEstado}", "Admin");
            CargarDatos();
        }

        protected void btnEditar_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int usuId = int.Parse(btn.CommandArgument);
            DataRow r = CN_tbl_usuario.ObtenerPorId(usuId);

            if (r != null)
            {
                hfEditId.Value = usuId.ToString();
                lblEditNick.Text = r["usu_nick"].ToString();
                txtEditCedula.Text = r["usu_cedula"].ToString();
                txtEditNombres.Text = r["usu_nombres"].ToString();
                txtEditApellidos.Text = r["usu_apellidos"].ToString();
                txtEditCorreo.Text = r["usu_correo"].ToString();
                pnlEditor.Visible = true;
            }
        }

        protected void btnGuardarCambios_Click(object sender, EventArgs e)
        {
            try
            {
                int id = int.Parse(hfEditId.Value);
                CN_tbl_usuario.ActualizarUsuario(id, txtEditCedula.Text, txtEditNombres.Text, txtEditApellidos.Text, txtEditCorreo.Text);
                pnlEditor.Visible = false;
                CargarDatos();
                CN_Auditoria.Log((int)Session["usu_id"], "Actualizó datos del usuario ID: " + id, "Admin");
            }
            catch (Exception ex) { /* Manejar error */ }
        }

        protected void btnCloseEditor_Click(object sender, EventArgs e)
        {
            pnlEditor.Visible = false;
        }

        protected void btnCrearAdmin_Click(object sender, EventArgs e)
        {
            try
            {
                string ced = txtAdminCedula.Text.Trim();
                string nom = txtAdminNombres.Text.Trim();
                string ape = txtAdminApellidos.Text.Trim();
                string mail = txtAdminCorreo.Text.Trim();
                string nick = txtAdminNick.Text.Trim();
                string pass = txtAdminPass.Text.Trim();

                if (ced == "" || nom == "" || ape == "" || mail == "" || nick == "" || pass == "")
                {
                    lblMsgAdmin.Text = "⚠ Complete todos los campos.";
                    lblMsgAdmin.ForeColor = System.Drawing.Color.Orange;
                    return;
                }

                // ID 3 = Administrador
                int res = CN_tbl_usuario.RegistrarUsuario(ced, nom, ape, "0000000000", mail, nick, pass, DateTime.Now.AddYears(-20), 3);

                if (res > 0)
                {
                    lblMsgAdmin.Text = "✅ Administrador creado con éxito.";
                    lblMsgAdmin.ForeColor = System.Drawing.Color.Lime;
                    LimpiarFormAdmin();
                    CargarDatos();
                    CN_Auditoria.Log((int)Session["usu_id"], "Creó nuevo administrador: " + nick, "Admin");
                }
                else
                {
                    lblMsgAdmin.Text = "❌ No se pudo crear. Revise si la cédula o nick ya existen.";
                    lblMsgAdmin.ForeColor = System.Drawing.Color.Red;
                }
            }
            catch (Exception ex)
            {
                lblMsgAdmin.Text = "❌ Error: " + ex.Message;
                lblMsgAdmin.ForeColor = System.Drawing.Color.Red;
            }
        }

        private void LimpiarFormAdmin()
        {
            txtAdminCedula.Text = txtAdminNombres.Text = txtAdminApellidos.Text = "";
            txtAdminCorreo.Text = txtAdminNick.Text = txtAdminPass.Text = "";
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("~/Seguridad/login.aspx?msg=logout");
        }
    }
}
