# 產生 SSH 金鑰（簡短版）
$sshPath = "$env:USERPROFILE\.ssh\id_rsa"
$pubPath = "$sshPath.pub"

if (-not (Test-Path $sshPath)) {
    Write-Host "SSH key not found, start generating..."
    $sshDir = Split-Path $sshPath
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir | Out-Null
    }
    ssh-keygen -t rsa -b 4096 -f $sshPath -N ""
    Write-Host "SSH key generated!!"
} else {
    Write-Host "SSH key already exist"
}

if (Test-Path $pubPath) {
    Write-Host "SSH key:"
    Get-Content $pubPath
} else {
    Write-Host "SSH key not found: $pubPath"
}
