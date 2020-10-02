function Install-JeaModule
{
<#
	.SYNOPSIS
		Installs a JEA module on a target endpoint.
	
	.DESCRIPTION
		Installs a JEA module on a target endpoint.
	
	.PARAMETER ComputerName
		The computers to install the module on
	
	.PARAMETER Credential
		The credentials to use for remoting
	
	.PARAMETER Module
		The module object(s) to export and install
		Generate a JEA module object using New-JeaModule
	
	.PARAMETER Basic
		Whether the JEA module should be deployed as a basic/compatibility version.
		In that mode, it will not generate a version folder and target role capabilities by name rather than path.
		This is compatible with older operating systems but prevents simple deployment via package management.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Install-JeaModule -ComputerName dc1.contoso.com,dc2.contoso.com -Module $Module
	
		Installs the JEA module in $Module on dc1.contoso.com and dc2.contoso.com
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[PSFComputer[]]
		$ComputerName,
		
		[PSCredential]
		$Credential,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[JEAnalyzer.Module[]]
		$Module,
		
		[switch]
		$Basic,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		$workingDirectory = New-Item -Path (Get-PSFPath -Name Temp) -Name "JEA_$(Get-Random)" -ItemType Directory -Force
		$credParam = $PSBoundParameters | ConvertTo-PSFHashtable -Include Credential
	}
	process
	{
		foreach ($moduleObject in $Module)
		{
			if (-not (Test-PSFShouldProcess -ActionString 'Install-JeaModule.Install' -Target ($ComputerName -join ", "))) { continue }
			
			Write-PSFMessage -String 'Install-JeaModule.Exporting.Module' -StringValues $moduleObject.Name
			Export-JeaModule -Path $workingDirectory.FullName -Module $moduleObject -Basic:$Basic
			$moduleName = "JEA_$($moduleObject.Name)"
			
			#region Establish Sessions
			Write-PSFMessage -String 'Install-JeaModule.Connecting.Sessions' -StringValues ($ComputerName -join ", ") -Target $ComputerName
			$sessions = New-PSSession -ComputerName $ComputerName -ErrorAction SilentlyContinue -ErrorVariable failedServers @credParam
			if ($failedServers)
			{
				if ($EnableException) { Stop-PSFFunction -String 'Install-JeaModule.Connections.Failed' -StringValues ($failedServers.TargetObject -join ", ") -Target $failedServers.TargetObject -EnableException $EnableException }
				foreach ($failure in $failedServers) { Write-PSFMessage -Level Warning -String 'Install-JeaModule.Connections.Failed' -StringValues $failure.TargetObject -ErrorRecord $_ -Target $failure.TargetObject }
			}
			if (-not $sessions)
			{
				Write-PSFMessage -Level Warning -String 'Install-JeaModule.Connections.NoSessions'
				return
			}
			#endregion Establish Sessions
			
			foreach ($session in $sessions)
			{
				Write-PSFMessage -String 'Install-JeaModule.Copying.Module' -StringValues $moduleObject.Name, $session.ComputerName -Target $session.ComputerName
				Copy-Item -Path "$($workingDirectory.FullName)\$moduleName" -Destination 'C:\Program Files\WindowsPowerShell\Modules' -Recurse -Force -ToSession $session
			}
			
			Write-PSFMessage -String 'Install-JeaModule.Installing.Module' -StringValues $moduleObject.Name -Target $sessions
			Invoke-Command -Session $sessions -ScriptBlock {
				Import-Module $using:moduleName
				$null = & (Get-Module $using:moduleName) { Register-JeaEndpoint -WarningAction SilentlyContinue }
			} -ErrorAction SilentlyContinue
			
			$sessions | Remove-PSSession -WhatIf:$false -Confirm:$false -ErrorAction Ignore
		}
	}
	end
	{
		Remove-Item -Path $workingDirectory.FullName -Force -Recurse -ErrorAction SilentlyContinue
	}
}