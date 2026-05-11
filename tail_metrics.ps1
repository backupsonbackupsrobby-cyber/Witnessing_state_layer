# XYO Lattice Metrics Tail - Deep Cycle Monitor
param(
    [int]$Lines = 20,
    [switch]$Follow
)

$root = "C:\tron-grid\XYO_UNIVERSAL_GRID\WINDOWS_LATTICE"

function Show-MetricsHead {
    Write-Host "=== XYO LATTICE DEEP CYCLE METRICS ===" -ForegroundColor Cyan
    Write-Host ""
    
    # W_02_XYO
    Write-Host "--- W_02_XYO ANCHOR ---" -ForegroundColor Yellow
    Get-Content -Path "$root\W_02_XYO\XYO_LOCK.txt" -Head $Lines
    Write-Host ""
    
    # W_05_RF_250GHZ
    Write-Host "--- W_05_RF_250GHZ NETWORK ---" -ForegroundColor Yellow
    Get-Content -Path "$root\W_05_RF_250GHZ\RF_250GHZ_LOCK.txt" -Head $Lines
    Write-Host ""
    
    # W_07_MCP_MOUTH
    Write-Host "--- W_07_MCP_MOUTH CONTINUITY (last $Lines lines) ---" -ForegroundColor Yellow
    Get-Content -Path "$root\W_07_MCP_MOUTH\TRON_CONTINUITY_HASH.txt" -Tail $Lines
    Write-Host ""
}

function Show-MetricsTail {
    while ($true) {
        Clear-Host
        Show-MetricsHead
        Start-Sleep -Seconds 2
    }
}

if ($Follow) {
    Show-MetricsTail
} else {
    Show-MetricsHead
}
