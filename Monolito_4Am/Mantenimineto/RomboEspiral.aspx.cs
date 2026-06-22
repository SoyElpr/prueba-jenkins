using System;
using System.Text;

namespace Monolito_4Am.Mantenimineto
{
    public partial class RomboEspiral : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GenerarRombo(10, 2);
            }
        }

        protected void btnGenerar_Click(object sender, EventArgs e)
        {
            int n = 10;
            int salto = 2;

            if (!int.TryParse(txtN.Text, out n) || !int.TryParse(txtSalto.Text, out salto))
            {
                MostrarError("⚠️ Solo se permiten números enteros en ambos campos.");
                return;
            }

            if (n <= 0 || salto <= 0)
            {
                MostrarError("❌ No se permiten números negativos ni cero. Ingresa valores mayores a 0.");
                return;
            }

            if (n > 40)
            {
                MostrarError("⚠️ El tamaño máximo permitido es 40 para evitar desbordamiento.");
                return;
            }

            lblError.Visible = false;
            GenerarRombo(n, salto);
        }

        private void MostrarError(string mensaje)
        {
            lblError.Text = "<i class=\"fas fa-exclamation-circle\"></i> " + mensaje;
            lblError.Visible = true;
            litResultado.Text = "";
        }

        private void GenerarRombo(int n, int salto)
        {
            int alto = 2 * n + 1;
            int ancho = 2 * n + 1;
            int centro = n;

            char[,] matriz = new char[alto, ancho];
            for (int i = 0; i < alto; i++)
            {
                for (int j = 0; j < ancho; j++)
                {
                    matriz[i, j] = ' ';
                }
            }

            int fila = n;
            int col = 0;
            matriz[fila, col] = '*';

            int[][] direcciones = new int[][]
            {
                new int[] { 1, 1 },
                new int[] { -1, 1 },
                new int[] { -1, -1 },
                new int[] { 1, -1 }
            };

            int largo = n;
            int direccion = 0;

            while (largo > 0)
            {
                for (int lado = 0; lado < 2; lado++)
                {
                    int mover_fila = direcciones[direccion % 4][0];
                    int mover_col = direcciones[direccion % 4][1];

                    for (int paso = 0; paso < largo; paso++)
                    {
                        fila += mover_fila;
                        col += mover_col;

                        if (fila >= 0 && fila < alto && col >= 0 && col < ancho)
                        {
                            matriz[fila, col] = '*';
                        }
                    }

                    direccion++;
                }

                largo -= salto;
            }

            StringBuilder sb = new StringBuilder();
            
            sb.Append("╔").Append(new String('═', ancho + 2)).AppendLine("╗");

            for (int i = 0; i < alto; i++)
            {
                sb.Append("║ ");
                for (int j = 0; j < ancho; j++)
                {
                    sb.Append(matriz[i, j]);
                }
                sb.AppendLine(" ║");
            }

            sb.Append("╚").Append(new String('═', ancho + 2)).AppendLine("╝");

            litResultado.Text = sb.ToString();
        }
    }
}
