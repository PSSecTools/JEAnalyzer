function Read-JeaScriptFile
{
<#
	.SYNOPSIS
		Parses scriptfiles and returns qualified command objects of commands found.
	
	.DESCRIPTION
		Parses scriptfiles and returns qualified command objects of commands found.
	
		Note:
		The IsDangerous property is a best-effort thing.
		We TRY to find all dangerous commands, that might allow the user to escalate permissions on the Jea Endpoint.
		There is no guarantee for complete success however.
	
	.PARAMETER Path
		The path to scan.
		Will ignore folders, does not discriminate by extension.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Get-ChildItem . -Filter *.ps1 -Recurse | Read-JeaScriptFile
	
		Scans all powershell script files in the folder and subfolder, then parses out command tokens.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string]
		$Path,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -Message "Bound parameters: $($PSBoundParameters.Keys -join ", ")" -Tag 'debug', 'start', 'param'
		$filesProcessed = @()
	}
	process
	{
		foreach ($pathItem in $Path)
		{
			Write-PSFMessage -Level Verbose -Message "Processing $pathItem" -Target $pathItem
			try { $resolvedPaths = Resolve-PSFPath -Path $pathItem -Provider FileSystem }
			catch { Stop-PSFFunction -Message "Unable to resolve path: $pathItem" -Target $pathItem -EnableException $EnableException -Continue }
			foreach ($resolvedPath in $resolvedPaths)
			{
				$pathObject = Get-Item $resolvedPath
				
				if ($filesProcessed -contains $pathObject.FullName) { continue }
				if ($pathObject.PSIsContainer) { continue }
				
				$filesProcessed += $pathObject.FullName
				$commands = (Read-Script -Path $pathObject.FullName).Tokens | Where-Object TokenFlags -like "*CommandName*" | Group-Object Text | Select-Object -ExpandProperty Name | Where-Object { $_ }
				Write-PSFMessage -Level Verbose -Message "$($commands.Count) different commands found" -Target $pathItem
					
				if ($commands) { Get-CommandMetaData -CommandName $commands -File $pathObject.FullName }
			}
		}
	}
}