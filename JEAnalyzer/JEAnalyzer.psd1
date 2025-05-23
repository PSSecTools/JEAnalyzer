﻿@{
	# Script module or binary module file associated with this manifest
	RootModule = 'JEAnalyzer.psm1'
	
	# Version number of this module.

	ModuleVersion = '1.3.19'
	
	# ID used to uniquely identify this module
	GUID = '346caa76-534a-4651-88f5-359e85cd71c0'
	
	# Author of this module
	Author = 'Miriam Wiesner, Friedrich Weinmann'
	
	# Company or vendor of this module
	CompanyName = ' '
	
	# Copyright statement for this module
	Copyright = 'Copyright (c) 2018 Miriam Wiesner'
	
	# Description of the functionality provided by this module
	Description = 'Simplifies the implementation of Just Enough Administration by providing functions to convert Code, ScripBlocks or Scripts into JEA role capability files.'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		@{ ModuleName = 'PSFramework'; ModuleVersion = '1.12.346' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @('bin\JEAnalyzer.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\JEAnalyzer.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\JEAnalyzer.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		'Add-JeaModuleRole'
		'Add-JeaModuleScript'
		'ConvertTo-JeaCapability'
		'Export-JeaModule'
		'Export-JeaRoleCapFile'
		'Get-JeaEndpoint'
		'Import-JeaScriptFile'
		'Install-JeaModule'
		'New-JeaCommand'
		'New-JeaModule'
		'New-JeaRole'
		'Read-JeaScriptblock'
		'Read-JeaScriptFile'
		'Test-JeaCommand'
		'Uninstall-JeaModule'
	)
	
	# Cmdlets to export from this module
	# CmdletsToExport = ''
	
	# Variables to export from this module
	# VariablesToExport = ''
	
	# Aliases to export from this module
	# AliasesToExport = ''
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('jea')
			
			# A URL to the license for this module.
			LicenseUri = 'https://github.com/PSSecTools/JEAnalyzer/blob/master/LICENSE'
			
			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/PSSecTools/JEAnalyzer'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}