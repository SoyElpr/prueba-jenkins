<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VerificarOTP.aspx.cs" Inherits="Monolito_4Am.Seguridad.VerificarOTP" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Seguridad OTP | MonolitoApp</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1;
            --accent: #06b6d4;
            --glass: rgba(30, 41, 59, 0.7);
            --glass-border: rgba(255, 255, 255, 0.1);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif;
            background: radial-gradient(circle at top, #1e1b4b, #0f172a);
            min-height: 100vh;
            display: flex; justify-content: center; align-items: center;
            color: #f8fafc;
        }

        .otp-card {
            background: var(--glass);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            padding: 40px; border-radius: 32px;
            width: 460px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            text-align: center;
        }

        .icon-shield {
            width: 80px; height: 80px; background: rgba(99, 102, 241, 0.1);
            border-radius: 20px; display: flex; align-items: center; justify-content: center;
            margin: 0 auto 24px; font-size: 40px; border: 1px solid rgba(99, 102, 241, 0.2);
        }

        h1 { font-size: 24px; font-weight: 800; margin-bottom: 8px; }
        .subtitle { font-size: 14px; color: #94a3b8; margin-bottom: 30px; line-height: 1.5; }

        .scan-area {
            background: rgba(15, 23, 42, 0.5);
            border: 2px dashed var(--glass-border);
            border-radius: 24px; padding: 30px;
            margin-bottom: 24px; transition: all 0.3s;
        }
        .scan-area:hover { border-color: var(--primary); background: rgba(15, 23, 42, 0.7); }

        .btn-scan {
            background: linear-gradient(135deg, var(--primary), #4f46e5);
            border: none; border-radius: 16px; color: white;
            padding: 16px 24px; font-size: 15px; font-weight: 700;
            cursor: pointer; width: 100%; transition: all 0.3s;
            display: flex; align-items: center; justify-content: center; gap: 10px;
        }
        .btn-scan:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(99, 102, 241, 0.3); }

        .scanner-window {
            display: none; margin-top: 20px; border-radius: 16px;
            overflow: hidden; border: 1px solid var(--primary);
        }
        #reader { width: 100%; background: black; }

        .btn-outline {
            background: transparent; border: 1px solid var(--glass-border);
            border-radius: 12px; color: #94a3b8; padding: 12px;
            font-size: 13px; font-weight: 600; cursor: pointer;
            transition: all 0.2s; flex: 1;
        }
        .btn-outline:hover { background: rgba(255,255,255,0.05); color: white; border-color: white; }

        .msg-box {
            margin-top: 24px; padding: 14px; border-radius: 14px;
            font-size: 14px; font-weight: 600;
        }
        .error { background: rgba(239, 68, 68, 0.1); border: 1px solid #ef4444; color: #f87171; }
        .success { background: rgba(34, 197, 94, 0.1); border: 1px solid #22c55e; color: #4ade80; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        <div class="otp-card">
            <div class="icon-shield">🛡️</div>
            <h1>Verificación de Seguridad</h1>
            <p class="subtitle">
                Para proteger tu cuenta, hemos enviado un código QR a <br />
                <strong style="color:white;"><asp:Label ID="lblCorreoDestino" runat="server" /></strong>
            </p>

            <asp:UpdatePanel runat="server">
                <ContentTemplate>
                    <div class="scan-area">
                        <button type="button" id="btnStartScan" class="btn-scan" onclick="startScanner()" style="margin-bottom:15px;">
                            📷 ESCANEAR CÓDIGO QR
                        </button>
                        
                        <div id="scannerArea" class="scanner-window">
                            <div id="reader"></div>
                        </div>

                        <div style="margin:20px 0; display:flex; align-items:center; gap:10px;">
                            <div style="flex:1; height:1px; background:var(--glass-border);"></div>
                            <span style="font-size:12px; color:#64748b; font-weight:800;">O INGRESA EL CÓDIGO</span>
                            <div style="flex:1; height:1px; background:var(--glass-border);"></div>
                        </div>

                        <asp:TextBox ID="txtOTP" runat="server" placeholder="000000" MaxLength="6" autocomplete="off"
                            style="background:rgba(0,0,0,0.3); border:2px solid var(--glass-border); border-radius:16px; padding:15px; width:100%; color:var(--accent); font-size:32px; text-align:center; letter-spacing:10px; font-weight:800; outline:none; margin-bottom:15px;" 
                            ClientIDMode="Static" />

                        <asp:Button ID="btnVerificar" runat="server" Text="✅ VERIFICAR CÓDIGO" OnClick="btnVerificar_Click" CssClass="btn-scan" style="background:var(--accent);" />
                    </div>

                    <div style="display:flex; gap:12px;">
                        <asp:Button ID="btnReenviar" runat="server" Text="📩 Reenviar Correo" CssClass="btn-outline" OnClick="btnReenviar_Click" />
                        <asp:Button ID="btnCancelar" runat="server" Text="Salir" CssClass="btn-outline" OnClick="btnCancelar_Click" />
                    </div>

                    <asp:Panel ID="pnlMensaje" runat="server" Visible="false">
                        <div class='msg-box <%: (pnlMensaje.CssClass ?? "").Contains("error") ? "error" : "success" %>'>
                            <asp:Label ID="lblMensaje" runat="server" />
                        </div>
                    </asp:Panel>

                    <!-- Hidden components -->
                    <asp:HiddenField ID="hfSecretNuevo" runat="server"/>
                    <asp:Panel ID="pnlConfigurar" runat="server" Visible="false"></asp:Panel>
                    <asp:Panel ID="pnlVerificar" runat="server" Visible="false"></asp:Panel>
                    <asp:Image ID="imgQR" runat="server" Visible="false" />
                    <asp:Label ID="lblSecretVisible" runat="server" Visible="false" />
                    <asp:Label ID="lblNombreUsuario" runat="server" Visible="false" />
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>

    <script src="https://unpkg.com/html5-qrcode"></script>
    <script>
        let html5QrCode;
        function startScanner() {
            const scannerDiv = document.getElementById('scannerArea');
            const btn = document.getElementById('btnStartScan');
            if (scannerDiv.style.display === 'block') { stopScanner(); return; }
            scannerDiv.style.display = 'block';
            btn.innerHTML = "❌ DETENER CÁMARA";
            html5QrCode = new Html5Qrcode("reader");
            html5QrCode.start({ facingMode: "user" }, { fps: 10, qrbox: 250 }, (text) => {
                document.getElementById('txtOTP').value = text.trim();
                document.getElementById('btnVerificar').click();
                stopScanner();
            }).catch(err => {
                alert("Error de cámara: " + err);
                stopScanner();
            });
        }
        function stopScanner() {
            const scannerDiv = document.getElementById('scannerArea');
            const btn = document.getElementById('btnStartScan');
            scannerDiv.style.display = 'none';
            btn.innerHTML = "📷 ESCANEAR CÓDIGO QR";
            if (html5QrCode) html5QrCode.stop();
        }
    </script>
</body>
</html>
