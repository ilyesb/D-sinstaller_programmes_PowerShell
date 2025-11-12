# =====================================================================
# Script : Uninstall-Programs.ps1
# Auteur : Ilyes Boukhris
# Objectif : Désinstaller plusieurs programmes sur une machine locale
# Contexte : Exécution dans un pipeline Azure DevOps Server 2022 (pool vs2019)
# =====================================================================

$ErrorActionPreference = "Stop"

Write-Host "=== 🚀 DÉBUT DE LA DÉSINSTALLATION SUR [$env:COMPUTERNAME] ==="
Write-Host "Date : $(Get-Date)"
Write-Host "Utilisateur : $env:USERNAME"
Write-Host "---------------------------------------------"

# Vérifie que le script tourne en administrateur
function Ensure-Admin {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "❌ Ce script doit être exécuté avec des privilèges administrateur."
        Exit 1
    }
}
Ensure-Admin

# Liste des programmes à désinstaller
$programsToUninstall = @(
    "Google Chrome",
    "Mozilla Firefox",
    "VLC media player",
    "Skype"
)

function Uninstall-Program {
    param([string]$ProgramName)
    Write-Host "`n🔍 Recherche du programme : $ProgramName ..."
    $keys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $found = $false
    foreach ($key in $keys) {
        $apps = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*$ProgramName*" }
        foreach ($app in $apps) {
            $found = $true
            Write-Host "➡️ Désinstallation de : $($app.DisplayName)"
            if ($app.UninstallString) {
                $cmd = $app.UninstallString
                if ($cmd -match "msiexec") {
                    $cmd = $cmd -replace "/I", "/x"
                    Write-Host "🧩 Exécution : msiexec /x $($app.PSChildName) /qn /norestart"
                    Start-Process "msiexec.exe" -ArgumentList "/x", $app.PSChildName, "/qn", "/norestart" -Wait
                } else {
                    Write-Host "🧩 Exécution : $cmd /quiet /norestart"
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$cmd /quiet /norestart`"" -Wait
                }
                Write-Host "✅ $($app.DisplayName) désinstallé avec succès."
            }
        }
    }
    if (-not $found) {
        Write-Host "⚠️ Programme non trouvé : $ProgramName — passage au suivant..."
    }
}

foreach ($program in $programsToUninstall) {
    try { Uninstall-Program -ProgramName $program }
    catch { Write-Host "⚠️ Erreur sur $program : $_" }
}

Write-Host "`n=== ✅ FIN DE LA DÉSINSTALLATION SUR [$env:COMPUTERNAME] ==="
