function New-JeaRole
{
<#
	.SYNOPSIS
		Creates a new role for use in a JEA Module.
	
	.DESCRIPTION
		Creates a new role for use in a JEA Module.
	
		A role is a what maps a user or group identity to the resources it may use.
		Thus it consists of:
		- An Identity to apply to
		- Capabilities the user is granted.
		Capabilities can be any command or a custom script / command that will be embedded in the module.
	
	.PARAMETER Name
		The name of the role.
		On any given endpoint, all roles across ALL JEA Modules must have a unique name.
		To ensure this happens, all roles will automatically receive the modulename as prefix.
	
	.PARAMETER Identity
		Users or groups with permission to connect to an endpoint and receive this role.
		If left empty, only remote management users will be able to connect to this endpoint.
		Either use AD Objects (such as the output of Get-ADGroup) or offer netbios-domain-qualified names as string.
	
	.PARAMETER Capability
		The capabilities a role is supposed to have.
		This can be any kind of object - the name of a command, the output of Get-Command, path to a scriptfile or the output of any of the processing commands JEAnalyzer possesses (such as Read-JeaScriptFile).
	
	.PARAMETER Module
		A JEA module to which to add the role.
	
	.EXAMPLE
		PS C:\> New-JeaRole -Name 'Test'
	
		Creates an empty JEA Role named 'Test'
	
	.EXAMPLE
		PS C:\> New-JeaRole -Name 'Test' -Identity (Get-ADGroup JeaTestGroup)
	
		Creates an empty JEA Role named 'Test' that will grant remote access to members of the JeaTestGroup group.
	
	.EXAMPLE
		PS C:\> Read-JeaScriptFile -Path .\logon.ps1 | Where-Object CommandName -like "Get-AD*" | New-JeaRole -Name Logon -Identity (Get-ADGroup Domain-Users) | Add-JeaModuleRole -Module $module
	
		Parses the file logon.ps1 for commands.
		Then selects all of those commands that are used to read from Active Directory.
		It then creates a JEA Role named 'Logon', granting access to all AD Users to the commands selected.
		Finally, it adds the new role to the JEA Module object stored in $module.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true)]
		$Identity,
		
		[Parameter(ValueFromPipeline = $true)]
		$Capability,
		
		[JEAnalyzer.Module]
		$Module
	)
	
	begin
	{
		Write-PSFMessage -String 'New-JeaRole.Creating' -StringValues $Name
		$role = New-Object -TypeName 'JEAnalyzer.Role' -ArgumentList $Name, $Identity
	}
	process
	{
		$Capability | ConvertTo-JeaCapability | ForEach-Object {
			$null = $role.CommandCapability[$_.Name] = $_
		}
	}
	end
	{
		if ($Module) { $Module.Roles[$role.Name] = $role }
		else { $role }
	}
}