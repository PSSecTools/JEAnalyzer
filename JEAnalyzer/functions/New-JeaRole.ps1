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
	
	.PARAMETER Capabilities
		The capabilities a role is supposed to have.
		This can be any kind of object - the name of a command, the output of Get-Command, path to a scriptfile or the output of any of the processing commands JEAnalyzer possesses (such as Read-JeaScriptFile).
	
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
	Param (
		[string]
		$Name,
		
		$Identity,
		
		[Parameter(ValueFromPipeline = $true)]
		$Capabilities
	)
	
	begin
	{
		Write-PSFMessage ($script:strings['New-JeaRole.Creating'] -f $Name)
		$role = [PSCustomObject]@{
			PSTypeName = 'JEAnalyzer.Role'
			Name	   = $Name
			Identity   = $Identity
			Capability = @()
		}
	}
	process
	{
		$role.Capability += $Capabilities | ConvertTo-Capability
	}
	end
	{
		$role
	}
}