function Start-Dashboard {
    Write-Host "=== TRON-GRID DASHBOARD ===" -ForegroundColor Cyan
    Write-Host "State endpoint: http://localhost:8000/state"
    Write-Host "Press Ctrl+C to exit." -ForegroundColor Yellow

    while (True) {
        try {
             = Invoke-WebRequest -Uri "http://localhost:8000/state" -UseBasicParsing
            Clear-Host
            Write-Host "=== TRON-GRID DASHBOARD ===" -ForegroundColor Cyan
            Write-Host .Content
        } catch {
            Clear-Host
            Write-Host "=== TRON-GRID DASHBOARD ===" -ForegroundColor Cyan
            Write-Host "State endpoint unreachable." -ForegroundColor Red
        }
        Start-Sleep -Seconds 1
    }
}
