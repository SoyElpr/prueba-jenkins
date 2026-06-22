using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;
using Capa_Datos;

namespace Monolito_4Am.Seguridad
{
    public partial class Registro : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // No cargamos tipos, el registro público es siempre para "Usuario"
            }
        }

        // Método eliminado: CargarTiposUsuario()

        protected void btnPrevisualizar_Click(object sender, EventArgs e)
        {
            if (fupFoto.HasFile)
            {
                // VALIDACIONES DE ARCHIVO
                string ext = System.IO.Path.GetExtension(fupFoto.FileName).ToLower();
                string[] permitidos = { ".jpg", ".jpeg", ".png", ".gif" };

                if (!Array.Exists(permitidos, ex => ex == ext))
                {
                    Mensaje("⚠ Formato no válido para previsualizar. Use: JPG, PNG o GIF.", true);
                    return;
                }

                if (fupFoto.PostedFile.ContentLength > 2 * 1024 * 1024)
                {
                    Mensaje("⚠ Imagen demasiado grande para previsualizar. Máximo 2 MB.", true);
                    return;
                }

                byte[] datos = fupFoto.FileBytes;
                Session["FotoPreview"] = datos;
                Session["FotoPreviewNombre"] = fupFoto.FileName;
                Session["FotoPreviewTipo"] = fupFoto.PostedFile.ContentType;

                string base64 = Convert.ToBase64String(datos);
                string mime = fupFoto.PostedFile.ContentType;
                imgPreview.ImageUrl = "data:" + mime + ";base64," + base64;
                
                imgPreview.Visible = true;
                pnlFotoPlaceholder.Visible = false;
                pnlMensaje.Visible = false; // Limpiar errores previos si todo salió bien
                upFoto.Update();
            }
            else
            {
                Mensaje("⚠ Seleccione una imagen primero.", true);
            }
        }

        protected void btnRegistrar_Click(object sender, EventArgs e)
        {
            string cedula = txtCedula.Text.Trim();
            string nombres = txtNombres.Text.Trim();
            string apellidos = txtApellidos.Text.Trim();
            string celular = txtCelular.Text.Trim();
            string correo = txtCorreo.Text.Trim();
            string nick = txtNick.Text.Trim();
            string pass = txtContrasena.Text.Trim();
            string confirmar = txtConfirmar.Text.Trim();
            string fnac = txtFechaNacimiento.Text.Trim();

            if (cedula == "" || nombres == "" || apellidos == "" || celular == "" || correo == "" ||
                nick == "" || pass == "" || confirmar == "" || fnac == "")
            {
                Mensaje("⚠ Complete todos los campos.", true);
                return;
            }

            if (pass != confirmar)
            {
                Mensaje("⚠ Las contraseñas no coinciden.", true);
                return;
            }

            byte[] fotoDatos = null;
            string fotoNombre = "";
            string fotoTipo = "";

            HttpPostedFile archivo = fupFoto.HasFile ? fupFoto.PostedFile : null;
            
            if (archivo != null)
            {
                // VALIDACIONES DE ARCHIVO
                string ext = System.IO.Path.GetExtension(archivo.FileName).ToLower();
                string[] permitidos = { ".jpg", ".jpeg", ".png", ".gif" };
                
                if (!Array.Exists(permitidos, ex => ex == ext))
                {
                    Mensaje("⚠ Formato no válido. Use: JPG, PNG o GIF.", true);
                    return;
                }

                if (archivo.ContentLength > 2 * 1024 * 1024) // 2MB
                {
                    Mensaje("⚠ La imagen es muy pesada. Máximo 2 MB.", true);
                    return;
                }

                fotoDatos = fupFoto.FileBytes;
                fotoNombre = fupFoto.FileName;
                fotoTipo = archivo.ContentType;
            }
            else
            {
                // Solo si no subió una nueva, buscamos en la sesión (previo)
                fotoDatos = Session["FotoPreview"] as byte[];
                fotoNombre = Session["FotoPreviewNombre"] as string;
                fotoTipo = Session["FotoPreviewTipo"] as string;
            }

            if (fotoDatos == null)
            {
                Mensaje("⚠ Suba una foto de perfil.", true);
                return;
            }

            try
            {
                // El registro público siempre asigna el tipo "Usuario" (ID 2)
                int tipoUsuarioId = 2; 

                int usuId = CN_tbl_usuario.RegistrarUsuario(
                    cedula, nombres, apellidos, celular, correo,
                    nick, pass, DateTime.Parse(fnac), tipoUsuarioId);

                if (usuId > 0)
                {
                    CN_tbl_foto_usuario.AgregarFoto(usuId, fotoDatos, fotoNombre, fotoTipo, true);

                    Session.Remove("FotoPreview");
                    Session.Remove("FotoPreviewNombre");
                    Session.Remove("FotoPreviewTipo");

                    CN_Auditoria.Log(usuId, "Nuevo Registro de Usuario", "Seguridad");

                    Mensaje("✅ ¡Registro exitoso! Ahora puede iniciar sesión.", false);
                    LimpiarCampos();
                }
                else
                {
                    Mensaje("❌ No se pudo completar el registro.", true);
                }
            }
            catch (Exception ex)
            {
                Mensaje("❌ Error: " + ex.Message, true);
            }
        }

        protected void btnVolver_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Seguridad/login.aspx");
        }

        void Mensaje(string txt, bool error)
        {
            pnlMensaje.Visible = true;
            pnlMensaje.CssClass = error ? "msg-box error" : "msg-box";
            lblMensaje.Text = txt;
        }

        void LimpiarCampos()
        {
            txtCedula.Text = txtNombres.Text = txtApellidos.Text = "";
            txtCelular.Text = txtCorreo.Text = txtNick.Text = "";
            txtContrasena.Text = txtConfirmar.Text = txtFechaNacimiento.Text = "";
            imgPreview.Visible = false;
            pnlFotoPlaceholder.Visible = true;
        }
    }
}