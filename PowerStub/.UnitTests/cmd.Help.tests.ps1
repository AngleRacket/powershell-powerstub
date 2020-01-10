. "$PSScriptRoot\shared\common.ps1"

# Pester tests
Set-StrictMode -Version Latest

Describe "Invoke-PowerStub" {

  Context "Help" {
    It "Should not fail with Get-Commands parameter" {
      try {
        $success = $true; $Error.clear(); $global:LASTEXITCODE = 0; $exitCode = 0;
        write-host $powerStubCmd
        & $powerStubCmd "Help" "Get-Commands"
        $success = $?
        if (Test-Path VARIABLE:GLOBAL:LASTEXITCODE) { $exitCode = $GLOBAL:LASTEXITCODE; } else { $exitCode = 0; }
      }
      catch {
        $success = $false
      }

      $exitCode | Should -Be 0
      $success | Should -Be $true
      
    }

    It "Should fail with a command that does not exist" {
      try {
        $success = $true; $Error.clear(); $global:LASTEXITCODE = 0; $exitCode = 0;
        & $powerStubCmd "Help" "command-that-doesnt-exist"
        $success = $?
        if (Test-Path VARIABLE:GLOBAL:LASTEXITCODE) { $exitCode = $GLOBAL:LASTEXITCODE; } else { $exitCode = 0; }
      }
      catch {
        $success = $false
      }

      $exitCode | Should -Be 1
      $success | Should -Be $false
      
    }
  }
}


