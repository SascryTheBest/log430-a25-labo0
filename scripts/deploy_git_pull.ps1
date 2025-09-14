# C:\Users\Assal\deploy_git_pull.ps1
$ErrorActionPreference = "Stop"

# --- CONFIG ---
$RepoUrl = "https://github.com/SascryTheBest/log430-a25-labo0.git"
$Branch  = "main"
$AppDir  = "C:\Users\Assal\apps\log430-a25-labo0"
$Token   = "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"   # <-- put your PAT here
# -------------

$env:GIT_TERMINAL_PROMPT = "0"
$env:GCM_INTERACTIVE     = "Never"

if (-not $Token -or $Token.Length -lt 20) {
  throw "PAT missing/too short. Put a real token in `$Token."
}

# Helper: build URL with token
function Add-TokenToUrl([string]$url, [string]$token) {
  return ($url -replace '^https://', "https://x-access-token:$token@")
}

# Ensure parent exists
$parent = Split-Path $AppDir
New-Item -ItemType Directory -Force $parent | Out-Null

# Git presence
git --version | Write-Host

if (-not (Test-Path (Join-Path $AppDir ".git"))) {
  Write-Host "Cloning fresh into $AppDir ..."
  $urlWithToken = Add-TokenToUrl $RepoUrl $Token
  git -c credential.helper= clone $urlWithToken $AppDir
  if ($LASTEXITCODE -ne 0) { throw "git clone failed" }

  Push-Location $AppDir
  try {
    git remote set-url origin $RepoUrl
  } finally {
    Pop-Location
  }
} else {
  Write-Host "Repo exists, updating ..."
}

Push-Location $AppDir
try {
  $cleanUrl     = (git remote get-url origin).Trim()
  $tokenizedUrl = Add-TokenToUrl $cleanUrl $Token
  git remote set-url origin $tokenizedUrl

  Write-Host "Fetching origin ..."
  git fetch --prune
  if ($LASTEXITCODE -ne 0) { throw "git fetch failed (check PAT)" }

  Write-Host "Checking out $Branch ..."
  git checkout $Branch
  if ($LASTEXITCODE -ne 0) { throw "git checkout failed" }

  Write-Host "Resetting to origin/$Branch ..."
  git reset --hard "origin/$Branch"
  if ($LASTEXITCODE -ne 0) { throw "git reset failed" }

} finally {
  git remote set-url origin $RepoUrl | Out-Null
  Pop-Location
}

$sha = (git -C $AppDir rev-parse --short HEAD).Trim()
Set-Content -Path (Join-Path $AppDir 'DEPLOY_SHA.txt') -Value $sha
Write-Host "Deploy OK -> $AppDir (HEAD=$sha)"
