using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using Capa_Negocio;
using Monolito_4Am.Helpers;

namespace Monolito_4Am.Seguridad
{
    public partial class VerificarOTP : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Verificar que haya sesión de login previo
            if (Session["usu_id"] == null)
            {
                Response.Redirect("~/Seguridad/login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblNombreUsuario.Text = Session["usu_nick"]?.ToString() ?? "Usuario";
                lblNombreUsuario.Visible = true;
                
                EnviarCodigoPorEmail();
            }
        }

        protected void btnReenviar_Click(object sender, EventArgs e)
        {
            EnviarCodigoPorEmail();
            if (string.IsNullOrEmpty(EmailHelper.UltimoError))
            {
                Msg("✅ Correo reenviado con éxito. Por favor, revisa tu bandeja de entrada (y Spam).", false);
            }
        }

        private void EnviarCodigoPorEmail()
        {
            int    usuId  = (int)Session["usu_id"];
            string nombre = Session["usu_nombres"]?.ToString() ?? "Usuario";
            bool   activo = (bool)(Session["totp_activo"] ?? false);
            string secret = Session["totp_secret"]?.ToString();
            string correo = Session["usu_correo"]?.ToString() ?? "";

            lblCorreoDestino.Text = correo;
            lblNombreUsuario.Text = nombre;

            if (!activo || string.IsNullOrEmpty(secret))
            {
                string nuevoSecret = hfSecretNuevo.Value;
                if (string.IsNullOrEmpty(nuevoSecret))
                {
                    nuevoSecret = TOTPHelper.GenerarSecretoBase32();
                    hfSecretNuevo.Value = nuevoSecret;
                }
                
                string otpUri = TOTPHelper.GenerarOtpAuthUri(nuevoSecret, correo, "MonolitoApp");
                string qrUrl  = TOTPHelper.GetQRCodeUrl(otpUri, 200);

                string html = EmailHelper.PlantillaQR(nombre, qrUrl, nuevoSecret);
                if (!EmailHelper.EnviarCorreo(correo, "🔐 Configura tu acceso seguro — MonolitoApp", html))
                {
                    Msg("❌ Error SMTP: " + EmailHelper.UltimoError, true);
                }
            }
            else
            {
                string codigoActual = TOTPHelper.GenerarCodigoActual(secret);
                string qrUrl        = TOTPHelper.GetQRCodeUrl(codigoActual, 250);

                string html = EmailHelper.PlantillaAcceso(nombre, qrUrl, codigoActual);
                if (!EmailHelper.EnviarCorreo(correo, "🔑 Tu código de acceso — MonolitoApp", html))
                {
                    Msg("❌ Error SMTP: " + EmailHelper.UltimoError, true);
                }
            }
        }

        // ── VERIFICAR CÓDIGO (Unificado) ──────────────────────────────────────
        protected void btnVerificar_Click(object sender, EventArgs e)
        {
            string codigo = txtOTP.Text.Trim();
            
            bool   activo = (bool)(Session["totp_activo"] ?? false);
            string secret = activo ? Session["totp_secret"]?.ToString() : hfSecretNuevo.Value;

            if (string.IsNullOrEmpty(codigo)) { Msg("⚠ No se detectó ningún código.", true); return; }
            if (string.IsNullOrEmpty(secret)) { Msg("⚠ Sesión inválida.", true); return; }

            bool esValido = false;

            // 1. Intentar validar como código TOTP de 6 dígitos
            if (codigo.Length == 6 && TOTPHelper.ValidarCodigo(secret, codigo))
            {
                esValido = true;
            }
            // 2. Si es el primer acceso, permitir entrar escaneando el secreto directamente
            else if (!activo && (codigo == secret || codigo.Contains("secret=" + secret)))
            {
                esValido = true;
            }
            // 3. Validar si el código coincide con el código actual generado (para el QR de acceso)
            else if (codigo == TOTPHelper.GenerarCodigoActual(secret))
            {
                esValido = true;
            }

            if (esValido)
            {
                if (!activo)
                {
                    int usuId = (int)Session["usu_id"];
                    CN_tbl_usuario.GuardarSecretoTOTP(usuId, secret);
                    Session["totp_activo"] = true;
                    Session["totp_secret"] = secret;
                }

                CN_Auditoria.Log((int)Session["usu_id"], "Verificación OTP Exitosa", "Seguridad");

                Session["autenticado"] = true;
                Response.Redirect(GetDashboardUrl());
            }
            else
            {
                Msg("❌ El código escaneado no es válido para esta cuenta. Intenta reenviar el QR.", true);
            }
        }

        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("~/Seguridad/login.aspx");
        }

        private string GetDashboardUrl()
        {
            // Recuperamos el ID de tipo de usuario de la sesión
            object tusuObj = Session["tusu_id"];
            int tipoId = 0;

            if (tusuObj != null && int.TryParse(tusuObj.ToString(), out tipoId))
            {
                // En tu base de datos, ID 3 es ADMINISTRADOR
                if (tipoId == 3)
                {
                    return "~/Dashboard/Admin.aspx";
                }
            }

            // Por defecto, o si es ID 2, va al Dashboard de Usuario (Juego)
            return "~/Dashboard/Usuario.aspx";
        }

        private void Msg(string txt, bool error)
        {
            pnlMensaje.Visible  = true;
            pnlMensaje.CssClass = error ? "message-box error" : "message-box";
            lblMensaje.Text     = txt;
        }
    }
}
