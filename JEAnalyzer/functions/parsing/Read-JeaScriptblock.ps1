function Read-JeaScriptblock
{
<#
	.SYNOPSIS
		Reads a scriptblock and returns qualified command objects of commands found.
	
	.DESCRIPTION
		Reads a scriptblock and returns qualified command objects of commands found.
	
	.PARAMETER ScriptCode
		The string version of the scriptcode to parse.
	
	.PARAMETER ScriptBlock
		A scriptblock to parse.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Get-SBLEvent | Read-JeaScriptblock
	
		Scans the local computer for scriptblock logging events and parses out the commands they use.
#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('Code')]
		[string[]]
		$ScriptCode,
		
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[System.Management.Automation.ScriptBlock[]]
		$ScriptBlock,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -Message "Bound parameters: $($PSBoundParameters.Keys -join ", ")" -Tag 'debug', 'start', 'param'
		
		$fromPipeline = Test-PSFParameterBinding -ParameterName ScriptCode, ScriptBlock -Not
	}
	process
	{
		#region Processing Scriptblock strings
		foreach ($codeItem in $ScriptCode)
		{
			if ($codeItem -eq 'System.Management.Automation.ScriptBlock') { continue }
			if ($ScriptBlock -and $fromPipeline) { continue }
			
			# Never log the full scriptblock, it might contain sensitive information
			Write-PSFMessage -Level Verbose -Message "Processing a scriptblock with $($codeItem.Length) characters"
			try { $codeBlock = [System.Management.Automation.ScriptBlock]::Create($codeItem) }
			catch { Stop-PSFFunction -Message "Failed to parse text as scriptblock, skipping" -EnableException $EnableException -ErrorRecord $_ -OverrideExceptionMessage -Continue }
			$commands = (Read-Script -ScriptCode $codeBlock).Tokens | Where-Object TokenFlags -like "*CommandName*" | Group-Object Text | Select-Object -ExpandProperty Name | Where-Object { $_ }
			
			Write-PSFMessage -Level Verbose -Message "$($commands.Count) different commands found" -Target $pathItem
			
			if ($commands) { Get-CommandMetaData -CommandName $commands }
		}
		#endregion Processing Scriptblock strings
		
		#region Processing Scriptblocks
		foreach ($codeItem in $ScriptBlock)
		{
			# Never log the full scriptblock, it might contain sensitive information
			Write-PSFMessage -Level Verbose -Message "Processing a scriptblock with $($codeItem.ToString().Length) characters"
			$commands = (Read-Script -ScriptCode $codeItem).Tokens | Where-Object TokenFlags -like "*CommandName*" | Group-Object Text | Select-Object -ExpandProperty Name | Where-Object { $_ }
			
			Write-PSFMessage -Level Verbose -Message "$($commands.Count) different commands found" -Target $pathItem
			
			if ($commands) { Get-CommandMetaData -CommandName $commands }
		}
		#endregion Processing Scriptblocks
	}
}