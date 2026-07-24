param(
    [Parameter(Mandatory=$true)][string]$Category,
    [Parameter(Mandatory=$true)][string]$Name
)
$ErrorActionPreference = "Stop"
$valid = @("web","crypto","forensics","rev","pwn","misc")
if ($valid -notcontains $Category.ToLower()) {
    Write-Error "Category must be one of: $($valid -join ', ')"; exit 1
}
$cat  = $Category.ToLower()
$slug = ($Name.ToLower() -replace '[^a-z0-9]+','-').Trim('-')
$root = Split-Path -Parent $PSScriptRoot
$dir  = Join-Path $root "challenges/$cat/$slug"
if (Test-Path $dir) { Write-Error "Challenge already exists: $dir"; exit 1 }

New-Item -ItemType Directory -Path $dir | Out-Null
New-Item -ItemType Directory -Path (Join-Path $dir "files")   | Out-Null
New-Item -ItemType Directory -Path (Join-Path $dir "scripts") | Out-Null
New-Item -ItemType File -Path (Join-Path $dir "files/.gitkeep")   | Out-Null
New-Item -ItemType File -Path (Join-Path $dir "scripts/.gitkeep") | Out-Null

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$tpl = Get-Content (Join-Path $root "templates/challenge-README.md") -Raw
$tpl = $tpl.Replace("{{NAME}}", $Name).Replace("{{CATEGORY}}", $cat)
[System.IO.File]::WriteAllText((Join-Path $dir "README.md"), $tpl, $utf8NoBom)

Copy-Item (Join-Path $root "templates/notes.md") (Join-Path $dir "notes.md")

$sol = "# Solution: $Name`n`n## Flag`n`n" +
       "``USCC{...}``  <!-- paste the flag here AFTER you submit it -->`n`n## Writeup`n`n- `n"
[System.IO.File]::WriteAllText((Join-Path $dir "solution.md"), $sol, $utf8NoBom)

Write-Host "Created $dir"
