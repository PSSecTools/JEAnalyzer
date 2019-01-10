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
	Param (
		[PsfValidateScript('JEAnalyzer.ValidateType.Module', ErrorString = 'JEAnalyzer.ValidateType.Module')]
		$Module,
		
		[PsfValidateScript('JEAnalyzer.ValidateType.Roles', ErrorString = 'JEAnalyzer.ValidateType.Roles')]
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
				Stop-PSFFunction -Message ($script:strings['Add-JeaModuleRole.RolePresent'] -f $roleItem.Name, $Module.Name) -EnableException $EnableException -Continue -Cmdlet $PSCmdlet -Target $Role
			}
			Write-PSFMessage -Message ($script:strings['Add-JeaModuleRole.AddingRole'] -f $roleItem.Name, $Module.Name) -Target $Role
			$Module.Roles[$roleItem.Name] = $roleItem
		}
	}
}