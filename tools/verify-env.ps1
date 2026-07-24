$ErrorActionPreference = "Continue"
$checks = @(
  @{ Name="Python";                    Kind="cmd";   Probe="python";          Hint="https://www.python.org/downloads/" },
  @{ Name="pwntools";                  Kind="pymod"; Probe="pwn";             Hint="pip install pwntools" },
  @{ Name="Ghidra (analyzeHeadless)";  Kind="cmd";   Probe="analyzeHeadless"; Hint="https://ghidra-sre.org/ (add support/ to PATH)" },
  @{ Name="ROPgadget";                 Kind="cmd";   Probe="ROPgadget";       Hint="pip install ROPgadget" },
  @{ Name="binwalk";                   Kind="cmd";   Probe="binwalk";         Hint="pip install binwalk" },
  @{ Name="exiftool";                  Kind="cmd";   Probe="exiftool";        Hint="https://exiftool.org/" },
  @{ Name="tshark";                    Kind="cmd";   Probe="tshark";          Hint="https://www.wireshark.org/ (install CLI tools)" },
  @{ Name="foremost";                  Kind="cmd";   Probe="foremost";        Hint="apt/brew install foremost (or use binwalk)" },
  @{ Name="file";                      Kind="cmd";   Probe="file";            Hint="Git Bash / coreutils" }
)
$missing = 0
foreach ($c in $checks) {
  $ok = $false
  if ($c.Kind -eq "cmd") { $ok = [bool](Get-Command $c.Probe -ErrorAction SilentlyContinue) }
  elseif ($c.Kind -eq "pymod") { python -c "import $($c.Probe)" 2>$null; $ok = ($LASTEXITCODE -eq 0) }
  if ($ok) { Write-Host ("[ OK ] " + $c.Name) }
  else { Write-Host ("[MISS] " + $c.Name + "  ->  " + $c.Hint); $missing++ }
}
Write-Host ""
Write-Host ("Missing: {0} of {1}" -f $missing, $checks.Count)
Write-Host "GUI/extension tools (Burp+PortSwigger MCP, Ghidra+ReVa): verify via their UIs and the Claude Code /mcp command."
