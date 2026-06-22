using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace Monolito_4Am.Mantenimineto
{
    public partial class estadisticas_producto : Page
    {
        // JSON strings injected into the .aspx page
        protected string StockLabelsJson { get; private set; }
        protected string StockValuesJson { get; private set; }
        protected string PriceLabelsJson { get; private set; }
        protected string PriceValuesJson { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarDatos();
            }
        }

        private void CargarDatos()
        {
            // Obtain full product table
            DataTable dt = CN_tbl_producto.ListarTodos();

            // Convert to strongly‑typed list for LINQ processing
            var productos = dt.AsEnumerable().Select(r => new Producto
            {
                Id = r.Field<int>("pro_id"),
                Codigo = r.Field<string>("pro_codigo"),
                Nombre = r.Field<string>("pro_nombre"),
                Cantidad = r.Field<int>("pro_cantidad"),
                Precio = r.Field<decimal>("pro_precio"),
                Foto = r.Field<string>("pro_foto"),
                Proveedor = r.Field<string>("prov_nombre")
            }).ToList();

            // ---------- Stock per Product (Bar Chart - Top 10 by stock) ----------
            var stockPorProducto = productos
                .OrderByDescending(p => p.Cantidad)
                .Take(10)
                .Select(p => new { Label = p.Nombre, Value = p.Cantidad })
                .ToList();

            // ---------- Products per Provider (Pie/Doughnut Chart) ----------
            var prodPorProv = productos
                .GroupBy(p => string.IsNullOrEmpty(p.Proveedor) ? "Sin Proveedor" : p.Proveedor)
                .Select(g => new { Label = g.Key, Value = g.Count() })
                .OrderByDescending(x => x.Value)
                .ToList();

            // Serialize to JSON for injection into the page
            var serializer = new JavaScriptSerializer();
            StockLabelsJson = serializer.Serialize(stockPorProducto.Select(x => x.Label).ToArray());
            StockValuesJson = serializer.Serialize(stockPorProducto.Select(x => x.Value).ToArray());
            PriceLabelsJson = serializer.Serialize(prodPorProv.Select(x => x.Label).ToArray());
            PriceValuesJson = serializer.Serialize(prodPorProv.Select(x => x.Value).ToArray());

            // ---------- Build carousel – top 5 products by stock ----------
            var topProductos = productos
                .OrderByDescending(p => p.Cantidad)
                .Take(5)
                .ToList();

            // Ensure the Uploads folder exists (image fallback)
            string defaultImg = ResolveUrl("~/Uploads/no_image.png");

            // Build HTML for each carousel‑item
            bool first = true;
            foreach (var p in topProductos)
            {
                string rawFoto = p.Foto ?? "";
                // Get first photo if multiple exist
                string firstFoto = rawFoto.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries).FirstOrDefault() ?? "";
                firstFoto = firstFoto.Trim();

                string imgSrc;
                if (string.IsNullOrEmpty(firstFoto) || firstFoto.Equals("no_image.png", StringComparison.OrdinalIgnoreCase))
                {
                    imgSrc = defaultImg;
                }
                else if (firstFoto.StartsWith("~/") || firstFoto.StartsWith("/"))
                {
                    imgSrc = ResolveUrl(firstFoto);
                }
                else
                {
                    imgSrc = ResolveUrl("~/Uploads/" + firstFoto);
                }

                string activeClass = first ? " active" : string.Empty;
                string itemHtml = $"<div class='carousel-item{activeClass}'>" +
                                 $"<img src='{imgSrc}' class='d-block w-100 carousel-img' alt='{p.Nombre}' />" +
                                 $"<div class='carousel-caption d-none d-md-block'><h5>{p.Nombre}</h5><p>Stock: {p.Cantidad} | Precio: {p.Precio:C2}</p></div>" +
                                 "</div>";
                carouselInner.Controls.Add(new LiteralControl(itemHtml));
                first = false;
            }
        }

        protected void btnVolver_Click(object sender, EventArgs e)
        {
            Response.Redirect("listar_tbl_producto.aspx");
        }

        // Simple DTO for internal use
        private class Producto
        {
            public int Id { get; set; }
            public string Codigo { get; set; }
            public string Nombre { get; set; }
            public int Cantidad { get; set; }
            public decimal Precio { get; set; }
            public string Foto { get; set; }
            public string Proveedor { get; set; }
        }
    }
}
