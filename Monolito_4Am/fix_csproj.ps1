$projPath = 'c:\Users\PR\Desktop\INSTI\PROG\4to\Monolito_4Am\Monolito_4Am\Monolito_4Am.csproj'
[xml]$xml = Get-Content $projPath

$ns = @{msb='http://schemas.microsoft.com/developer/msbuild/2003'}

$compileGroup = ($xml.Project.ItemGroup | Where-Object { $_.Compile })[0]
if (-not $compileGroup) {
    $compileGroup = $xml.CreateElement('ItemGroup', 'http://schemas.microsoft.com/developer/msbuild/2003')
    $xml.Project.AppendChild($compileGroup)
}

$contentGroup = ($xml.Project.ItemGroup | Where-Object { $_.Content })[0]

function AddCompile($path, $dep) {
    $node = $xml.CreateElement('Compile', 'http://schemas.microsoft.com/developer/msbuild/2003')
    $node.SetAttribute('Include', $path)
    if ($dep) {
        $depNode = $xml.CreateElement('DependentUpon', 'http://schemas.microsoft.com/developer/msbuild/2003')
        $depNode.InnerText = $dep
        $node.AppendChild($depNode) | Out-Null
    }
    $compileGroup.AppendChild($node) | Out-Null
}

function AddContent($path) {
    $node = $xml.CreateElement('Content', 'http://schemas.microsoft.com/developer/msbuild/2003')
    $node.SetAttribute('Include', $path)
    $contentGroup.AppendChild($node) | Out-Null
}

AddContent('Dashboard\Admin.aspx')
AddCompile('Dashboard\Admin.aspx.cs', 'Admin.aspx')
AddContent('Dashboard\Usuario.aspx')
AddCompile('Dashboard\Usuario.aspx.cs', 'Usuario.aspx')
AddContent('Handlers\FotoHandler.ashx')
AddCompile('Handlers\FotoHandler.ashx.cs', 'FotoHandler.ashx')
AddCompile('Helpers\EmailHelper.cs', $null)
AddCompile('Helpers\TOTPHelper.cs', $null)
AddCompile('Helpers\WhatsAppHelper.cs', $null)
AddContent('Juego\Juego.aspx')
AddCompile('Juego\Juego.aspx.cs', 'Juego.aspx')
AddContent('Seguridad\RecuperarPassword.aspx')
AddCompile('Seguridad\RecuperarPassword.aspx.cs', 'RecuperarPassword.aspx')
AddCompile('Seguridad\RecuperarPassword.aspx.designer.cs', 'RecuperarPassword.aspx')
AddContent('Seguridad\VerificarOTP.aspx')
AddCompile('Seguridad\VerificarOTP.aspx.cs', 'VerificarOTP.aspx')

$xml.Save($projPath)
