# iMorph Reloader - Restart WoW + Re-inject
# Since WoW anti-cheat blocks DLL unload, this script helps restart quickly
# Run as Administrator!

Write-Host ""
Write-Host "=== iMorph Reloader ===" -ForegroundColor Cyan
Write-Host ""

# Check if WoW is running
$wow = Get-Process -Name "Wow" -ErrorAction SilentlyContinue
if ($wow) {
    Write-Host "[OK] Found Wow.exe (PID: $($wow.Id))" -ForegroundColor Green
    Write-Host ""
    Write-Host "WoW anti-cheat blocks DLL unload." -ForegroundColor Yellow
    Write-Host "Need to restart WoW client." -ForegroundColor Yellow
    Write-Host ""

    $answer = Read-Host "Restart WoW now? (Y/N)"
    if ($answer -ne "Y" -and $answer -ne "y") {
        Write-Host "Cancelled." -ForegroundColor Red
        Start-Sleep -Seconds 2
        exit 0
    }

    Write-Host "[..] Closing WoW..." -ForegroundColor Yellow
    Stop-Process -Name "Wow" -Force
    Start-Sleep -Seconds 3
    Write-Host "[OK] WoW closed" -ForegroundColor Green
} else {
    Write-Host "[OK] Wow.exe not running" -ForegroundColor Green
}

# Ask user to start WoW and login
Write-Host ""
Write-Host "Please start WoW and login to your character." -ForegroundColor Cyan
Write-Host "When you see the game world, press Enter..." -ForegroundColor Cyan
Read-Host

# Wait a bit for full load
Write-Host "[..] Waiting for game to fully load..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Run RuniMorph.exe
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$exePath = Join-Path $scriptDir "RuniMorph.exe"
if (Test-Path $exePath) {
    Write-Host "[..] Injecting iMorph..." -ForegroundColor Yellow
    Start-Process -FilePath $exePath -WorkingDirectory $scriptDir
    Write-Host "[OK] Done! iMorph should be working." -ForegroundColor Green
} else {
    Write-Host "[FAIL] RuniMorph.exe not found" -ForegroundColor Red
}

Start-Sleep -Seconds 2
