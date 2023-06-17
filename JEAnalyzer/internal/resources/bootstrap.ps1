<#
.SYNOPSIS
	This is a wrapper script around whatever data was injected into it when it was built.

.DESCRIPTION
	This is a wrapper script around whatever data was injected into it when it was built.
	To inspect what is contained, run this script with the "-ExpandTo" parameter pointing at the folder where to extract it to.
	The "run.ps1" file in the root folder is what is being executed after unwrapping it if executed without parameters.

.PARAMETER ExpandTo
	Expand the wrapped code, rather than execute it.
	Specify the folder you want it exported to.

.EXAMPLE
	PS C:\> .\%scriptname%

	Execute the wrapped code.

.EXAMPLE
	PS C:\> .\%scriptname% -ExpandTo C:\temp

	Export the wrapped code to C:\temp without executing it.
#>
[CmdletBinding()]
param (
	[string]
	$ExpandTo
)

# The actual code to deploy
$payload = '%data%'

$tempPath = Join-Path -Path ([System.Environment]::GetFolderPath("LocalApplicationData")) -ChildPath 'Temp'
$name = "Bootstrap-$(Get-Random)"
$tempFile = Join-Path -Path $tempPath -ChildPath "$name.zip"

$bytes = [Convert]::FromBase64String($payload)
[System.IO.File]::WriteAllBytes($tempFile, $bytes)

if ($ExpandTo) {
	Expand-Archive -Path $tempFile -DestinationPath $ExpandTo
	Remove-Item -Path $tempFile -Force
	return
}

$tempFolder = New-Item -Path $tempPath -Name $name -ItemType Directory -Force
Expand-Archive -Path $tempFile -DestinationPath $tempFolder.FullName

$launchPath = Join-Path -Path $tempFolder.FullName -ChildPath run.ps1
try {
	& $launchPath
}
finally {
	Remove-Item -Path $tempFile -Force
	Remove-Item -Path $tempFolder.FullName -Force -Recurse
}