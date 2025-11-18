# ===== monitor.ps1 =====
# Monitor any outgoing packets to 180.76.76.76 and log details to CSV
$TargetIP = '180.76.76.76'
$OutFile  = Join-Path $env:USERPROFILE 'Desktop\monitor.csv'

# Create header if file does not exist
if (-not (Test-Path $OutFile)) {
    'Timestamp,Proto,Local,Remote,State,PID,ProcessName' | Out-File -Encoding UTF8 $OutFile
}

$seen = @{}

Write-Host "Monitoring started: Target $TargetIP (Press Ctrl + C to stop)`nLog file: $OutFile" -ForegroundColor Cyan

while ($true) {
    try {
        $now = Get-Date
        $seen.Clear()

        $lines = @()
        $lines += (netstat -ano -p tcp) 2>$null
        $lines += (netstat -ano -p udp) 2>$null

        $hits = $lines | Select-String $TargetIP

        foreach ($h in $hits) {
            $line = ($h.Line -replace '\s{2,}', ' ').Trim()
            $m = [regex]::Match($line, '^(TCP|UDP)\s+(\S+)\s+(\S+)(?:\s+(\S+))?\s+(\d+)$')
            if (-not $m.Success) { continue }

            $proto  = $m.Groups[1].Value
            $local  = $m.Groups[2].Value
            $remote = $m.Groups[3].Value
            $state  = $m.Groups[4].Value
            $pid    = [int]$m.Groups[5].Value

            if ($remote -notmatch [regex]::Escape($TargetIP)) { continue }

            $pname = try { (Get-Process -Id $pid -ErrorAction Stop).ProcessName } catch { '' }

            $key = "$proto|$local|$remote|$pid|$state"
            if ($seen.ContainsKey($key)) { continue }
            $seen[$key] = $true

            $csvLine = ('{0},{1},{2},{3},{4},{5},{6}' -f `
                $now.ToString('o'), $proto, $local, $remote, $state, $pid, $pname)
            Add-Content -Encoding UTF8 -Path $OutFile -Value $csvLine

            Write-Host ("[{0}] {1} {2} -> {3} {4} PID={5} {6}" -f `
                $now.ToString('HH:mm:ss'), $proto, $local, $remote, $state, $pid, $pname) -ForegroundColor Yellow
        }
    } catch {
        Write-Warning $_.Exception.Message
    }

    Start-Sleep -Seconds 3
}
