param(
    [Parameter(Mandatory=$true, Position=0)][string]$Name,
    [string]$CtfHost = "TBD",
    [string]$FlagPrefix = "FLAG"
)
$ErrorActionPreference = "Stop"
$slug = ($Name.ToLower() -replace '[^a-z0-9]+','-').Trim('-')
if (-not $slug) { Write-Error "name has no usable characters"; exit 1 }
$root = Split-Path -Parent $PSScriptRoot
$dir  = Join-Path $root "ctfs/$slug"
if (Test-Path $dir) { Write-Error "CTF already exists: $dir"; exit 1 }
New-Item -ItemType Directory -Path (Join-Path $dir "challenges") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $dir "artifacts")  | Out-Null
New-Item -ItemType File -Path (Join-Path $dir "challenges/.gitkeep") | Out-Null
New-Item -ItemType File -Path (Join-Path $dir "artifacts/.gitkeep")  | Out-Null
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$tpl = Get-Content (Join-Path $root "templates/CTF.md") -Raw -Encoding UTF8
$tpl = $tpl.Replace("{{NAME}}", $Name).Replace("{{SLUG}}", $slug).Replace("{{FLAG_PREFIX}}", $FlagPrefix).Replace("{{HOST}}", $CtfHost)
[System.IO.File]::WriteAllText((Join-Path $dir "CTF.md"), $tpl, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $root "ctfs/.active"), "$slug`n", $utf8NoBom)
Write-Host "Created $dir and set active CTF -> $slug"
Write-Host 'Next: tools/new-challenge.ps1 <category> "<name>"'
