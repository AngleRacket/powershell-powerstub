<#
.SYNOPSIS
  Displays the help associated with PowerStub scripts.
.DESCRIPTION
  Every PowerStub command script should contain standard powershell help information
  such as SYNOPSIS, DESCRIPTION, EXAMPLES, INPUTS, OUTPUTS, and NOTES.
.EXAMPLE
  PS C:\> PowerStub help Get-Commmands
.NOTES
#>
param(
  [string] $commandName,
  [string] $rootFolder
)

. "$PSScriptRoot\..\PowerStub-Functions.ps1"

$powerStubFolder = Resolve-Path "$PSScriptRoot\.."
$systemCommandsFolder = Join-Path $powerStubFolder "Commands"
if (!$rootFolder) { $rootFolder = Resolve-Path $powerStubFolder }

$stubName = $(Split-Path $rootFolder -Leaf)
$cmdScript = Find-PowerStubCommand $commandName $stubName $rootFolder $systemCommandsFolder

if (!$cmdScript -or !(Test-Path $cmdScript)) {
  #if we didn't find the command then there is nothing to do but report the error 
  #and fail with an exit code
  Write-Host "ERROR: Command '$commandName' not found!" -ForegroundColor Red
  exit 1
}

& Get-Help $cmdScript -Detailed