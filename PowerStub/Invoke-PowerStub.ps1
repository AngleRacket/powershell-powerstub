<#
.SYNOPSIS
  PowerStub offers a consistent way to organize, access, and document PowerShell scripts 
.DESCRIPTION
  PowerStub offers a consistent way to organize, access, and document PowerShell scripts 
.NOTES
  Created by Richard Carruthers on 01/01/19
#>
Param (
	[string] $stubCommand,
	[string] $commandName,
	[object[]] $parameters
)

Set-PSDebug -strict
Set-StrictMode -Version latest

. "$PSScriptRoot\PowerStub-Functions.ps1"

if ($stubCommand)
{
	$stubInvocationFolder = Split-Path $stubCommand -Parent
	$stubName = $(Split-Path $stubCommand -Leaf) -replace ".ps1", ""

	#the cmd folder is where powerstub expects to find all of the command scripts
	#either in .\[commandName].ps1 files or .\[commandName]\[commandName].ps1
	$stubRootFolder = Join-Path $stubInvocationFolder $stubName;
}
else {
	$stubName = "PowerStub"

	#the cmd folder is where powerstub expects to find all of the command scripts
	#either in .\[commandName].ps1 files or .\[commandName]\[commandName].ps1
	$stubRootFolder = $PSScriptRoot;
}

$systemCommandsFolder = Join-Path $PSScriptRoot "Commands"; 
$env:PowerStub_SystemCommands = $systemCommandsFolder

if (!($commandName))
{
	Get-Help -Detailed $stubCommand
	$stubRootFolder
	$commandName = "Get-Commands"
	$parameters = @()
}

[string] $cmdScript = Find-PowerStubCommand $commandName $stubName $stubRootFolder $systemCommandsFolder

if (!$cmdScript -or !(Test-Path $cmdScript))
{
	#if we didn't find the command then there is nothing to do but report the error 
	#and fail with an exit code
	Write-Host "ERROR: $stubName command '$commandName' not found!" -ForegroundColor Red
	ExitWithCode 1
}

#all system commands expect to be passed the root of the current stub command
if ($cmdScript.StartsWith($systemCommandsFolder))
{
	#$extraArgs.rootFolder = $stubRootFolder
	$parameters += "-rootFolder"
	$parameters += $stubRootFolder
}

Invoke-CheckedCommandWithParams $cmdScript $parameters
