function New-JeaCommand
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
	
	.PARAMETER Force
		Override the security warning when generating an unsafe command.
		By default, New-JeaCommand will refuse to create a command object for commands deemed unsafe for use in JEA.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> New-JeaCommand -Name 'value1'
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[JEAnalyzer.Parameter[]]
		$Parameter,
		
		[JEAnalyzer.Role]
		$Role,
		
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
			CommandType = $commandData.CommandObject.CommandType
		}
		foreach ($parameterItem in $Parameter)
		{
			$resultCommand.Parameter[$parameterItem.Name] = $parameterItem
		}
		# Add to role if specified, otherwise return
		if ($Role) { $null = $Role.CommandCapability[$commandData.CommandName] = $resultCommand }
		else { $resultCommand }
	}
}