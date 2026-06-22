using System;
using System.Net;
using System.Net.Mail;
using System.Configuration;

namespace Monolito_4Am.Helpers
{
    public static class EmailHelper
    {
        public static string UltimoError { get; private set; }

        public static bool EnviarCorreo(string destinatario, string asunto, string cuerpoHtml)
        {
            try
            {
                UltimoError = null;
                // Forzar TLS 1.2 para compatibilidad con Gmail
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

                string host  = ConfigurationManager.AppSettings["SMTP_Host"]  ?? "smtp.gmail.com";
                int    port  = int.Parse(ConfigurationManager.AppSettings["SMTP_Port"] ?? "587");
                string user  = ConfigurationManager.AppSettings["SMTP_User"]  ?? "";
                string pass  = ConfigurationManager.AppSettings["SMTP_Pass"]  ?? "";

                if (string.IsNullOrEmpty(user) || string.IsNullOrEmpty(pass))
                {
                    UltimoError = "Credenciales SMTP no configuradas en Web.config";
                    return false;
                }

                using (var smtp = new SmtpClient(host, port))
                {
                    smtp.Timeout               = 15000; // 15 seconds
                    smtp.EnableSsl             = true;
                    smtp.UseDefaultCredentials = false;
                    smtp.Credentials           = new NetworkCredential(user, pass);
                    smtp.DeliveryMethod        = SmtpDeliveryMethod.Network;

                    var msg = new MailMessage
                    {
                        From       = new MailAddress(user, "MonolitoApp"),
                        Subject    = asunto,
                        Body       = cuerpoHtml,
                        IsBodyHtml = true
                    };
                    msg.To.Add(destinatario);
                    smtp.Send(msg);
                }
                return true;
            }
            catch (Exception ex)
            {
                UltimoError = ex.Message + (ex.InnerException != null ? " -> " + ex.InnerException.Message : "");
                return false;
            }
        }

        public static string PlantillaQR(string nombre, string qrUrl, string otpSecret)
        {
            return $@"
            <div style='font-family:Arial, sans-serif; max-width:600px; margin:auto; background:#000000; border-radius:40px; overflow:hidden; border:2px solid #6366f1; box-shadow:0 0 50px rgba(99,102,241,0.4);'>
              <div style='background:linear-gradient(45deg, #6366f1, #a855f7); padding:40px; text-align:center;'>
                <h1 style='color:white; margin:0; font-size:32px; letter-spacing:2px; text-transform:uppercase;'>¡PROTECCIÓN TOTAL! 🛡️</h1>
                <p style='color:rgba(255,255,255,0.9); margin-top:10px; font-size:18px;'>Activa tu Identidad Digital en MonolitoApp</p>
              </div>
              <div style='padding:40px; background:#0f172a; text-align:center;'>
                <p style='color:#f8fafc; font-size:18px; margin-bottom:30px;'>Hola <span style='color:#6366f1; font-weight:bold;'>{nombre}</span>, escanea el QR o usa el código manual:</p>
                
                <div style='display:inline-block; padding:20px; background:white; border-radius:30px; box-shadow:0 0 30px rgba(99,102,241,0.5); transform:rotate(-2deg);'>
                  <img src='{qrUrl}' width='240' height='240' alt='SECURE QR' style='display:block;' />
                </div>

                <div style='margin-top:30px; background:rgba(255,255,255,0.05); padding:15px; border-radius:15px; border:1px dashed #6366f1;'>
                   <p style='color:#94a3b8; font-size:12px; margin:0; text-transform:uppercase;'>Código de Vinculación Manual</p>
                   <h2 style='color:#a855f7; font-size:28px; margin:5px 0; letter-spacing:5px;'>{otpSecret}</h2>
                </div>

                <div style='margin-top:30px; background:rgba(99,102,241,0.1); padding:20px; border-radius:20px; border:1px solid #6366f1;'>
                   <h3 style='color:#6366f1; margin:0; font-size:20px;'>🚀 PASO ÚNICO</h3>
                   <p style='color:#94a3b8; font-size:14px; margin-top:5px;'>Vincula este código en tu App de Autenticación para proteger tu cuenta.</p>
                </div>

                <div style='margin-top:30px;'>
                  <p style='color:#475569; font-size:12px; font-weight:bold; letter-spacing:1px;'>MONOLITOAPP — NEXT GEN SECURITY</p>
                </div>
              </div>
            </div>";
        }

        public static string PlantillaAcceso(string nombre, string qrUrl, string codigo)
        {
            return $@"
            <div style='font-family:Arial, sans-serif; max-width:600px; margin:auto; background:#000000; border-radius:40px; overflow:hidden; border:2px solid #06b6d4; box-shadow:0 0 50px rgba(6,182,212,0.4);'>
              <div style='background:linear-gradient(45deg, #06b6d4, #3b82f6); padding:40px; text-align:center;'>
                <h1 style='color:white; margin:0; font-size:32px; letter-spacing:2px; text-transform:uppercase;'>¡ACCESO AUTORIZADO! 🔑</h1>
                <p style='color:rgba(255,255,255,0.9); margin-top:10px; font-size:18px;'>Tu llave digital está lista</p>
              </div>
              <div style='padding:40px; background:#0f172a; text-align:center;'>
                <p style='color:#f8fafc; font-size:18px; margin-bottom:30px;'>¡Hola <span style='color:#06b6d4; font-weight:bold;'>{nombre}</span>! Escanea el QR o ingresa el PIN:</p>
                
                <div style='display:inline-block; padding:20px; background:white; border-radius:30px; box-shadow:0 0 30px rgba(6,182,212,0.5);'>
                  <img src='{qrUrl}' width='240' height='240' alt='ACCESS QR' style='display:block;' />
                </div>

                <div style='margin-top:30px; background:rgba(255,255,255,0.05); padding:15px; border-radius:15px; border:1px dashed #06b6d4;'>
                   <p style='color:#94a3b8; font-size:12px; margin:0; text-transform:uppercase;'>Tu Código PIN Temporal</p>
                   <h2 style='color:#3b82f6; font-size:32px; margin:5px 0; letter-spacing:10px;'>{codigo}</h2>
                </div>

                <div style='margin-top:30px; padding:20px; border-radius:20px; background:rgba(6,182,212,0.05); border:1px dashed #06b6d4;'>
                   <p style='color:#94a3b8; font-size:14px; margin:0;'>Válido por 5 minutos • Solo un uso • MonolitoApp Protocol</p>
                </div>

                <div style='margin-top:30px;'>
                  <p style='color:#475569; font-size:11px; font-weight:bold; letter-spacing:2px;'>SISTEMA DE VERIFICACIÓN BIOMÉTRICA</p>
                </div>
              </div>
            </div>";
        }
    }
}
