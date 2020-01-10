<#
.SYNOPSIS
	Exits using provided exit code or throws an exception using the provided message
.DESCRIPTION
	Exits using provided exit code or throws an exception using the provided message
#>

param (
    [int]$exitCode,
    [string]$ExceptionMessage
)

if ($ExceptionMessage)
{
    throw $ExceptionMessage
}
else
{
    Exit $exitCode
}