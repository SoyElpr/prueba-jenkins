<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin.aspx.cs" Inherits="Monolito_4Am.Dashboard.Admin" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Panel de Administración | MonolitoApp</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #8b5cf6; --secondary: #ec4899; --accent: #06b6d4;
            --glass: rgba(30, 41, 59, 0.7); --glass-border: rgba(255, 255, 255, 0.1);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif; background: #020617; color: #f8fafc;
            min-height: 100vh; overflow-x: hidden;
        }

        .navbar {
            background: rgba(15, 23, 42, 0.9); backdrop-filter: blur(10px);
            padding: 15px 40px; display: flex; justify-content: space-between; align-items: center;
            border-bottom: 1px solid var(--glass-border); position: sticky; top: 0; z-index: 100;
        }
        .nav-logo { font-size: 22px; font-weight: 800; background: linear-gradient(to right, #a78bfa, #f472b6); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }

        .container { max-width: 1400px; margin: 40px auto; padding: 0 20px; }

        .dashboard-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 24px; margin-bottom: 40px; }
        .stat-card {
            background: var(--glass); border: 1px solid var(--glass-border); border-radius: 24px; padding: 30px;
            display: flex; align-items: center; gap: 20px;
        }
        .stat-icon { width: 60px; height: 60px; border-radius: 18px; display: flex; align-items: center; justify-content: center; font-size: 30px; }

        .table-card {
            background: var(--glass); backdrop-filter: blur(20px); border: 1px solid var(--glass-border);
            border-radius: 32px; padding: 35px; margin-bottom: 40px; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.5);
        }
        .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .table-header h2 { font-size: 24px; font-weight: 800; display: flex; align-items: center; gap: 12px; }

        .gv-container { border-radius: 16px; overflow: hidden; border: 1px solid var(--glass-border); }
        .m-grid { width: 100%; border-collapse: collapse; background: rgba(0,0,0,0.2); }
        .m-grid th { background: rgba(255,255,255,0.03); padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; color: #94a3b8; }
        .m-grid td { padding: 16px; border-top: 1px solid var(--glass-border); font-size: 14px; }
        .m-grid tr:hover { background: rgba(255,255,255,0.02); }

        .avatar-tbl { width: 36px; height: 36px; border-radius: 50%; border: 2px solid var(--primary); object-fit: cover; }
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
        .badge-A { background: rgba(34,197,94,0.1); color: #4ade80; border: 1px solid rgba(34,197,94,0.2); }
        .badge-B { background: rgba(239,68,68,0.1); color: #f87171; border: 1px solid rgba(239,68,68,0.2); }

        .btn-action {
            padding: 8px 16px; border-radius: 10px; border: none; font-size: 12px; font-weight: 700;
            cursor: pointer; transition: all 0.2s; background: var(--primary); color: white;
        }
        .btn-action:hover { transform: translateY(-2px); filter: brightness(1.2); }

        .audit-log { font-family: 'Consolas', monospace; font-size: 13px; color: #cbd5e1; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        
        <nav class="navbar">
            <a href="#" class="nav-logo">ADMIN CONTROL</a>
            <div style="display:flex; gap:20px; align-items:center;">
                <span style="font-size:14px; color:#94a3b8;">Hola, <strong>Admin</strong></span>
                <asp:LinkButton ID="btnCerrarSesion" runat="server" OnClick="btnCerrarSesion_Click" style="color:#ef4444; font-size:13px; font-weight:700; text-decoration:none;">SALIR</asp:LinkButton>
            </div>
        </nav>

        <div class="container">
            <div class="dashboard-grid">
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(139,92,246,0.1); color:#a78bfa;">👥</div>
                    <div><p style="font-size:13px; color:#94a3b8;">Usuarios Totales</p><h3 style="font-size:24px;"><asp:Label ID="lblTotalUsers" runat="server" Text="0" /></h3></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(236,72,153,0.1); color:#f472b6;">🚫</div>
                    <div><p style="font-size:13px; color:#94a3b8;">Bloqueados</p><h3 style="font-size:24px;"><asp:Label ID="lblLockedUsers" runat="server" Text="0" /></h3></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(6,182,212,0.1); color:#22d3ee;">📜</div>
                    <div><p style="font-size:13px; color:#94a3b8;">Acciones Hoy</p><h3 style="font-size:24px;"><asp:Label ID="lblTodayActions" runat="server" Text="0" /></h3></div>
                </div>
            </div>

            <asp:UpdatePanel runat="server">
                <ContentTemplate>

                    <!-- GESTIÓN DE STAFF (CREAR ADMINS) -->
                    <div class="table-card" style="background: linear-gradient(135deg, rgba(139,92,246,0.1), rgba(0,0,0,0)); border: 1px solid rgba(139,92,246,0.3);">
                        <div class="table-header">
                            <h2>🛡️ Gestión de Staff Administrativo</h2>
                            <span style="font-size:11px; color:#a78bfa; font-weight:700; text-transform:uppercase;">Nivel: Superusuario</span>
                        </div>
                        <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:15px; margin-bottom:20px;">
                            <asp:TextBox ID="txtAdminCedula" runat="server" placeholder="Cédula Admin" autocomplete="none" style="background:rgba(0,0,0,0.3); border:1px solid rgba(255,255,255,0.1); padding:12px; border-radius:10px; color:white;" />
                            <asp:TextBox ID="txtAdminNombres" runat="server" placeholder="Nombres" autocomplete="none" style="background:rgba(0,0,0,0.3); border:1px solid rgba(255,255,255,0.1); padding:12px; border-radius:10px; color:white;" />
                            <asp:TextBox ID="txtAdminApellidos" runat="server" placeholder="Apellidos" autocomplete="none" style="background:rgba(0,0,0,0.3); border:1px solid rgba(255,255,255,0.1); padding:12px; border-radius:10px; color:white;" />
                            <asp:TextBox ID="txtAdminCorreo" runat="server" placeholder="Correo Electrónico" autocomplete="none" style="background:rgba(0,0,0,0.3); border:1px solid rgba(255,255,255,0.1); padding:12px; border-radius:10px; color:white;" />
                            <asp:TextBox ID="txtAdminNick" runat="server" placeholder="Usuario (Nick)" autocomplete="none" style="background:rgba(0,0,0,0.3); border:1px solid rgba(255,255,255,0.1); padding:12px; border-radius:10px; color:white;" />
                            <asp:TextBox ID="txtAdminPass" runat="server" placeholder="Contraseña Temporal" TextMode="Password" autocomplete="new-password" style="background:rgba(0,0,0,0.3); border:1px solid rgba(255,255,255,0.1); padding:12px; border-radius:10px; color:white;" />
                        </div>
                        <div style="text-align:right">
                            <asp:Button ID="btnCrearAdmin" runat="server" Text="➕ REGISTRAR NUEVO ADMINISTRADOR" OnClick="btnCrearAdmin_Click" 
                                style="background:var(--primary); color:white; border:none; padding:15px 30px; border-radius:12px; font-weight:800; cursor:pointer;" />
                        </div>
                        <asp:Label ID="lblMsgAdmin" runat="server" style="display:block; margin-top:15px; font-size:13px; text-align:center;" />
                    </div>

                    <!-- EDITOR DE USUARIO (SOLO VISIBLE AL EDITAR) -->
                    <asp:Panel ID="pnlEditor" runat="server" Visible="false" CssClass="table-card" style="border:1px solid var(--accent); background:rgba(6,182,212,0.05);">
                        <div class="table-header">
                            <h2>✏️ Editando Usuario: <asp:Label ID="lblEditNick" runat="server" /></h2>
                            <asp:LinkButton ID="btnCloseEditor" runat="server" OnClick="btnCloseEditor_Click" style="color:#ef4444; font-size:18px; text-decoration:none;">✕</asp:LinkButton>
                        </div>
                        <asp:HiddenField ID="hfEditId" runat="server" />
                        <div style="display:grid; grid-template-columns: repeat(2, 1fr); gap:15px;">
                            <asp:TextBox ID="txtEditCedula" runat="server" placeholder="Cédula" style="background:rgba(0,0,0,0.2); border:1px solid var(--glass-border); padding:10px; border-radius:8px; color:white;" />
                            <asp:TextBox ID="txtEditCorreo" runat="server" placeholder="Correo" style="background:rgba(0,0,0,0.2); border:1px solid var(--glass-border); padding:10px; border-radius:8px; color:white;" />
                            <asp:TextBox ID="txtEditNombres" runat="server" placeholder="Nombres" style="background:rgba(0,0,0,0.2); border:1px solid var(--glass-border); padding:10px; border-radius:8px; color:white;" />
                            <asp:TextBox ID="txtEditApellidos" runat="server" placeholder="Apellidos" style="background:rgba(0,0,0,0.2); border:1px solid var(--glass-border); padding:10px; border-radius:8px; color:white;" />
                        </div>
                        <div style="margin-top:20px; text-align:right;">
                            <asp:Button ID="btnGuardarCambios" runat="server" Text="💾 GUARDAR CAMBIOS" OnClick="btnGuardarCambios_Click" CssClass="btn-action" style="padding:12px 25px; background:var(--accent);" />
                        </div>
                    </asp:Panel>
                    
                    <!-- TABLA BLOQUEADOS -->
                    <div class="table-card">
                        <div class="table-header">
                            <h2>🔒 Usuarios Bloqueados</h2>
                            <p style="font-size:13px; color:#94a3b8;">Intentos fallidos excedidos</p>
                        </div>
                        <div class="gv-container">
                            <asp:GridView ID="gvBloqueados" runat="server" AutoGenerateColumns="false" CssClass="m-grid" ShowHeaderWhenEmpty="true">
                                <Columns>
                                    <asp:TemplateField HeaderText="Foto">
                                        <ItemTemplate>
                                            <asp:Image ID="imgFoto" runat="server" ImageUrl='<%# "~/Handlers/FotoHandler.ashx?usu_id=" + Eval("usu_id") %>' CssClass="avatar-tbl" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="usu_cedula" HeaderText="Cédula" />
                                    <asp:BoundField DataField="usu_nick" HeaderText="Usuario" />
                                    <asp:TemplateField HeaderText="Acción">
                                        <ItemTemplate>
                                            <asp:Button ID="btnDesbloquear" runat="server" Text="🔓 RE-ACTIVAR" CssClass="btn-action" 
                                                CommandArgument='<%# Eval("usu_id") %>' OnClick="btnDesbloquear_Click" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div style="padding:20px; text-align:center; color:#64748b;">No hay bloqueos recientes.</div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>

                    <!-- TABLA TODOS -->
                    <div class="table-card">
                        <div class="table-header">
                            <h2>👥 Directorio de Usuarios</h2>
                            <asp:LinkButton ID="btnRefreshUsers" runat="server" OnClick="btnRefreshUsers_Click" style="font-size:13px; color:var(--primary);">🔄 Actualizar</asp:LinkButton>
                        </div>
                        <div class="gv-container">
                            <asp:GridView ID="gvTodos" runat="server" AutoGenerateColumns="false" CssClass="m-grid">
                                <Columns>
                                    <asp:TemplateField HeaderText="Foto">
                                        <ItemTemplate>
                                            <asp:Image ID="imgFotoAll" runat="server" ImageUrl='<%# "~/Handlers/FotoHandler.ashx?usu_id=" + Eval("usu_id") %>' CssClass="avatar-tbl" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="usu_cedula" HeaderText="Cédula" />
                                    <asp:BoundField DataField="usu_nombres" HeaderText="Nombres" />
                                    <asp:BoundField DataField="usu_apellidos" HeaderText="Apellidos" />
                                    <asp:BoundField DataField="usu_nick" HeaderText="Nick" />
                                    <asp:BoundField DataField="usu_correo" HeaderText="Correo" />
                                    <asp:TemplateField HeaderText="Estado">
                                        <ItemTemplate>
                                            <span class='badge badge-<%# Eval("usu_estado") %>'>
                                                <%# Eval("usu_estado").ToString()=="A"?"Activo":"Inactivo" %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Acciones">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEditar" runat="server" Text="✏️" CommandArgument='<%# Eval("usu_id") %>' OnClick="btnEditar_Click" style="text-decoration:none; margin-right:10px;" title="Editar Datos" />
                                            <asp:LinkButton ID="btnToggle" runat="server" 
                                                Text='<%# Eval("usu_estado").ToString() == "A" ? "🚫" : "✅" %>' 
                                                CommandArgument='<%# Eval("usu_id") + "|" + Eval("usu_estado") %>' 
                                                OnClick="btnToggleStatus_Click" 
                                                style="text-decoration:none;" 
                                                title='<%# Eval("usu_estado").ToString() == "A" ? "Desactivar" : "Activar" %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                    <!-- AUDITORÍA -->
                    <div class="table-card">
                        <div class="table-header">
                            <h2>📜 Auditoría del Sistema</h2>
                            <asp:LinkButton ID="btnRefreshLogs" runat="server" OnClick="btnRefreshLogs_Click" style="font-size:13px; color:var(--accent);">🔄 Ver Logs Recientes</asp:LinkButton>
                        </div>
                        <div class="gv-container">
                            <asp:GridView ID="gvLogs" runat="server" AutoGenerateColumns="false" CssClass="m-grid audit-log">
                                <Columns>
                                    <asp:BoundField DataField="audi_fecha" HeaderText="Fecha/Hora" DataFormatString="{0:dd/MM HH:mm:ss}" />
                                    <asp:BoundField DataField="usu_nick" HeaderText="Usuario" />
                                    <asp:BoundField DataField="audi_accion" HeaderText="Acción" />
                                    <asp:BoundField DataField="audi_modulo" HeaderText="Módulo" />
                                    <asp:BoundField DataField="audi_ip" HeaderText="IP Address" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>
