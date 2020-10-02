function Get-CommandMetaData
{
<#
	.SYNOPSIS
		Processes extra meta-information for a command
	
	.DESCRIPTION
		Processes extra meta-information for a command
	
	.PARAMETER CommandName
		The command to add information for.
	
	.PARAMETER File
		The file the command was read from.
	
	.EXAMPLE
		PS C:\> Get-CommandMetaData -CommandName 'Get-Help'
	
		Adds additional information for Get-Help and returns a useful data object.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string[]]
		$CommandName,
		
		[string]
		$File
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -String 'General.BoundParameters' -StringValues ($PSBoundParameters.Keys -join ", ") -Tag 'debug', 'start', 'param'
		
		if (-not $script:allcommands)
		{
			# Cache known commands once
			Write-PSFMessage -Level Warning -Message "Gathering command information for the first time. This may take quite a while."
			[System.Collections.ArrayList]$script:allcommands = Get-Command | Group-Object Name | ForEach-Object { $_.Group | Sort-Object Version -Descending | Select-Object -First 1 }
			Get-Alias | Where-Object Name -NotIn $script:allcommands.Name | ForEach-Object { $null = $script:allcommands.Add($_) }
		}
	}
	process
	{
		foreach ($command in $CommandName)
		{
			Write-PSFMessage -Level Verbose -Message "Adding meta information for: $($command)"
			$commandObject = New-Object -TypeName 'JEAnalyzer.CommandInfo' -Property @{
				CommandName   = $command
				File		  = $File
			}
			if ($object = $script:allcommands | Where-Object Name -EQ $command) { $commandObject.CommandObject = $object }
			$commandObject | Select-PSFObject -KeepInputObject -ScriptProperty @{
				IsDangerous = {
					# Parameters that accept scriptblocks are assumed to be dangerous
					if ($this.CommandObject.Parameters.Values | Where-Object { $_.ParameterType.FullName -eq 'System.Management.Automation.ScriptBlock' }) { return $true }
					
					# If the command is flagged as dangerous for JEA, mark it as such
					if ($this.CommandObject.Definition -match 'PSFramework\.PSFCore\.NoJeaCommand') { return $true }
					
					# If the command has a parameter flagged as dangerous for JEA, the command is a danger
					if ($this.CommandObject.Parameters.Values | Where-Object { $_.Attributes | Where-Object { $_ -is [PSFramework.PSFCore.NoJeaParameterAttribute] } }) { return $true }
						
					# Default: Is the command blacklisted?
					(& (Get-Module JEAnalyzer) { $script:dangerousCommands }) -contains $this.CommandName
				}
			}
		}
	}
}