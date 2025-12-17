$ErrorActionPreference = 'Stop'

function Header {
    Write-Host "========================================" -ForegroundColor Cyan
}

Header
Write-Host "Ordem - Service Ordering Tool" -ForegroundColor Cyan
Header
Write-Host ""

if ($env:OS -ne "Windows_NT") {
    Write-Error "Windows only"
    exit 1
}

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $scriptDir "dist\backend"
$uiDir      = Join-Path $scriptDir "ui"
$distUiDir  = Join-Path $scriptDir "dist\ui"

$EndpointUrl = "http://127.0.0.1:4000"

function Open-Browser($Url) {
    try {
        Start-Process $Url
    } catch {
        Write-Warning "Open browser manually: $Url"
    }
}

$isDevEnvironment = Test-Path (Join-Path $uiDir "package.json")

if ($isDevEnvironment) {

    Write-Host "Development environment detected" -ForegroundColor Cyan

    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Error "npm not found"
        exit 1
    }

    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        Write-Error "cargo not found"
        exit 1
    }

    $nodeModules = Join-Path $uiDir "node_modules"
    if (-not (Test-Path $nodeModules)) {
        Push-Location $uiDir
        npm install --omit=dev
        Pop-Location
    }

    $backendExeList = Get-ChildItem $backendDir -Filter "*.exe" -ErrorAction SilentlyContinue
    $uiBundleExists = Test-Path (Join-Path $distUiDir "bundle.js")

    if (-not $backendExeList -or -not $uiBundleExists) {
        $buildScript = Join-Path $scriptDir "scripts\build-all.ps1"
        & $buildScript
    }
}

$backendExe = Get-ChildItem $backendDir -Filter "*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $backendExe) {
    Write-Error "Backend executable not found"
    exit 1
}

Header
Write-Host "Server starting on port 4000" -ForegroundColor Cyan
Header
Write-Host "Open browser: $EndpointUrl" -ForegroundColor Green
Write-Host ""

Open-Browser $EndpointUrl
& $backendExe.FullName
