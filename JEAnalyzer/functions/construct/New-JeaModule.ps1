function New-JeaModule
{
<#
	.SYNOPSIS
		Creates a new JEA module object.
	
	.DESCRIPTION
		Used to create a JEA module object.
		This is the container used to add roles and resources that will later be used to generate a full JEA Module.
		
		Modules are created with an empty default role. Unless adding additional roles, all changes will be applied against the default role.
		To create a new role, use the New-JeaRole command.
		
		Use Export-JeaModule to convert this object into the full module.
	
	.PARAMETER Name
		The name of the JEA Module.
		Cannot coexist with other modules of the same name, the latest version will superseed older versions.
	
	.PARAMETER Identity
		Users or groups with permission to connect to an endpoint and receive the default role.
		If left empty, only remote management users will be able to connect to this endpoint.
		Either use AD Objects (such as the output of Get-ADGroup) or offer netbios-domain-qualified names as string.
	
	.PARAMETER Description
		A description for the module to be created.
	
	.PARAMETER Author
		The author that created the JEA Module.
		Controlled using the 'JEAnalyzer.Author' configuration setting.
	
	.PARAMETER Company
		The company the JEA Module was created for.
		Controlled using the 'JEAnalyzer.Company' configuration setting.
	
	.PARAMETER Version
		The version of the JEA Module.
		A higher version will superseed all older versions of the same name.
	
	.EXAMPLE
		PS C:\> New-JeaModule -Name 'JEA_ADUser' -Description 'Grants access to the Get-ADUser command'
		
		Creates a JEA module object with the name JEA_ADUser.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[string]
		$Identity,
		
		[string]
		$Description,
		
		[string]
		$Author = (Get-PSFConfigValue -FullName 'JEAnalyzer.Author'),
		
		[string]
		$Company = (Get-PSFConfigValue -FullName 'JEAnalyzer.Company'),
		
		[version]
		$Version = '1.0.0'
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -String 'General.BoundParameters' -StringValues ($PSBoundParameters.Keys -join ", ") -Tag 'debug', 'start', 'param'
	}
	process
	{
		Write-PSFMessage -String 'New-JeaModule.Creating' -StringValues $Name, $Version
		$module = New-Object -TypeName JEAnalyzer.Module -Property @{
			Name	    = $Name
			Description = $Description
			Version	    = $Version
			Author	    = $Author
			Company	    = $Company
		}
		if ($Identity) { $module.Roles[$Name] = New-JeaRole -Name $Name -Identity $Identity }
		$module
	}
}