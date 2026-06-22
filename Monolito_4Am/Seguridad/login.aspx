<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Monolito_4Am.Seguridad.Login" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Acceso al Sistema | MonolitoApp</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1;
            --primary-hover: #4f46e5;
            --accent: #06b6d4;
            --bg: #0f172a;
            --glass: rgba(30, 41, 59, 0.7);
            --glass-border: rgba(255, 255, 255, 0.1);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif;
            background: radial-gradient(circle at top right, #1e1b4b, #0f172a);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #f8fafc;
            overflow-x: hidden;
        }

        .bg-animate {
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            z-index: -1;
            overflow: hidden;
        }
        .blob {
            position: absolute;
            width: 500px; height: 500px;
            background: linear-gradient(135deg, var(--primary), var(--accent));
            filter: blur(100px);
            border-radius: 50%;
            opacity: 0.15;
            animation: move 25s infinite alternate;
        }
        @keyframes move {
            from { transform: translate(-10%, -10%) scale(1); }
            to { transform: translate(20%, 20%) scale(1.1); }
        }

        .login-card {
            background: var(--glass);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            padding: 48px;
            border-radius: 32px;
            width: 440px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            text-align: center;
            position: relative;
            animation: fadeIn 0.8s ease-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .logo-area { margin-bottom: 35px; }
        .logo-text {
            font-size: 34px;
            font-weight: 800;
            background: linear-gradient(to right, #818cf8, #22d3ee);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 8px;
            display: block;
        }
        .subtitle { font-size: 14px; color: #94a3b8; font-weight: 300; }

        .input-group { margin-bottom: 24px; text-align: left; }
        .input-group label {
            display: block;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            margin-bottom: 10px;
            color: #64748b;
            padding-left: 4px;
        }
        .input-wrapper {
            position: relative;
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid var(--glass-border);
            border-radius: 16px;
            display: flex;
            align-items: center;
            padding: 0 16px;
            transition: all 0.3s;
        }
        .input-wrapper:focus-within {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.2);
            background: rgba(15, 23, 42, 0.8);
        }
        .input-wrapper span { font-size: 20px; margin-right: 12px; opacity: 0.6; }
        .input-wrapper input {
            width: 100%;
            background: transparent;
            border: none;
            padding: 14px 0;
            color: white;
            font-size: 16px;
            outline: none;
            font-family: inherit;
        }

        .btn-primary {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, var(--primary), var(--primary-hover));
            border: none;
            border-radius: 16px;
            color: white;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 10px 15px -3px rgba(99, 102, 241, 0.3);
            margin-top: 10px;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 20px 25px -5px rgba(99, 102, 241, 0.4);
        }

        .btn-secondary {
            width: 100%;
            padding: 14px;
            background: transparent;
            border: 1px solid var(--glass-border);
            border-radius: 16px;
            color: #cbd5e1;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            margin-top: 15px;
        }
        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.05);
            border-color: #f8fafc;
            color: white;
        }

        .divider {
            display: flex;
            align-items: center;
            margin: 30px 0;
            color: #475569;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .divider::before, .divider::after {
            content: "";
            flex: 1;
            height: 1px;
            background: var(--glass-border);
        }
        .divider span { padding: 0 15px; }

        .social-row { display: flex; gap: 12px; margin-bottom: 25px; }
        .btn-social {
            flex: 1;
            padding: 12px;
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--glass-border);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            color: #94a3b8;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-social:hover { background: rgba(255, 255, 255, 0.08); color: white; }

        .msg-box {
            margin-top: 25px;
            padding: 14px;
            border-radius: 14px;
            font-size: 14px;
            font-weight: 600;
            animation: shake 0.5s ease;
        }
        .msg-box.error { background: rgba(239, 68, 68, 0.1); border: 1px solid #ef4444; color: #f87171; }
        .msg-box:not(.error) { background: rgba(34, 197, 94, 0.1); border: 1px solid #22c55e; color: #4ade80; }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            20%, 60% { transform: translateX(-5px); }
            40%, 80% { transform: translateX(5px); }
        }
    </style>
</head>
<body>
    <div class="bg-animate"><div class="blob"></div></div>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        <div class="login-card">
            <div class="logo-area">
                <span class="logo-text">MonolitoApp</span>
                <p class="subtitle">Acceso seguro al sistema de gestión</p>
            </div>

            <asp:UpdatePanel runat="server">
                <ContentTemplate>
                    <div class="input-group">
                        <label>Cédula de Identidad</label>
                        <div class="input-wrapper">
                            <span>🪪</span>
                            <asp:TextBox ID="txtCedula" runat="server" placeholder="Ej: 1712345678" MaxLength="10" autocomplete="off" />
                        </div>
                    </div>

                    <div class="input-group">
                        <label>Contraseña</label>
                        <div class="input-wrapper">
                            <span>🔒</span>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
                        </div>
                    </div>

                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 25px;">
                        <label style="display:flex; align-items:center; gap:8px; font-size:13px; color:#94a3b8; cursor:pointer;">
                            <asp:CheckBox ID="chkRemember" runat="server" /> Recordar usuario
                        </label>
                        <a href="RecuperarPassword.aspx" style="color: var(--primary); font-size: 13px; text-decoration: none; font-weight: 600;">¿Olvidaste tu contraseña?</a>
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Entrar al Sistema" CssClass="btn-primary" OnClick="btnLogin_Click" OnClientClick="showLoader()" />
                    
                    <asp:Button ID="btnRegistrar" runat="server" Text="Crear cuenta nueva" CssClass="btn-secondary" OnClick="btnRegistrar_Click" CausesValidation="false" />

                    <asp:Panel ID="pnlMensaje" runat="server" Visible="false">
                        <asp:Label ID="lblMensaje" runat="server" />
                    </asp:Panel>
                </ContentTemplate>
            </asp:UpdatePanel>

            <div class="divider"><span>O continúa con</span></div>
            
            <div class="social-row">
                <div class="btn-social">
                    <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" width="18" /> Google
                </div>
                <div class="btn-social">
                    <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" width="18" style="filter: invert(1);" /> GitHub
                </div>
            </div>
        </div>
    </form>
    <style>
        /* Loading Overlay */
        #loading-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(15, 23, 42, 0.9); backdrop-filter: blur(8px);
            z-index: 9999; flex-direction: column; justify-content: center; align-items: center;
        }
        .spinner-pro {
            width: 60px; height: 60px; border: 4px solid var(--glass-border);
            border-top: 4px solid var(--primary); border-radius: 50%;
            animation: spin 1s linear infinite; margin-bottom: 20px;
        }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        .loading-text { font-size: 14px; font-weight: 600; letter-spacing: 2px; color: var(--primary); text-transform: uppercase; }
    </style>
    <div id="loading-overlay">
        <div class="spinner-pro"></div>
        <div class="loading-text">Verificando Credenciales...</div>
    </div>

    <script>
        function showLoader() {
            document.getElementById('loading-overlay').style.display = 'flex';
        }

        // Script para ocultar el loader después de un UpdatePanel (Partial Postback)
        if (typeof(Sys) !== 'undefined') {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function() {
                document.getElementById('loading-overlay').style.display = 'none';
            });
        }
    </script>
</body>
</html>