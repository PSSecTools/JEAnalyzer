function Export-JeaModule
{
<#
	.SYNOPSIS
		Exports a JEA module object into a PowerShell Module.
	
	.DESCRIPTION
		Exports a JEA module object into a PowerShell Module.
		This will create a full PowerShell Module, including:
		- Role Definitions for all Roles
		- Command: Register-JeaEndpoint_<ModuleName> to register the session configuration.
		- Any additional commands and scripts required/contained by the Roles
		Create a JEA Module object using New-JeaModule
		Create roles by using New-JeaRole.
	
	.PARAMETER Path
		The folder where to place the module.
	
	.PARAMETER Module
		The module object to export.
	
	.EXAMPLE
		PS C:\> $module | Export-JeaModule -Path 'C:\temp'
	
		Exports the JEA Module stored in $module to the designated path.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[PsfValidateScript('JEAnalyzer.ValidatePath.Directory', ErrorString = 'Validate.FileSystem.Directory.Fail')]
		[string]
		$Path,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[JEAnalyzer.Module[]]
		$Module
	)
	
	begin
	{
		#region Utility Functions
		function Write-Function
		{
		<#
			.SYNOPSIS
				Creates a function file with UTF8Bom encoding.
			
			.DESCRIPTION
				Creates a function file with UTF8Bom encoding.
			
			.PARAMETER Function
				The function object to write.
			
			.PARAMETER Path
				The path to writer it to
			
			.EXAMPLE
				PS C:\> Write-Function -Function (Get-Command mkdir) -Path C:\temp\mkdir.ps1
			
				Writes the function definition for mkdir (including function statement) to the specified path.
		#>
			[CmdletBinding()]
			param (
				[System.Management.Automation.FunctionInfo]
				$Function,
				
				[string]
				$Path
			)
			
			$functionString = @'
function {0}
{{
{1}
}}
'@ -f $Function.Name, $Function.Definition.Trim("`n`r")
			$encoding = New-Object System.Text.UTF8Encoding($true)
			Write-PSFMessage -String 'Export-JeaModule.File.Create' -StringValues $Path -FunctionName Export-JeaModule
			[System.IO.File]::WriteAllText($Path, $functionString, $encoding)
		}
		
		function Write-File
		{
			[CmdletBinding()]
			param (
				[string]
				$Text,
				
				[string]
				$Path
			)
			$encoding = New-Object System.Text.UTF8Encoding($true)
			Write-PSFMessage -String 'Export-JeaModule.File.Create' -StringValues $Path -FunctionName Export-JeaModule
			[System.IO.File]::WriteAllText($Path, $Text, $encoding)
		}
		#endregion Utility Functions
		
		# Will succeede, as the validation scriptblock checks this first
		$resolvedPath = Resolve-PSFPath -Path $Path -Provider FileSystem -SingleItem
	}
	process
	{
		foreach ($moduleObject in $Module)
		{
			$moduleName = $moduleObject.Name -replace '\s', '_'
			if ($moduleName -notlike "JEA_*") { $moduleName = "JEA_{0}" -f $moduleName }
			
			#region Create Module folder
			if (Test-Path -Path (Join-Path $resolvedPath $moduleName))
			{
				$moduleBase = Get-Item -Path (Join-Path $resolvedPath $moduleName)
				Write-PSFMessage -String 'Export-JeaModule.Folder.ModuleBaseExists' -StringValues $moduleBase.FullName
			}
			else
			{
				$moduleBase = New-Item -Path $resolvedPath -Name $moduleName -ItemType Directory -Force
				Write-PSFMessage -String 'Export-JeaModule.Folder.ModuleBaseNew' -StringValues $moduleBase.FullName
			}
			Write-PSFMessage -String 'Export-JeaModule.Folder.VersionRoot' -StringValues $moduleBase.FullName, $moduleObject.Version
			$rootFolder = New-Item -Path $moduleBase.FullName -Name $moduleObject.Version -ItemType Directory -Force
			
			# Other folders for the scaffold
			$folders = @(
				'functions'
				'internal\functions'
				'internal\scriptsPre'
				'internal\scriptsPost'
				'internal\scriptsRole'
			)
			foreach ($folder in $folders)
			{
				Write-PSFMessage -String 'Export-JeaModule.Folder.Content' -StringValues $folder
				$folderItem = New-Item -Path (Join-Path -Path $rootFolder.FullName -ChildPath $folder) -ItemType Directory -Force
				'# <Placeholder>' | Set-Content -Path "$($folderItem.FullName)\readme.md"
			}
			#endregion Create Module folder
			
			#region Create Role Capabilities
			Write-PSFMessage -String 'Export-JeaModule.Folder.RoleCapailities' -StringValues $rootFolder.FullName
			$roleCapabilityFolder = New-Item -Path $rootFolder.FullName -Name 'RoleCapabilities' -Force -ItemType Directory
			foreach ($role in $moduleObject.Roles.Values)
			{
				$RoleCapParams = @{
					Path		   = ('{0}\{1}.psrc' -f $roleCapabilityFolder.FullName, $role.Name)
					Author		   = $moduleObject.Author
					CompanyName    = $moduleObject.Company
					VisibleCmdlets = $role.VisibleCmdlets()
					VisibleFunctions = $role.VisibleFunctions($moduleName)
				}
				Write-PSFMessage -String 'Export-JeaModule.Role.NewRole' -StringValues $role.Name, $role.CommandCapability.Count
				New-PSRoleCapabilityFile @RoleCapParams
				#region Logging Visible Commands
				foreach ($cmdlet in $role.VisibleCmdlets())
				{
					$commandName = $cmdlet.Name
					$parameters = @()
					foreach ($parameter in $cmdlet.Parameters)
					{
						$string = $parameter.Name
						if ($parameter.ValidateSet) { $string += (' | {0}' -f ($parameter.ValidateSet -join ",")) }
						if ($parameter.ValidatePattern) { $string += (' | {0}' -f $parameter.ValidatePattern) }
						$parameters += '({0})' -f $string
					}
					$parameterText = ' : {0}' -f ($parameters -join ",")
					if (-not $parameters) { $parameterText = '' }
					Write-PSFMessage -String 'Export-JeaModule.Role.VisibleCmdlet' -StringValues $role.Name, $commandName, $parameterText
				}
				foreach ($cmdlet in $role.VisibleFunctions($moduleName))
				{
					$commandName = $cmdlet.Name
					$parameters = @()
					foreach ($parameter in $cmdlet.Parameters)
					{
						$string = $parameter.Name
						if ($parameter.ValidateSet) { $string += (' | {0}' -f ($parameter.ValidateSet -join ",")) }
						if ($parameter.ValidatePattern) { $string += (' | {0}' -f $parameter.ValidatePattern) }
						$parameters += '({0})' -f $string
					}
					$parameterText = ' : {0}' -f ($parameters -join ",")
					if (-not $parameters) { $parameterText = '' }
					Write-PSFMessage -String 'Export-JeaModule.Role.VisibleFunction' -StringValues $role.Name, $commandName, $parameterText
				}
				#endregion Logging Visible Commands
				
				# Transfer all function definitions stored in the role.
				$role.CopyFunctionDefinitions($moduleObject)
			}
			#endregion Create Role Capabilities
			
			#region Create Private Functions
			$privateFunctionPath = Join-Path -Path $rootFolder.FullName -ChildPath 'internal\functions'
			foreach ($privateFunction in $moduleObject.PrivateFunctions.Values)
			{
				$outputPath = Join-Path -Path $privateFunctionPath -ChildPath "$($privateFunction.Name).ps1"
				Write-Function -Function $privateFunction -Path $outputPath
			}
			#endregion Create Private Functions
			
			#region Create Public Functions
			$publicFunctionPath = Join-Path -Path $rootFolder.FullName -ChildPath 'functions'
			foreach ($publicFunction in $moduleObject.PublicFunctions.Values)
			{
				$outputPath = Join-Path -Path $publicFunctionPath -ChildPath "$($publicFunction.Name).ps1"
				Write-Function -Function $publicFunction -Path $outputPath
			}
			#endregion Create Public Functions
			
			#region Create Scriptblocks
			foreach ($scriptFile in $moduleObject.PreimportScripts.Value)
			{
				Write-File -Text $scriptFile.Text -Path "$($rootFolder.FullName)\internal\scriptsPre\$($scriptFile.Name).ps1"
			}
			foreach ($scriptFile in $moduleObject.PostimportScripts.Value)
			{
				Write-File -Text $scriptFile.Text -Path "$($rootFolder.FullName)\internal\scriptsPost\$($scriptFile.Name).ps1"
			}
			#endregion Create Scriptblocks
			
			#region Create Common Resources
			# Register-JeaEndpoint
			$encoding = New-Object System.Text.UTF8Encoding($true)
			$functionText = [System.IO.File]::ReadAllText("$script:ModuleRoot\internal\resources\Register-JeaEndpoint.ps1", $encoding)
			$functionText = $functionText -replace 'Register-JeaEndpoint', "Register-JeaEndpoint_$($moduleName)"
			Write-File -Text $functionText -Path "$($rootFolder.FullName)\functions\Register-JeaEndpoint_$($moduleName).ps1"
			
			# PSM1
			Copy-Item -Path "$script:ModuleRoot\internal\resources\jeamodule.psm1" -Destination "$($rootFolder.FullName)\$($moduleName).psm1"
			
			# PSSession Configuration
			$grouped = $moduleObject.Roles.Values | ForEach-Object {
				foreach ($identity in $_.Identity)
				{
					[pscustomobject]@{
						Identity = $identity
						Role = $_
					}
				}
			} | Group-Object Identity
			$roleDefinitions = @{ }
			foreach ($groupItem in $grouped)
			{
				$roleDefinitions[$groupItem.Name] = @{
					RoleCapabilityFiles = ($groupItem.Group.Role.Name | ForEach-Object { "C:\Program Files\WindowsPowerShell\Modules\{0}\{1}\RoleCapabilities\{2}.psrc" -f $moduleName, $Module.Version, $_ })
				}
			}
			$paramNewPSSessionConfigurationFile = @{
				SessionType = 'RestrictedRemoteServer'
				Path	    = "$($rootFolder.FullName)\sessionconfiguration.pssc"
				RunAsVirtualAccount = $true
				RoleDefinitions = $roleDefinitions
				Author	    = $moduleObject.Author
				Description = "[{0} {1}] {2}" -f $moduleName, $moduleObject.Version, $moduleObject.Description
				CompanyName = $moduleObject.Company
			}
			Write-PSFMessage -String 'Export-JeaModule.File.Create' -StringValues "$($rootFolder.FullName)\sessionconfiguration.pssc"
			New-PSSessionConfigurationFile @paramNewPSSessionConfigurationFile
			
			# Create Manifest
			$paramNewModuleManifest = @{
				FunctionsToExport = (Get-ChildItem -Path "$($rootFolder.FullName)\functions" -Filter '*.ps1').BaseName
				CmdletsToExport   = @()
				AliasesToExport   = @()
				VariablesToExport = @()
				Path			  = "$($rootFolder.FullName)\$($moduleName).psd1"
				Author		      = $moduleObject.Author
				Description	      = $moduleObject.Description
				CompanyName	      = $moduleObject.Company
				RootModule	      = "$($moduleName).psm1"
				ModuleVersion	  = $moduleObject.Version
				Tags			  = 'JEA', 'JEAnalyzer', 'JEA_Module'
			}
			Write-PSFMessage -String 'Export-JeaModule.File.Create' -StringValues "$($rootFolder.FullName)\$($moduleName).psd1"
			New-ModuleManifest @paramNewModuleManifest
			#endregion Create Common Resources
			
			#region Generate Connection Script
			$connectionSegments = @()
			foreach ($role in $moduleObject.Roles.Values)
			{
				$connectionSegments += @'
# Connect to JEA Endpoint for Role {0}
$session = New-PSSession -ComputerName '<InsertNameHere>' -ConfigurationName '{1}'
Import-PSSession -AllowClobber -Session $session -DisableNameChecking -CommandName '{2}'
Invoke-Command -Session $session -Scriptblock {{ {3} }}
'@ -f $role.Name, $moduleName, ($role.CommandCapability.Keys -join "', '"), ($role.CommandCapability.Keys | Select-Object -First 1)
			}
			
			$finalConnectionText = @'
<#
These are the connection scriptblocks for the {0} JEA Module.
For each role there is an entry with all that is needed to connect and consume it.
Just Copy&Paste the section you need, add it to the top of your script and insert the computername.
You will always need to create the session, but whether to Import it or use Invoke-Command is up to you.
Either option will work, importing it is usually more convenient but will overwrite local copies.
Invoke-Command is the better option if you want to connect to multiple such sessions or still need access to the local copies.

Note: If a user has access to multiple roles, you still only need one session, but:
- On Invoke-Command you have immediately access to ALL commands allowed in any role the user is in.
- On Import-PSSession, you need to explicitly state all the commands you want.
#>

{1}
'@ -f $moduleName, ($connectionSegments -join "`n`n`n")
			Write-File -Text $finalConnectionText -Path (Join-Path -Path $resolvedPath -ChildPath "connect_$($moduleName).ps1")
			#endregion Generate Connection Script
		}
	}
}