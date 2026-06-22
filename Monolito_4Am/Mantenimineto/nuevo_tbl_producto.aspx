<%@ Page Title="Nuevo / Editar Producto" Language="C#" AutoEventWireup="true" CodeBehind="nuevo_tbl_producto.aspx.cs" Inherits="Monolito_4Am.Mantenimineto.nuevo_tbl_producto" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Nuevo / Editar Producto</title>

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
            max-width: 900px;
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

        .btn-secondary {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-main);
            border: 1px solid var(--border-light);
        }

        .btn-secondary:hover {
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

        /* GLASS CARDS & FORM */
        .glass-card {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 18px;
            padding: 30px;
            margin-bottom: 25px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .input-dark {
            width: 100%;
            padding: 14px 16px;
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid var(--border-light);
            border-radius: 12px;
            color: white;
            font-size: 14px;
            outline: none;
            transition: all 0.3s;
            box-sizing: border-box;
            font-family: 'Outfit', sans-serif;
        }

        .input-dark:focus {
            border-color: var(--primary);
            background: rgba(0, 0, 0, 0.5);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
        }

        textarea.input-dark {
            resize: vertical;
            min-height: 100px;
        }

        /* UPLOAD & GALLERY */
        .photo-gallery-edit {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 15px;
        }

        .photo-item {
            position: relative;
            width: 120px;
            height: 120px;
            border-radius: 12px;
            overflow: hidden;
            border: 2px solid rgba(99,102,241,0.4);
            box-shadow: 0 8px 20px rgba(0,0,0,0.3);
            flex-shrink: 0;
            transition: 0.3s;
        }

        .photo-item:hover {
            border-color: var(--primary-light);
            box-shadow: 0 10px 25px rgba(167,139,250,0.4);
            transform: translateY(-3px);
        }

        .photo-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            cursor: pointer;
        }

        .photo-item .btn-delete-photo {
            position: absolute;
            top: 6px;
            right: 6px;
            background: rgba(239,68,68,0.9);
            color: white;
            border: none;
            border-radius: 50%;
            width: 28px;
            height: 28px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: 0.2s;
            z-index: 10;
        }

        .photo-item .btn-delete-photo:hover {
            background: var(--danger);
            transform: scale(1.15);
        }

        .photo-item.deleted {
            opacity: 0.4;
            filter: grayscale(1);
            border-color: rgba(239,68,68,0.5);
            transform: none;
        }

        .photo-item .restore-badge {
            display: none;
            position: absolute;
            inset: 0;
            background: rgba(0,0,0,0.7);
            align-items: center;
            justify-content: center;
            font-size: 12px;
            color: var(--text-main);
            text-align: center;
            padding: 5px;
        }

        .photo-item.deleted .restore-badge { display: flex; }

        .photo-label {
            position: absolute;
            bottom: 0; left: 0; right: 0;
            background: rgba(0,0,0,0.7);
            color: #cbd5e1;
            font-size: 11px;
            padding: 4px 6px;
            text-overflow: ellipsis;
            overflow: hidden;
            white-space: nowrap;
        }

        #previewContainer {
            display: flex;
            gap: 15px;
            margin-top: 20px;
            flex-wrap: wrap;
        }

        /* ALERTS */
        .msg-box {
            margin-top: 25px;
            padding: 16px 20px;
            border-radius: 12px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: fadeIn 0.4s ease;
        }

        .msg-box.error { background: rgba(239, 68, 68, 0.1); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.2); }
        .msg-box.success { background: rgba(16, 185, 129, 0.1); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.2); }

        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        @media (max-width: 768px) {
            .form-grid { grid-template-columns: 1fr; }
        }

        /* CUSTOM FILE UPLOAD */
        .file-input::file-selector-button {
            padding: 10px 18px;
            border-radius: 8px;
            border: none;
            background: rgba(255,255,255,0.1);
            color: white;
            font-weight: 600;
            cursor: pointer;
            margin-right: 15px;
            transition: 0.3s;
            font-family: 'Outfit', sans-serif;
        }
        .file-input::file-selector-button:hover { background: rgba(255,255,255,0.2); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="main-container">
            
            <!-- HEADER -->
            <div class="page-header">
                <h1><i class="fas fa-box-open"></i> <span id="lblTitle" runat="server">Nuevo Producto</span></h1>
                <asp:LinkButton ID="btnBack" runat="server" CssClass="btn-modern btn-secondary" OnClick="btnBack_Click">
                    <i class="fas fa-arrow-left"></i> Volver al Catálogo
                </asp:LinkButton>
            </div>

            <asp:Panel ID="pnlForm" runat="server">
                
                <div class="glass-card form-grid">
                    <div class="form-group">
                        <label for="txtCodigo"><i class="fas fa-barcode"></i> Código Interno</label>
                        <asp:TextBox ID="txtCodigo" runat="server" CssClass="input-dark" MaxLength="50" placeholder="Ej: PRD-001"></asp:TextBox>
                    </div>
                    
                    <div class="form-group">
                        <label for="txtNombre"><i class="fas fa-tag"></i> Nombre del Producto</label>
                        <asp:TextBox ID="txtNombre" runat="server" CssClass="input-dark" MaxLength="150" placeholder="Ej: Camisa Premium de Algodón"></asp:TextBox>
                    </div>
                    
                    <div class="form-group full-width">
                        <label for="txtDescripcion"><i class="fas fa-align-left"></i> Descripción</label>
                        <asp:TextBox ID="txtDescripcion" runat="server" CssClass="input-dark" TextMode="MultiLine" Rows="3" placeholder="Ingresa los detalles técnicos o caracteristicas del producto..."></asp:TextBox>
                    </div>
                    
                    <div class="form-group">
                        <label for="txtPrecio"><i class="fas fa-dollar-sign"></i> Precio</label>
                        <asp:TextBox ID="txtPrecio" runat="server" CssClass="input-dark" MaxLength="20" placeholder="Ej: 49.99"></asp:TextBox>
                    </div>
                    
                    <div class="form-group">
                        <label for="txtCantidad"><i class="fas fa-boxes"></i> Cantidad Inicial (Stock)</label>
                        <asp:TextBox ID="txtCantidad" runat="server" CssClass="input-dark" MaxLength="10" placeholder="Ej: 100"></asp:TextBox>
                    </div>
                    
                    <div class="form-group full-width">
                        <label for="ddlProveedor"><i class="fas fa-truck"></i> Proveedor</label>
                        <asp:DropDownList ID="ddlProveedor" runat="server" CssClass="input-dark"></asp:DropDownList>
                    </div>
                </div>

                <!-- GALERÍA DE FOTOS ACTUALES -->
                <asp:PlaceHolder ID="phCarruselActual" runat="server" Visible="false">
                    <div class="glass-card" style="border-color: rgba(244,114,182,0.3);">
                        <div class="form-group full-width">
                            <label style="color: #f472b6;"><i class="fas fa-images"></i> Fotos Actuales del Producto</label>
                            <p style="font-size:13px; color:var(--text-muted); margin:0 0 15px 0;">
                                Haz clic en la <span style="color:var(--danger); font-weight:bold;">✕</span> para marcar una foto como eliminada. Se borrará permanentemente al guardar.
                            </p>
                            
                            <asp:HiddenField ID="hfFotosEliminar" runat="server" Value="" />
                            
                            <div class="photo-gallery-edit" id="photoGalleryEdit">
                                <asp:Repeater ID="rptCurrentImages" runat="server">
                                    <ItemTemplate>
                                        <%# BuildPhotoItem(Container.DataItem as string[]) %>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </asp:PlaceHolder>

                <!-- NUEVAS FOTOS -->
                <div class="glass-card">
                    <div class="form-group full-width" style="margin-bottom:0;">
                        <label><i class="fas fa-cloud-upload-alt"></i> Subir Nuevas Imágenes (Máx. 5 fotos, hasta 3 MB c/u)</label>
                        <p style="font-size:13px; color:var(--text-muted); margin:0 0 15px 0;">Formatos admitidos: .png, .jpg, .jpeg</p>
                        
                        <asp:FileUpload ID="fuImagen" runat="server" CssClass="input-dark file-input" AllowMultiple="true" accept=".png,.jpg,.jpeg" />
                        
                        <div style="display:flex; align-items:center; gap:15px; margin-top:20px;">
                            <button type="button" id="btnPreviewImages" onclick="previewImages()" class="btn-modern" style="background: rgba(255,255,255,0.1); opacity:0.5; pointer-events:none;">
                                <i class="fas fa-eye"></i> Generar Previsualización
                            </button>
                            <span id="fileCounter" style="font-size:13px; font-weight:600; color:var(--accent);"></span>
                        </div>
                        
                        <div id="previewContainer"></div>
                    </div>
                </div>

                <div style="text-align: right; margin-top: 30px;">
                    <asp:LinkButton ID="btnGuardar" runat="server" CssClass="btn-modern btn-primary" OnClick="btnGuardar_Click" style="padding: 14px 30px; font-size: 16px;">
                        <i class="fas fa-save"></i> Guardar Producto
                    </asp:LinkButton>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlMensaje" runat="server" Visible="false">
                <div id="lblMensaje" runat="server" class="msg-box"></div>
            </asp:Panel>

        </div>
    </form>

    <script>
        // ELIMINAR FOTO EXISTENTE
        function marcarEliminar(btn, fileName) {
            var item = btn.closest('.photo-item');
            var hf   = document.getElementById('<%= hfFotosEliminar.ClientID %>');

            if (item.classList.contains('deleted')) {
                // Restaurar
                item.classList.remove('deleted');
                btn.title = 'Eliminar esta foto';
                btn.innerHTML = '<i class="fas fa-times"></i>';
                var lista = hf.value ? hf.value.split(';') : [];
                lista = lista.filter(function(f){ return f !== fileName; });
                hf.value = lista.join(';');
            } else {
                // Marcar para eliminar
                item.classList.add('deleted');
                btn.title = 'Clic para restaurar';
                btn.innerHTML = '<i class="fas fa-undo"></i>';
                var lista = hf.value ? hf.value.split(';').filter(function(f){ return f.length > 0; }) : [];
                if (lista.indexOf(fileName) === -1) lista.push(fileName);
                hf.value = lista.join(';');
            }
        }

        // PREVISUALIZAR NUEVAS FOTOS
        var _selectedFiles = [];
        document.addEventListener("DOMContentLoaded", function () {
            var fileUpload = document.getElementById('<%= fuImagen.ClientID %>');
            var btnPrev    = document.getElementById('btnPreviewImages');
            var counter    = document.getElementById('fileCounter');
            var container  = document.getElementById('previewContainer');

            if (!fileUpload) return;

            fileUpload.addEventListener('change', function () {
                container.innerHTML = '';
                _selectedFiles = Array.prototype.slice.call(this.files);

                if (_selectedFiles.length === 0) {
                    counter.innerHTML = '';
                    btnPrev.style.opacity = '0.5';
                    btnPrev.style.pointerEvents = 'none';
                    return;
                }
                if (_selectedFiles.length > 5) {
                    alert('Puedes subir un máximo de 5 imágenes.');
                    fileUpload.value = ''; _selectedFiles = [];
                    counter.innerHTML = '';
                    btnPrev.style.opacity = '0.5';
                    btnPrev.style.pointerEvents = 'none';
                    return;
                }
                for (var i = 0; i < _selectedFiles.length; i++) {
                    if (_selectedFiles[i].size > 3 * 1024 * 1024) {
                        alert("El archivo '" + _selectedFiles[i].name + "' supera los 3 MB.");
                        fileUpload.value = ''; _selectedFiles = [];
                        counter.innerHTML = '';
                        btnPrev.style.opacity = '0.5';
                        btnPrev.style.pointerEvents = 'none';
                        return;
                    }
                    var ext = _selectedFiles[i].name.split('.').pop().toLowerCase();
                    if (['png','jpg','jpeg'].indexOf(ext) === -1) {
                        alert("Solo se permiten archivos .png, .jpg o .jpeg");
                        fileUpload.value = ''; _selectedFiles = [];
                        counter.innerHTML = '';
                        btnPrev.style.opacity = '0.5';
                        btnPrev.style.pointerEvents = 'none';
                        return;
                    }
                }
                counter.innerHTML = '<i class="fas fa-check-circle"></i> ' + _selectedFiles.length + ' archivo(s) validado(s)';
                btnPrev.style.opacity = '1';
                btnPrev.style.pointerEvents = 'auto';
            });
        });

        function previewImages() {
            var container = document.getElementById('previewContainer');
            container.innerHTML = '';
            if (_selectedFiles.length === 0) return;

            for (var i = 0; i < _selectedFiles.length; i++) {
                (function(file) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var w = document.createElement('div');
                        w.className = 'photo-item';
                        w.style.borderColor = 'rgba(16, 185, 129, 0.5)'; // green border for new

                        var img = document.createElement('img');
                        img.src = e.target.result;
                        img.title = file.name;

                        var lbl = document.createElement('div');
                        lbl.className = 'photo-label';
                        lbl.textContent = file.name;

                        w.appendChild(img); 
                        w.appendChild(lbl);
                        container.appendChild(w);
                    };
                    reader.readAsDataURL(file);
                })(_selectedFiles[i]);
            }
        }
    </script>
</body>
</html>