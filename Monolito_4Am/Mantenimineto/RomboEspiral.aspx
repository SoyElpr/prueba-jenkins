<%@ Page Title="Rombo en Espiral" Language="C#" AutoEventWireup="true" CodeBehind="RomboEspiral.aspx.cs" Inherits="Monolito_4Am.Mantenimineto.RomboEspiral" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Rombo en Espiral Dinámico</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        :root {
            --bg-dark: #020617;
            --bg-card: rgba(15, 23, 42, 0.6);
            --primary: #6366f1;
            --primary-light: #818cf8;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --border-light: rgba(255, 255, 255, 0.08);
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
            max-width: 900px;
            margin: 40px 20px;
            padding: 40px;
            background: rgba(15, 23, 42, 0.45);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border: 1px solid var(--border-light);
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            text-align: center;
        }

        .header h1 {
            font-size: 32px;
            font-weight: 800;
            margin: 0;
            background: linear-gradient(135deg, #a78bfa, #f472b6, #fb923c);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 10px;
        }

        .info-msg {
            background: rgba(99, 102, 241, 0.1);
            border: 1px solid rgba(99, 102, 241, 0.3);
            color: var(--primary-light);
            padding: 12px 20px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 500;
            display: inline-block;
            margin-bottom: 30px;
        }

        .controls {
            display: flex;
            gap: 20px;
            justify-content: center;
            align-items: flex-end;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }

        .input-group {
            display: flex;
            flex-direction: column;
            text-align: left;
            gap: 8px;
        }

        .input-group label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .input-dark {
            padding: 12px 18px;
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid var(--border-light);
            border-radius: 12px;
            color: white;
            font-size: 15px;
            outline: none;
            transition: all 0.3s;
            font-family: 'Outfit', sans-serif;
            width: 150px;
        }

        .input-dark:focus {
            border-color: var(--primary);
            background: rgba(0, 0, 0, 0.5);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), #4f46e5);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 14px rgba(99, 102, 241, 0.3);
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 2px;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
        }

        .btn-back {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-main);
            border: 1px solid var(--border-light);
            padding: 12px 24px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 2px;
        }

        .btn-back:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
            color: white;
        }

        .result-container {
            background: rgba(0, 0, 0, 0.4);
            border: 1px solid var(--border-light);
            border-radius: 16px;
            padding: 24px;
            overflow-x: auto;
            text-align: left;
            box-shadow: inset 0 2px 10px rgba(0, 0, 0, 0.3);
            display: inline-block;
            min-width: 50%;
        }

        pre {
            margin: 0;
            font-family: 'Consolas', 'Courier New', monospace;
            font-size: 14px;
            line-height: 1.2;
            color: #38bdf8;
            font-weight: bold;
            white-space: pre;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="main-container">
            <div class="header">
                <h1><i class="fas fa-shapes"></i> Generador Dinámico de Rombo</h1>
            </div>

            <div class="info-msg">
                <i class="fas fa-info-circle"></i> 
                <strong>Recomendación:</strong> El tamaño estándar recomendado es <strong>n = 10</strong> y una separación de <strong>salto = 2</strong>.
            </div>

            <div class="controls">
                <div class="input-group">
                    <label>Tamaño (n)</label>
                    <asp:TextBox ID="txtN" runat="server" CssClass="input-dark" TextMode="Number" min="1">10</asp:TextBox>
                </div>
                
                <div class="input-group">
                    <label>Separación (salto)</label>
                    <asp:TextBox ID="txtSalto" runat="server" CssClass="input-dark" TextMode="Number" min="1">2</asp:TextBox>
                </div>

                <asp:LinkButton ID="btnGenerar" runat="server" CssClass="btn-primary" OnClick="btnGenerar_Click">
                    <i class="fas fa-magic"></i> Dibujar Rombo
                </asp:LinkButton>

                <a href="listar_tbl_producto.aspx" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Volver
                </a>
            </div>

            <asp:Label ID="lblError" runat="server" CssClass="info-msg" Visible="false" style="background: rgba(239, 68, 68, 0.1); border-color: rgba(239, 68, 68, 0.3); color: #fca5a5;"></asp:Label>

            <div class="result-container">
                <pre><asp:Literal ID="litResultado" runat="server"></asp:Literal></pre>
            </div>
        </div>
    </form>
</body>
</html>
