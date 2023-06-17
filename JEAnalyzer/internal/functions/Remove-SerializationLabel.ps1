function Remove-SerializationLabel {
	<#
	.SYNOPSIS
		Strips the "Deserialized." prefix out of the typenames of the specified objects.
	
	.DESCRIPTION
		Strips the "Deserialized." prefix out of the typenames of the specified objects.
		Use this if you want an object received from a remote session to look like a local object.
	
	.PARAMETER InputObject
		The object to fix the typenames of.
	
	.EXAMPLE
		PS C:\> $res = $res | Remove-SerializationLabel
		
		Renames the typenames of all objects in $res to no longer include the "Deserialized." prefix.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject
	)
	process {
		if ($null -eq $InputObject) { return }

		$names = $($InputObject.PSObject.TypeNames)
		foreach ($name in $names) {
			$null = $InputObject.PSObject.TypeNames.Remove($name)
			$InputObject.PSObject.TypeNames.Add(($name -replace '^Deserialized\.'))
		}
		$InputObject
	}
}