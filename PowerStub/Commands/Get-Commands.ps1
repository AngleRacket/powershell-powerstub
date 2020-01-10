<#
.SYNOPSIS
  Lists commands with synopsis.
.DESCRIPTION
  Lists commands with synopsis.
.EXAMPLE
  PS C:\> Get-Commands
.PARAMETER quiet
  Limits output to only a list of commands (optional)
.PARAMETER fullName
  Limits output to only a list of commands (optional)
.PARAMETER rootFolder
  Path to folder that contains Commands (optional)
.NOTES
#>
param(
  [switch]$quiet,
  [switch]$fullName,
  [string]$rootFolder
)

. "$PSScriptRoot\..\PowerStub-Functions.ps1"

if (!$rootFolder) { $rootFolder = Resolve-Path "$PSScriptRoot\.." }

$systemCommandsFolder = $env:PowerStub_SystemCommands
if (!$systemCommandsFolder) { $systemCommandsFolder = $PSScriptRoot }

$stubName = $(Split-Path $rootFolder -Leaf)
$preReleaseMode = Get-PreReleaseMode $stubName

[string[]] $searchFolders = Find-PowerStubCommandLocations $stubName $rootFolder $systemCommandsFolder

function GetCommandName($fileName, $showFullName) {
  if ($showFullName) { return $fileName }
  $shortName = [IO.Path]::GetFileNameWithoutExtension($fileName);
  if ((!$quiet) -and $fileName -like "*$preReleaseFolderName*") { $shortName = "*" + $shortName } 
  return $shortName;
}

function ShouldListCommand($cmdFile) {
  if (!$cmdFile) { return $false };

  $fileName = Split-Path $cmdFile -leaf
  $fileNameOnly = [io.path]::GetFileNameWithoutExtension($fileName)
  $parentFolder = Split-Path $cmdFile -parent
  $parentFolderName = Split-Path (Split-Path $cmdFile -parent) -leaf

  #if the parent folder doesnt exactly match one of our search folders, then this must be a subcommand
  $subFolderCmd = $searchFolders -notcontains $parentFolder;

  if ($fileName.StartsWith("_")) { return $false; }
  if ($subFolderCmd -and $parentFolderName.StartsWith("_")) { return $false; }
  if ($subFolderCmd -and $parentFolderName -ne $fileNameOnly) { return $false }
  return $true
}


[string[]] $allcommands = @()
foreach ($searchFolder in $searchFolders) {
  $allcommands += @(Get-ChildItem -Path $searchFolder -include "*.ps1" -recurse | Where-Object { ShouldListCommand $_ } | select-object -ExpandProperty FullName)
}

if ($quiet) {
  $allcommands | ForEach-Object { $(GetCommandName $_ $fullName) }    
}
else {
  $helps = $allcommands | ForEach-Object { Get-Help $_ } 
  $helps |
  Select-Object @{N = "Command Name"; E = { GetCommandName $_.Name $fullName } }, @{N = "Description"; E = { $_.Synopsis } } |
  Sort-Object -Property "Command Name" |
  Format-Table -Auto

  Write-Host "Execute: $stubName help [Command] for details on a specific command" -ForegroundColor Cyan
    
  if ($preReleaseMode -eq '1') {
    Write-Host "* denotes pre-release commands" -ForegroundColor Cyan
  }
  else {
    Write-Host "Use '`$env:$($stubName)_prerelease=1' to enable pre-release commands" -ForegroundColor DarkGray
  }
    
}
