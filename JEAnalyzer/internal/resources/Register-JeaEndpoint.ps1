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
		try {
			$null = Get-PSSessionConfiguration -Name $moduleName -ErrorAction Stop
			Unregister-PSSessionConfiguration -Name $moduleName -Force -Confirm:$false
		}
		catch { }

		# Plan to start WinRM in case it does not recover from registering the JEA session
		$taskname = "Start-WinRM-$(Get-Random)"
		$action = New-ScheduledTaskAction -Execute powershell.exe -Argument ('-Command Start-Sleep -Seconds 60; Start-Service WinRM -Confirm:$false; Unregister-ScheduledTask -TaskName {0} -Confirm:$false' -f $taskname)
		$principal = New-ScheduledTaskPrincipal -UserId SYSTEM -RunLevel Highest
		$null = Register-ScheduledTask -TaskName $taskname -Action $action -Principal $principal
		Start-ScheduledTask -TaskName $taskname

		Register-PSSessionConfiguration -Name $moduleName -Path "$script:ModuleRoot\sessionconfiguration.pssc" -Force
	}
}