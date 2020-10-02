function Import-JeaScriptFile
{
<#
	.SYNOPSIS
		Loads scriptfiles as JEA Capability.
	
	.DESCRIPTION
		Loads scriptfiles as JEA Capability.
		This will ...
		- convert the specified script into a function,
		- register that function as a capability and
		- add the function as a public function to the module.
	
	.PARAMETER Path
		The path to the file(s).
		Folder items will be skipped.
		
	.PARAMETER FunctionName
		The name to apply to the function.
		Overrides the default function name finding.
	
	.PARAMETER Role
		The role to add the capability to.
		Specifying a role will suppress the object return.
	
	.PARAMETER Encoding
		The encoding in which to read the files.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Import-JeaScriptFile -Path '.\script.ps1'
	
		Creates a script capability from the .\script.ps1 file.
		The function added will be named 'Invoke-Script'
	
	.EXAMPLE
		PS C:\> Import-JeaScriptFile -Path .\script.ps1 -FunctionName 'Get-ServerHealth'
	
		Creates a script capability from the .\script.ps1 file.
		The function added will be named 'Get-ServerHealth'
	
	.EXAMPLE
		PS C:\> Get-ChildItem C:\JEA\Role1\*.ps1 | Import-JeaScriptFile -Role $role
	
		Reads all scriptfiles in C:\JEA\Role1, converts them into functions, names them and adds them to the role stored in $role.
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '')]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[string]
		$FunctionName,
		
		[JEAnalyzer.Role]
		$Role,
		
		[PSFEncoding]
		$Encoding = (Get-PSFConfigValue -FullName PSFramework.Text.Encoding.DefaultRead),
		
		[switch]
		$EnableException
	)
	
	begin
	{
		#region Utility Functions
		function Test-Function
		{
			[CmdletBinding()]
			param (
				[string]
				$Path
			)
			$tokens = $null
			$errors = $null
			$ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
			if ($errors)
			{
				return [pscustomobject]@{
					IsFunction = $false
					ErrorType  = 'ParseError'
					Errors	   = $errors
				}
			}
			elseif ($ast.EndBlock.Statements.Count -ne 1)
			{
				return $false
			}
			elseif ($ast.EndBlock.Statements[0] -is [System.Management.Automation.Language.FunctionDefinitionAst])
			{
				return [pscustomobject]@{
					IsFunction = $true
					Name	   = $Ast.EndBlock.Statements[0].Name
				}
			}
			return $false
		}
		#endregion Utility Functions
	}
	process
	{
		foreach ($file in (Resolve-PSFPath -Path $Path -Provider FileSystem))
		{
			Write-PSFMessage -String 'Import-JeaScriptFile.ProcessingInput' -StringValues $file
			$fileItem = Get-Item -LiteralPath $Path
			if ($fileItem.PSIsContainer) { continue }
			
			$testResult = Test-Function -Path $file
			#region Case: Script File
			if (-not $testResult)
			{
				$functionName = 'Invoke-{0}' -f $host.CurrentCulture.TextInfo.ToTitleCase(($fileItem.BaseName -replace '\[\]\s','_'))
				if ($fileItem.BaseName -like '*-*')
				{
					$verb = $fileItem.BaseName -split '-', 2
					if (Get-Verb -verb $verb) { $functionName = $host.CurrentCulture.TextInfo.ToTitleCase(($fileItem.BaseName -replace '\[\]\s', '_')) }
				}
				if ($Name) { $functionName = $Name }
				
				$functionString = @'
function {0}
{{
{1}
}}
'@ -f $functionName, ([System.IO.File]::ReadAllText($file, $Encoding))
				
				Invoke-Expression $functionString
				$functionInfo = Get-Command -Name $functionName
				$capability = New-Object -TypeName 'JEAnalyzer.CapabilityScript'
				$capability.Content = $functionInfo
				$capability.Name = $functionInfo.Name
				if ($Role) { $Role.CommandCapability[$capability.Name] = $capability }
				else { $capability }
			}
			#endregion Case: Script File
			
			#region Case: Parse Error
			elseif ($testResult.ErrorType -eq 'ParseError')
			{
				Stop-PSFFunction -String 'Import-JeaScriptFile.ParsingError' -StringValues $file -Continue -EnableException $EnableException
			}
			#endregion Case: Parse Error
			
			#region Case: Function File
			elseif ($testResult.IsFunction)
			{
				. $file
				$functionInfo = Get-Command -Name $testResult.Name
				$capability = New-Object -TypeName 'JEAnalyzer.CapabilityScript'
				$capability.Content = $functionInfo
				$capability.Name = $functionInfo.Name
				if ($Role) { $Role.CommandCapability[$capability.Name] = $capability }
				else { $capability }
			}
			#endregion Case: Function File
			
			#region Case: Unknown State (Should never happen)
			else
			{
				Stop-PSFFunction -String 'Import-JeaScriptFile.UnknownError' -StringValues $file -Continue -EnableException $EnableException
			}
			#endregion Case: Unknown State (Should never happen)
		}
	}
}