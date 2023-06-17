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
	
	.PARAMETER ServiceAccount
		The group Managed Service Account under which the JEA endpoint is being executed.
		If this is not specified, the JEA endpoint will run under a virtual local admin account.

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
	
	.PARAMETER PreImport
		Scripts to execute during JEA module import, before loading functions.
		Offer either:
		- The path to the file to add
		- A hashtable with two keys: Name & Text
	
	.PARAMETER PostImport
		Scripts to execute during JEA module import, after loading functions.
		Offer either:
		- The path to the file to add
		- A hashtable with two keys: Name & Text
	
	.PARAMETER RequiredModules
		Any dependencies the module has.
		Note: Specify this in the same manner you would in a module manifest.
		Note2: Do not use this for modules you cannot publish in a repository if you want to distribute this JEA module in such.
		For example, taking a dependency on the Active Directory module would be disadvised.
		In this cases, use the ModulesToImport instead.

	.PARAMETER ModulesToImport
		Any modules to also import when importing the JEA module.
		For modules that are distributed via package management you should instead use the RequiredModules parameter.
		For modules that are not - such as built-in windows modules - this is the place to put them.
		In a JEA endpoint, automatic module import is disabled, all modules must either be a dependency or loaded explicitly.
	
	.EXAMPLE
		PS C:\> New-JeaModule -Name 'JEA_ADUser' -Description 'Grants access to the Get-ADUser command'
		
		Creates a JEA module object with the name JEA_ADUser.
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[string]
		$Identity,

		[string]
		$ServiceAccount,
		
		[string]
		$Description,
		
		[string]
		$Author = (Get-PSFConfigValue -FullName 'JEAnalyzer.Author'),
		
		[string]
		$Company = (Get-PSFConfigValue -FullName 'JEAnalyzer.Company'),
		
		[version]
		$Version = '1.0.0',
		
		[JEAnalyzer.ScriptFile[]]
		$PreImport,
		
		[JEAnalyzer.ScriptFile[]]
		$PostImport,
		
		[object]
		$RequiredModules,

		[string[]]
		$ModulesToImport
	)
	
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
		if ($ServiceAccount) { $module.ServiceAccount = $ServiceAccount }
		if ($RequiredModules) { $module.RequiredModules = $RequiredModules }
		if ($ModulesToImport) { $module.ModulesToImport = $ModulesToImport }
		foreach ($scriptFile in $PreImport) { $module.PreimportScripts[$scriptFile.Name] = $scriptFile }
		foreach ($scriptFile in $PostImport) { $module.PostimportScripts[$scriptFile.Name] = $scriptFile }
		
		$module
	}
}