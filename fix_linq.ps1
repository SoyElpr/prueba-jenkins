$path = "Monolito_4Am\Monolito_4Am.csproj"
$content = Get-Content $path -Raw
$target = '<Reference Include="System.Data" />'
$replacement = '<Reference Include="System.Data" />' + [char]13 + [char]10 + '    <Reference Include="System.Data.Linq" />'
$newContent = $content.Replace($target, $replacement)
Set-Content -Path $path -Value $newContent -Encoding UTF8
