# Wi-Fi diagnostic for Windows - read-only, changes nothing.
# Run: right-click PowerShell > Run as Administrator, then:
#   powershell -ExecutionPolicy Bypass -File .\wifi-diag-windows.ps1
$out = "$env:USERPROFILE\Desktop\wifi-report.txt"
Start-Transcript -Path $out -Force | Out-Null

Write-Host "=== 1. Current Wi-Fi link (signal, channel, band, link rate) ==="
netsh wlan show interfaces

Write-Host "`n=== 2. Nearby networks (channel congestion) ==="
netsh wlan show networks mode=bssid

$gw = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1).IPv4DefaultGateway.NextHop
Write-Host "`n=== 3. Ping router ($gw) - tests Wi-Fi link quality ==="
ping -n 30 $gw

Write-Host "`n=== 4. Ping internet (1.1.1.1) - tests ISP ==="
ping -n 30 1.1.1.1

Write-Host "`n=== 5. DNS lookup speed ==="
foreach ($d in "google.com","netflix.com","microsoft.com") {
  $t = Measure-Command { Resolve-DnsName $d -DnsOnly -ErrorAction SilentlyContinue | Out-Null }
  Write-Host ("{0,-15} {1,6:N0} ms" -f $d, $t.TotalMilliseconds)
}

Write-Host "`n=== 6. Route to internet ==="
tracert -d -h 10 1.1.1.1

Write-Host "`n=== 7. Wi-Fi adapter / driver ==="
Get-NetAdapter -Physical | Where-Object { $_.MediaType -match "802.11|Native" -or $_.Name -match "Wi-?Fi" } |
  Format-List Name, InterfaceDescription, DriverVersion, DriverDate, LinkSpeed

Stop-Transcript | Out-Null
Write-Host "`nReport saved to $out - paste its contents back to Claude."
