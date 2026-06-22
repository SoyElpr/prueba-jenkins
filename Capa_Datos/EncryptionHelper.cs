using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace Capa_Datos
{
    public static class EncryptionHelper
    {
        private static readonly byte[] Key = Encoding.UTF8.GetBytes("Monolito4AmSecretKey12345"); // Must be 24 or 32 bytes for AES
        private static readonly byte[] Iv = Encoding.UTF8.GetBytes("Monolito4AmIV123");     // Must be 16 bytes for AES

        static EncryptionHelper()
        {
            // Ensure key is correct size (32 bytes)
            Array.Resize(ref Key, 32);
            // Ensure IV is correct size (16 bytes)
            Array.Resize(ref Iv, 16);
        }

        public static byte[] Encrypt(string plainText)
        {
            if (string.IsNullOrEmpty(plainText)) return new byte[0];

            using (var aes = Aes.Create())
            {
                aes.Key = Key;
                aes.IV = Iv;

                using (var encryptor = aes.CreateEncryptor(aes.Key, aes.IV))
                using (var ms = new MemoryStream())
                {
                    using (var cs = new CryptoStream(ms, encryptor, CryptoStreamMode.Write))
                    using (var sw = new StreamWriter(cs))
                    {
                        sw.Write(plainText);
                    }
                    return ms.ToArray();
                }
            }
        }

        public static string Decrypt(byte[] cipherBytes)
        {
            if (cipherBytes == null || cipherBytes.Length == 0) return string.Empty;

            try
            {
                using (var aes = Aes.Create())
                {
                    aes.Key = Key;
                    aes.IV = Iv;

                    using (var decryptor = aes.CreateDecryptor(aes.Key, aes.IV))
                    using (var ms = new MemoryStream(cipherBytes))
                    using (var cs = new CryptoStream(ms, decryptor, CryptoStreamMode.Read))
                    using (var sr = new StreamReader(cs))
                    {
                        return sr.ReadToEnd();
                    }
                }
            }
            catch
            {
                // Return empty string or fallback if decryption fails
                return string.Empty;
            }
        }
    }
}
