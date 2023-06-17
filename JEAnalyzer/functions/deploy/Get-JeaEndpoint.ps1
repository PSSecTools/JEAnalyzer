function Get-JeaEndpoint {
	<#
	.SYNOPSIS
		Retrieve JEA Endpoints and their capabilities from target computers.
	
	.DESCRIPTION
		Retrieve JEA Endpoints and their capabilities from target computers.
		Resolves all roles / identity mappings, all capabilities and the remoting configuration.
		Check the "Roles" property for the actual capabilities exposed by the endpoint.
	
	.PARAMETER Name
		Name of the JEA endpoint to filter by.
		Defaults to '*'
	
	.PARAMETER ComputerName
		Computer to retrieve JEA endpoints from.
		Defaults to: $env:COMPUTERNAME
	
	.PARAMETER Credential
		Credentials to use for the remoting connection.
	
	.EXAMPLE
		PS C:\> Get-JeaEndpoint

		Searches the current computer for JEA endpoints

	.EXAMPLE
		PS C:\> Get-JeaEndpoint -ComputerName server1,server2,server3 -Name JEA_ServiceManager

		Retrieves the deployed JEA endpoints named JEA_ServiceManager.
		This includes the version they are deployed at if they were originally deployed through JEAnalyzer.
	#>
	[CmdletBinding()]
	param (
		[string]
		$Name = '*',

		[Parameter(ValueFromPipeline = $true)]
		[PSFComputer[]]
		$ComputerName = $env:COMPUTERNAME,

		[PSCredential]
		$Credential
	)
	begin {
		#region Scriptblock
		$scriptblock = {
			param (
				$Name
			)

			#region Functions
			function Convert-JeaSessionConfiguration {
				[CmdletBinding()]
				param (
					$Configuration
				)
			
				$fromJEAnalyzer = $false
				$version = 'unknown'
				$description = $Configuration.Description
				$pattern = '^\[{0} \d+\.\d+\.\d+\]' -f ([regex]::Escape($Configuration.Name))
				if ($Configuration.Description -match $pattern) {
					$fromJEAnalyzer = $true
					$version = ($description -replace '^\[.+? (\d+\.\d+\.\d+)\].{0,}$', '$1') -as [version]
					$description = ($description -replace '^.+?\]').Trim()
				}
				$mode = 'gMSA'
				if ($Configuration.RunAsVirtualAccount) {
					$mode = 'Virtual Admin'
					if ($Configuration.RunAsVirtualAccountGroups) {
						$mode = 'Virtual Admin (Constrained)'
					}
				}
			
				[PSCustomObject]@{
					PSTypeName                = 'JEAnalyzer.Jea.Endpoint'
					ComputerName              = $env:COMPUTERNAME
					Name                      = $Configuration.Name
					Mode                      = $mode
					Author                    = $Configuration.Author
					Description               = $description
					Version                   = $version
					Permissions               = $Configuration.Permission
					Roles                     = $null
					FromJEAnalyzer            = $fromJEAnalyzer
					PSVersion                 = $Configuration.PSVersion
					RunAsUser                 = $Configuration.RunAsUser
					RunAsVirtualAccount       = $Configuration.RunAsVirtualAccount
					RunAsVirtualAccountGroups = $Configuration.RunAsVirtualAccountGroups
				}
			}

			function Convert-JeaSessionConfiguration {
				[CmdletBinding()]
				param (
					$Configuration
				)
			
				$fromJEAnalyzer = $false
				$version = 'unknown'
				$description = $Configuration.Description
				$pattern = '^\[{0} \d+\.\d+\.\d+\]' -f ([regex]::Escape($Configuration.Name))
				if ($Configuration.Description -match $pattern) {
					$fromJEAnalyzer = $true
					$version = ($description -replace '^\[.+? (\d+\.\d+\.\d+)\].{0,}$', '$1') -as [version]
					$description = ($description -replace '^.+?\]').Trim()
				}
				$mode = 'gMSA'
				if ($Configuration.RunAsVirtualAccount) {
					$mode = 'Virtual Admin'
					if ($Configuration.RunAsVirtualAccountGroups) {
						$mode = 'Virtual Admin (Constrained)'
					}
				}
			
				[PSCustomObject]@{
					PSTypeName                = 'JEAnalyzer.Jea.Endpoint'
					ComputerName              = $env:COMPUTERNAME
					Name                      = $Configuration.Name
					Mode                      = $mode
					Enabled                   = $Configuration.Enabled
					Author                    = $Configuration.Author
					Description               = $description
					Version                   = $version
					Permissions               = $Configuration.Permission
					Roles                     = $null
					FromJEAnalyzer            = $fromJEAnalyzer
					PSVersion                 = $Configuration.PSVersion
					RunAsUser                 = $Configuration.RunAsUser
					RunAsVirtualAccount       = $Configuration.RunAsVirtualAccount
					RunAsVirtualAccountGroups = $Configuration.RunAsVirtualAccountGroups
				}
			}
			
			function Get-JeaRoleDefinition {
				[CmdletBinding()]
				param (
					$Configuration,
			
					[string]
					$Identity,
			
					[Hashtable]
					$Definition
				)
			
				foreach ($capabilityFile in $Definition.RoleCapabilityFiles) {
					$fail = $null
					$content = $null
					try { $content = Import-PowerShellDataFile -Path $capabilityFile -ErrorAction Stop }
					catch {
						$fail = $_
					}
					$name = (Split-Path -Path $capabilityFile -Leaf) -replace '\.psrc$'
					[PSCustomObject]@{
						PSTypeName              = 'JEAnalyzer.Jea.RoleCapability'
						ComputerName            = $ENV:COMPUTERNAME
						JeaEndpoint             = $Configuration.Name
						Identity                = $Identity
						Type                    = 'ByFile'
						Name                    = $name
						Path                    = $capabilityFile
						Error                   = $fail
						ModulesToImport         = $content.ModulesToImport
						VisibleCmdlets          = $($content.VisibleCmdlets)
						VisibleAliases          = $($content.VisibleAliases)
						VisibleFunctions        = $($content.VisibleFunctions)
						VisibleExternalCommands = $($content.VisibleExternalCommands)
						VisibleProviders        = $($content.VisibleProviders)
						AliasDefinitions        = $($content.AliasDefinitions)
						FunctionDefinitions     = $($content.FunctionDefinitions)
					}
				}
			
				foreach ($capability in $Definition.RoleCapabilities) {
					$file = $null
					$fail = $null
					$content = $null
					$file = Get-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\*\RoleCapability\$capability.psrc" -ErrorAction Ignore | Select-Object -First 1
					if (-not $file) { $fail = "Role Capability File not found!" }
					else {
						try { $content = Import-PowerShellDataFile -Path $file.FullName -ErrorAction Stop }
						catch { $fail = $_ }
					}
			
					[PSCustomObject]@{
						PSTypeName              = 'JEAnalyzer.Jea.RoleCapability'
						ComputerName            = $ENV:COMPUTERNAME
						JeaEndpoint             = $Configuration.Name
						Identity                = $Identity
						Type                    = 'ByName'
						Name                    = $capability
						Path                    = $file.FullName
						Error                   = $fail
						ModulesToImport         = $content.ModulesToImport
						VisibleCmdlets          = $content.VisibleCmdlets
						VisibleAliases          = $content.VisibleAliases
						VisibleFunctions        = $content.VisibleFunctions
						VisibleExternalCommands = $content.VisibleExternalCommands
						VisibleProviders        = $content.VisibleProviders
						AliasDefinitions        = $content.AliasDefinitions
						FunctionDefinitions     = $content.FunctionDefinitions
					}
				}
			}
			#endregion Functions

			$jeaConfigurations = Get-PSSessionConfiguration | Where-Object SessionType -EQ RestrictedRemoteServer
			foreach ($jeaConfiguration in $jeaConfigurations) {
				if ($jeaConfiguration.Name -notlike $Name) { continue }
				$coreData = Convert-JeaSessionConfiguration -Configuration $jeaConfiguration
				$coreData.Roles = foreach ($pair in $jeaConfiguration.RoleDefinitions.GetEnumerator()) {
					Get-JeaRoleDefinition -Identity $pair.Key -Definition $pair.Value -Configuration $jeaConfiguration
				}
				$coreData
			}
		}
		#endregion Scriptblock
	}
	process {
		Invoke-PSFCommand -ComputerName $ComputerName -Credential $Credential -ScriptBlock $scriptblock -ArgumentList $Name | Remove-SerializationLabel | ForEach-Object {
			$_.Roles = $_.Roles | Remove-SerializationLabel
			$_
		}
	}
}