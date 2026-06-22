// subida_excel.aspx.cs
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito_4Am.Mantenimineto
{
    public partial class subida_excel : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlMsg.Visible = false;
                pnlStats.Visible = false;
                pnlPreview.Visible = false;
            }
        }

        /// <summary>
        /// Previsualiza el archivo sin modificar la base.
        /// Nota: hace postback COMPLETO (no async) para que el FileUpload funcione.
        /// </summary>
        protected void btnPrevisualizar_Click(object sender, EventArgs e)
        {
            if (!fuArchivo.HasFile)
            {
                MostrarMensaje("⚠ Selecciona un archivo primero.", true);
                return;
            }

            try
            {
                string tempPath = GuardarTemporal();
                if (tempPath == null) return;

                Session["TempFilePath"] = tempPath;
                ProcesarPreview(tempPath);
            }
            catch (Exception ex)
            {
                MostrarMensaje("❌ Error al leer el archivo: " + ex.Message, true);
            }
        }

        /// <summary>
        /// Importa el archivo a la BD.
        /// Si se sube archivo nuevo en este postback, lo procesa directamente.
        /// Si ya había un archivo en sesión, lo usa.
        /// </summary>
        protected void btnProcesar_Click(object sender, EventArgs e)
        {
            string tempPath = null;

            // Prioridad: archivo recién subido en este postback
            if (fuArchivo.HasFile)
            {
                tempPath = GuardarTemporal();
                if (tempPath == null) return;
                Session["TempFilePath"] = tempPath;
            }
            else
            {
                // Usar el archivo de la sesión (previsualizó antes)
                tempPath = Session["TempFilePath"] as string;
            }

            if (string.IsNullOrEmpty(tempPath) || !File.Exists(tempPath))
            {
                MostrarMensaje("⚠ Selecciona el archivo CSV y vuelve a hacer clic en Importar.", true);
                return;
            }

            try
            {
                var result = CN_tbl_producto.ImportarExcel(tempPath);
                int insertados = result.Item1;
                int actualizados = result.Item2;
                var errores = result.Item3;

                string resumen = string.Format("✅ Importación completa: {0} producto(s) insertado(s), {1} actualizado(s).", insertados, actualizados);
                if (errores.Count > 0)
                    resumen += string.Format(" ⚠ {0} error(es): ", errores.Count) + string.Join(" | ", errores);

                MostrarMensaje(resumen, errores.Count > 0 && insertados + actualizados == 0);

                pnlPreview.Visible = false;
                pnlStats.Visible = false;
                Session["TempFilePath"] = null;

                // Redirigir al listado después de 2 s
                ClientScript.RegisterStartupScript(this.GetType(), "redirect",
                    "setTimeout(function(){ window.location='listar_tbl_producto.aspx'; }, 2000);", true);
            }
            catch (Exception ex)
            {
                MostrarMensaje("❌ Error al procesar: " + ex.Message, true);
            }
        }

        // ──────────────────────────────────────────────────────────
        private void ProcesarPreview(string tempPath)
        {
            List<string[]> rows;
            try
            {
                rows = CN_tbl_producto.ObtenerFilasPreview(tempPath);
            }
            catch (Exception ex)
            {
                MostrarMensaje("❌ Error al leer el archivo: " + ex.Message, true);
                return;
            }

            if (rows == null || rows.Count < 2)
            {
                MostrarMensaje("⚠ El archivo está vacío o sólo tiene encabezado.", true);
                return;
            }

            string[] headers = rows[0];

            // Índice de pro_id
            int proIdColIdx = -1;
            for (int ci = 0; ci < headers.Length; ci++)
            {
                if (headers[ci].Trim().Equals("pro_id", StringComparison.OrdinalIgnoreCase))
                { proIdColIdx = ci; break; }
            }

            int totalRows = 0, nuevos = 0, actualizaciones = 0;
            var existingIds = CN_tbl_producto.ObtenerIdsExistentes();

            DataTable dt = new DataTable();
            foreach (var h in headers)
                dt.Columns.Add(h.Trim());

            for (int i = 1; i < rows.Count; i++)
            {
                string[] fields = rows[i];
                if (fields == null || fields.Length == 0) continue;

                DataRow row = dt.NewRow();
                for (int c = 0; c < headers.Length; c++)
                    row[c] = c < fields.Length ? fields[c].Trim() : "";
                dt.Rows.Add(row);
                totalRows++;

                string proIdStr = (proIdColIdx >= 0 && proIdColIdx < fields.Length)
                    ? fields[proIdColIdx].Trim() : "";

                int parsedId;
                if (int.TryParse(proIdStr, out parsedId) && parsedId > 0 && existingIds.Contains(parsedId))
                    actualizaciones++;
                else
                    nuevos++;
            }

            lblNuevos.Text = nuevos.ToString();
            lblActualizar.Text = actualizaciones.ToString();
            lblTotal.Text = totalRows.ToString();
            pnlStats.Visible = true;

            // Mostrar máx 50 filas en el grid
            DataTable dtShow = dt;
            if (dt.Rows.Count > 50)
            {
                dtShow = dt.Clone();
                for (int r = 0; r < 50; r++) dtShow.ImportRow(dt.Rows[r]);
            }
            gvPreview.DataSource = dtShow;
            gvPreview.DataBind();
            pnlPreview.Visible = true;

            MostrarMensaje(string.Format("✅ Previsualización: {0} fila(s). Se insertarán {1} nuevo(s) y se actualizarán {2} existente(s).{3}",
                totalRows, nuevos, actualizaciones, dt.Rows.Count > 50 ? " (mostrando primeros 50)" : ""), false);
        }

        private string GuardarTemporal()
        {
            try
            {
                string ext = Path.GetExtension(fuArchivo.PostedFile.FileName).ToLower();
                // Aceptar xls (SpreadsheetML), csv, txt, tsv — también xlsx
                if (ext != ".xls" && ext != ".csv" && ext != ".txt" && ext != ".tsv" && ext != ".xlsx")
                {
                    MostrarMensaje("⚠ Formato no admitido. Sube el archivo .xls exportado desde este sistema.", true);
                    return null;
                }

                string tempDir = Server.MapPath("~/TempUploads/");
                if (!Directory.Exists(tempDir)) Directory.CreateDirectory(tempDir);
                string filePath = Path.Combine(tempDir, Guid.NewGuid().ToString() + ext);
                fuArchivo.SaveAs(filePath);
                return filePath;
            }
            catch (Exception ex)
            {
                MostrarMensaje("❌ Error al guardar: " + ex.Message, true);
                return null;
            }
        }

        private void MostrarMensaje(string texto, bool esError)
        {
            pnlMsg.Visible = true;
            msgDiv.Attributes["class"] = esError ? "msg-panel msg-error" : "msg-panel msg-success";
            msgDiv.InnerHtml = texto;
        }
    }
}
