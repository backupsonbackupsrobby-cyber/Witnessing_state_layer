# XYO + 250GHz NETWORK – POWERSHELL ONLY

$rootBase = "C:\tron-grid\XYO_UNIVERSAL_GRID"
$root     = Join-Path $rootBase "WINDOWS_LATTICE"

if (!(Test-Path $rootBase)) { New-Item -Path $rootBase -ItemType Directory | Out-Null }
if (!(Test-Path $root))     { New-Item -Path $root -ItemType Directory | Out-Null }

# XYO layer
$xyoLayer = Join-Path $root "W_02_XYO"
if (!(Test-Path $xyoLayer)) { New-Item -Path $xyoLayer -ItemType Directory | Out-Null }

$ts   = [int][DateTimeOffset]::Now.ToUnixTimeSeconds()
$data = "XYO|$ts|WINDOWS_LATTICE"

$sha  = [System.Security.Cryptography.SHA512]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($data)
$hash  = [System.BitConverter]::ToString($sha.ComputeHash($bytes)).Replace("-","").ToLower()

$xyoFile = Join-Path $xyoLayer "XYO_LOCK.txt"
@"
--- XYO LAYER ---
TIMESTAMP: $ts
DATA: $data
HASH: $hash
STATUS: @XYO_ANCHORED
"@ | Set-Content $xyoFile

# 250GHz RF layer
$rfLayer = Join-Path $root "W_05_RF_250GHZ"
if (!(Test-Path $rfLayer)) { New-Item -Path $rfLayer -ItemType Directory | Out-Null }

$rfData = "RF_250GHz|$ts|XYO|WINDOWS_LATTICE"
$rfBytes = [System.Text.Encoding]::UTF8.GetBytes($rfData)
$rfHash  = [System.BitConverter]::ToString($sha.ComputeHash($rfBytes)).Replace("-","").ToLower()

$rfFile = Join-Path $rfLayer "RF_250GHZ_LOCK.txt"
@"
--- RF 250GHz NETWORK ---
TIMESTAMP: $ts
DATA: $rfData
HASH: $rfHash
STATUS: @RF_250GHZ_ANCHORED
"@ | Set-Content $rfFile

Write-Host "XYO + 250GHz network written under $root"
