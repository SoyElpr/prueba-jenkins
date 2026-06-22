using System;
using System.Web;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito_4Am.Seguridad
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Leer cookie de "Recordar Usuario"
                if (Request.Cookies["usu_recuerdame"] != null)
                {
                    txtCedula.Text = Request.Cookies["usu_recuerdame"].Value;
                    chkRemember.Checked = true;
                }

                if (Request.QueryString["msg"] == "logout")
                {
                    Session.Clear();
                    pnlMensaje.Visible = true;
                    pnlMensaje.CssClass = "msg-box";
                    lblMensaje.Text = "✅ Sesión cerrada correctamente.";
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string cedula   = txtCedula.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(cedula) || string.IsNullOrEmpty(password))
            {
                Mensaje("⚠ Ingrese su cédula y contraseña.", true);
                return;
            }

            var info = CN_tbl_usuario.Login(cedula, password);

            switch (info.Resultado)
            {
                case CN_tbl_usuario.ResultadoLogin.Exitoso:
                    // Manejar "Recordar Usuario"
                    if (chkRemember.Checked)
                    {
                        HttpCookie cookie = new HttpCookie("usu_recuerdame", cedula);
                        cookie.Expires = DateTime.Now.AddDays(15);
                        Response.Cookies.Add(cookie);
                    }
                    else
                    {
                        if (Request.Cookies["usu_recuerdame"] != null)
                        {
                            Response.Cookies["usu_recuerdame"].Expires = DateTime.Now.AddDays(-1);
                        }
                    }

                    Session["usu_id"]          = info.UsuId;
                    Session["usu_nombres"]     = info.Nombres;
                    Session["usu_apellidos"]   = info.Apellidos;
                    Session["usu_nick"]        = info.Nick;
                    Session["usu_correo"]      = info.Correo;
                    Session["usu_celular"]     = info.Celular;
                    Session["tusu_id"]         = info.TipoUsuId;
                    Session["tipo_usuario"]    = info.TipoUsuNombre;
                    Session["totp_secret"]     = info.TotpSecret;
                    Session["totp_activo"]     = info.TotpActivo;

                    CN_Auditoria.Log(info.UsuId, "Inicio de Sesión (Fase 1)", "Seguridad");
                    // Bypass OTP para usuarios de tipo Proveedor
                    if (info.TipoUsuNombre != null && info.TipoUsuNombre.Equals("Proveedor", StringComparison.OrdinalIgnoreCase))
                    {
                        // Redirigir directamente a la gestión de productos
                        Response.Redirect("~/Mantenimineto/listar_tbl_producto.aspx");
                    }
                    else
                    {
                        // Continuar con verificación OTP para demás usuarios
                        Response.Redirect("~/Seguridad/VerificarOTP.aspx");
                    }
                    break;

                case CN_tbl_usuario.ResultadoLogin.UsuarioBloqueado:
                    CN_Auditoria.Log(info.UsuId, "Intento Fallido (Usuario Bloqueado)", "Seguridad");
                    Mensaje("🚫 Tu cuenta está BLOQUEADA por demasiados intentos fallidos.", true);
                    break;

                case CN_tbl_usuario.ResultadoLogin.CredencialesInvalidas:
                     CN_Auditoria.Log(info.UsuId > 0 ? (int?)info.UsuId : null, "Credenciales Inválidas", "Seguridad");
                     string msjBase = (info.UsuId > 0) ? "❌ Contraseña incorrecta." : "❌ Cédula no registrada.";
                     string resto = info.IntentosRestantes > 0
                         ? $" Te quedan {info.IntentosRestantes} intento(s)."
                         : " Tu cuenta ha sido BLOQUEADA.";
                     Mensaje($"{msjBase}{resto}", true);
                     break;

                case CN_tbl_usuario.ResultadoLogin.UsuarioInactivo:
                    Mensaje("⚠ Tu cuenta está inactiva.", true);
                    break;
            }
        }

        protected void btnRegistrar_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Seguridad/Registro.aspx");
        }

        private void Mensaje(string texto, bool esError)
        {
            pnlMensaje.Visible = true;
            pnlMensaje.CssClass = esError ? "msg-box error" : "msg-box";
            lblMensaje.Text = texto;
        }
    }
}