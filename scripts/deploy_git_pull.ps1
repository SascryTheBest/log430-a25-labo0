# scripts/deploy_git_pull.ps1
# Met à jour le code dans C:\Users\Assal\apps\log430-a25-labo0 en clonant la 1re fois puis fetch/reset.
# Si -Token est vide, lit ~\pat.txt (puis supprime le fichier).
# should work now

param(
  [string]$Token = ""
)

$ErrorActionPreference = "Stop"

# --------- CONFIG SPÉCIFIQUE À TON CAS ---------
$RepoUrl = "https://github.com/SascryTheBest/log430-a25-labo0"
$Branch  = "main"
$AppDir  = "C:\Users\Assal\apps\log430-a25-labo0"
# -----------------------------------------------

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  throw "Git n'est pas installé sur le serveur Windows."
}

# Option: lire le token depuis un fichier déposé par la CI (et le supprimer)
if (-not $Token) {
  $patFile = Join-Path $env:USERPROFILE "pat.txt"
  if (Test-Path $patFile) {
    $Token = (Get-Content $patFile -Raw).Trim()
    Remove-Item $patFile -Force
  }
}

# Préparer le dossier
New-Item -ItemType Directory -Force (Split-Path $AppDir) | Out-Null

# Clone si nécessaire
if (-not (Test-Path (Join-Path $AppDir ".git"))) {
  Write-Host "Clonage initial dans $AppDir ..."
  if ($Token) {
    git -c http.extraheader="Authorization: Bearer $Token" clone $RepoUrl $AppDir
  } else {
    git clone $RepoUrl $AppDir
  }
}

Push-Location $AppDir
try {
  Write-Host "Mise à jour '$Branch' depuis origin ..."
  if ($Token) {
    git -c http.extraheader="Authorization: Bearer $Token" fetch --all --prune
    git -c http.extraheader="Authorization: Bearer $Token" checkout $Branch
    git -c http.extraheader="Authorization: Bearer $Token" reset --hard "origin/$Branch"
  } else {
    git fetch --all --prune
    git checkout $Branch
    git reset --hard "origin/$Branch"
  }
  $sha = (git rev-parse --short HEAD).Trim()
  Set-Content -Path (Join-Path $AppDir "DEPLOY_SHA.txt") -Value $sha
  Write-Host "Deploy OK -> $AppDir (HEAD=$sha)"
}
finally {
  Pop-Location
}
