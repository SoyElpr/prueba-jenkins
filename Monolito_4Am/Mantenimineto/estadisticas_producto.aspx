<%@ Page Title="Estadísticas de Productos" Language="C#" AutoEventWireup="true" CodeBehind="estadisticas_producto.aspx.cs" Inherits="Monolito_4Am.Mantenimineto.estadisticas_producto" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Estadísticas e Indicadores</title>

    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />

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

        /* CHARTS GRID - STACKED VERTICALLY */
        .charts-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 30px;
            margin-bottom: 40px;
        }

        .glass-card {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 18px;
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            display: flex;
            flex-direction: column;
        }

        .chart-header {
            margin-bottom: 20px;
        }

        .chart-header h3 {
            font-size: 18px;
            font-weight: 700;
            margin: 0;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .chart-header h3 i {
            color: var(--primary-light);
        }

        .chart-container {
            position: relative;
            height: 340px;
            width: 100%;
        }

        /* CAROUSEL */
        .carousel-card {
            background: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 18px;
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .carousel-card h3 {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 20px;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .carousel-card h3 i {
            color: var(--secondary);
        }

        .carousel-wrapper {
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid var(--border-light);
        }

        .carousel-img {
            width: 100%;
            height: 380px;
            object-fit: cover;
            filter: brightness(0.65);
        }

        .carousel-caption {
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(8px);
            border-radius: 12px;
            border: 1px solid var(--border-light);
            padding: 15px 20px;
            bottom: 20px;
        }

        .carousel-caption h5 {
            font-weight: 700;
            font-size: 18px;
            margin-bottom: 4px;
            color: white;
        }

        .carousel-caption p {
            font-size: 14px;
            margin: 0;
            color: var(--text-muted);
        }

        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.2); border-radius: 4px; }
        ::-webkit-scrollbar-thumb { background: rgba(99,102,241,0.5); border-radius: 4px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="main-container">
            <div class="page-header">
                <h1><i class="fas fa-chart-pie"></i> Estadísticas de Inventario</h1>
                <asp:LinkButton ID="btnVolver" runat="server" CssClass="btn-modern btn-secondary" OnClick="btnVolver_Click">
                    <i class="fas fa-arrow-left"></i> Volver al Catálogo
                </asp:LinkButton>
            </div>

            <!-- Gráficas Una Debajo de Otra -->
            <div class="charts-grid">
                <!-- Gráfica 1: Stock por Producto -->
                <div class="glass-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-box-open"></i> Stock por Producto (Top 10)</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="stockChart"></canvas>
                    </div>
                </div>

                <!-- Gráfica 2: Proveedores -->
                <div class="glass-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-truck-loading"></i> Productos por Proveedor</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="providerChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Top Productos Destacados -->
            <div class="carousel-card">
                <h3><i class="fas fa-star"></i> Productos con Mayor Stock</h3>
                <div class="carousel-wrapper">
                    <div id="carouselProductos" class="carousel slide" data-bs-ride="carousel">
                        <div class="carousel-inner" runat="server" id="carouselInner"></div>
                        
                        <button class="carousel-control-prev" type="button" data-bs-target="#carouselProductos" data-bs-slide="prev">
                            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Anterior</span>
                        </button>
                        <button class="carousel-control-next" type="button" data-bs-target="#carouselProductos" data-bs-slide="next">
                            <span class="carousel-control-next-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Siguiente</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script type="text/javascript">
        // Stock por Producto (Bar Chart)
        const stockCtx = document.getElementById('stockChart').getContext('2d');
        new Chart(stockCtx, {
            type: 'bar',
            data: {
                labels: <%= StockLabelsJson %>,
                datasets: [{
                    label: 'Unidades en Stock',
                    data: <%= StockValuesJson %>,
                    backgroundColor: 'rgba(99, 102, 241, 0.65)',
                    borderColor: 'rgba(129, 140, 248, 1)',
                    borderWidth: 1.5,
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: '#94a3b8', font: { family: 'Outfit', size: 12 } }
                    },
                    y: {
                        grid: { color: 'rgba(255, 255, 255, 0.05)' },
                        ticks: { color: '#94a3b8', font: { family: 'Outfit', size: 12 } },
                        beginAtZero: true
                    }
                }
            }
        });

        // Productos por Proveedor (Doughnut Chart)
        const providerCtx = document.getElementById('providerChart').getContext('2d');
        new Chart(providerCtx, {
            type: 'doughnut',
            data: {
                labels: <%= PriceLabelsJson %>,
                datasets: [{
                    data: <%= PriceValuesJson %>,
                    backgroundColor: [
                        '#6366f1',
                        '#ec4899',
                        '#10b981',
                        '#f59e0b',
                        '#ef4444',
                        '#3b82f6',
                        '#8b5cf6',
                        '#06b6d4'
                    ],
                    borderWidth: 2,
                    borderColor: '#0f172a'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            color: '#94a3b8',
                            font: { family: 'Outfit', size: 13 }
                        }
                    }
                }
            }
        });
    </script>
</body>
</html>
