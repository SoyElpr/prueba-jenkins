<%@ Page Title="Nuevo / Editar Proveedor" Language="C#" AutoEventWireup="true" CodeBehind="nuevo_tbl_proveedor.aspx.cs" Inherits="Monolito_4Am.Mantenimineto.nuevo_tbl_proveedor" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Nuevo / Editar Proveedor</title>

    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        :root {
            --bg-dark: #020617;
            --bg-card: rgba(15, 23, 42, 0.6);
            --primary: #6366f1;
            --primary-light: #818cf8;
            --secondary: #ec4899;
            --accent: #10b981;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --border-light: rgba(255, 255, 255, 0.08);
            --border-focus: rgba(99, 102, 241, 0.5);
            --danger: #ef4444;
        }

        body {
            margin: 0;
            padding: 0;
            font-family: 'Outfit', sans-serif;
            background: radial-gradient(circle at top, #1e1b4b 0%, var(--bg-dark) 40%, var(--bg-dark) 100%);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .main-container {
            width: 100%;
            max-width: 600px;
            margin: 40px 20px;
            padding: 40px;
            background: rgba(15, 23, 42, 0.45);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border: 1px solid var(--border-light);
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }

        /* HEADER */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border-light);
        }

        .page-header h1 {
            font-size: 28px;
            font-weight: 800;
            margin: 0;
            background: linear-gradient(135deg, #a78bfa, #f472b6, #fb923c);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-modern {
            padding: 12px 20px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            border: none;
            outline: none;
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-main);
            border: 1px solid var(--border-light);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
            color: white;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), #4f46e5);
            color: white;
            box-shadow: 0 4px 14px rgba(99, 102, 241, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
        }

        .glass-card {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 18px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .form-group {
            margin-bottom: 24px;
        }

        .form-group label {
            display:block;
            margin-bottom: 8px;
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .input-dark {
            width: 100%;
            box-sizing: border-box;
            padding: 14px 16px;
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid var(--border-light);
            border-radius: 10px;
            color: white;
            font-size: 14px;
            outline: none;
            transition: all 0.3s;
            font-family: 'Outfit', sans-serif;
        }

        .input-dark:focus {
            border-color: var(--primary);
            background: rgba(15, 23, 42, 0.8);
            box-shadow: 0 0 0 3px var(--border-focus);
        }

        .actions-bar {
            display: flex;
            justify-content: flex-end;
            margin-top: 30px;
        }

        /* MESSAGES */
        .msg-box {
            padding: 14px 18px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .msg-box.error {
            background: rgba(239, 68, 68, 0.15);
            border: 1px solid rgba(239, 68, 68, 0.3);
            color: #fca5a5;
        }

        .msg-box.success {
            background: rgba(16, 185, 129, 0.15);
            border: 1px solid rgba(16, 185, 129, 0.3);
            color: #a7f3d0;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="main-container">
            <div class="page-header">
                <h1><i class="fas fa-truck-loading"></i> <span id="lblTitle" runat="server">Nuevo Proveedor</span></h1>
                <asp:LinkButton ID="btnBack" runat="server" CssClass="btn-modern btn-secondary" OnClick="btnBack_Click">
                    <i class="fas fa-arrow-left"></i> Volver
                </asp:LinkButton>
            </div>

            <asp:Panel ID="pnlMensaje" runat="server" Visible="false">
                <div id="lblMensaje" runat="server" class="msg-box"></div>
            </asp:Panel>

            <div class="glass-card">
                <asp:Panel ID="pnlForm" runat="server">
                    <div class="form-group">
                        <label for="txtNombre">Nombre del Proveedor</label>
                        <asp:TextBox ID="txtNombre" runat="server" CssClass="input-dark" MaxLength="100" placeholder="Ej: Distribuidora XYZ"></asp:TextBox>
                    </div>
                    
                    <div class="form-group">
                        <label for="txtTelefono">Teléfono (Opcional)</label>
                        <asp:TextBox ID="txtTelefono" runat="server" CssClass="input-dark" MaxLength="20" placeholder="+1 555 1234"></asp:TextBox>
                    </div>
                    
                    <div class="form-group">
                        <label for="txtEmail">Email (Opcional)</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="input-dark" MaxLength="120" placeholder="proveedor@ejemplo.com"></asp:TextBox>
                    </div>

                    <div class="actions-bar">
                        <asp:LinkButton ID="btnGuardar" runat="server" CssClass="btn-modern btn-primary" OnClick="btnGuardar_Click">
                            <i class="fas fa-save"></i> Guardar Proveedor
                        </asp:LinkButton>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </form>
</body>
</html>
