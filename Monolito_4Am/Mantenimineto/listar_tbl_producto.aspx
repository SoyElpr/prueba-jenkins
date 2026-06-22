<%@ Page Title="Gestión de Productos" Language="C#" AutoEventWireup="true" CodeBehind="listar_tbl_producto.aspx.cs" Inherits="Monolito_4Am.Mantenimineto.listar_tbl_producto" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Catálogo de Productos</title>

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
            max-width: 1300px;
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

        /* SEARCH SECTION */
        .glass-card {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 18px;
            padding: 24px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .search-container {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
        }

        .search-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .search-group label {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .input-dark {
            padding: 12px 15px;
            background: rgba(0, 0, 0, 0.3);
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
            background: rgba(0, 0, 0, 0.5);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
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
        }

        .table-elegant tr:last-child td { border-bottom: none; }
        .table-elegant tr:hover td { background: rgba(255,255,255,0.03); }

        /* PHOTOS */
        .photo-strip {
            display: flex;
            gap: 5px;
            align-items: center;
        }

        .photo-thumb {
            width: 42px;
            height: 42px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.1);
            cursor: pointer;
            transition: 0.3s;
        }

        .photo-thumb:hover {
            border-color: var(--primary-light);
            transform: scale(1.15);
            box-shadow: 0 4px 12px rgba(99,102,241,0.4);
            z-index: 2;
            position: relative;
        }

        .photo-count-badge {
            background: rgba(99, 102, 241, 0.2);
            border: 1px solid rgba(99, 102, 241, 0.3);
            color: var(--primary-light);
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 8px;
            cursor: pointer;
            transition: 0.2s;
        }

        .photo-count-badge:hover {
            background: rgba(99, 102, 241, 0.4);
        }

        /* ACTIONS */
        .btn-text-action {
            color: #38bdf8;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 13px;
            text-decoration: none;
            margin-right: 12px;
            font-weight: 600;
            transition: 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .btn-text-action:hover {
            color: #bae6fd;
            text-decoration: underline;
        }

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
        .pager-style a {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-muted);
            border: 1px solid var(--border-light);
        }
        .pager-style a:hover {
            background: rgba(99, 102, 241, 0.2);
            color: white;
            border-color: var(--primary);
        }
        .pager-style span {
            background: var(--primary);
            color: white;
            border: 1px solid var(--primary);
        }

        /* MODAL */
        #photoModal {
            display: none; position: fixed; inset: 0; background: rgba(0, 0, 0, 0.9); z-index: 9999;
            align-items: center; justify-content: center; flex-direction: column; gap: 16px; backdrop-filter: blur(5px);
        }
        #photoModal.open { display: flex; animation: fadeIn 0.3s ease; }
        #photoModal .modal-close {
            position: absolute; top: 20px; right: 30px; color: white; font-size: 32px; cursor: pointer;
            background: rgba(255,255,255,0.1); border-radius: 50%; width: 44px; height: 44px;
            display: flex; align-items: center; justify-content: center; transition: 0.2s; border: none;
        }
        #photoModal .modal-close:hover { background: rgba(239, 68, 68, 0.6); }
        #photoModal .modal-img-wrap { position: relative; max-width: 90vw; max-height: 70vh; display: flex; align-items: center; justify-content: center; }
        #photoModal .modal-img-wrap img { max-width: 90vw; max-height: 70vh; border-radius: 12px; box-shadow: 0 20px 60px rgba(0,0,0,0.8); object-fit: contain; }
        #photoModal .modal-nav {
            position: absolute; top: 50%; transform: translateY(-50%); background: rgba(0,0,0,0.6); color: white; border: 1px solid rgba(255,255,255,0.1);
            border-radius: 50%; width: 44px; height: 44px; font-size: 20px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s;
        }
        #photoModal .modal-nav:hover { background: var(--primary); border-color: var(--primary-light); }
        #photoModal .modal-nav.prev { left: -60px; }
        #photoModal .modal-nav.next { right: -60px; }
        #photoModal .modal-strip { display: flex; gap: 10px; flex-wrap: wrap; justify-content: center; max-width: 90vw; }
        #photoModal .modal-strip img {
            width: 60px; height: 60px; object-fit: cover; border-radius: 8px; border: 2px solid rgba(255,255,255,0.1); cursor: pointer; transition: 0.2s; opacity: 0.6;
        }
        #photoModal .modal-strip img.active, #photoModal .modal-strip img:hover { border-color: var(--primary-light); opacity: 1; }

        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.2); border-radius: 4px; }
        ::-webkit-scrollbar-thumb { background: rgba(99,102,241,0.5); border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(99,102,241,0.8); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        
        <div class="main-container">
            <!-- Título y Botones de Navegación -->
            <div class="page-header">
                <h1><i class="fas fa-cubes"></i> Catálogo de Productos</h1>
                <div class="nav-buttons">
                    <a href="listar_tbl_proveedor.aspx" class="btn-modern btn-secondary">
                        <i class="fas fa-truck-loading"></i> Proveedores
                    </a>
                    <asp:LinkButton ID="btnExportarExcel" runat="server" CssClass="btn-modern btn-secondary" OnClick="btnExportarExcel_Click" ToolTip="Exportar base completa a Excel">
                        <i class="fas fa-file-excel"></i> Exportar
                    </asp:LinkButton>
                    <a href="subida_excel.aspx" class="btn-modern btn-secondary">
                        <i class="fas fa-cloud-upload-alt"></i> Importar
                    </a>
                    <a href="estadisticas_producto.aspx" class="btn-modern btn-secondary">
                        <i class="fas fa-chart-pie"></i> Estadísticas
                    </a>
                    <a href="RomboEspiral.aspx" class="btn-modern btn-secondary">
                        <i class="fas fa-shapes"></i> Rombo
                    </a>
                    <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn-modern btn-primary" OnClick="btnNuevo_Click">
                        <i class="fas fa-plus"></i> Nuevo Producto
                    </asp:LinkButton>
                </div>
            </div>

            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                <ContentTemplate>
                    <div class="glass-card">
                        <!-- Buscador Moderno -->
                        <div class="search-container">
                            <div class="search-group" style="width: 180px;">
                                <label>Filtro</label>
                                <asp:DropDownList ID="ddlFiltro" runat="server" CssClass="input-dark" AutoPostBack="True" OnSelectedIndexChanged="ddlFiltro_SelectedIndexChanged">
                                    <asp:ListItem Text="Nombre" Value="nombre"></asp:ListItem>
                                    <asp:ListItem Text="ID Interno" Value="id"></asp:ListItem>
                                    <asp:ListItem Text="Proveedor" Value="proveedor"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="search-group" style="flex-grow: 1;">
                                <label>Término de búsqueda</label>
                                <asp:TextBox ID="txtBuscar" runat="server" CssClass="input-dark" Placeholder="Escribe aquí para buscar instantáneamente..." AutoPostBack="True" OnTextChanged="txtBuscar_TextChanged"></asp:TextBox>
                            </div>

                            <asp:LinkButton ID="btnBuscar" runat="server" CssClass="btn-modern btn-primary" OnClick="btnBuscar_Click" style="margin-bottom: 2px;">
                                <i class="fas fa-search"></i> Buscar
                            </asp:LinkButton>

                            <asp:LinkButton ID="btnLimpiar" runat="server" CssClass="btn-modern btn-secondary" OnClick="btnLimpiar_Click" ToolTip="Limpiar Filtros" style="margin-bottom: 2px;">
                                <i class="fas fa-sync-alt"></i>
                            </asp:LinkButton>
                        </div>

                        <!-- Mensajes Informativos -->
                        <div style="margin-bottom: 15px; margin-top: 5px;">
                            <asp:Label ID="lblInfo" runat="server" style="color: var(--accent); font-size: 13px; font-weight: 600;" />
                        </div>

                        <!-- Tabla de Datos -->
                        <div class="table-responsive">
                            <asp:GridView ID="gvProductos" runat="server"
                                AutoGenerateColumns="False"
                                CssClass="table-elegant"
                                GridLines="None"
                                ShowHeaderWhenEmpty="True"
                                EmptyDataText="No hay productos registrados en el inventario."
                                DataKeyNames="pro_id"
                                AllowPaging="True"
                                PageSize="5"
                                OnPageIndexChanging="gvProductos_PageIndexChanging"
                                OnRowCommand="gvProductos_RowCommand">

                                <PagerStyle CssClass="pager-style" HorizontalAlign="Center" />

                                <Columns>
                                    <asp:BoundField DataField="pro_id" HeaderText="ID">
                                        <HeaderStyle Width="6%" />
                                    </asp:BoundField>

                                    <asp:TemplateField HeaderText="Fotos">
                                        <HeaderStyle Width="14%" />
                                        <ItemTemplate>
                                            <div class="photo-strip">
                                                <%# BuildPhotoStrip(Eval("pro_foto"), Eval("pro_id")) %>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField DataField="pro_codigo" HeaderText="Código">
                                        <HeaderStyle Width="12%" />
                                    </asp:BoundField>

                                    <asp:BoundField DataField="pro_nombre" HeaderText="Producto">
                                        <HeaderStyle Width="25%" />
                                        <ItemStyle Font-Bold="true" ForeColor="White" />
                                    </asp:BoundField>

                                    <asp:BoundField DataField="pro_cantidad" HeaderText="Stock">
                                        <HeaderStyle Width="8%" />
                                    </asp:BoundField>

                                    <asp:BoundField DataField="pro_precio" HeaderText="Precio" DataFormatString="{0:C2}">
                                        <HeaderStyle Width="10%" />
                                        <ItemStyle ForeColor="#34d399" Font-Bold="true" />
                                    </asp:BoundField>

                                    <asp:BoundField DataField="prov_nombre" HeaderText="Proveedor">
                                        <HeaderStyle Width="13%" />
                                        <ItemStyle ForeColor="#a78bfa" />
                                    </asp:BoundField>

                                    <asp:TemplateField HeaderText="Acciones">
                                        <HeaderStyle Width="12%" />
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEditar" runat="server"
                                                CssClass="btn-text-action"
                                                CommandName="Editar"
                                                CommandArgument='<%# Eval("pro_id") %>'
                                                ToolTip="Editar Producto">
                                                <i class="fas fa-edit"></i> Editar
                                            </asp:LinkButton>

                                            <asp:LinkButton ID="btnEliminar" runat="server"
                                                CssClass="btn-text-action btn-text-danger"
                                                CommandName="Eliminar"
                                                CommandArgument='<%# Eval("pro_id") %>'
                                                OnClientClick="return confirm('¿Eliminar este producto permanentemente?');"
                                                ToolTip="Eliminar Producto">
                                                <i class="fas fa-trash"></i> Eliminar
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <!-- MODAL LIGHTBOX -->
        <div id="photoModal">
            <button type="button" class="modal-close" onclick="closeModal()" title="Cerrar">&times;</button>
            <div class="modal-img-wrap">
                <button type="button" class="modal-nav prev" onclick="modalNav(-1)">&#10094;</button>
                <img id="modalMainImg" src="" alt="Foto producto" />
                <button type="button" class="modal-nav next" onclick="modalNav(1)">&#10095;</button>
            </div>
            <div id="modalStrip" class="modal-strip"></div>
        </div>

        <script>
            var _modalPhotos = [];
            var _modalIdx = 0;

            function openModal(photos, startIdx) {
                _modalPhotos = photos;
                _modalIdx = startIdx || 0;
                renderModal();
                document.getElementById('photoModal').classList.add('open');
            }

            function closeModal() {
                document.getElementById('photoModal').classList.remove('open');
            }

            function renderModal() {
                var main = document.getElementById('modalMainImg');
                var strip = document.getElementById('modalStrip');
                main.src = _modalPhotos[_modalIdx];
                strip.innerHTML = '';
                for (var i = 0; i < _modalPhotos.length; i++) {
                    (function(idx) {
                        var img = document.createElement('img');
                        img.src = _modalPhotos[idx];
                        if (idx === _modalIdx) img.className = 'active';
                        img.onclick = function() { _modalIdx = idx; renderModal(); };
                        strip.appendChild(img);
                    })(i);
                }
            }

            function modalNav(dir) {
                _modalIdx = (_modalIdx + dir + _modalPhotos.length) % _modalPhotos.length;
                renderModal();
            }

            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') closeModal();
                if (e.key === 'ArrowLeft') { if (_modalPhotos.length) modalNav(-1); }
                if (e.key === 'ArrowRight') { if (_modalPhotos.length) modalNav(1); }
            });
            document.getElementById('photoModal').addEventListener('click', function(e) {
                if (e.target === this) closeModal();
            });
        </script>
    </form>
</body>
</html>