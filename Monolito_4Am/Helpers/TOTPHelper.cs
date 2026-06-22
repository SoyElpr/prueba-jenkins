using System;
using System.Security.Cryptography;
using System.Text;

namespace Monolito_4Am.Helpers
{
    /// <summary>
    /// Implementación manual de TOTP (RFC 6238) + HOTP (RFC 4226)
    /// Compatible con Google Authenticator — sin dependencias externas.
    /// </summary>
    public static class TOTPHelper
    {
        private const int DIGITS = 6;
        private const int STEP   = 30; // segundos por ventana

        // ── GENERACIÓN DE SECRETO ──────────────────────────────────────────────
        public static string GenerarSecretoBase32()
        {
            byte[] raw = new byte[20]; // 160 bits
            using (var rng = new RNGCryptoServiceProvider())
                rng.GetBytes(raw);
            return Base32Encode(raw);
        }

        // ── URI otpauth (para el QR) ───────────────────────────────────────────
        public static string GenerarOtpAuthUri(string secret, string correo, string emisor = "MonolitoApp")
        {
            string label   = Uri.EscapeDataString($"{emisor}:{correo}");
            string issuer  = Uri.EscapeDataString(emisor);
            return $"otpauth://totp/{label}?secret={secret}&issuer={issuer}&algorithm=SHA1&digits=6&period=30";
        }

        // ── URL DEL QR (Usando api.qrserver.com para mayor confiabilidad) ─────
        public static string GetQRCodeUrl(string data, int size = 200)
        {
            string encoded = Uri.EscapeDataString(data);
            return $"https://api.qrserver.com/v1/create-qr-code/?size={size}x{size}&data={encoded}";
        }

        public static string GenerarCodigoActual(string base32Secret)
        {
            if (string.IsNullOrWhiteSpace(base32Secret)) return "000000";
            byte[] key = Base32Decode(base32Secret);
            long   ts  = DateTimeOffset.UtcNow.ToUnixTimeSeconds() / STEP;
            return ComputeHOTP(key, ts);
        }

        // ── VALIDACIÓN DEL CÓDIGO OTP ──────────────────────────────────────────
        public static bool ValidarCodigo(string base32Secret, string codigoIngresado)
        {
            if (string.IsNullOrWhiteSpace(base32Secret) ||
                string.IsNullOrWhiteSpace(codigoIngresado)) return false;

            try
            {
                byte[] key = Base32Decode(base32Secret);
                long   ts  = DateTimeOffset.UtcNow.ToUnixTimeSeconds() / STEP;

                // Verificar ventana actual y la anterior (±30 s de tolerancia)
                for (long delta = -1; delta <= 1; delta++)
                {
                    string codigo = ComputeHOTP(key, ts + delta);
                    if (codigo == codigoIngresado.Trim()) return true;
                }
                return false;
            }
            catch { return false; }
        }

        // ── HOTP INTERNO ───────────────────────────────────────────────────────
        private static string ComputeHOTP(byte[] key, long counter)
        {
            byte[] msg = BitConverter.GetBytes(counter);
            if (BitConverter.IsLittleEndian) Array.Reverse(msg);

            byte[] hash;
            using (var hmac = new HMACSHA1(key))
                hash = hmac.ComputeHash(msg);

            int offset = hash[hash.Length - 1] & 0x0F;
            int code   = ((hash[offset]     & 0x7F) << 24)
                       | ((hash[offset + 1] & 0xFF) << 16)
                       | ((hash[offset + 2] & 0xFF) << 8)
                       |  (hash[offset + 3] & 0xFF);

            return (code % (int)Math.Pow(10, DIGITS)).ToString($"D{DIGITS}");
        }

        // ── BASE32 ENCODE ──────────────────────────────────────────────────────
        private static readonly char[] BASE32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567".ToCharArray();

        public static string Base32Encode(byte[] data)
        {
            var sb = new StringBuilder();
            int buffer = data[0], bitsLeft = 8, i = 1;
            while (bitsLeft > 0 || i < data.Length)
            {
                if (bitsLeft < 5)
                {
                    if (i < data.Length)
                    {
                        buffer <<= 8;
                        buffer |= data[i++] & 0xFF;
                        bitsLeft += 8;
                    }
                    else
                    {
                        buffer <<= (5 - bitsLeft);
                        bitsLeft = 5;
                    }
                }
                bitsLeft -= 5;
                sb.Append(BASE32[(buffer >> bitsLeft) & 31]);
            }
            return sb.ToString();
        }

        // ── BASE32 DECODE ──────────────────────────────────────────────────────
        public static byte[] Base32Decode(string input)
        {
            input = input.TrimEnd('=').ToUpper();
            var output = new byte[input.Length * 5 / 8];
            int buffer = 0, bitsLeft = 0, idx = 0;
            foreach (char c in input)
            {
                int val = Array.IndexOf(BASE32, c);
                if (val < 0) continue;
                buffer   = (buffer << 5) | val;
                bitsLeft += 5;
                if (bitsLeft >= 8)
                {
                    output[idx++] = (byte)(buffer >> (bitsLeft - 8));
                    bitsLeft -= 8;
                }
            }
            return output;
        }
    }
}
