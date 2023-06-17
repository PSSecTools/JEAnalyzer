function Uninstall-JeaModule {
	<#
	.SYNOPSIS
		Removes a JEA endpoint from the target computer, optionally including the implementing code.
	
	.DESCRIPTION
		Removes a JEA endpoint from the target computer, optionally including the implementing code.
	
	.PARAMETER ComputerName
		The computer to execute against.
		Defaults to: $env:COMPUTERNAME
	
	.PARAMETER Credential
		The credentials to use for the operation
	
	.PARAMETER Name
		The name(s) of the JEA endpoints to remove.
		Must be the exact, case insensitive name, wildcards not supported.
	
	.PARAMETER RemoveCode
		Whether to also remove the code implementing the JEA endpoint.
		When this is set, the command will check all Role Capability files registered,
		and if they are inside of a module under programfiles, the entire module will be removed.
	
	.PARAMETER Force
		Whether to skip the endpoint type check.
		By default, only full JEA session configurations are being processed.
	
	.EXAMPLE
		PS C:\> Get-JeaEndpoint | Uninstall-JeaModule -RemoveCode
		
		Removes all JEA endpoints from the current machine, including all their implementing code.
	#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PSFComputer[]]
		$ComputerName = $env:COMPUTERNAME,

		[PSCredential]
		$Credential,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$Name,

		[switch]
		$RemoveCode,

		[switch]
		$Force
	)
	begin {
		#region Scriptblock
		$scriptblock = {
			param (
				$Data
			)

			foreach ($name in $Data.Name) {
				$configuration = Get-PSSessionConfiguration | Where-Object {
					$name -eq $_.Name -and
					(
						$Data.Force -or
						$_.SessionType -EQ 'RestrictedRemoteServer'
					)
				}
				if (-not $configuration) { continue }

				Unregister-PSSessionConfiguration -Name $configuration.Name

				if (-not $Data.RemoveCode) { continue }

				$moduleRoot = "$env:ProgramFiles\WindowsPowerShell\Modules"
				foreach ($filePath in $configuration.RoleDefinitions.Values.RoleCapabilityFiles) {
					if ($filePath -notlike "$moduleRoot\*") { continue }

					$moduleName = ($filePath.SubString($moduleRoot.Length).Trim("\/") -split '\\|/')[0]
					$modulePath = Join-Path -Path $moduleRoot -ChildPath $moduleName

					Remove-Item -LiteralPath $modulePath -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
				}

				foreach ($capability in $configuration.RoleDefinitions.Values.RoleCapabilities) {
					$file = $null
					$filePath = $null
					$file = Get-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\*\RoleCapability\$capability.psrc" -ErrorAction Ignore | Select-Object -First 1
					$filePath = $file.FullName
					if ($filePath -notlike "$moduleRoot\*") { continue }

					$moduleName = ($filePath.SubString($moduleRoot.Length).Trim("\/") -split '\\|/')[0]
					$modulePath = Join-Path -Path $moduleRoot -ChildPath $moduleName

					Remove-Item -LiteralPath $modulePath -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
				}
			}
		}
		#endregion Scriptblock
	}
	process {
		$data = @{
			Name = $Name
			RemoveCode = $RemoveCode
			Force = $Force
		}
		Invoke-PSFCommand -ComputerName $ComputerName -Credential $Credential -ScriptBlock $scriptblock -ArgumentList $data
	}
}