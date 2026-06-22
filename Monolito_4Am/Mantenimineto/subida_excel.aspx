<%@ Page Title="Importar / Exportar Productos" Language="C#" AutoEventWireup="true" CodeBehind="subida_excel.aspx.cs" Inherits="Monolito_4Am.Mantenimineto.subida_excel" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Importar y Exportar Productos</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    
    <style>
        :root {
            --bg-dark: #020617;
            --bg-card: rgba(15, 23, 42, 0.6);
            --bg-card-hover: rgba(30, 41, 59, 0.8);
            --primary: #6366f1;
            --primary-light: #818cf8;
            --secondary: #ec4899;
            --accent: #10b981;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --border-light: rgba(255, 255, 255, 0.08);
            --border-focus: rgba(99, 102, 241, 0.5);
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
            max-width: 1100px;
            margin: 40px 20px;
            padding: 40px;
            background: rgba(15, 23, 42, 0.45);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border: 1px solid var(--border-light);
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            animation: fadeIn 0.6s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* HEADER SECTION */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border-light);
            flex-wrap: wrap;
            gap: 15px;
        }

        .page-header h1 {
            font-size: 32px;
            font-weight: 800;
            margin: 0;
            background: linear-gradient(135deg, #a78bfa, #f472b6, #fb923c);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            display: flex;
            align-items: center;
            gap: 12px;
            letter-spacing: -0.5px;
        }

        .btn-modern {
            padding: 12px 24px;
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

        .btn-back {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-main);
            border: 1px solid var(--border-light);
        }

        .btn-back:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateX(-3px);
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

        .btn-success {
            background: linear-gradient(135deg, #059669, #10b981);
            color: white;
            box-shadow: 0 4px 14px rgba(16, 185, 129, 0.2);
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.3);
        }

        /* GRID LAYOUT FOR CONTENT */
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }

        @media (max-width: 850px) {
            .content-grid { grid-template-columns: 1fr; }
        }

        /* CARDS */
        .glass-card {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 18px;
            padding: 30px;
            transition: 0.3s;
        }

        .glass-card:hover {
            background: var(--bg-card-hover);
            border-color: rgba(255,255,255,0.12);
        }

        .card-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--primary-light);
            margin-top: 0;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* INFO LIST */
        .info-list {
            margin: 0;
            padding: 0;
            list-style: none;
        }

        .info-list li {
            position: relative;
            padding-left: 28px;
            margin-bottom: 14px;
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.6;
        }

        .info-list li::before {
            content: "\f058";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            position: absolute;
            left: 0;
            top: 2px;
            color: var(--secondary);
            font-size: 15px;
        }

        .info-list code {
            background: rgba(255,255,255,0.1);
            padding: 2px 6px;
            border-radius: 6px;
            font-family: 'Courier New', Courier, monospace;
            font-size: 12px;
            color: #fb923c;
        }

        /* UPLOAD ZONE */
        .upload-zone {
            border: 2px dashed rgba(99, 102, 241, 0.3);
            border-radius: 16px;
            padding: 40px 20px;
            text-align: center;
            background: rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
            position: relative;
            margin-bottom: 20px;
        }

        .upload-zone:hover {
            border-color: var(--primary-light);
            background: rgba(99, 102, 241, 0.05);
        }

        .upload-zone i.icon-upload {
            font-size: 48px;
            color: var(--primary);
            margin-bottom: 16px;
            display: block;
            filter: drop-shadow(0 0 10px rgba(99,102,241,0.4));
            transition: 0.3s;
        }

        .upload-zone:hover i.icon-upload {
            transform: scale(1.1);
        }

        .upload-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--text-main);
            margin-bottom: 8px;
        }

        .upload-subtitle {
            font-size: 13px;
            color: var(--text-muted);
            margin-bottom: 20px;
        }

        .file-input-wrapper {
            max-width: 100%;
            display: flex;
            justify-content: center;
        }

        .file-input {
            width: 100%;
            max-width: 300px;
            padding: 10px;
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--border-light);
            border-radius: 10px;
            color: var(--text-muted);
            font-size: 13px;
            outline: none;
            cursor: pointer;
        }

        .file-input::file-selector-button {
            padding: 8px 16px;
            border-radius: 6px;
            border: none;
            background: var(--primary);
            color: white;
            font-weight: 600;
            cursor: pointer;
            margin-right: 15px;
            transition: 0.3s;
            font-family: 'Outfit', sans-serif;
        }

        .file-input::file-selector-button:hover {
            background: var(--primary-light);
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }

        /* STATS CARDS */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-top: 30px;
        }

        .stat-box {
            background: rgba(0,0,0,0.2);
            border: 1px solid var(--border-light);
            border-radius: 16px;
            padding: 20px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .stat-box::before {
            content: '';
            position: absolute;
            top: 0; left: 0; width: 100%; height: 3px;
        }

        .stat-box.inserts::before { background: var(--accent); }
        .stat-box.updates::before { background: #3b82f6; }
        .stat-box.totals::before { background: var(--primary-light); }

        .stat-value {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 5px;
        }

        .stat-box.inserts .stat-value { color: var(--accent); }
        .stat-box.updates .stat-value { color: #3b82f6; }
        .stat-box.totals .stat-value { color: var(--text-main); }

        .stat-label {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* ALERTS */
        .alert {
            margin-top: 20px;
            padding: 16px 20px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: fadeIn 0.4s ease;
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            color: #34d399;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.1);
            color: #f87171;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }

        /* TABLE */
        .preview-section {
            margin-top: 40px;
        }

        .table-responsive {
            width: 100%;
            overflow-x: auto;
            border-radius: 16px;
            border: 1px solid var(--border-light);
            background: rgba(0,0,0,0.2);
            box-shadow: inset 0 2px 10px rgba(0,0,0,0.2);
        }

        .table-elegant {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .table-elegant th {
            background: rgba(15, 23, 42, 0.8);
            padding: 16px;
            text-align: left;
            font-weight: 600;
            color: var(--primary-light);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-size: 11px;
            border-bottom: 2px solid var(--border-light);
            white-space: nowrap;
        }

        .table-elegant td {
            padding: 14px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.03);
            color: var(--text-main);
            vertical-align: middle;
            white-space: nowrap;
        }

        .table-elegant tr:last-child td { border-bottom: none; }
        .table-elegant tr:hover td { background: rgba(255,255,255,0.03); }

        /* SCROLLBAR */
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.2); border-radius: 4px; }
        ::-webkit-scrollbar-thumb { background: rgba(99,102,241,0.5); border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(99,102,241,0.8); }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="main-container">
            
            <!-- HEADER -->
            <div class="page-header">
                <h1><i class="fas fa-bolt"></i> Carga Masiva de Productos</h1>
                <a href="listar_tbl_producto.aspx" class="btn-modern btn-back">
                    <i class="fas fa-arrow-left"></i> Volver al Listado
                </a>
            </div>

            <!-- DOS COLUMNAS -->
            <div class="content-grid">
                
                <!-- COLUMNA IZQUIERDA: INSTRUCCIONES -->
                <div class="glass-card">
                    <h2 class="card-title"><i class="fas fa-book-open"></i> Instrucciones de Uso</h2>
                    <ul class="info-list">
                        <li><strong>Descarga la plantilla:</strong> Ve al listado y presiona "Exportar Excel". Obtendrás un archivo <code>.xls</code> listo para editar.</li>
                        <li><strong>Estructura requerida:</strong> Mantén los encabezados originales: <code>pro_id</code>, <code>pro_codigo</code>, <code>pro_nombre</code>, etc.</li>
                        <li><strong>Actualizar registros:</strong> Si el <code>pro_id</code> ya existe en el sistema, los datos se actualizarán automáticamente.</li>
                        <li><strong>Agregar registros:</strong> Para ingresar productos nuevos, deja el <code>pro_id</code> vacío. El sistema lo creará.</li>
                        <li><strong>Datos seguros:</strong> Los productos de tu base de datos que NO estén en el Excel no serán eliminados.</li>
                        <li><strong>Orden visual:</strong> Los productos nuevos que insertes aparecerán primero en la tabla.</li>
                    </ul>
                </div>

                <!-- COLUMNA DERECHA: UPLOAD -->
                <div class="glass-card">
                    <h2 class="card-title"><i class="fas fa-cloud-upload-alt"></i> Subir Archivo</h2>
                    
                    <div class="upload-zone">
                        <i class="fas fa-file-excel icon-upload"></i>
                        <div class="upload-title">Selecciona tu archivo Excel</div>
                        <div class="upload-subtitle">Formatos admitidos: .xls (SpreadsheetML), .csv</div>
                        
                        <div class="file-input-wrapper">
                            <asp:FileUpload ID="fuArchivo" runat="server" CssClass="file-input" />
                        </div>
                    </div>

                    <div class="action-buttons">
                        <asp:LinkButton ID="btnPrevisualizar" runat="server" CssClass="btn-modern btn-primary" OnClick="btnPrevisualizar_Click">
                            <i class="fas fa-search"></i> Previsualizar
                        </asp:LinkButton>
                        
                        <asp:LinkButton ID="btnProcesar" runat="server" CssClass="btn-modern btn-success" OnClick="btnProcesar_Click">
                            <i class="fas fa-check-circle"></i> Importar Datos
                        </asp:LinkButton>
                    </div>

                    <asp:Panel ID="pnlMsg" runat="server" Visible="false">
                        <div id="msgDiv" runat="server" class="alert"></div>
                    </asp:Panel>
                </div>
            </div>

            <!-- SECCIÓN DE ESTADÍSTICAS (Oculta por defecto) -->
            <asp:Panel ID="pnlStats" runat="server" Visible="false">
                <div class="stats-container">
                    <div class="stat-box inserts">
                        <div class="stat-value"><asp:Label ID="lblNuevos" runat="server" Text="0" /></div>
                        <div class="stat-label">Filas Nuevas</div>
                    </div>
                    <div class="stat-box updates">
                        <div class="stat-value"><asp:Label ID="lblActualizar" runat="server" Text="0" /></div>
                        <div class="stat-label">A Actualizar</div>
                    </div>
                    <div class="stat-box totals">
                        <div class="stat-value"><asp:Label ID="lblTotal" runat="server" Text="0" /></div>
                        <div class="stat-label">Total en Excel</div>
                    </div>
                </div>
            </asp:Panel>

            <!-- SECCIÓN DE PREVISUALIZACIÓN (Oculta por defecto) -->
            <asp:Panel ID="pnlPreview" runat="server" Visible="false" CssClass="preview-section">
                <h2 class="card-title"><i class="fas fa-table"></i> Vista Previa de Datos</h2>
                <div class="table-responsive">
                    <asp:GridView ID="gvPreview" runat="server"
                        AutoGenerateColumns="True"
                        CssClass="table-elegant"
                        GridLines="None"
                        ShowHeaderWhenEmpty="True"
                        EmptyDataText="No hay datos para previsualizar." />
                </div>
            </asp:Panel>

        </div>
    </form>
</body>
</html>
