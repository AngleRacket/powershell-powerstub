<#
.SYNOPSIS
	Template PowerStub Command, also used for unit testing.
.DESCRIPTION
	Template PowerStub Command, also used for unit testing.
.EXAMPLE
  PS C:\> PowerStubTemplate Get-Commands

  Shows a list of all available commands.
.EXAMPLE
  PS C:\> PowerStubTemplate help Get-Commands

  Shows the help information for "Get-Commands"
#>
[CmdletBinding()]
param (
  [Parameter(ValueFromRemainingArguments=$true)] [object[]]$Parameters
)

DynamicParam 
{
  #!!!! this line must be updated to point to the correct folder
  $powerStubPath = Resolve-Path $(Join-Path $PSScriptRoot "..")

  $dynFnPath = Join-Path $powerStubPath "New-DynamicParam.ps1"
  . $dynFnPath

  $stubName = $MyInvocation.MyCommand -replace ".ps1", ""
  $rootFolder = Join-Path $PSScriptRoot $stubName

  #get sub commands
  $listCmd = Join-Path $powerStubPath "Commands\Get-Commands.ps1";
  $commandNames = $(& $listCmd -q $rootFolder)

  $RuntimeParamDic = New-Object  System.Management.Automation.RuntimeDefinedParameterDictionary

  New-DynamicParam -Name "Command" -ValidateSet $commandNames -Position 0 -DPDictionary $RuntimeParamDic

  return $RuntimeParamDic
}

begin
{
  #!!!! this line must be updated to point to the correct folder
  $powerStubPath = Join-Path $PSScriptRoot ".."
  $powerStubCmd = Join-Path $powerStubPath "Invoke-PowerStub.ps1"

  $commandName = $PSBoundParameters['Command']
  if ($null -eq $Parameters) { $Parameters = @()}
  $stubCommand = $MyInvocation.MyCommand.Source
}

process {
  $Error.clear()
  $global:LASTEXITCODE = 0
  $exitCode = 0

  & $powerStubCmd $stubCommand $commandName $Parameters

  $success = $?

  if (Test-Path VARIABLE:GLOBAL:LASTEXITCODE) {$exitCode = $GLOBAL:LASTEXITCODE;} 
  else { 
    if (Test-Path VARIABLE:LASTEXITCODE) {$exitCode = $LASTEXITCODE;}
    else { $exitCode = 0; }
  }

  if (!$success -or ($exitCode -ne 0))
  {
    Exit $exitCode
  }
}
