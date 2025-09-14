$ErrorActionPreference = "Stop"

# --- CONFIG ---
$RepoUrl = "https://github.com/SascryTheBest/log430-a25-labo0.git"
$Branch  = "main"
$AppDir  = "C:\Users\Assal\apps\log430-a25-labo0"
# Replace with your PAT (fine-grained or classic with repo read access)
$Token   = "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"
# --------------

# Non-interactive
$env:GIT_TERMINAL_PROMPT = "0"
$env:GCM_INTERACTIVE     = "Never"

# Ensure parent exists
New-Item -ItemType Directory -Force (Split-Path $AppDir) | Out-Null

if (-not (Test-Path (Join-Path $AppDir ".git"))) {
  Write-Host "Cloning into $AppDir ..."
  $urlWithToken = $RepoUrl -replace '^https://', "https://x-access-token:$Token@"
  & git -c credential.helper= clone $urlWithToken $AppDir
  if ($LASTEXITCODE -ne 0) { throw "git clone failed" }
  Push-Location $AppDir
  & git remote set-url origin $RepoUrl
  Pop-Location
}

Push-Location $AppDir
try {
  Write-Host "Updating '$Branch' from origin ..."
  & git -c credential.helper= -c "http.extraheader=Authorization: Bearer $Token" fetch --all --prune
  & git checkout $Branch
  & git -c credential.helper= -c "http.extraheader=Authorization: Bearer $Token" reset --hard "origin/$Branch"
  $sha = (& git rev-parse --short HEAD).Trim()
  Write-Host "Deploy OK -> $AppDir (HEAD=$sha)"
}
finally {
  Pop-Location
}
