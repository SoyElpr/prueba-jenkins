<%@ Page Title="Gestión de Proveedores" Language="C#" AutoEventWireup="true" CodeBehind="listar_tbl_proveedor.aspx.cs" Inherits="Monolito_4Am.Mantenimineto.listar_tbl_proveedor" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Gestión de Proveedores</title>

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
            max-width: 1100px;
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
            flex-wrap: wrap;
            gap: 20px;
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
        }

        .nav-buttons {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn-modern {
            padding: 10px 18px;
            border-radius: 12px;
            font-size: 13px;
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
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        /* TABLE */
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
            font-size: 14px;
        }

        .table-elegant th {
            background: rgba(15, 23, 42, 0.8);
            padding: 18px;
            text-align: left;
            font-weight: 600;
            color: var(--primary-light);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-size: 12px;
            border-bottom: 2px solid var(--border-light);
        }

        .table-elegant td {
            padding: 16px 18px;
            border-bottom: 1px solid rgba(255,255,255,0.03);
            color: var(--text-main);
            vertical-align: middle;
        }

        .table-elegant tr:last-child td { border-bottom: none; }
        .table-elegant tr:hover td { background: rgba(255,255,255,0.03); }

        /* ACTIONS */
        .btn-text-action {
            color: #38bdf8;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 13px;
            text-decoration: none;
            margin-right: 15px;
            font-weight: 600;
            transition: 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-text-action:hover { color: #bae6fd; text-decoration: underline; }
        .btn-text-danger { color: #f87171; }
        .btn-text-danger:hover { color: #fca5a5; }

        /* PAGER */
        .pager-style td { padding: 15px 5px; }
        .pager-style a, .pager-style span {
            display: inline-block;
            padding: 8px 14px;
            border-radius: 8px;
            margin: 0 4px;
            text-decoration: none;
            font-weight: 600;
            font-size: 13px;
            transition: 0.2s;
        }
        .pager-style a { background: rgba(255, 255, 255, 0.05); color: var(--text-muted); border: 1px solid var(--border-light); }
        .pager-style a:hover { background: rgba(99, 102, 241, 0.2); color: white; border-color: var(--primary); }
        .pager-style span { background: var(--primary); color: white; border: 1px solid var(--primary); }

        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.2); border-radius: 4px; }
        ::-webkit-scrollbar-thumb { background: rgba(99,102,241,0.5); border-radius: 4px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="main-container">
            <div class="page-header">
                <h1><i class="fas fa-truck-loading"></i> Gestión de Proveedores</h1>
                <div class="nav-buttons">
                    <a href="listar_tbl_producto.aspx" class="btn-modern btn-secondary">
                        <i class="fas fa-cubes"></i> Catálogo Productos
                    </a>
                    <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn-modern btn-primary" OnClick="btnNuevo_Click">
                        <i class="fas fa-plus"></i> Nuevo Proveedor
                    </asp:LinkButton>
                </div>
            </div>

            <div class="glass-card">
                <div class="table-responsive">
                    <asp:GridView ID="gvProveedores" runat="server" 
                        AutoGenerateColumns="False" 
                        CssClass="table-elegant" 
                        GridLines="None"
                        DataKeyNames="Prov_id" 
                        AllowPaging="True" 
                        PageSize="8" 
                        OnPageIndexChanging="gvProveedores_PageIndexChanging"
                        OnRowCommand="gvProveedores_RowCommand">
                        
                        <PagerStyle CssClass="pager-style" HorizontalAlign="Center" />
                        
                        <Columns>
                            <asp:BoundField DataField="Prov_id" HeaderText="ID">
                                <HeaderStyle Width="15%" />
                            </asp:BoundField>
                            <asp:BoundField DataField="Prov_nombre" HeaderText="Nombre del Proveedor">
                                <HeaderStyle Width="55%" />
                                <ItemStyle Font-Bold="true" />
                            </asp:BoundField>
                            
                            <asp:TemplateField HeaderText="Acciones">
                                <HeaderStyle Width="30%" />
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEditar" runat="server" 
                                        CssClass="btn-text-action" 
                                        CommandName="Editar" 
                                        CommandArgument='<%# Eval("Prov_id") %>'>
                                        <i class="fas fa-edit"></i> Editar
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnEliminar" runat="server" 
                                        CssClass="btn-text-action btn-text-danger" 
                                        CommandName="Eliminar" 
                                        CommandArgument='<%# Eval("Prov_id") %>' 
                                        OnClientClick="return confirm('¿Eliminar este proveedor de forma permanente?');">
                                        <i class="fas fa-trash"></i> Eliminar
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
