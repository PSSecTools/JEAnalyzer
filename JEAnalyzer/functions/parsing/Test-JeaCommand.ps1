function Test-JeaCommand
{
<#
	.SYNOPSIS
		Tests, whether a command is safe to expose in JEA.
	
	.DESCRIPTION
		Tests, whether a command is safe to expose in JEA.
		Unsafe commands allow escaping the lockdown that JEA is supposed to provide.
		Safety check is a best effort initiative and not an absolute determination.
	
	.PARAMETER Name
		Name of the command to test
	
	.EXAMPLE
		PS C:\> Test-JeaCommand -Name 'Get-Command'
	
		Tests whether Get-Command is safe to expose in JEA (Hint: It is)
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('CommandName')]
		[string[]]
		$Name
	)
	
	process
	{
		foreach ($commandName in $Name)
		{
			Get-CommandMetaData -CommandName $commandName
		}
	}
}