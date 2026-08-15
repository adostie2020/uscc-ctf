param(
    [Parameter(Mandatory=$true, Position=0)][string]$Category,
    [Parameter(Mandatory=$true, Position=1)][string]$Name,
    [string]$Ctf
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

# resolve active CTF: -Ctf -> $env:CTF -> ctfs/.active
$ctf = $Ctf
if (-not $ctf) { $ctf = $env:CTF }
if (-not $ctf) {
    $activeFile = Join-Path $root "ctfs/.active"
    if (Test-Path $activeFile) { $ctf = (Get-Content $activeFile -TotalCount 1).Trim() }
}
if (-not $ctf) { Write-Error "no active CTF: run tools/new-ctf.ps1 or pass -Ctf <slug> (or set `$env:CTF)"; exit 1 }
$ctfdir = Join-Path $root "ctfs/$ctf"
if (-not (Test-Path $ctfdir)) { Write-Error "CTF not found: $ctfdir"; exit 1 }

$valid = @("web","crypto","forensics","rev","pwn","misc")
if ($valid -notcontains $Category.ToLower()) { Write-Error "Category must be one of: $($valid -join ', ')"; exit 1 }
$cat  = $Category.ToLower()
$slug = ($Name.ToLower() -replace '[^a-z0-9]+','-').Trim('-')
$dir  = Join-Path $ctfdir "challenges/$cat/$slug"
if (Test-Path $dir) { Write-Error "Challenge already exists: $dir"; exit 1 }

# flag prefix from CTF.md (default FLAG)
$prefix = "FLAG"
$fmt = Select-String -Path (Join-Path $ctfdir "CTF.md") -Pattern '\*\*Flag format:\*\*' | Select-Object -First 1
if ($fmt -and $fmt.Line -match '`([^`]*)`') { $p = $Matches[1] -replace '\{.*$',''; if ($p) { $prefix = $p } }

New-Item -ItemType Directory -Path $dir | Out-Null
New-Item -ItemType Directory -Path (Join-Path $dir "files")   | Out-Null
New-Item -ItemType Directory -Path (Join-Path $dir "scripts") | Out-Null
New-Item -ItemType File -Path (Join-Path $dir "files/.gitkeep")   | Out-Null
New-Item -ItemType File -Path (Join-Path $dir "scripts/.gitkeep") | Out-Null
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$tpl = Get-Content (Join-Path $root "templates/challenge-README.md") -Raw -Encoding UTF8
$tpl = $tpl.Replace("{{NAME}}", $Name).Replace("{{CATEGORY}}", $cat)
[System.IO.File]::WriteAllText((Join-Path $dir "README.md"), $tpl, $utf8NoBom)
Copy-Item (Join-Path $root "templates/notes.md") (Join-Path $dir "notes.md")
$sol = "# Solution: $Name`n`n## Flag`n`n" + "``$prefix{...}``  <!-- paste the flag here AFTER you submit it -->`n`n## Writeup`n`n- `n"
[System.IO.File]::WriteAllText((Join-Path $dir "solution.md"), $sol, $utf8NoBom)
Write-Host "Created $dir"
