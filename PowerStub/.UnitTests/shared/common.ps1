$sharedFolder = Resolve-Path "$PSScriptRoot"
$scriptFolder = Resolve-Path "$PSScriptRoot\..\..\..\"
$powerStubCmd = Resolve-Path $(Join-Path $scriptFolder "PowerStub\.TemplateCommand\PowerStubTemplate.ps1")

$cmdRoot = Join-Path $scriptFolder "powerstub"
$cmdCommandsFolder = Join-Path $cmdRoot "Commands"
$cmdPreReleaseFolder = Join-Path $cmdRoot ".PreRelease"

if (!(Test-Path $sharedFolder)) { Throw "Testing path to shared folder '$sharedFolder' invalid!" }
if (!(Test-Path $cmdRoot)) { Throw "Testing path to command folder '$cmdCommandsFolder' invalid!" }
if (!(Test-Path $cmdPreReleaseFolder)) { Throw "Testing path to command prerelease folder '$cmdPreReleaseFolder' invalid!" }
