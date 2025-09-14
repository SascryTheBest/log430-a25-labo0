# The file is in a specific location on the machine, and is run via SSH from GitHub Actions
$ErrorActionPreference = "Stop"

# --- CONFIG ---
$RepoUrl = "https://github.com/SascryTheBest/log430-a25-labo0.git"
$Branch  = "main"
$AppDir  = "C:\Users\Assal\apps\log430-a25-labo0"
$Token   = "PAT"   # ← The pat is put here on the machine file system, not in the repo for security reasons

$env:GIT_TERMINAL_PROMPT = "0"
$env:GCM_INTERACTIVE     = "Never"

# Helper: build URL with token
function Add-TokenToUrl([string]$url, [string]$token) {
  return ($url -replace '^https://', "https://x-access-token:$token@")
}

# Ensure parent exists
$parent = Split-Path $AppDir
New-Item -ItemType Directory -Force $parent | Out-Null

if (-not (Test-Path (Join-Path $AppDir ".git"))) {
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

  git fetch --prune
  if ($LASTEXITCODE -ne 0) { throw "git fetch failed" }

  git checkout $Branch
  if ($LASTEXITCODE -ne 0) { throw "git checkout failed" }

  git reset --hard "origin/$Branch"
  if ($LASTEXITCODE -ne 0) { throw "git reset failed" }

} finally {
  git remote set-url origin $RepoUrl | Out-Null
  Pop-Location
}

