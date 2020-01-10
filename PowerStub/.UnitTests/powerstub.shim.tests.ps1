. "$PSScriptRoot\shared\common.ps1"

# Pester tests
Set-StrictMode -Version Latest

#$argTestCommand = Resolve-Path $(Join-Path $PSScriptRoot "..\helpers\test-returnargs.ps1")
#$exitCodeTestCommand = Resolve-Path $(Join-Path $PSScriptRoot "..\helpers\test-exitcode.ps1")

$argTestCommand = "test-returnargs"
$exitCodeTestCommand = "test-exitcode"

Describe 'powerstub shim tests' {

  Context "Basic Tests" {
    It "Given no parameters, doesnt fail" {
      try {
        $success = $true
        $result = & $powerStubCmd
        $success = $?
      }
      catch {
        $success = $false
      }

      $success | Should -Be $true
    }
  }

  Context 'powerstub passes exact parameters to specified command' {
    It "passes no parameters" {
      $result = & $powerStubCmd $argTestCommand
      $result | Should -Be $null
    }

    It "passes one parameter" {
      $result = & $powerStubCmd $argTestCommand 1
      $result | Should -Be "1"
    }

    It "passes multiple parameters" {
      $result = & $powerStubCmd $argTestCommand 1 2 3
      $result | Should -Be @(1, 2, 3)
    }

    It "passes parameters with param names" {
      $result = & $powerStubCmd $argTestCommand -first 1 -second 2 -third 3
      $result | Should -Be @("-first:", 1, "-second:", 2, "-third:", 3)
    }

    It "passes quoted parameter" {
      $p = "a b c"
      $result = & $powerStubCmd $argTestCommand $p
      $result | Should -Be @($p)
    }

    It "passes quoted parameter with other parameters" {
      $p = "a b c"
      $result = & $powerStubCmd $argTestCommand 1 $p 2
      $result | Should -Be @(1, $p, 2)
    }

    It "passes multiple quoted parameter with other parameters" {
      $p = "a b c"
      $result = & $powerStubCmd $argTestCommand 1 $p 2 $p $p 3
      $result | Should -Be @(1, $p, 2, $p, $p, 3)
    }

    It "passes quoted parameter with double quotes" {
      $p = "a `"b`" c"
      $result = & $powerStubCmd $argTestCommand $p
      $result | Should -Be @($p)
    }

    It "passes multiple quoted parameter with double quotes and other parameters" {
      $p = "a `"b`" c"
      $result = & $powerStubCmd $argTestCommand 1 $p 2 $p $p 3
      $result | Should -Be @(1, $p, 2, $p, $p, 3)
    }

    It "passes quoted parameter with unmatched double quotes" {
      $p = "a `"b c"
      $result = & $powerStubCmd $argTestCommand $p
      $result | Should -Be @($p)
    }

    It "passes multiple quoted parameter with unmatched double quotes and other parameters" {
      $p = "a `"b c"
      $result = & $powerStubCmd $argTestCommand 1 $p 2 $p $p 3
      $result | Should -Be @(1, $p, 2, $p, $p, 3)
    }

    It "passes quoted parameter with double double quotes" {
      $p = "a `"`"b`"`" c"
      $result = & $powerStubCmd $argTestCommand $p
      $result | Should -Be @($p)
    }

    It "passes quoted parameter with single quotes" {
      $p = "a 'b' c"
      $result = & $powerStubCmd $argTestCommand $p
      $result | Should -Be @($p)
    }

    It "passes string parameters carriage return quotes" {
      $p = "a `nb c"
      $result = & $powerStubCmd $argTestCommand $p
      $result | Should -Be @($p)
    }

    It "passes object parameters" {
      #obj has multiple properties
      $obj = Get-Location
      $result = & $powerStubCmd $argTestCommand 1 $obj
      $result | Should -Be @(1, $obj)
    }
  }

  Context "Exit code tests" {
    It "return command exit code when 1" {
      [int] $exitCode = 1
      $result = & $powerStubCmd $exitCodeTestCommand $exitCode
      $GLOBAL:LASTEXITCODE | Should -Be $exitCode
    }

    It "return command exit code when greater than 1" {
      [int] $exitCode = 99
      $result = & $powerStubCmd $exitCodeTestCommand $exitCode
      $GLOBAL:LASTEXITCODE | Should -Be $exitCode
    }

    It "return command exit code when -1" {
      [int] $exitCode = -1
      $result = & $powerStubCmd $exitCodeTestCommand $exitCode
      $GLOBAL:LASTEXITCODE | Should -Be $exitCode
    }

    It "return command exit code when exception thrown" {
      [int] $exitCode = 1
      $result = & $powerStubCmd $exitCodeTestCommand $exitCode "ERROR!"
      $GLOBAL:LASTEXITCODE | Should -Be $exitCode
    }
  }
}


