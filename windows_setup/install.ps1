# DeniKey Kurulum Scripti
# Yönetici olarak çalıştırın: sağ tık → "PowerShell ile çalıştır"

$AppName    = "DeniKey"
$AppVersion = "1.0.0"
$Publisher  = "DeniKey"
$InstallDir = "$env:LOCALAPPDATA\DeniKey"
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir  = Join-Path $ScriptDir "bundle"
$ExePath    = "$InstallDir\DeniKey.exe"

Write-Host "DeniKey kuruluyor..." -ForegroundColor Cyan

# Kurulum dizini oluştur
if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

# Dosyaları kopyala
Write-Host "Dosyalar kopyalanıyor..." -ForegroundColor Gray
Copy-Item -Path "$SourceDir\*" -Destination $InstallDir -Recurse -Force

# Masaüstü kısayolu
$DesktopShortcut = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "DeniKey.lnk")
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($DesktopShortcut)
$Shortcut.TargetPath    = $ExePath
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.IconLocation  = "$ExePath,0"
$Shortcut.Description   = "DeniKey - Sıfır Bilgi Şifre Yöneticisi"
$Shortcut.Save()

# Start Menu kısayolu
$StartMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\DeniKey"
if (!(Test-Path $StartMenuDir)) {
    New-Item -ItemType Directory -Path $StartMenuDir | Out-Null
}
$StartShortcut = $WshShell.CreateShortcut("$StartMenuDir\DeniKey.lnk")
$StartShortcut.TargetPath      = $ExePath
$StartShortcut.WorkingDirectory = $InstallDir
$StartShortcut.IconLocation    = "$ExePath,0"
$StartShortcut.Description     = "DeniKey - Sıfır Bilgi Şifre Yöneticisi"
$StartShortcut.Save()

# Kaldır kısayolu (Start Menu)
$UninstallShortcut = $WshShell.CreateShortcut("$StartMenuDir\DeniKey Kaldır.lnk")
$UninstallShortcut.TargetPath = "powershell.exe"
$UninstallShortcut.Arguments  = "-ExecutionPolicy Bypass -File `"$InstallDir\uninstall.ps1`""
$UninstallShortcut.Save()

# Kaldırma scripti oluştur
$UninstallScript = @"
Remove-Item -Path '$InstallDir' -Recurse -Force
Remove-Item -Path '$DesktopShortcut' -Force -ErrorAction SilentlyContinue
Remove-Item -Path '$StartMenuDir' -Recurse -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\DeniKey' -Name * -ErrorAction SilentlyContinue
Write-Host 'DeniKey kaldırıldı.' -ForegroundColor Green
Start-Sleep 2
"@
Set-Content -Path "$InstallDir\uninstall.ps1" -Value $UninstallScript

# Windows Programlar listesine ekle (Ayarlar → Uygulamalar)
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\DeniKey"
New-Item -Path $RegPath -Force | Out-Null
Set-ItemProperty -Path $RegPath -Name "DisplayName"     -Value $AppName
Set-ItemProperty -Path $RegPath -Name "DisplayVersion"  -Value $AppVersion
Set-ItemProperty -Path $RegPath -Name "Publisher"       -Value $Publisher
Set-ItemProperty -Path $RegPath -Name "InstallLocation" -Value $InstallDir
Set-ItemProperty -Path $RegPath -Name "DisplayIcon"     -Value "$ExePath,0"
Set-ItemProperty -Path $RegPath -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$InstallDir\uninstall.ps1`""
Set-ItemProperty -Path $RegPath -Name "NoModify"        -Value 1 -Type DWord
Set-ItemProperty -Path $RegPath -Name "NoRepair"        -Value 1 -Type DWord

Write-Host ""
Write-Host "DeniKey basariyla kuruldu!" -ForegroundColor Green
Write-Host "  Masaustu: DeniKey kisayolu olusturuldu"     -ForegroundColor Gray
Write-Host "  Baslat Menusu: DeniKey klasoru olusturuldu" -ForegroundColor Gray
Write-Host "  Ayarlar > Uygulamalar: DeniKey listelendi"  -ForegroundColor Gray
Write-Host ""
Write-Host "Uygulamayi baslatmak icin masaustundeki DeniKey ikonuna tiklayin." -ForegroundColor Cyan
Start-Sleep 2
