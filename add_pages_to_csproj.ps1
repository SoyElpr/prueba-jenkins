$path = "Monolito_4Am\Monolito_4Am.csproj"
$content = Get-Content $path -Raw

# 1) Add Content Items
$targetContent = '    <Content Include="Mantenimineto\nuevo_tbl_producto.aspx" />'
$addContent = '    <Content Include="Mantenimineto\nuevo_tbl_producto.aspx" />' + [char]13 + [char]10 + `
'    <Content Include="Mantenimineto\listar_tbl_proveedor.aspx" />' + [char]13 + [char]10 + `
'    <Content Include="Mantenimineto\nuevo_tbl_proveedor.aspx" />' + [char]13 + [char]10 + `
'    <Content Include="Mantenimineto\subida_excel.aspx" />' + [char]13 + [char]10 + `
'    <Content Include="Mantenimineto\estadisticas_producto.aspx" />'

if ($content.Contains($targetContent) -and -not $content.Contains("Mantenimineto\listar_tbl_proveedor.aspx")) {
    $content = $content.Replace($targetContent, $addContent)
}

# 2) Add Compile Items
$targetCompile = '    <Compile Include="Mantenimineto\nuevo_tbl_producto.aspx.designer.cs">' + [char]13 + [char]10 + `
'      <DependentUpon>nuevo_tbl_producto.aspx</DependentUpon>' + [char]13 + [char]10 + `
'    </Compile>'

$addCompile = '    <Compile Include="Mantenimineto\nuevo_tbl_producto.aspx.designer.cs">' + [char]13 + [char]10 + `
'      <DependentUpon>nuevo_tbl_producto.aspx</DependentUpon>' + [char]13 + [char]10 + `
'    </Compile>' + [char]13 + [char]10 + `
'    <Compile Include="Mantenimineto\listar_tbl_proveedor.aspx.cs">' + [char]13 + [char]10 + `
'      <DependentUpon>listar_tbl_proveedor.aspx</DependentUpon>' + [char]13 + [char]10 + `
'      <SubType>ASPXCodeBehind</SubType>' + [char]13 + [char]10 + `
'    </Compile>' + [char]13 + [char]10 + `
'    <Compile Include="Mantenimineto\listar_tbl_proveedor.aspx.designer.cs">' + [char]13 + [char]10 + `
'      <DependentUpon>listar_tbl_proveedor.aspx</DependentUpon>' + [char]13 + [char]10 + `
'    </Compile>' + [char]13 + [char]10 + `
'    <Compile Include="Mantenimineto\nuevo_tbl_proveedor.aspx.cs">' + [char]13 + [char]10 + `
'      <DependentUpon>nuevo_tbl_proveedor.aspx</DependentUpon>' + [char]13 + [char]10 + `
'      <SubType>ASPXCodeBehind</SubType>' + [char]13 + [char]10 + `
'    </Compile>' + [char]13 + [char]10 + `
'    <Compile Include="Mantenimineto\nuevo_tbl_proveedor.aspx.designer.cs">' + [char]13 + [char]10 + `
'      <DependentUpon>nuevo_tbl_proveedor.aspx</DependentUpon>' + [char]13 + [char]10 + `
'    </Compile>' + [char]13 + [char]10 + `
'    <Compile Include="Mantenimineto\subida_excel.aspx.cs">' + [char]13 + [char]10 + `
'      <DependentUpon>subida_excel.aspx</DependentUpon>' + [char]13 + [char]10 + `
'      <SubType>ASPXCodeBehind</SubType>' + [char]13 + [char]10 + `
'    </Compile>' + [char]13 + [char]10 + `
'    <Compile Include="Mantenimineto\subida_excel.aspx.designer.cs">' + [char]13 + [char]10 + `
'      <DependentUpon>subida_excel.aspx</DependentUpon>' + [char]13 + [char]10 + `
'    </Compile>' + [char]13 + [char]10 + `
'    <Compile Include="Mantenimineto\estadisticas_producto.aspx.cs">' + [char]13 + [char]10 + `
'      <DependentUpon>estadisticas_producto.aspx</DependentUpon>' + [char]13 + [char]10 + `
'      <SubType>ASPXCodeBehind</SubType>' + [char]13 + [char]10 + `
'    </Compile>' + [char]13 + [char]10 + `
'    <Compile Include="Mantenimineto\estadisticas_producto.aspx.designer.cs">' + [char]13 + [char]10 + `
'      <DependentUpon>estadisticas_producto.aspx</DependentUpon>' + [char]13 + [char]10 + `
'    </Compile>'

if ($content.Contains($targetCompile) -and -not $content.Contains("Mantenimineto\listar_tbl_proveedor.aspx.cs")) {
    $content = $content.Replace($targetCompile, $addCompile)
}

Set-Content -Path $path -Value $content -Encoding UTF8
