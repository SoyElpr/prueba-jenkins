<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Registro.aspx.cs" Inherits="Monolito_4Am.Seguridad.Registro" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Registro de Usuario | MonolitoApp</title>
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
            background: radial-gradient(circle at bottom left, #1e1b4b, #0f172a);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #f8fafc;
            padding: 40px 20px;
        }

        .reg-card {
            background: var(--glass);
            backdrop-filter: blur(25px);
            border: 1px solid var(--glass-border);
            padding: 40px;
            border-radius: 32px;
            width: 800px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            animation: fadeIn 0.8s ease-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }

        .header { margin-bottom: 30px; text-align: center; }
        .logo-text {
            font-size: 32px; font-weight: 800;
            background: linear-gradient(to right, #818cf8, #22d3ee);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }

        .input-group { margin-bottom: 20px; }
        .input-group label {
            display: block; font-size: 11px; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1px;
            margin-bottom: 8px; color: #94a3b8;
        }
        .input-wrapper {
            background: rgba(15, 23, 42, 0.5);
            border: 1px solid var(--glass-border);
            border-radius: 14px;
            padding: 0 16px;
            display: flex; align-items: center;
            transition: all 0.3s;
        }
        .input-wrapper:focus-within {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15);
        }
        .input-wrapper input, .input-wrapper select {
            width: 100%; background: transparent; border: none;
            padding: 12px 0; color: white; font-size: 15px; outline: none;
            font-family: inherit;
        }
        .input-wrapper select option { background: #1e293b; color: white; }

        .foto-section {
            grid-column: span 2;
            background: rgba(255,255,255,0.03);
            border-radius: 20px;
            padding: 24px;
            display: flex; align-items: center; gap: 30px;
            border: 1px dashed var(--glass-border);
        }
        .preview-circle {
            width: 100px; height: 100px; border-radius: 50%;
            border: 3px solid var(--primary);
            overflow: hidden; background: #0f172a;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .preview-circle img { width: 100%; height: 100%; object-fit: cover; }
        .preview-circle span { font-size: 40px; }

        .btn-primary {
            width: 100%; padding: 16px;
            background: linear-gradient(to right, var(--primary), var(--primary-hover));
            border: none; border-radius: 16px; color: white;
            font-size: 16px; font-weight: 700; cursor: pointer;
            transition: all 0.3s; margin-top: 10px;
        }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(99,102,241,0.4); }

        .btn-ghost {
            background: transparent; border: 1px solid var(--glass-border);
            color: #94a3b8; padding: 10px 20px; border-radius: 12px;
            cursor: pointer; transition: all 0.2s; font-size: 13px;
        }
        .btn-ghost:hover { background: rgba(255,255,255,0.05); color: white; border-color: white; }

        .msg-box {
            margin-top: 20px; padding: 14px; border-radius: 14px;
            font-size: 14px; font-weight: 600; text-align: center;
        }
        .msg-box.error { background: rgba(239,68,68,0.1); border: 1px solid #ef4444; color: #f87171; }
        .msg-box:not(.error) { background: rgba(34,197,94,0.1); border: 1px solid #22c55e; color: #4ade80; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        <div class="reg-card">
            <div class="header">
                <span class="logo-text">Únete a MonolitoApp</span>
                <p style="color:#94a3b8; font-size:14px; margin-top:5px;">Crea tu perfil y empieza a jugar</p>
            </div>

            <asp:UpdatePanel ID="upFoto" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div class="grid">
                        <div class="input-group">
                            <label>Cédula</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtCedula" runat="server" placeholder="1712345678" autocomplete="off" /></div>
                        </div>
                        <div class="input-group" style="opacity:0.5; cursor:not-allowed;">
                            <label>Rol de Sistema</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtRolFijo" runat="server" Text="Usuario Final" ReadOnly="true" /></div>
                        </div>
                        <div class="input-group">
                            <label>Nombres</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtNombres" runat="server" autocomplete="new-name" /></div>
                        </div>
                        <div class="input-group">
                            <label>Apellidos</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtApellidos" runat="server" autocomplete="new-surname" /></div>
                        </div>
                        <div class="input-group">
                            <label>Correo Electrónico</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtCorreo" runat="server" TextMode="Email" autocomplete="off" /></div>
                        </div>
                        <div class="input-group">
                            <label>Celular (WhatsApp)</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtCelular" runat="server" placeholder="0991234567" autocomplete="off" /></div>
                        </div>
                        <div class="input-group">
                            <label>Apodo (Nick)</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtNick" runat="server" autocomplete="off" /></div>
                        </div>
                        <div class="input-group">
                            <label>Fecha de Nacimiento</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtFechaNacimiento" runat="server" TextMode="Date" /></div>
                        </div>
                        <div class="input-group">
                            <label>Contraseña</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtContrasena" runat="server" TextMode="Password" autocomplete="new-password" /></div>
                        </div>
                        <div class="input-group">
                            <label>Confirmar Contraseña</label>
                            <div class="input-wrapper"><asp:TextBox ID="txtConfirmar" runat="server" TextMode="Password" autocomplete="new-password" /></div>
                        </div>

                        <div class="foto-section">
                            <div class="preview-circle">
                                <asp:Image ID="imgPreview" runat="server" Visible="false" />
                                <asp:Panel ID="pnlFotoPlaceholder" runat="server"><span>👤</span></asp:Panel>
                            </div>
                            <div style="flex-grow:1">
                                <p style="font-size:14px; font-weight:700; margin-bottom:8px;">Foto de Perfil</p>
                                <asp:FileUpload ID="fupFoto" runat="server" accept=".jpg,.jpeg,.png" style="color:#94a3b8; font-size:12px;" />
                                <div style="margin-top:10px;">
                                    <asp:Button ID="btnPrevisualizar" runat="server" Text="👁 Previsualizar" CssClass="btn-ghost" OnClick="btnPrevisualizar_Click" CausesValidation="false" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <asp:Button ID="btnRegistrar" runat="server" Text="Finalizar Registro" CssClass="btn-primary" OnClick="btnRegistrar_Click" style="margin-top:30px;" />
                    
                    <div style="text-align:center; margin-top:20px;">
                        <asp:LinkButton ID="btnVolver" runat="server" OnClick="btnVolver_Click" style="color:#94a3b8; font-size:14px; text-decoration:none;">¿Ya tienes cuenta? Inicia sesión</asp:LinkButton>
                    </div>

                    <asp:Panel ID="pnlMensaje" runat="server" Visible="false">
                        <asp:Label ID="lblMensaje" runat="server" />
                    </asp:Panel>
                </ContentTemplate>
                <Triggers>
                    <asp:PostBackTrigger ControlID="btnRegistrar" />
                    <asp:PostBackTrigger ControlID="btnPrevisualizar" />
                </Triggers>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>