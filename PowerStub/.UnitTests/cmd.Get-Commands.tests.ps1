. "$PSScriptRoot\shared\common.ps1"

# Pester tests
Set-StrictMode -Version Latest

Describe "Invoke-PowerStub" {

  Context "Get-Command" {
    It "Should Not Fail With No Parameters" {
      try {
        $success = $true; $Error.clear(); $global:LASTEXITCODE = 0; $exitCode = 0;
        & $powerStubCmd "Get-Commands"
        $success = $?
        if (Test-Path VARIABLE:GLOBAL:LASTEXITCODE) { $exitCode = $GLOBAL:LASTEXITCODE; } else { $exitCode = 0; }
      }
      catch {
        $success = $false
      }

      $exitCode | Should -Be 0
      $success | Should -Be $true
      
    }
  }
}

