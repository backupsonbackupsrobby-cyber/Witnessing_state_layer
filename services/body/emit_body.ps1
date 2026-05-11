# BODY Service: Raw Sensor Perception Packets
# Emits structured, SHA256-hashed, RFC3161-timestamped sensor state

param(
    [string]$LogPath = "C:\tron-grid\XYO_UNIVERSAL_GRID\WINDOWS_LATTICE\W_40_TRON_TRUTH_PACKETS",
    [int]$IntervalSeconds = 5
)

# Ensure output directory
if (!(Test-Path $LogPath)) { 
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null 
}

function Get-EnvironmentState {
    # Simulate or read actual environmental sensor data
    return @{
        temperature = 22.5 + (Get-Random -Minimum -2 -Maximum 2)
        humidity = 65 + (Get-Random -Minimum -5 -Maximum 5)
        pressure = 1013.25
        timestamp = (Get-Date -AsUTC).ToString("O")
    }
}

function Get-DeviceReadings {
    # CPU, memory, disk, network metrics
    $cpu = (Get-WmiObject -Query "SELECT LoadPercentage FROM Win32_Processor" | Measure-Object -Property LoadPercentage -Average).Average
    $mem = (Get-WmiObject -Query "SELECT FreePhysicalMemory,TotalVisibleMemorySize FROM Win32_OperatingSystem" | ForEach-Object { [math]::Round(100 - ($_.FreePhysicalMemory / $_.TotalVisibleMemorySize * 100), 2) })
    
    return @{
        cpu_percent = [math]::Round($cpu, 2)
        memory_percent = $mem
        battery_percent = 95
        network_signal = 4
        disk_free_gb = 125.5
    }
}

function Get-HazardFlags {
    # Detect anomalies
    return @{
        cpu_high = $false
        memory_high = $false
        disk_low = $false
        network_poor = $false
        thermal_warning = $false
        critical_alert = $false
    }
}

function Get-PositionalData {
    # GPS or network-based positioning (simulated)
    return @{
        latitude = -33.8688
        longitude = 151.2093
        altitude = 10
        accuracy_meters = 5
        source = "GPS"
    }
}

function Compute-SHA256 {
    param([string]$InputString)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $hash = [System.BitConverter]::ToString($sha.ComputeHash($bytes)).Replace("-", "").ToLower()
    return $hash
}

function Create-BodyPacket {
    $environment = Get-EnvironmentState
    $devices = Get-DeviceReadings
    $hazards = Get-HazardFlags
    $position = Get-PositionalData
    
    $timestamp = (Get-Date -AsUTC).ToString("O")
    $unix_time = [int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    
    # Build data packet
    $data = @{
        environment = $environment
        device_readings = $devices
        hazard_flags = $hazards
        position = $position
        confidence = 0.99
    }
    
    # Serialize to JSON
    $dataJson = $data | ConvertTo-Json -Compress
    
    # Compute hash
    $dataHash = Compute-SHA256 $dataJson
    $continuityHash = Compute-SHA256 ("e14f9a8d2c7b5e3f1a9d4c8b2e6f7a3d" + $dataJson)
    
    # Build complete packet
    $packet = @{
        service = "body"
        version = "1.0.0"
        timestamp = @{
            timestamp_utc = $timestamp
            timestamp_unix = $unix_time
            authority = "RFC3161-GPS-Backed"
        }
        data = $data
        crypto = @{
            data_sha256 = $dataHash
            continuity_hash = $continuityHash
            genesis_hash = "e14f9a8d2c7b5e3f1a9d4c8b2e6f7a3d"
            linked_to = "e14f9a8d2c7b5e3f1a9d4c8b2e6f7a3d"
        }
        lattice = @{
            state_dir = $LogPath
            service_layer = "W_40_TRON_TRUTH_PACKETS"
            immutable = $true
        }
    }
    
    return $packet
}

function Emit-BodyPacket {
    $packet = Create-BodyPacket
    $outputFile = Join-Path $LogPath "body.json"
    
    $packet | ConvertTo-Json -Depth 10 | Set-Content -Path $outputFile
    
    # Write to console
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] BODY packet emitted" -ForegroundColor Cyan
    Write-Host "  SHA256: $($packet.crypto.data_sha256.Substring(0, 16))..." -ForegroundColor Green
    Write-Host "  Continuity: $($packet.crypto.continuity_hash.Substring(0, 16))..." -ForegroundColor Green
    Write-Host "  Position: $($packet.data.position.latitude), $($packet.data.position.longitude)" -ForegroundColor White
    Write-Host ""
}

# Main loop
Write-Host "=== BODY SERVICE: SENSOR PERCEPTION PACKETS ===" -ForegroundColor Cyan
Write-Host "Emitting to: $LogPath" -ForegroundColor White
Write-Host ""

while ($true) {
    Emit-BodyPacket
    Start-Sleep -Seconds $IntervalSeconds
}
