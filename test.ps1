<#
  Copyright (c) 2025
#>

$ErrorActionPreference = 'Stop'

function Write-Header {
    Write-Host "========================================" -ForegroundColor Cyan
}

Write-Header
Write-Host "Ordem - Service Ordering Tool" -ForegroundColor Cyan
Write-Header
Write-Host ""

# -----------------------------------------------------------------------------
# Windows check (safe for all PowerShell versions)
# -----------------------------------------------------------------------------
if ($env:OS -ne "Windows_NT") {
    Write-Error "This application only runs on Windows."
    exit 1
}

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $scriptDir "dist\backend"
$uiDir      = Join-Path $scriptDir "ui"
$distUiDir  = Join-Path $scriptDir "dist\ui"

$bind = "127.0.0.1:4000"
$EndpointUrl = "http://$bind"

# -----------------------------------------------------------------------------
# Helper: open browser
# -----------------------------------------------------------------------------
function Open-Browser {
    param ([string]$Url)

    try {
        Start-Process $Url
        Write-Host "Opened browser at: $Url" -ForegroundColor Green
    }
    catch {
        Write-Warning "Could not open browser automatically. Open manually: $Url"
    }
}

# -----------------------------------------------------------------------------
# Detect dev environment
# -----------------------------------------------------------------------------
$isDevEnvironment = Test-Path (Join-Path $scriptDir "ui\package.json")

if ($isDevEnvironment) {

    Write-Host "Development environment detected." -ForegroundColor Cyan
    Write-Host ""

    # Check npm
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Error "npm is required. Install Node.js from https://nodejs.org/"
        exit 1
    }

    # Check cargo
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        Write-Error "cargo is required. Install Rust from https://rustup.rs/"
        exit 1
    }

    Write-Host "✓ npm found" -ForegroundColor Green
    Write-Host "✓ cargo found" -ForegroundColor Green
    Write-Host ""

    # Install UI deps if needed
    $nodeModulesPath = Join-Path $uiDir "node_modules"
    if (-not (Test-Path $nodeModulesPath)) {
        Write-Host "Installing UI dependencies..." -ForegroundColor Yellow
        Push-Location $uiDir
        npm install --omit=dev
        Pop-Location
    }

    # Check build artifacts
    $needsBuild = $false

    if (-not (Get-ChildItem $backendDir -Filter "*.exe" -ErrorAction Silentl*
