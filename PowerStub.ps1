<#
.SYNOPSIS
  Stub is an example implementation of PowerStub
.DESCRIPTION
  Stub is an example implementation of PowerStub
.EXAMPLE
  PS C:\> stub Get-Commands

  Shows a list of all available commands.
.EXAMPLE
  PS C:\> stub help Get-Commands

  Shows the help information for "Get-Commands"
#>
[CmdletBinding()]
param (
  [Parameter(ValueFromRemainingArguments = $true)] [object[]]$Parameters
)

DynamicParam {
  #!!!! this line must be updated to point to the correct folder
  #this assumes PowerStub folder is beneath the current script folder
  $powerStubPath = Join-Path $PSScriptRoot "PowerStub"

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

begin {
  #!!!! this line must be updated to point to the correct folder
  $powerStubPath = Join-Path $PSScriptRoot "PowerStub"
  $powerStubCmd = Join-Path $powerStubPath "Invoke-PowerStub.ps1"

  $commandName = $PSBoundParameters['Command']
  #$Parameters = $MyInvocation.UnboundArguments
  if ($null -eq $Parameters) { $Parameters = @() }
  $stubCommand = $MyInvocation.MyCommand.Source
}

process {
  $Error.clear()
  $global:LASTEXITCODE = 0
  $exitCode = 0

  & $powerStubCmd $stubCommand $commandName $Parameters

  $success = $?

  if (Test-Path VARIABLE:GLOBAL:LASTEXITCODE) { $exitCode = $GLOBAL:LASTEXITCODE; } 
  else { 
    if (Test-Path VARIABLE:LASTEXITCODE) { $exitCode = $LASTEXITCODE; }
    else { $exitCode = 0; }
  }

  if (!$success -or ($exitCode -ne 0)) {
    Exit $exitCode
  }
}
