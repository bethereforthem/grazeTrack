# GrazeTrack — One-Click Server Starter
# Run this script every time you want to start the backend.
# It will: open the firewall, detect your IP, start the server, and show connection info.

# ── Auto-elevate to Administrator if not already ─────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Host "Requesting Administrator rights to open firewall port 5000..." -ForegroundColor Yellow
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ── Open Windows Firewall for port 5000 ─────────────────────────────────────
$ruleName = "GrazeTrack API Port 5000"
$existingRule = netsh advfirewall firewall show rule name=$ruleName 2>$null
if ($existingRule -notmatch "Rule Name") {
    netsh advfirewall firewall add rule name=$ruleName dir=in action=allow protocol=TCP localport=5000 | Out-Null
    Write-Host "Firewall rule added: port 5000 is now open." -ForegroundColor Green
} else {
    Write-Host "Firewall rule already exists." -ForegroundColor Green
}

# ── Detect your local network IP ─────────────────────────────────────────────
$ip = (Get-NetIPAddress -AddressFamily IPv4 |
       Where-Object { $_.IPAddress -notmatch "^127\." -and
                      $_.IPAddress -notmatch "^169\.254\." -and
                      $_.IPAddress -notmatch "^172\." -and
                      $_.PrefixOrigin -ne "WellKnown" } |
       Sort-Object -Property InterfaceIndex |
       Select-Object -First 1).IPAddress

if (-not $ip) {
    $ip = "192.168.31.242"   # fallback to last known IP
}

$apiUrl = "http://$ip:5000/api/v1"

# ── Print connection banner ───────────────────────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  ██████╗ ██████╗  █████╗ ███████╗███████╗" -ForegroundColor Green
Write-Host "  ██╔════╝ ██╔══██╗██╔══██╗╚══███╔╝██╔════╝" -ForegroundColor Green
Write-Host "  ██║  ███╗██████╔╝███████║  ███╔╝ █████╗  " -ForegroundColor Green
Write-Host "  ██║   ██║██╔══██╗██╔══██║ ███╔╝  ██╔══╝  " -ForegroundColor Green
Write-Host "  ╚██████╔╝██║  ██║██║  ██║███████╗███████╗" -ForegroundColor Green
Write-Host "   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝" -ForegroundColor Green
Write-Host "  TRACK" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GrazeTrack Backend Server" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Your PC IP   : $ip" -ForegroundColor Yellow
Write-Host "  API URL      : $apiUrl" -ForegroundColor Yellow
Write-Host "  API Docs     : http://$ip:5000/api-docs" -ForegroundColor DarkYellow
Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor DarkCyan
Write-Host "  HOW TO CONNECT FROM YOUR PHONE:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Step 1: Make sure your phone is on the same Wi-Fi as this PC." -ForegroundColor White
Write-Host ""
Write-Host "  Step 2: Open the GrazeTrack app on your phone." -ForegroundColor White
Write-Host ""
Write-Host "  Step 3: Go to  Settings --> Server Address" -ForegroundColor White
Write-Host "          and enter exactly:" -ForegroundColor White
Write-Host ""
Write-Host "          $apiUrl" -ForegroundColor Green
Write-Host ""
Write-Host "  Step 4: Tap Save. The app will connect instantly." -ForegroundColor White
Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor DarkCyan
Write-Host "  FOR DEVELOPERS (flutter run):" -ForegroundColor Cyan
Write-Host ""
Write-Host "  flutter run --dart-define=API_URL=$apiUrl" -ForegroundColor White
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Starting server... (press Ctrl+C to stop)" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ── Start the backend server ──────────────────────────────────────────────────
$backendPath = Join-Path $PSScriptRoot "backend"
Set-Location $backendPath
node src/server.js
