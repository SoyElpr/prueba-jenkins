# publish_to_azure.ps1
# ---------------------------------------------------------------
# Prerequisites:
#   - Azure CLI installed (az)
#   - Logged in via `az login`
#   - Azure subscription set (`az account set --subscription <SUB_ID>`)
#   - Resource group and App Service created beforehand.
#
param(
    [Parameter(Mandatory=$true)][string]$ResourceGroup,
    [Parameter(Mandatory=$true)][string]$AppServiceName,
    [Parameter(Mandatory=$true)][string]$Location = "westus2",
    [Parameter(Mandatory=$false)][string]$CustomDomain,
    [Parameter(Mandatory=$false)][string]$SslCertThumbprint
)
# ---------------------------------------------------------------
# 1. Build the project (Release) using MSBuild
Write-Host "Building the project..."
$solutionPath = "C:\Users\PR\Desktop\INSTI\PROG\4to\Monolito_4Am\Monolito_4Am.sln"
MSBuild $solutionPath /p:Configuration=Release /t:Rebuild

# 2. Package the compiled site
Write-Host "Packaging site..."
$publishDir = "C:\Users\PR\Desktop\INSTI\PROG\4to\Monolito_4Am\Monolito_4Am\bin\Release\PublishOutput"
# Ensure directory exists
if (!(Test-Path $publishDir)) {
    New-Item -ItemType Directory -Path $publishDir | Out-Null
}
# Use MSBuild Publish target
MSBuild $solutionPath /p:DeployOnBuild=true /p:PublishProfile=FolderProfile /p:Configuration=Release /p:PublishDir=$publishDir

# 3. Zip the publish folder
Write-Host "Creating deployment zip..."
$zipPath = "$publishDir.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($publishDir, $zipPath)

# 4. Deploy to Azure App Service
Write-Host "Deploying to Azure App Service $AppServiceName..."
az webapp deployment source config-zip --resource-group $ResourceGroup --name $AppServiceName --src $zipPath

# 5. Bind custom domain (if provided)
if ($CustomDomain) {
    Write-Host "Adding custom domain $CustomDomain..."
    az webapp config hostname add --resource-group $ResourceGroup --webapp-name $AppServiceName --hostname $CustomDomain
    
    if ($SslCertThumbprint) {
        Write-Host "Binding SSL certificate (thumbprint: $SslCertThumbprint) to $CustomDomain..."
        az webapp config ssl bind --resource-group $ResourceGroup --name $AppServiceName --certificate-thumbprint $SslCertThumbprint --ssl-type SNI --hostname $CustomDomain
    }
}

Write-Host "Deployment completed. Your site should be reachable via HTTPS."
