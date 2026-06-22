<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Juego.aspx.cs" Inherits="Monolito_4Am.Juego.Juego" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <title>Cyber-Sequence | MonolitoApp</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #6366f1; --accent: #06b6d4; --glass: rgba(15, 23, 42, 0.9); }
        body { font-family: 'Outfit', sans-serif; background: #020617; color: white; margin: 0; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        
        .game-card { background: var(--glass); backdrop-filter: blur(20px); border: 2px solid rgba(255,255,255,0.1); border-radius: 40px; padding: 40px; width: 400px; text-align: center; box-shadow: 0 0 100px rgba(99,102,241,0.2); }
        
        .grid-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin: 30px 0; }
        .grid-btn { 
            aspect-ratio: 1; border-radius: 15px; border: 2px solid rgba(255,255,255,0.05); 
            background: rgba(255,255,255,0.02); cursor: pointer; transition: all 0.2s; 
            font-size: 0; position: relative; overflow: hidden;
        }
        
        /* Colores Individuales */
        .btn-1 { --c: #ff0055; } .btn-2 { --c: #00ff99; } .btn-3 { --c: #00ccff; }
        .btn-4 { --c: #ffcc00; } .btn-5 { --c: #ff00ff; } .btn-6 { --c: #9900ff; }
        .btn-7 { --c: #ccff00; } .btn-8 { --c: #ff6600; } .btn-9 { --c: #ffffff; }

        .grid-btn:hover { border-color: var(--c); background: rgba(255,255,255,0.05); box-shadow: inset 0 0 15px var(--c); }
        
        /* Estado Activo (Iluminado por C#) */
        .btn-active { 
            background: var(--c) !important; 
            box-shadow: 0 0 40px var(--c), inset 0 0 20px rgba(255,255,255,0.5) !important; 
            border-color: white !important;
            transform: scale(1.05);
        }

        .btn-correct { background: #10b981 !important; box-shadow: 0 0 30px #10b981 !important; }
        .btn-wrong { background: #ef4444 !important; box-shadow: 0 0 30px #ef4444 !important; }

        .stats { display: flex; justify-content: space-between; margin-bottom: 20px; font-weight: 700; color: var(--accent); letter-spacing: 1px; }
        .btn-main { background: var(--primary); color: white; border: none; padding: 15px 30px; border-radius: 12px; font-weight: 800; cursor: pointer; width: 100%; }
        .btn-back { display: block; margin-bottom: 20px; color: #64748b; text-decoration: none; font-size: 11px; font-weight: 700; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        
        <div class="game-card">
            <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn-back">← VOLVER AL PANEL</asp:LinkButton>
            
            <asp:UpdatePanel ID="upGame" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Timer ID="timerSequence" runat="server" Interval="1000" OnTick="timerSequence_Tick" Enabled="false" />
                    
                    <div class="stats">
                        <asp:Label ID="lblStatus" runat="server" Text="PROTOCOL: SEQUENCE" />
                        <asp:Label ID="lblScore" runat="server" Text="LVL: 1" />
                    </div>

                    <div class="grid-container">
                        <asp:Button ID="btn1" runat="server" CssClass="grid-btn btn-1" OnClick="Grid_Click" CommandArgument="1" />
                        <asp:Button ID="btn2" runat="server" CssClass="grid-btn btn-2" OnClick="Grid_Click" CommandArgument="2" />
                        <asp:Button ID="btn3" runat="server" CssClass="grid-btn btn-3" OnClick="Grid_Click" CommandArgument="3" />
                        <asp:Button ID="btn4" runat="server" CssClass="grid-btn btn-4" OnClick="Grid_Click" CommandArgument="4" />
                        <asp:Button ID="btn5" runat="server" CssClass="grid-btn btn-5" OnClick="Grid_Click" CommandArgument="5" />
                        <asp:Button ID="btn6" runat="server" CssClass="grid-btn btn-6" OnClick="Grid_Click" CommandArgument="6" />
                        <asp:Button ID="btn7" runat="server" CssClass="grid-btn btn-7" OnClick="Grid_Click" CommandArgument="7" />
                        <asp:Button ID="btn8" runat="server" CssClass="grid-btn btn-8" OnClick="Grid_Click" CommandArgument="8" />
                        <asp:Button ID="btn9" runat="server" CssClass="grid-btn btn-9" OnClick="Grid_Click" CommandArgument="9" />
                    </div>

                    <asp:Literal ID="litSound" runat="server" />

                    <asp:Panel ID="pnlStart" runat="server">
                        <asp:Button ID="btnStart" runat="server" Text="INICIAR SECUENCIA" OnClick="btnStart_Click" CssClass="btn-main" />
                    </asp:Panel>

                    <asp:Panel ID="pnlMsg" runat="server" Visible="false" style="margin-top:20px;">
                        <asp:Label ID="lblMsg" runat="server" style="font-weight:700;" />
                        <br /><br />
                        <asp:Button ID="btnRestart" runat="server" Text="REINTENTAR" OnClick="btnStart_Click" CssClass="btn-main" style="background:#334155" />
                    </asp:Panel>

                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>
