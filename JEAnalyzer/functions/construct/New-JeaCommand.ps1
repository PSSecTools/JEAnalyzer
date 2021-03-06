﻿function New-JeaCommand
{
<#
	.SYNOPSIS
		Creates a new command for use in a JEA Module's capability.
	
	.DESCRIPTION
		Creates a new command for use in a JEA Module's capability.
	
	.PARAMETER Name
		The name of the command.
	
	.PARAMETER Parameter
		Parameters to constrain.
		Specifying this will allow the end user to only use the thus listed parameters on the command.
		Valid input:
		- The string name of the parameter
		- A finished parameter object
		- A hashtable that contains further input value constraints. E.g.: @{ Name = 'Name'; ValidateSet = 'Dns', 'Spooler' }
	
	.PARAMETER Role
		A role to which to add the command.
		By default, the command object will just be returned by this function.
		If you specify a role, it will instead only be added to the role.
	
	.PARAMETER CommandType
		The type of command to add.
		Only applies when the command cannot be resolved.
		Defaults to function.
	
	.PARAMETER Force
		Override the security warning when generating an unsafe command.
		By default, New-JeaCommand will refuse to create a command object for commands deemed unsafe for use in JEA.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> New-JeaCommand -Name 'Restart-Service' -parameter 'Name'

		Generates a command object allowing the use of Get-Service, but only with the parameter "-Name"
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[JEAnalyzer.Parameter[]]
		$Parameter,
		
		[JEAnalyzer.Role]
		$Role,
		
		[System.Management.Automation.CommandTypes]
		$CommandType = [System.Management.Automation.CommandTypes]::Function,
		
		[switch]
		$Force,
		
		[switch]
		$EnableException
	)
	
	process
	{
		$commandData = Get-CommandMetaData -CommandName $Name
		# Eliminate Aliases
		if ($commandData.CommandObject.CommandType -eq 'Alias')
		{
			$commandData = Get-CommandMetaData -CommandName $commandData.CommandObject.ResolvedCommand.Name
		}
		if ($commandData.IsDangerous -and -not $Force)
		{
			Stop-PSFFunction -String 'New-JeaCommand.DangerousCommand' -StringValues $Name -EnableException $EnableException.ToBool() -Target $Name
			return
		}
		
		$resultCommand = New-Object -TypeName 'JEAnalyzer.CapabilityCommand' -Property @{
			Name = $commandData.CommandName
		}
		if ($commandData.CommandObject) { $resultCommand.CommandType = $commandData.CommandObject.CommandType }
		else { $resultCommand.CommandType = $CommandType }
		
		foreach ($parameterItem in $Parameter)
		{
			$resultCommand.Parameters[$parameterItem.Name] = $parameterItem
		}
		# Add to role if specified, otherwise return
		if ($Role) { $null = $Role.CommandCapability[$commandData.CommandName] = $resultCommand }
		else { $resultCommand }
	}
}