$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$skillsDir = Join-Path $root ".claude/skills"
if (-not (Test-Path $skillsDir)) { Write-Error "no .claude/skills dir"; exit 1 }
$fail = 0
Get-ChildItem -Path $skillsDir -Directory | ForEach-Object {
  $skill = Join-Path $_.FullName "SKILL.md"
  if (-not (Test-Path $skill)) { Write-Host ("[FAIL] {0}: no SKILL.md" -f $_.Name); $fail++; return }
  $c = Get-Content $skill -Raw
  $fm = if ($c -match '(?s)^---\s*\r?\n(.*?)\r?\n---') { $Matches[1] } else { $null }
  if (-not $fm)                          { Write-Host ("[FAIL] {0}: no frontmatter" -f $_.Name); $fail++ }
  elseif ($fm -notmatch '(?m)^name:\s*\S+')        { Write-Host ("[FAIL] {0}: no name" -f $_.Name); $fail++ }
  elseif ($fm -notmatch '(?m)^description:\s*\S+') { Write-Host ("[FAIL] {0}: no description" -f $_.Name); $fail++ }
  else { Write-Host ("[ OK ] {0}" -f $_.Name) }
}
if ($fail -gt 0) { Write-Error "$fail skill(s) failed"; exit 1 }
Write-Host "All skills valid"
