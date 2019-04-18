function Register-JeaEndpoint
{
<#
	.SYNOPSIS
		Registers the module's JEA session configuration in WinRM.
	
	.DESCRIPTION
		Registers the module's JEA session configuration in WinRM.
		This effectively enables the module as a remoting endpoint.
	
	.EXAMPLE
		PS C:\> Register-JeaEndpoint
	
		Register this module in WinRM as a remoting target.
#>
	[CmdletBinding()]
	Param (
	
	)
	
	process
	{
		$moduleName = (Get-Item -Path "$script:ModuleRoot\*.psd1").BaseName
		Register-PSSessionConfiguration -Name $moduleName -Path "$script:ModuleRoot\sessionconfiguration.pssc" -Force
	}
}