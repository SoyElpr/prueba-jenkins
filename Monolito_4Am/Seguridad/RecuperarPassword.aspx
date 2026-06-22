<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RecuperarPassword.aspx.cs" Inherits="Monolito_4Am.Seguridad.RecuperarPassword" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Recuperar Contraseña | MonolitoApp</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1; --accent: #06b6d4;
            --glass: rgba(30, 41, 59, 0.7); --glass-border: rgba(255, 255, 255, 0.1);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif;
            background: radial-gradient(circle at center, #1e1b4b, #0f172a);
            min-height: 100vh; display: flex; justify-content: center; align-items: center; color: #f8fafc;
        }
        .card {
            background: var(--glass); backdrop-filter: blur(20px); border: 1px solid var(--glass-border);
            padding: 40px; border-radius: 32px; width: 480px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }
        .steps { display: flex; justify-content: space-between; margin-bottom: 35px; position: relative; }
        .steps::before {
            content: ""; position: absolute; top: 15px; left: 0; width: 100%; height: 2px;
            background: rgba(255,255,255,0.1); z-index: 0;
        }
        .step {
            width: 32px; height: 32px; border-radius: 50%; background: #1e293b; border: 2px solid #334155;
            display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 700;
            position: relative; z-index: 1; transition: all 0.3s;
        }
        .step.active { background: var(--primary); border-color: var(--primary); box-shadow: 0 0 15px rgba(99,102,241,0.5); }
        .step.done { background: #22c55e; border-color: #22c55e; }

        h1 { font-size: 24px; font-weight: 800; text-align: center; margin-bottom: 8px; }
        .subtitle { font-size: 14px; color: #94a3b8; text-align: center; margin-bottom: 30px; }

        .input-group { margin-bottom: 24px; }
        .input-group label { display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; margin-bottom: 8px; color: #64748b; }
        .input-wrapper {
            background: rgba(15, 23, 42, 0.6); border: 1px solid var(--glass-border); border-radius: 14px;
            display: flex; align-items: center; padding: 0 16px;
        }
        .input-wrapper input { width: 100%; background: transparent; border: none; padding: 14px 0; color: white; font-size: 16px; outline: none; font-family: inherit; }

        .btn-primary {
            width: 100%; padding: 16px; background: linear-gradient(135deg, var(--primary), #4f46e5);
            border: none; border-radius: 14px; color: white; font-size: 15px; font-weight: 700; cursor: pointer; transition: all 0.3s;
        }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(99,102,241,0.3); }

        .wa-btn {
            display: inline-flex; align-items: center; gap: 8px; background: #25d366; color: white;
            padding: 12px 20px; border-radius: 12px; text-decoration: none; font-weight: 700; font-size: 14px; margin-top: 15px;
        }
        .msg-box { margin-top: 25px; padding: 14px; border-radius: 14px; font-size: 14px; font-weight: 600; text-align: center; }
        .error { background: rgba(239, 68, 68, 0.1); border: 1px solid #ef4444; color: #f87171; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        <div class="card">
            <div class="steps">
                <asp:Label ID="lblStep1" runat="server" CssClass="step active" Text="1" />
                <asp:Label ID="lblStep2" runat="server" CssClass="step" Text="2" />
                <asp:Label ID="lblStep3" runat="server" CssClass="step" Text="3" />
            </div>

            <h1>Recuperar Acceso</h1>
            <p class="subtitle">Sigue los pasos para restablecer tu contraseña</p>

            <asp:UpdatePanel runat="server">
                <ContentTemplate>
                    <asp:Panel ID="pnlPaso1" runat="server">
                        <div class="input-group">
                            <label>Cédula de Identidad</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtCedulaPaso1" runat="server" placeholder="1712345678" autocomplete="off" /></div>
                        </div>
                        <asp:Button ID="btnEnviarClave" runat="server" Text="Enviar Clave por WhatsApp 📱" CssClass="btn-primary" OnClick="btnEnviarClave_Click" />
                    </asp:Panel>

                    <asp:Panel ID="pnlPaso2" runat="server" Visible="false">
                        <div class="input-group">
                            <label>Clave Temporal Recibida</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtClaveTemporal" runat="server" placeholder="Ej: AB12CD34" style="text-transform:uppercase; text-align:center; letter-spacing:4px;" autocomplete="off" /></div>
                        </div>
                        <asp:Button ID="btnValidarClave" runat="server" Text="Validar Clave" CssClass="btn-primary" OnClick="btnValidarClave_Click" />
                        <div style="text-align:center">
                            <asp:HyperLink ID="hlWaMe" runat="server" CssClass="wa-btn" Target="_blank">💬 Ver clave en WhatsApp</asp:HyperLink>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlPaso3" runat="server" Visible="false">
                        <div class="input-group">
                            <label>Nueva Contraseña</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtNuevaPass" runat="server" TextMode="Password" autocomplete="new-password" /></div>
                        </div>
                        <div class="input-group">
                            <label>Confirmar Nueva Contraseña</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtConfirmarPass" runat="server" TextMode="Password" autocomplete="new-password" /></div>
                        </div>
                        <asp:Button ID="btnCambiarPass" runat="server" Text="Restablecer Contraseña" CssClass="btn-primary" OnClick="btnCambiarPass_Click" />
                    </asp:Panel>

                    <asp:Panel ID="pnlMensaje" runat="server" Visible="false">
                        <div class='msg-box <%: (pnlMensaje.CssClass ?? "").Contains("error") ? "error" : "" %>'>
                            <asp:Label ID="lblMensaje" runat="server" />
                        </div>
                    </asp:Panel>
                </ContentTemplate>
            </asp:UpdatePanel>
            
            <div style="text-align:center; margin-top:25px;">
                <a href="Login.aspx" style="color:#94a3b8; font-size:14px; text-decoration:none;">⬅ Volver al inicio</a>
            </div>
        </div>
    </form>
</body>
</html>
