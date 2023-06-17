#requires -RunAsAdministrator

<#
.SYNOPSIS
	Bootstrap launch script that will install the wrapped JEA endpoint

.DESCRIPTION
	Bootstrap launch script that will install the wrapped JEA endpoint

.PARAMETER EndpointName
	Name of the JEA Endpoint to register
#>
[CmdletBinding()]
param (
	[string]
	$EndpointName = '%name%'
)

if (-not (Test-Path -Path "$PSScriptRoot\Modules")) {
	throw "Package Error: No modules found!"
}

$moduleRoot = Join-Path -Path $env:ProgramFiles -ChildPath 'WindowsPowerShell\Modules'
foreach ($moduleFolder in Get-ChildItem -Path "$PSScriptRoot\Modules" -Directory) {
	Copy-Item -LiteralPath $moduleFolder.FullName -Destination $moduleRoot -Recurse -Force
}

$module = Import-Module -Name $EndpointName -PassThru
& $module { Register-JeaEndpoint }