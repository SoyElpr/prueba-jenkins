<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Usuario.aspx.cs" Inherits="Monolito_4Am.Dashboard.Usuario" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Panel de Usuario | MonolitoApp</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1; --accent: #06b6d4;
            --glass: rgba(30, 41, 59, 0.7); --glass-border: rgba(255, 255, 255, 0.1);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif;
            background: #0f172a; color: #f8fafc;
            background-image: radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%), 
                              radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%), 
                              radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
            min-height: 100vh;
        }

        .navbar {
            background: rgba(15, 23, 42, 0.8); backdrop-filter: blur(10px);
            padding: 20px 40px; display: flex; justify-content: space-between; align-items: center;
            border-bottom: 1px solid var(--glass-border); position: sticky; top: 0; z-index: 100;
        }
        .nav-logo { font-size: 24px; font-weight: 800; color: white; text-decoration: none; }
        .nav-user { display: flex; align-items: center; gap: 15px; }
        .avatar-sm { width: 40px; height: 40px; border-radius: 50%; border: 2px solid var(--primary); object-fit: cover; }

        .container { max-width: 1200px; margin: 40px auto; padding: 0 20px; display: grid; grid-template-columns: 1fr 350px; gap: 40px; }

        .main-card {
            background: var(--glass); backdrop-filter: blur(20px); border: 1px solid var(--glass-border);
            border-radius: 32px; padding: 40px; box-shadow: 0 20px 50px rgba(0,0,0,0.3);
        }

        .welcome-hero { margin-bottom: 40px; }
        .welcome-hero h1 { font-size: 42px; font-weight: 800; margin-bottom: 10px; }
        .welcome-hero p { color: #94a3b8; font-size: 18px; }

        .action-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 40px; }
        .action-btn {
            background: rgba(255,255,255,0.05); border: 1px solid var(--glass-border);
            padding: 30px; border-radius: 24px; text-decoration: none; color: white;
            transition: all 0.3s; display: flex; flex-direction: column; gap: 15px;
        }
        .action-btn:hover { background: rgba(99,102,241,0.1); border-color: var(--primary); transform: translateY(-5px); }
        .action-btn .icon { font-size: 40px; }
        .action-btn h3 { font-size: 20px; font-weight: 700; }

        .sidebar-card {
            background: rgba(15, 23, 42, 0.4); border: 1px solid var(--glass-border);
            border-radius: 24px; padding: 25px; margin-bottom: 25px;
        }
        .sidebar-card h2 { font-size: 18px; margin-bottom: 20px; color: var(--accent); }

        .leaderboard-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 12px 0; border-bottom: 1px solid rgba(255,255,255,0.05);
        }
        .rank { font-weight: 800; color: #64748b; width: 30px; }

        /* Profile Modal Style */
        .profile-section {
            position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
            width: 500px; background: #1e293b; border: 1px solid var(--primary);
            border-radius: 32px; padding: 40px; z-index: 1000; box-shadow: 0 0 100px rgba(0,0,0,0.8);
        }
        .avatar-lg { width: 120px; height: 120px; border-radius: 50%; border: 4px solid var(--primary); display: block; margin: 0 auto 20px; object-fit: cover; }
        
        .btn-update {
            width: 100%; padding: 14px; background: var(--primary); border: none; border-radius: 12px;
            color: white; font-weight: 700; cursor: pointer; margin-top: 20px;
        }
        .msg-ok { color: #4ade80; font-size: 13px; text-align: center; margin-top: 10px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        
        <nav class="navbar">
            <a href="#" class="nav-logo">MonolitoApp</a>
            <div class="nav-user">
                <span style="font-weight:600;"><asp:Label ID="lblUserNick" runat="server" /></span>
                <asp:Image ID="imgAvatar" runat="server" CssClass="avatar-sm" />
                <asp:LinkButton ID="btnCerrarSesion" runat="server" OnClick="btnCerrarSesion_Click" style="color:#ef4444; font-size:13px; text-decoration:none; font-weight:700;">SALIR</asp:LinkButton>
            </div>
        </nav>

        <div class="container">
            <div class="main-content">
                <div class="main-card">
                    <div class="welcome-hero">
                        <h1>Hola, <asp:Label ID="lblNombres" runat="server" /> 👋</h1>
                        <p>¿Listo para superar tu récord hoy?</p>
                    </div>

                    <div class="action-grid">
                        <asp:HyperLink ID="lnkJuego" runat="server" NavigateUrl="~/Juego/Juego.aspx" CssClass="action-btn">
                            <span class="icon">🎮</span>
                            <div>
                                <h3>Jugar Ahora</h3>
                                <p style="font-size:13px; opacity:0.6;">Descifra el código secreto</p>
                            </div>
                        </asp:HyperLink>
                        
                        <a href="javascript:void(0)" onclick="togglePerfil()" class="action-btn">
                            <span class="icon">👤</span>
                            <div>
                                <h3>Mi Perfil</h3>
                                <p style="font-size:13px; opacity:0.6;">Gestiona tu cuenta y foto</p>
                            </div>
                        </a>
                    </div>

                    <div class="sidebar-card">
                        <h2>🏅 Ranking Global (Top 10)</h2>
                        <asp:Repeater ID="rptLeaderboard" runat="server">
                            <ItemTemplate>
                                <div class="leaderboard-row">
                                    <span class="rank">#<%# Container.ItemIndex + 1 %></span>
                                    <span style="flex:1; font-weight:600;"><%# Eval("usu_nick") %></span>
                                    <span style="color:var(--accent); font-weight:800;"><%# Eval("punt_valor") %> pts</span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>

            <div class="sidebar">
                <div class="sidebar-card">
                    <h2>🕒 Tus Últimos Juegos</h2>
                    <asp:Repeater ID="rptMisPuntajes" runat="server">
                        <ItemTemplate>
                            <div class="leaderboard-row" style="font-size:13px;">
                                <span><%# Eval("punt_fecha", "{0:dd/MM}") %></span>
                                <span style="font-weight:700;"><%# Eval("punt_valor") %> pts</span>
                                <span style="color:#94a3b8;"><%# Eval("punt_rondas") %> rds</span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>

        <!-- SECCIÓN PERFIL (MODAL) -->
        <asp:UpdatePanel ID="upPerfil" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <div class="profile-section" id="secPerfil" runat="server" style="display:none;">
                    <div style="text-align:right"><button type="button" onclick="togglePerfil()" style="background:none; border:none; color:#64748b; cursor:pointer; font-size:20px;">✕</button></div>
                    <h2 style="text-align:center; margin-bottom:20px;">Tu Perfil</h2>
                    <asp:Image ID="imgFotoPerfil" runat="server" CssClass="avatar-lg" />
                    
                    <div style="background:rgba(0,0,0,0.2); padding:20px; border-radius:16px; margin-bottom:20px;">
                        <p style="font-size:12px; color:#64748b; text-transform:uppercase; font-weight:700;">Cambiar Foto de Perfil</p>
                        <asp:FileUpload ID="fupNuevoFoto" runat="server" accept=".jpg,.jpeg,.png" style="margin-top:10px; font-size:12px;" />
                        <div style="display:flex; gap:10px; margin-top:15px;">
                            <asp:Button ID="btnPrevNuevoFoto" runat="server" Text="👁 Previsualizar" CssClass="btn-update" style="background:#334155; margin-top:0;" OnClick="btnPrevNuevoFoto_Click" CausesValidation="false" />
                            <asp:Button ID="btnSubirFoto" runat="server" Text="💾 Guardar Foto" CssClass="btn-update" style="margin-top:0;" OnClick="btnSubirFoto_Click" CausesValidation="false" />
                        </div>
                        <asp:Image ID="imgNuevoFotoPreview" runat="server" style="width:60px; height:60px; border-radius:50%; margin-top:15px; display:block; margin: 15px auto 0;" Visible="false" />
                    </div>

                    <div style="background:rgba(0,0,0,0.2); padding:20px; border-radius:16px;">
                        <p style="font-size:12px; color:#64748b; text-transform:uppercase; font-weight:700; margin-bottom:10px;">Mi Galería de Fotos</p>
                        
                        <div style="display:flex; flex-wrap:wrap; gap:8px; margin-bottom:15px;">
                            <asp:Repeater ID="rptGaleria" runat="server">
                                <ItemTemplate>
                                    <div style="position:relative; width:60px; height:60px;">
                                        <img src='<%# "../Handlers/FotoHandler.ashx?foto_id=" + Eval("foto_id") %>' style="width:100%; height:100%; object-fit:cover; border-radius:8px; border:1px solid rgba(255,255,255,0.1);" />
                                        <asp:LinkButton runat="server" CommandArgument='<%# Eval("foto_id") %>' OnClick="btnEliminarFoto_Click" style="position:absolute; top:-5px; right:-5px; background:#ef4444; color:white; border-radius:50%; width:18px; height:18px; font-size:10px; text-align:center; text-decoration:none; line-height:18px;">✕</asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <p style="font-size:11px; color:#94a3b8; margin-bottom:5px;">Añadir fotos a la galería (Puedes seleccionar varias):</p>
                        <asp:FileUpload ID="fupGaleria" runat="server" AllowMultiple="true" accept=".jpg,.jpeg,.png" style="font-size:11px; color:var(--accent);" />
                        <asp:Button ID="btnSubirGaleria" runat="server" Text="🚀 SUBIR A MI GALERÍA" CssClass="btn-update" style="background:linear-gradient(to right, #06b6d4, #3b82f6); font-size:12px; padding:10px; border:none; margin-top:10px;" OnClick="btnSubirGaleria_Click" CausesValidation="false" />
                    </div>

                    <asp:Panel ID="pnlMsgPerfil" runat="server" Visible="false">
                        <div class="msg-ok"><asp:Label ID="lblMsgPerfil" runat="server" /></div>
                    </asp:Panel>
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="btnSubirFoto" />
                <asp:PostBackTrigger ControlID="btnPrevNuevoFoto" />
                <asp:PostBackTrigger ControlID="btnSubirGaleria" />
            </Triggers>
        </asp:UpdatePanel>

    </form>

    <script>
        function togglePerfil() {
            var s = document.getElementById('<%= secPerfil.ClientID %>');
            s.style.display = (s.style.display === 'none' || s.style.display === '') ? 'block' : 'none';
        }
    </script>
</body>
</html>
