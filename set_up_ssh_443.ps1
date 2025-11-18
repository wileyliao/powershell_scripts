# 建立 .ssh 目錄（如果沒有）
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.ssh" | Out-Null

# 寫入 SSH over HTTPS 設定
@"
Host github.com
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile $env:USERPROFILE\.ssh\id_rsa
  IdentitiesOnly yes
"@ | Set-Content "$env:USERPROFILE\.ssh\config"

Write-Host "Sucessful: SSH over HTTPS (Port 443)"
Write-Host "Test connect: ssh -T -p 443 git@ssh.github.com"
