# scripts/deploy_git_pull.ps1
# Non-interactive deploy: clone once, then fetch/reset using a PAT without storing credentials.

param(
  [string]$Token = ""   # read from ~/pat.txt if not provided
)

$ErrorActionPreference = "Stop"

# ---- CONFIG ----
$RepoUrl = "https://github.com/SascryTheBest/log430-a25-labo0.git"
$Branch  = "main"
$AppDir  = "C:\Users\Assal\apps\log430-a25-labo0"
# ---------------

# Make git non-interactive; never prompt/persist creds
$env:GIT_TERMINAL_PROMPT = "0"
$env:GCM_INTERACTIVE     = "Never"

# Option: read token from temp file dropped by CI, then remove it
if (-not $Token) {
  $patFile = Join-Path $env:USERPROFILE "pat.txt"
  if (Test-Path $patFile) {
    $Token = (Get-Content $patFile -Raw).Trim()
    Remove-Item $patFile -Force -ErrorAction SilentlyContinue
  }
}

function Invoke-Git {
  param([string[]]$Args)
  if ($Token) {
    # Disable helper; pass Authorization header per-invocation
    git -c credential.helper= -c "http.extraheader=Authorization: Bearer $Token" @Args
  } else {
    git -c credential.helper= @Args
  }
}

# Prepare target dir
New-Item -ItemType Directory -Force (Split-Path $AppDir) | Out-Null

# Clone if needed (using token in URL once), then set clean origin URL (no creds stored)
if (-not (Test-Path (Join-Path $AppDir ".git"))) {
  Write-Host "Cloning into $AppDir ..."
  if ($Token) {
    $RepoUrlWithToken = $RepoUrl -replace '^https://', "https://x-access-token:$Token@"
    git -c credential.helper= clone $RepoUrlWithToken $AppDir
    Push-Location $AppDir
    git remote set-url origin $RepoUrl
    Pop-Location
  } else {
    git -c credential.helper= clone $RepoUrl $AppDir
  }
}

Push-Location $AppDir
try {
  Write-Host "Updating '$Branch' from origin ..."
  Invoke-Git @('fetch','--all','--prune')
  Invoke-Git @('checkout', $Branch)
  Invoke-Git @('reset','--hard',"origin/$Branch")

  $sha = (git rev-parse --short HEAD).Trim()
  Set-Content -Path (Join-Path $AppDir 'DEPLOY_SHA.txt') -Value $sha
  Write-Host "Deploy OK -> $AppDir (HEAD=$sha)"
}
finally {
  Pop-Location
}
