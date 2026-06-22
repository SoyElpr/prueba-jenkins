using System;
using System.Linq;
using System.Web.UI;
using Capa_Negocio;
using Monolito_4Am.Helpers;
using System.Configuration;

namespace Monolito_4Am.Seguridad
{
    public partial class RecuperarPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        // ── PASO 1: Enviar clave temporal por WhatsApp ─────────────────────────
        protected void btnEnviarClave_Click(object sender, EventArgs e)
        {
            string cedula = txtCedulaPaso1.Text.Trim();
            if (string.IsNullOrEmpty(cedula)) { Msg("⚠ Ingrese su cédula.", true); return; }

            string connStr = ConfigurationManager.ConnectionStrings["conexion"].ConnectionString;
            using (var db = new Capa_Datos.DataClasses1DataContext(connStr))
            {
                var usu = db.Tbl_usuario.FirstOrDefault(u => u.Usu_cedula == cedula);
                if (usu == null) { Msg("❌ Cédula no registrada en el sistema.", true); return; }

                string clave = CN_tbl_usuario.GenerarClaveTemp(cedula);
                if (clave == null) { Msg("❌ Cédula no registrada en el sistema.", true); return; }

                string celular = usu.Usu_celular ?? "";
                string nombres = usu.Usu_nombres ?? "Usuario";

                // Guardar estado en Session
                Session["RecCedula"]  = cedula;
                Session["RecCelular"] = celular;
                Session["RecClave"]   = clave;   // solo para link wa.me

                string mensaje   = WhatsAppHelper.MensajeRecuperacion(nombres, clave);
                string apiKey    = ConfigurationManager.AppSettings["WA_ApiKey"] ?? "";
                string telFormato = celular.TrimStart('0');
                if (!telFormato.StartsWith("593")) telFormato = "593" + telFormato;

                bool enviado = WhatsAppHelper.EnviarMensaje(telFormato, mensaje, apiKey);

                // Siempre mostrar link wa.me como respaldo
                string waUrl = WhatsAppHelper.GenerarUrlWaMe(celular, mensaje);
                hlWaMe.NavigateUrl = waUrl;

                // Avanzar a paso 2
                pnlPaso1.Visible = false;
                pnlPaso2.Visible = true;
                lblStep1.CssClass = "step done";
                lblStep2.CssClass = "step active";

                Msg(enviado
                    ? "✅ Clave enviada por WhatsApp. Revisa tu teléfono."
                    : "📱 Haz clic en el botón de WhatsApp para ver tu clave temporal.", false);
            }
        }

        // ── PASO 2: Validar clave temporal ─────────────────────────────────────
        protected void btnValidarClave_Click(object sender, EventArgs e)
        {
            string cedula = Session["RecCedula"]?.ToString();
            string clave  = txtClaveTemporal.Text.Trim().ToUpper();

            if (string.IsNullOrEmpty(cedula)) { Msg("⚠ Sesión expirada. Vuelva al paso 1.", true); return; }
            if (string.IsNullOrEmpty(clave))  { Msg("⚠ Ingrese la clave temporal.", true); return; }

            if (CN_tbl_usuario.ValidarClaveTemp(cedula, clave))
            {
                pnlPaso2.Visible = false;
                pnlPaso3.Visible = true;
                lblStep2.CssClass = "step done";
                lblStep3.CssClass = "step active";
                Msg("✅ Clave válida. Ingresa tu nueva contraseña.", false);
            }
            else
            {
                Msg("❌ Clave incorrecta o expirada (máx. 15 min). Solicite una nueva.", true);
            }
        }

        // ── PASO 3: Cambiar contraseña ─────────────────────────────────────────
        protected void btnCambiarPass_Click(object sender, EventArgs e)
        {
            string cedula    = Session["RecCedula"]?.ToString();
            string nuevaPass = txtNuevaPass.Text.Trim();
            string confirmar = txtConfirmarPass.Text.Trim();

            if (string.IsNullOrEmpty(cedula)) { Msg("⚠ Sesión expirada.", true); return; }
            if (nuevaPass.Length < 6) { Msg("⚠ La contraseña debe tener al menos 6 caracteres.", true); return; }
            if (nuevaPass != confirmar) { Msg("⚠ Las contraseñas no coinciden.", true); return; }

            CN_tbl_usuario.CambiarPassword(cedula, nuevaPass);
            Session.Remove("RecCedula");
            Session.Remove("RecCelular");
            Session.Remove("RecClave");

            lblStep3.CssClass = "step done";
            pnlPaso3.Visible  = false;
            Msg("✅ ¡Contraseña cambiada exitosamente! Redirigiendo...", false);

            ScriptManager.RegisterStartupScript(this, GetType(), "redir",
                "setTimeout(function(){ window.location='login.aspx'; }, 2500);", true);
        }

        void Msg(string txt, bool error)
        {
            pnlMensaje.Visible   = true;
            pnlMensaje.CssClass  = error ? "message-box error" : "message-box";
            lblMensaje.Text      = txt;
        }
    }
}
