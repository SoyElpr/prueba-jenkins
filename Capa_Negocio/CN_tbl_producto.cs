using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_producto
    {
        private static string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["conexion"].ConnectionString;
        }

        // ─────────────────────────────────────────────────────────────────────
        public static DataTable ListarTodos()
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var query = from p in db.Tbl_producto
                            join pr in db.Tbl_provedor on p.Prov_id equals pr.Prov_id into joined
                            from subPr in joined.DefaultIfEmpty()
                            orderby p.Pro_id descending
                            select new
                            {
                                p.Pro_id, p.Pro_codigo, p.Pro_nombre,
                                p.Pro_cantidad, p.Pro_precio, p.Pro_descripcion,
                                p.Pro_foto, p.Pro_estado, p.Prov_id,
                                prov_nombre = subPr != null ? subPr.Prov_nombre : "Sin Proveedor"
                            };
                return CN_tbl_usuario.ToDataTable(query.ToList());
            }
        }

        public static DataTable Buscar(string term, string field)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var query = from p in db.Tbl_producto
                            join pr in db.Tbl_provedor on p.Prov_id equals pr.Prov_id into joined
                            from subPr in joined.DefaultIfEmpty()
                            select new
                            {
                                p.Pro_id, p.Pro_codigo, p.Pro_nombre,
                                p.Pro_cantidad, p.Pro_precio, p.Pro_descripcion,
                                p.Pro_foto, p.Pro_estado, p.Prov_id,
                                prov_nombre = subPr != null ? subPr.Prov_nombre : "Sin Proveedor"
                            };

                if (!string.IsNullOrEmpty(term))
                {
                    term = term.ToLower();
                    if (field == "nombre")
                        query = query.Where(x => x.Pro_nombre.ToLower().Contains(term));
                    else if (field == "id")
                    {
                        int id;
                        if (int.TryParse(term, out id))
                            query = query.Where(x => x.Pro_id == id);
                    }
                    else if (field == "proveedor")
                        query = query.Where(x => x.prov_nombre.ToLower().Contains(term));
                }
                return CN_tbl_usuario.ToDataTable(query.OrderByDescending(x => x.Pro_id).ToList());
            }
        }

        public static Tbl_producto ObtenerPorId(int proId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
                return db.Tbl_producto.FirstOrDefault(x => x.Pro_id == proId);
        }

        public static System.Collections.Generic.HashSet<int> ObtenerIdsExistentes()
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
                return new System.Collections.Generic.HashSet<int>(db.Tbl_producto.Select(x => x.Pro_id).ToList());
        }

        public static int Insertar(string codigo, string nombre, int cantidad, decimal precio,
            string descripcion, string foto, int? provId, string estado = "A")
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var p = new Tbl_producto
                {
                    Pro_codigo = codigo, Pro_nombre = nombre, Pro_cantidad = cantidad,
                    Pro_precio = precio, Pro_descripcion = descripcion, Pro_foto = foto,
                    Pro_estado = string.IsNullOrEmpty(estado) ? "A" : estado, Prov_id = provId
                };
                db.Tbl_producto.InsertOnSubmit(p);
                db.SubmitChanges();
                return p.Pro_id;
            }
        }

        public static void Actualizar(int proId, string codigo, string nombre, int cantidad,
            decimal precio, string descripcion, string foto, int? provId, string estado)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var p = db.Tbl_producto.FirstOrDefault(x => x.Pro_id == proId);
                if (p != null)
                {
                    p.Pro_codigo = codigo; p.Pro_nombre = nombre; p.Pro_cantidad = cantidad;
                    p.Pro_precio = precio; p.Pro_descripcion = descripcion;
                    if (foto != null) p.Pro_foto = foto;
                    p.Pro_estado = string.IsNullOrEmpty(estado) ? "A" : estado;
                    p.Prov_id = provId;
                    db.SubmitChanges();
                }
            }
        }

        public static void Eliminar(int proId)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                var p = db.Tbl_producto.FirstOrDefault(x => x.Pro_id == proId);
                if (p != null) { db.Tbl_producto.DeleteOnSubmit(p); db.SubmitChanges(); }
            }
        }

        // ─────────────────────────────────────────────────────────────────────
        // EXPORTAR — SpreadsheetML XML (.xls nativo de Excel)
        // Cada campo va en su propia celda, sin problema de separadores locales.
        // Columnas: pro_id, pro_codigo, pro_nombre, pro_cantidad, pro_precio,
        //           pro_descripcion, pro_foto, pro_estado, prov_id, prov_nombre
        // ─────────────────────────────────────────────────────────────────────
        public static byte[] ExportarExcel()
        {
            var dt = ListarTodos();

            var sb = new StringBuilder();
            sb.AppendLine("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
            sb.AppendLine("<?mso-application progid=\"Excel.Sheet\"?>");
            sb.AppendLine("<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"");
            sb.AppendLine(" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\">");
            sb.AppendLine(" <Worksheet ss:Name=\"Productos\">");
            sb.AppendLine("  <Table>");

            // Fila de encabezados
            string[] headers = { "pro_id", "pro_codigo", "pro_nombre", "pro_cantidad",
                                  "pro_precio", "pro_descripcion", "pro_foto", "pro_estado",
                                  "prov_id", "prov_nombre" };
            sb.AppendLine("   <Row>");
            foreach (var h in headers)
                sb.AppendFormat("    <Cell><Data ss:Type=\"String\">{0}</Data></Cell>{1}", h, "\r\n");
            sb.AppendLine("   </Row>");

            // Filas de datos
            foreach (DataRow row in dt.Rows)
            {
                string precioStr = row["pro_precio"] == DBNull.Value ? "" : 
                    Convert.ToDecimal(row["pro_precio"]).ToString(System.Globalization.CultureInfo.InvariantCulture);

                sb.AppendLine("   <Row>");
                sb.AppendFormat("    <Cell><Data ss:Type=\"Number\">{0}</Data></Cell>{1}", XmlEsc(row["pro_id"]), "\r\n");
                sb.AppendFormat("    <Cell><Data ss:Type=\"String\">{0}</Data></Cell>{1}", XmlEsc(row["pro_codigo"]), "\r\n");
                sb.AppendFormat("    <Cell><Data ss:Type=\"String\">{0}</Data></Cell>{1}", XmlEsc(row["pro_nombre"]), "\r\n");
                sb.AppendFormat("    <Cell><Data ss:Type=\"Number\">{0}</Data></Cell>{1}", XmlEsc(row["pro_cantidad"]), "\r\n");
                sb.AppendFormat("    <Cell><Data ss:Type=\"Number\">{0}</Data></Cell>{1}", precioStr, "\r\n");
                sb.AppendFormat("    <Cell><Data ss:Type=\"String\">{0}</Data></Cell>{1}", XmlEsc(row["pro_descripcion"]), "\r\n");
                sb.AppendFormat("    <Cell><Data ss:Type=\"String\">{0}</Data></Cell>{1}", XmlEsc(row["pro_foto"]), "\r\n");
                sb.AppendFormat("    <Cell><Data ss:Type=\"String\">{0}</Data></Cell>{1}", XmlEsc(row["pro_estado"]), "\r\n");
                sb.AppendFormat("    <Cell><Data ss:Type=\"Number\">{0}</Data></Cell>{1}", XmlEsc(row["prov_id"]), "\r\n");
                sb.AppendFormat("    <Cell><Data ss:Type=\"String\">{0}</Data></Cell>{1}", XmlEsc(row["prov_nombre"]), "\r\n");
                sb.AppendLine("   </Row>");
            }

            sb.AppendLine("  </Table>");
            sb.AppendLine(" </Worksheet>");
            sb.AppendLine("</Workbook>");

            return Encoding.UTF8.GetBytes(sb.ToString());
        }

        /// <summary>Escapa caracteres especiales XML.</summary>
        private static string XmlEsc(object val)
        {
            if (val == null || val == DBNull.Value) return "";
            return val.ToString()
                .Replace("&", "&amp;")
                .Replace("<", "&lt;")
                .Replace(">", "&gt;")
                .Replace("\"", "&quot;");
        }

        // ─────────────────────────────────────────────────────────────────────
        // IMPORTAR — acepta tanto el .xls SpreadsheetML exportado por este
        // sistema, como archivos .csv/.txt delimitados (coma, punto y coma, tab).
        // Reglas de merge:
        //   • Si pro_id existe en BD → actualiza
        //   • Si pro_id vacío o 0    → inserta nuevo (aparece primero)
        //   • Productos en BD no incluidos en el archivo → NO se eliminan
        // ─────────────────────────────────────────────────────────────────────
        public static Tuple<int, int, List<string>> ImportarExcel(string filePath)
        {
            int insertados = 0, actualizados = 0;
            var errores = new List<string>();

            // 1. Parsear el archivo → lista de filas (cada fila = array de strings)
            List<string[]> rows;
            try
            {
                rows = EsSpreadsheetML(filePath) ? ParsearSpreadsheetML(filePath) : ParsearDelimitado(filePath);
            }
            catch (Exception ex)
            {
                errores.Add("Error al leer el archivo: " + ex.Message);
                return Tuple.Create(0, 0, errores);
            }

            if (rows == null || rows.Count < 2)
            {
                errores.Add("El archivo esta vacio o solo tiene encabezado.");
                return Tuple.Create(insertados, actualizados, errores);
            }

            // 2. Detectar índices de columna desde la primera fila (encabezado)
            string[] headers = rows[0];
            var colIdx = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            for (int i = 0; i < headers.Length; i++)
                colIdx[headers[i].Trim()] = i;

            if (!colIdx.ContainsKey("pro_nombre"))
            {
                errores.Add("El archivo no tiene la columna 'pro_nombre'. Exporta primero desde el sistema.");
                return Tuple.Create(insertados, actualizados, errores);
            }

            // 3. Procesar filas de datos
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                for (int rowNum = 1; rowNum < rows.Count; rowNum++)
                {
                    string[] fields = rows[rowNum];
                    try
                    {
                        string GetF(string col)
                        {
                            if (!colIdx.ContainsKey(col)) return "";
                            int ci = colIdx[col];
                            return ci < fields.Length ? fields[ci].Trim() : "";
                        }

                        string nombre    = GetF("pro_nombre");
                        if (string.IsNullOrEmpty(nombre)) continue;

                        string proIdStr  = GetF("pro_id");
                        string codigo    = GetF("pro_codigo");
                        string desc      = GetF("pro_descripcion");
                        string foto      = GetF("pro_foto");
                        string estado    = GetF("pro_estado");
                        string provNomb  = GetF("prov_nombre");
                        string provIdStr = GetF("prov_id");

                        int cantidad;
                        int.TryParse(GetF("pro_cantidad"), out cantidad);

                        decimal precio;
                        decimal.TryParse(GetF("pro_precio").Replace(",", "."),
                            System.Globalization.NumberStyles.Any,
                            System.Globalization.CultureInfo.InvariantCulture, out precio);

                        if (string.IsNullOrEmpty(estado)) estado = "A";
                        if (string.IsNullOrEmpty(foto))   foto   = "no_image.png";

                        // Resolver proveedor
                        int? provId = null;
                        int pvId = 0;
                        bool hasProvId = int.TryParse(provIdStr, out pvId) && pvId > 0;
                        bool hasProvNomb = !string.IsNullOrEmpty(provNomb);

                        if (hasProvId || hasProvNomb)
                        {
                            Tbl_provedor prov = null;
                            if (hasProvId)
                            {
                                prov = db.Tbl_provedor.FirstOrDefault(x => x.Prov_id == pvId);
                            }
                            if (prov == null && hasProvNomb)
                            {
                                prov = db.Tbl_provedor.FirstOrDefault(x => x.Prov_nombre.ToLower() == provNomb.ToLower());
                            }
                            if (prov == null && hasProvNomb)
                            {
                                prov = new Tbl_provedor { Prov_nombre = provNomb, Prov_estado = "A" };
                                db.Tbl_provedor.InsertOnSubmit(prov);
                                db.SubmitChanges();
                            }
                            if (prov != null)
                            {
                                provId = prov.Prov_id;
                            }
                        }

                        // INSERT o UPDATE
                        int proId;
                        if (int.TryParse(proIdStr, out proId) && proId > 0)
                        {
                            var existing = db.Tbl_producto.FirstOrDefault(x => x.Pro_id == proId);
                            if (existing != null)
                            {
                                existing.Pro_codigo = codigo; existing.Pro_nombre = nombre;
                                existing.Pro_cantidad = cantidad; existing.Pro_precio = precio;
                                existing.Pro_descripcion = desc;
                                if (!string.IsNullOrEmpty(foto)) existing.Pro_foto = foto;
                                existing.Pro_estado = estado; existing.Prov_id = provId;
                                db.SubmitChanges();
                                actualizados++;
                                continue;
                            }
                        }

                        // Nuevo producto
                        db.Tbl_producto.InsertOnSubmit(new Tbl_producto
                        {
                            Pro_codigo = codigo, Pro_nombre = nombre, Pro_cantidad = cantidad,
                            Pro_precio = precio, Pro_descripcion = desc, Pro_foto = foto,
                            Pro_estado = estado, Prov_id = provId
                        });
                        db.SubmitChanges();
                        insertados++;
                    }
                    catch (Exception ex)
                    {
                        errores.Add(string.Format("Fila {0}: {1}", rowNum + 1, ex.Message));
                    }
                }
            }

            return Tuple.Create(insertados, actualizados, errores);
        }

        /// <summary>
        /// Parsea el archivo y devuelve las filas para la previsualización en la UI.
        /// Primera fila = encabezados, resto = datos.
        /// </summary>
        public static List<string[]> ObtenerFilasPreview(string filePath)
        {
            return EsSpreadsheetML(filePath) ? ParsearSpreadsheetML(filePath) : ParsearDelimitado(filePath);
        }

        // ─── Detectar formato ────────────────────────────────────────────────
        private static bool EsSpreadsheetML(string filePath)
        {
            try
            {
                using (var sr = new StreamReader(filePath, Encoding.UTF8))
                {
                    string line1 = sr.ReadLine() ?? "";
                    string line2 = sr.ReadLine() ?? "";
                    return (line1 + line2).Contains("schemas-microsoft-com:office:spreadsheet")
                        || (line1 + line2).Contains("mso-application");
                }
            }
            catch { return false; }
        }

        // ─── Parser SpreadsheetML XML ────────────────────────────────────────
        private static List<string[]> ParsearSpreadsheetML(string filePath)
        {
            var result = new List<string[]>();
            var doc = new System.Xml.XmlDocument();
            doc.Load(filePath);

            var ns = new System.Xml.XmlNamespaceManager(doc.NameTable);
            ns.AddNamespace("ss", "urn:schemas-microsoft-com:office:spreadsheet");

            var tableNode = doc.SelectSingleNode("//ss:Table", ns);
            if (tableNode == null) return result;

            int maxCols = 0;
            foreach (System.Xml.XmlNode rowNode in tableNode.SelectNodes("ss:Row", ns))
            {
                var cells = new List<string>();
                int currentIdx = 1; // SpreadsheetML usa índices basados en 1

                foreach (System.Xml.XmlNode cell in rowNode.SelectNodes("ss:Cell", ns))
                {
                    if (cell.Attributes["ss:Index"] != null)
                    {
                        int parsedIdx;
                        if (int.TryParse(cell.Attributes["ss:Index"].Value, out parsedIdx))
                            currentIdx = parsedIdx;
                    }

                    // Rellenar espacios vacíos si Excel saltó celdas
                    while (cells.Count < currentIdx - 1)
                        cells.Add("");

                    var dataNode = cell.SelectSingleNode("ss:Data", ns);
                    cells.Add(dataNode != null ? dataNode.InnerText : "");
                    currentIdx++;
                }

                if (cells.Count > 0)
                {
                    if (maxCols == 0) maxCols = cells.Count; // Usar el número de columnas del encabezado
                    
                    // Rellenar al final si faltan columnas vacías
                    while (cells.Count < maxCols)
                        cells.Add("");

                    result.Add(cells.ToArray());
                }
            }
            return result;
        }

        // ─── Parser delimitado (CSV / TSV / SSV) ────────────────────────────
        private static List<string[]> ParsearDelimitado(string filePath)
        {
            var result = new List<string[]>();
            string[] lines = File.ReadAllLines(filePath, Encoding.UTF8);
            if (lines.Length == 0) return result;

            // Quitar BOM si hay
            if (lines[0].Length > 0 && lines[0][0] == '\uFEFF')
                lines[0] = lines[0].Substring(1);

            // Saltar línea sep= si existe
            int start = 0;
            if (lines[0].StartsWith("sep=", StringComparison.OrdinalIgnoreCase)) start = 1;

            if (start >= lines.Length) return result;

            // Detectar separador a partir del encabezado
            string hdr = lines[start];
            char sep;
            if (hdr.Contains("\t"))      sep = '\t';
            else if (hdr.Contains(";"))  sep = ';';
            else                         sep = ',';

            for (int i = start; i < lines.Length; i++)
            {
                if (string.IsNullOrWhiteSpace(lines[i])) continue;
                result.Add(ParseCsvLine(lines[i], sep));
            }
            return result;
        }

        /// <summary>Parsea una línea CSV respetando campos entre comillas.</summary>
        private static string[] ParseCsvLine(string line, char sep)
        {
            var fields = new List<string>();
            var field  = new StringBuilder();
            bool inQ   = false;

            for (int i = 0; i < line.Length; i++)
            {
                char c = line[i];
                if (inQ)
                {
                    if (c == '"' && i + 1 < line.Length && line[i + 1] == '"')
                    { field.Append('"'); i++; }
                    else if (c == '"') inQ = false;
                    else field.Append(c);
                }
                else
                {
                    if (c == '"') inQ = true;
                    else if (c == sep) { fields.Add(field.ToString()); field.Clear(); }
                    else field.Append(c);
                }
            }
            fields.Add(field.ToString());
            return fields.ToArray();
        }

        // ─────────────────────────────────────────────────────────────────────
        // Legacy — ParsearCSV y GuardarSubidaMasiva se conservan por compatibilidad
        // ─────────────────────────────────────────────────────────────────────
        public static DataTable ParsearCSV(string filePath)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("prov_nombre", typeof(string));
            dt.Columns.Add("pro_codigo",  typeof(string));
            dt.Columns.Add("pro_nombre",  typeof(string));
            dt.Columns.Add("pro_cantidad", typeof(int));
            dt.Columns.Add("pro_precio",  typeof(decimal));
            dt.Columns.Add("pro_descripcion", typeof(string));

            string[] lines = File.ReadAllLines(filePath, Encoding.UTF8);
            foreach (string line in lines)
            {
                if (string.IsNullOrWhiteSpace(line)) continue;
                char separator = line.Contains(";") ? ';' : ',';
                string[] fields = line.Split(separator);
                if (fields.Length >= 5)
                {
                    string pn = fields[0].Trim();
                    if (pn.Equals("Proveedor", StringComparison.OrdinalIgnoreCase) ||
                        pn.Equals("prov_nombre", StringComparison.OrdinalIgnoreCase)) continue;
                    int qty = 0; int.TryParse(fields[3].Trim(), out qty);
                    decimal price = 0;
                    decimal.TryParse(fields[4].Trim().Replace(",", "."),
                        System.Globalization.NumberStyles.Any,
                        System.Globalization.CultureInfo.InvariantCulture, out price);
                    dt.Rows.Add(pn, fields[1].Trim(), fields[2].Trim(), qty, price,
                        fields.Length > 5 ? fields[5].Trim() : "");
                }
            }
            return dt;
        }

        public static void GuardarSubidaMasiva(DataTable data)
        {
            using (var db = new DataClasses1DataContext(GetConnectionString()))
            {
                foreach (DataRow row in data.Rows)
                {
                    string provName = row["prov_nombre"].ToString().Trim();
                    string name     = row["pro_nombre"].ToString().Trim();
                    if (string.IsNullOrEmpty(name)) continue;

                    int? provId = null;
                    if (!string.IsNullOrEmpty(provName))
                    {
                        var prov = db.Tbl_provedor.FirstOrDefault(x => x.Prov_nombre.ToLower() == provName.ToLower());
                        if (prov == null)
                        {
                            prov = new Tbl_provedor { Prov_nombre = provName, Prov_estado = "A" };
                            db.Tbl_provedor.InsertOnSubmit(prov);
                            db.SubmitChanges();
                        }
                        provId = prov.Prov_id;
                    }

                    int qty = Convert.ToInt32(row["pro_cantidad"]);
                    decimal price = Convert.ToDecimal(row["pro_precio"]);

                    db.Tbl_producto.InsertOnSubmit(new Tbl_producto
                    {
                        Pro_codigo = row["pro_codigo"].ToString().Trim(),
                        Pro_nombre = name,
                        Pro_cantidad = qty,
                        Pro_precio = price,
                        Pro_descripcion = row["pro_descripcion"].ToString().Trim(),
                        Pro_foto = "no_image.png",
                        Pro_estado = "A",
                        Prov_id = provId
                    });
                }
                db.SubmitChanges();
            }
        }
    }
}
