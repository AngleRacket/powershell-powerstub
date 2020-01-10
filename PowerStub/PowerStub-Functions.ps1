$preReleaseFolderName = ".PreRelease"

function Get-PreReleaseMode {
	param (
		[string] $stubName
	)

	$preReleaseMode = ""
	$envPrereleaseVarName = "$($stubName)_prerelease"
	$prereleaseVariable = get-item "env:$envPrereleaseVarName" -ErrorAction SilentlyContinue
	if ($prereleaseVariable) { $prereleaseMode = $prereleaseVariable.Value }

	return $preReleaseMode
}

function Find-PowerStubCommandLocations {
	param (
		[string] $stubName,
		[string] $stubFolder,
		[string] $systemCommandsFolder
	)

	$cmdFolder = Join-Path $stubFolder "Commands";

	$locations = @($cmdFolder)
	$preReleaseMode = Get-PreReleaseMode $stubName
	if ($preReleaseMode -eq '1') {
		$preReleaseFolder = Join-Path $stubFolder $preReleaseFolderName;
		$locations += $preReleaseFolder
	}

	#last resort, check the system command folder (help, update, get-commands, etc...)
	if ($locations -notcontains $systemCommandsFolder) { $locations += $systemCommandsFolder }
	
	return $locations
}

function Find-PowerStubCommand {
	param (
		[string] $commandName,
		[string] $stubName,
		[string] $stubFolder,
		[string] $systemCommandsFolder
	)

	#allow the command name to be passed as a full path to a ps1 file, used in unit testing
	if ($commandName -and (Test-Path $commandName)) { return $commandName }

	$locations = Find-PowerStubCommandLocations $stubName $stubFolder $systemCommandsFolder

	foreach ($location in $locations) {
		$path = Join-Path $location "$commandName.ps1"
		if (Test-Path $path) { return $path }

		$path = Join-Path $location "$commandName\$commandName.ps1"
		if (Test-Path $path) { return $path }
	}

	throw "Command '$commandName' could not be found!"
}

Function Get-EscapedString {
	param (
		[string] $value
	)

	if ($value -like "*``*") {
		$value = $value.Replace("``", "````")
	}

	if ($value -like "*`"*") {
		$value = $value.Replace("`"", "```"")
	}

	if ($value -like "* *") {
		$value = "`"" + $value + "`""
	}

	return $value
}


Function New-ExpresionString {
	param (
		[string] $command,
		[string[]] $parameters
	)

	if ($command.EndsWith(".exe")) {
		$paramString = ""
		foreach ($param in $parameters) {
			$param = Get-QuotedParam $param		
			$paramString += " " + $param
		}
	
		$command = Get-EscapedString $command
		$exp = "& $command --% " + $paramString
		
		return $exp
	}
	else {
		$paramString = ""
		foreach ($param in $parameters) {
			$param = Get-EscapedString $param		
			$paramString += " " + $param
		}
	
		$command = Get-EscapedString $command
		$exp = "& $command" + $paramString
		
		return $exp
	}
}

function Extract-NamedParameters([object[]] $params) {
	#Convert vars to hashtable
	[string]$lastvar = $null
	$namedParams = [ordered] @{ }
	$unnamedParams = @()
	foreach ($param in $params) {
		if ($param -is [string] -and $param -match '^-') {
			#New parameter
			$lastvar = $param.TrimStart('-') #remove the dash prefix
			$lastvar = $lastvar.TrimEnd(':') #remove trailing colon added by powershell
			$namedParams[$lastvar] = $true #default to true in case this is a switch
		} 
		else {
			#if the last object processed was a string param name, then this is it's value
			if ($lastvar) {
				$namedParams[$lastvar] = $param
			}
			else { #otherwise, it is an unnamed parameter 
				$unnamedParams += $param
			}
		}
	}    
	
	return @{Named = $namedParams; Unnamed = $unnamedParams }
}

function Invoke-CheckedCommandWithParams([string] $command, [object[]] $params) {
	try {
		$Error.clear()
		$global:LASTEXITCODE = 0
		$exitCode = 0

		#$hasObjects = ($params | Where-Object {!($_ -is [String])})
		$hasObjects = $false
		$stringTypes = "System.String", "String"
		foreach ($param in $params) {
			$type = $param.GetType().FullName
			if (!($stringTypes -contains $type)) {
				$hasObjects = $true
				break
			}
		}
		if ($hasObjects) {
			$processedParams = Extract-NamedParameters $params
			$named = $processedParams.Named
			$unnamed = $processedParams.Unnamed 
			#run the command
			& "$command" @unnamed @named
		}
		else { #all the parameters are strings, so lets avoid splatting problems by using a more compatible method
			$exp = New-ExpresionString $command $params
			Invoke-Expression -Command $exp
		}

		$success = $?
		if (Test-Path VARIABLE:GLOBAL:LASTEXITCODE) { $exitCode = $GLOBAL:LASTEXITCODE; } 
		else { 
			if (Test-Path VARIABLE:LASTEXITCODE) { $exitCode = $LASTEXITCODE; }
			else { $exitCode = 0; }
		}
		if (!$success -or ($exitCode -ne 0)) {
			Write-Output $("$command exited with error code " + $exitCode)
			Write-Output $("params: " + $($params -join " "))
			Exit $exitCode
		}
	}
	catch {
		Write-Output $("$command raised a PowerShell exception. " + $exitCode)
		Write-Output $("params: " + $($params -join " "))
		Write-Output $($_ | format-list -force)
		Exit 1
	}
}
