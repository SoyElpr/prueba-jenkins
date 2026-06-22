using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace Monolito_4Am.Juego
{
    public partial class Juego : System.Web.UI.Page
    {
        private List<int> Sequence { get { return (List<int>)Session["Seq"]; } set { Session["Seq"] = value; } }
        private int CurrentLevel { get { return (int)Session["Lvl"]; } set { Session["Lvl"] = value; } }
        private int DisplayIndex { get { return (int)Session["Idx"]; } set { Session["Idx"] = value; } }
        private int UserIndex { get { return (int)Session["UIdx"]; } set { Session["UIdx"] = value; } }
        private bool IsShowing { get { return (bool)Session["Show"]; } set { Session["Show"] = value; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usu_id"] == null) Response.Redirect("~/Seguridad/login.aspx");

            if (!IsPostBack)
            {
                ResetGame();
            }
        }

        private void ResetGame()
        {
            Sequence = new List<int>();
            CurrentLevel = 1;
            DisplayIndex = 0;
            UserIndex = 0;
            IsShowing = false;
            pnlStart.Visible = true;
            pnlMsg.Visible = false;
        }

        protected void btnStart_Click(object sender, EventArgs e)
        {
            ResetGame();
            StartNextLevel();
        }

        private void StartNextLevel()
        {
            Random rnd = new Random();
            Sequence.Add(rnd.Next(1, 10)); // Añadir paso a la secuencia
            DisplayIndex = 0;
            UserIndex = 0;
            IsShowing = true;
            pnlStart.Visible = false;
            lblStatus.Text = "OBSERVA...";
            lblScore.Text = "LVL: " + CurrentLevel;
            
            ResetButtons();
            timerSequence.Enabled = true; // Empezar a mostrar
            upGame.Update();
        }

        protected void timerSequence_Tick(object sender, EventArgs e)
        {
            ResetButtons();

            if (DisplayIndex < Sequence.Count)
            {
                int btnNum = Sequence[DisplayIndex];
                HighlightButton(btnNum);
                DisplayIndex++;
            }
            else
            {
                timerSequence.Enabled = false;
                IsShowing = false;
                lblStatus.Text = "TU TURNO";
            }
            upGame.Update();
        }

        private void HighlightButton(int num)
        {
            Button btn = (Button)upGame.FindControl("btn" + num);
            if (btn != null) {
                btn.CssClass = "grid-btn btn-" + num + " btn-active";
                PlaySound("beep");
            }
        }

        private void ResetButtons()
        {
            litSound.Text = ""; // Limpiar sonido anterior
            for (int i = 1; i <= 9; i++)
            {
                Button btn = (Button)upGame.FindControl("btn" + i);
                if (btn != null) btn.CssClass = "grid-btn btn-" + i;
            }
        }

        private void PlaySound(string type)
        {
            // Usamos un timestamp para que el navegador lo trate como un sonido nuevo cada vez
            string ticks = DateTime.Now.Ticks.ToString();
            string url = type == "beep" 
                ? "https://www.soundjay.com/buttons/button-37.mp3" 
                : "https://www.soundjay.com/buttons/button-10.mp3";
            
            litSound.Text = $"<audio src='{url}?v={ticks}' autoplay='autoplay' style='display:none;' />";
        }

        protected void Grid_Click(object sender, EventArgs e)
        {
            if (IsShowing || Sequence == null || UserIndex >= Sequence.Count) return; 

            Button btnClicked = (Button)sender;
            int num = int.Parse(btnClicked.CommandArgument);

            if (num == Sequence[UserIndex])
            {
                btnClicked.CssClass = "grid-btn btn-" + num + " btn-correct";
                PlaySound("beep");
                UserIndex++;

                if (UserIndex == Sequence.Count)
                {
                    CurrentLevel++;
                    StartNextLevel();
                }
            }
            else
            {
                btnClicked.CssClass = "grid-btn btn-" + num + " btn-wrong";
                PlaySound("error");
                GameOver();
            }
        }

        private void GameOver()
        {
            lblStatus.Text = "FALLO DE SISTEMA";
            lblMsg.Text = "NIVEL ALCANZADO: " + CurrentLevel;
            lblMsg.ForeColor = System.Drawing.Color.Red;
            pnlMsg.Visible = true;

            try
            {
                CN_Puntuacion.RegistrarPuntuacion((int)Session["usu_id"], CurrentLevel * 150, CurrentLevel);
            }
            catch { }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Dashboard/Usuario.aspx");
        }
    }
}
