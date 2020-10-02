function Add-JeaModuleScript
{
<#
	.SYNOPSIS
		Adds a script to a JEA module.
	
	.DESCRIPTION
		Adds a script to a JEA module.
		This script will be executed on import, either before or after loading functiosn contained in the module.
		Use this to add custom logic - such as logging - as users connect to the JEA endpoint.
	
	.PARAMETER Module
		The JEA module to add the script to.
		Use New-JeaModule to create such a module object.
	
	.PARAMETER Path
		Path to the scriptfile to add.
	
	.PARAMETER Text
		Script-Code to add.
	
	.PARAMETER Name
		Name of the scriptfile.
		This parameter is optional. What happens if you do NOT use it depends on other parameters:
		-Path : Uses the filename instead
		-Text : Uses a random guid
		This is mostly cosmetic, as you would generally not need to manually modify the output module.
	
	.PARAMETER Type
		Whether the script is executed before or after the functions of the JEA module are available.
		It needs to run BEFORE loading the functions if defining PowerShell classes, AFTER if it uses the functions.
		If neither: Doesn't matter.
		Defaults to: PostScript
	
	.EXAMPLE
		PS C:\> Add-JeaModuleScript -Module $Module -Path '.\connect.ps1'
	
		Adds the connect.ps1 scriptfile as a script executed after loading functions.
#>
	[CmdletBinding(DefaultParameterSetName = 'File')]
	Param (
		[Parameter(Mandatory = $true, Position = 0)]
		[JEAnalyzer.Module]
		$Module,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'File')]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[Alias('FullName')]
		[string]
		$Path,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Text')]
		[string]
		$Text,
		
		[string]
		$Name,
		
		[ValidateSet('PreScript','PostScript')]
		[string]
		$Type = 'PostScript'
	)
	
	process
	{
		if ($Path)
		{
			$file = [JEAnalyzer.ScriptFile]::new($Path)
			if ($Name) { $file.Name = $Name }
		}
		else
		{
			if (-not $Name) { $Name = [System.Guid]::NewGuid().ToString() }
			$file = [JEAnalyzer.ScriptFile]::new($Name, $Text)
		}
		switch ($Type)
		{
			'PreScript' { $Module.PreimportScripts[$file.Name] = $file }
			'PostScript' { $Module.PostimportScripts[$file.Name] = $file }
		}
	}
}