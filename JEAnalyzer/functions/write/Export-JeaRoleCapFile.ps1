function Export-JeaRoleCapFile
{
<#
	.SYNOPSIS
		Converts a list of commands into a JEA Role Capability File.
	
	.DESCRIPTION
		Converts a list of commands into a JEA Role Capability File.
	
		Accepts a list of input types, both from the output of other commands in the module and other calls legitimately pointing at a command.
		Then builds a Role Capability File that can be used to create a JEA Endpoint permitting use of the listed commands.
	
	.PARAMETER Path
		The path where to create the output file.
		If only a folder is specified, a 'configuration.psrc' will be created in that folder.
		If a filename is specified, it will use the name, adding the '.psrc' extension if necessary.
		The parent folder must exist, the file needs not exist (and will be overwritten if it does).
	
	.PARAMETER InputObject
		The commands to add to the list of allowed commands.
	
	.PARAMETER Author
		The author that created the RCF.
		Controlled using the 'JEAnalyzer.Author' configuration setting.
	
	.PARAMETER Company
		The company the RCF was created for.
		Controlled using the 'JEAnalyzer.Company' configuration setting.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Get-Content commands.txt | Export-JeaRoleCapFile -Path '.\mytask.psrc'
	
		Creates a Jea Role Capability File permitting the use of all commands allowed in commands.txt.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Path,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Alias('CommandName','Name','Command')]
		[object[]]
		$InputObject,
		
		[string]
		$Author = (Get-PSFConfigValue -FullName 'JEAnalyzer.Author'),
		
		[string]
		$Company = (Get-PSFConfigValue -FullName 'JEAnalyzer.Company'),
		
		[switch]
		$EnableException
	)
	
	begin
	{
		#region Resolves the path
		try { $resolvedPath = Resolve-PSFPath -Path $Path -NewChild -Provider FileSystem -SingleItem -ErrorAction Stop }
		catch
		{
			Stop-PSFFunction -Message 'Failed to resolve output path' -ErrorRecord $_ -EnableException $EnableException
			return
		}
		if (Test-Path $resolvedPath)
		{
			$item = Get-Item -Path $resolvedPath
			if ($item.PSIsContainer) { $resolvedPath = Join-Path -Path $resolvedPath -ChildPath 'configuration.psrc' }
		}
		if ($resolvedPath -notlike '*.psrc') { $resolvedPath += '.psrc' }
		#endregion Resolves the path
		
		$commands = @()
	}
	process
	{
		if (Test-PSFFunctionInterrupt) { return }
		
		#region Add commands to list as they are received
		foreach ($item in $InputObject)
		{
			# Plain Names
			if ($item -is [string])
			{
				Write-PSFMessage -Level Verbose -Message "Adding command: $item" -Target $item
				$commands += $item
				continue
			}
			# Cmdlet objects
			if ($item -is [System.Management.Automation.CmdletInfo])
			{
				Write-PSFMessage -Level Verbose -Message "Adding command: $item" -Target $item
				$commands += $item.Name
				continue
			}
			# Function objects
			if ($item -is [System.Management.Automation.FunctionInfo])
			{
				Write-PSFMessage -Level Verbose -Message "Adding command: $item" -Target $item
				$commands += $item.Name
				continue
			}
			# Alias objects
			if ($item -is [System.Management.Automation.AliasInfo])
			{
				Write-PSFMessage -Level Verbose -Message "Adding command: $($item.ResolvedCommand.Name)" -Target $item
				$commands += $item.ResolvedCommand.Name
				continue
			}
			# Analyzer Objects
			if ($item.CommandName -is [string])
			{
				Write-PSFMessage -Level Verbose -Message "Adding command: $($item.CommandName)" -Target $item
				$commands += $item.CommandName
				continue
			}
			Stop-PSFFunction -Message "Failed to interpret as command: $item" -Target $item -Continue -EnableException $EnableException
		}
		#endregion Add commands to list as they are received
	}
	end
	{
		if (Test-PSFFunctionInterrupt) { return }
		
		#region Realize RCF
		if ($commands)
		{
			Write-PSFMessage -Level Verbose -Message "Creating Jea Role Capability File with $($commands.Count) commands permitted."
			$RoleCapParams = @{
				Path = $resolvedPath
				Author = $Author
				CompanyName = $Company
				VisibleCmdlets = ([string[]]($commands | Select-Object -Unique))
			}
			New-PSRoleCapabilityFile @RoleCapParams
		}
		else
		{
			Write-PSFMessage -Level Warning -Message 'No commands specified!'
		}
		#endregion Realize RCF
	}
}