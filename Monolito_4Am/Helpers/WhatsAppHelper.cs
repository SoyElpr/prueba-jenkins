using System;
using System.Net;
using System.Text;

namespace Monolito_4Am.Helpers
{
    /// <summary>
    /// Envío de mensajes de WhatsApp via CallMeBot API.
    /// Prerequisito: el usuario debe enviar "I allow callmebot to send me messages"
    /// al número +34 644 59 79 23 en WhatsApp para obtener su API key.
    /// </summary>
    public static class WhatsAppHelper
    {
        // API Key de CallMeBot (se configura en Web.config → appSettings)
        private const string CALLMEBOT_URL = "https://api.callmebot.com/whatsapp.php";

        /// <summary>
        /// Envía un mensaje de WhatsApp usando CallMeBot.
        /// </summary>
        /// <param name="telefono">Número en formato internacional sin + (ej: 593987654321)</param>
        /// <param name="mensaje">Texto a enviar</param>
        /// <param name="apiKey">API Key de CallMeBot del destinatario</param>
        public static bool EnviarMensaje(string telefono, string mensaje, string apiKey = "")
        {
            try
            {
                // Si no tiene API Key configurada, usar link wa.me como fallback
                if (string.IsNullOrWhiteSpace(apiKey) || apiKey == "TU_API_KEY")
                    return EnviarViaLink(telefono, mensaje);

                string url = $"{CALLMEBOT_URL}?phone={telefono}&text={Uri.EscapeDataString(mensaje)}&apikey={apiKey}";
                using (var wc = new WebClient())
                {
                    wc.Headers.Add("User-Agent", "Mozilla/5.0");
                    string resp = wc.DownloadString(url);
                    return resp.Contains("Message queued") || resp.Contains("200");
                }
            }
            catch
            {
                return EnviarViaLink(telefono, mensaje);
            }
        }

        /// <summary>
        /// Fallback: genera una URL wa.me con el mensaje pre-escrito.
        /// Redirige al usuario para enviar manualmente.
        /// </summary>
        public static string GenerarUrlWaMe(string telefono, string mensaje)
        {
            string tel = telefono.TrimStart('+').Replace(" ", "").Replace("-", "");
            if (!tel.StartsWith("593") && tel.Length == 10)
                tel = "593" + tel.TrimStart('0');
            return $"https://wa.me/{tel}?text={Uri.EscapeDataString(mensaje)}";
        }

        private static bool EnviarViaLink(string telefono, string mensaje)
        {
            // En modo fallback retorna false para que la UI abra el link wa.me
            return false;
        }

        /// <summary>
        /// Mensaje estándar para recuperación de contraseña.
        /// </summary>
        public static string MensajeRecuperacion(string nombre, string clave)
        {
            return $"🔐 *MonolitoApp - Recuperación de Contraseña*\n\n" +
                   $"Hola {nombre}, tu clave temporal es:\n\n" +
                   $"*{clave}*\n\n" +
                   $"⏰ Válida por 15 minutos.\n" +
                   $"Si no solicitaste esto, ignora este mensaje.";
        }
    }
}
