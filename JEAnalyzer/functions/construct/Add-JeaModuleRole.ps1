function Add-JeaModuleRole
{
<#
	.SYNOPSIS
		Adds JEA roles to JEA Modules.
	
	.DESCRIPTION
		Adds JEA roles to JEA Modules.
	
	.PARAMETER Module
		The module to add roles to.
		Create a new module by using New-JeaModule command.
	
	.PARAMETER Role
		The role(s) to add.
		Create a new role by using the New-JeaRole command.
	
	.PARAMETER Force
		Enforce adding the role, overwriting existing roles of the same name.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> $roles | Add-JeaModuleRole -Module $module
	
		Adds the roles stored in $roles to the module stored in $module
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[JEAnalyzer.Module]
		$Module,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[JEAnalyzer.Role[]]
		$Role,
		
		[switch]
		$Force,
		
		[switch]
		$EnableException
	)
	
	process
	{
		foreach ($roleItem in $Role)
		{
			if ($Module.Roles.ContainsKey($roleItem.Name) -and -not $Force)
			{
				Stop-PSFFunction -String 'Add-JeaModuleRole.RolePresent' -StringValues $roleItem.Name, $Module.Name -EnableException $EnableException -Continue -Cmdlet $PSCmdlet -Target $Role
			}
			Write-PSFMessage -String 'Add-JeaModuleRole.AddingRole' -StringValues $roleItem.Name, $Module.Name -Target $Role
			$Module.Roles[$roleItem.Name] = $roleItem
		}
	}
}