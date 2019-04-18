function ConvertTo-JeaCapability
{
<#
	.SYNOPSIS
		Converts the input into JEA Capabilities.
	
	.DESCRIPTION
		Converts the input into JEA Capabilities.
		This is a multitool conversion command, accepting a wide range of input objects.
		Whether it is a simple command name, the output of Get-Command, items returned by Read-JeaScriptFile or a complex hashtable.
		Example hashtable:
		@{
			'Get-Service' = @{
				Name = 'Restart-Service'
				Parameters = @{
					Name = 'Name'
					ValidateSet = 'dns', 'spooler'
				}
			}
		}
	
	.PARAMETER InputObject
		The object(s) to convert into a capability object.
	
	.EXAMPLE
		PS C:\> Get-Command Get-AD* | ConvertTo-JeaCapability
	
		Retrieves all ad commands that read data and converts them into capabilities.
#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject
	)
	
	process
	{
		foreach ($inputItem in $InputObject)
		{
			# Skip empty entries
			if ($null -eq $inputItem) { continue }
			
			# Pass through finished capabilities
			if ($inputItem -is [JEAnalyzer.Capability])
			{
				$inputItem
				continue
			}
			
			#region Decide based on input type
			switch ($inputItem.GetType().FullName)
			{
				#region Get-Command data
				'System.Management.Automation.AliasInfo'
				{
					New-Object -TypeName JEAnalyzer.CapabilityCommand -Property @{
						Name = $inputItem.ResolvedCommand.Name
						CommandType = 'Alias'
					}
					break
				}
				'System.Management.Automation.FunctionInfo'
				{
					New-Object -TypeName JEAnalyzer.CapabilityCommand -Property @{
						Name = $inputItem.Name
						CommandType = 'Function'
					}
					break
				}
				'System.Management.Automation.CmdletInfo'
				{
					New-Object -TypeName JEAnalyzer.CapabilityCommand -Property @{
						Name = $inputItem.Name
						CommandType = 'Cmdlet'
					}
					break
				}
				#endregion Get-Command data
				#region String
				'System.String'
				{
					Get-Command -Name $inputItem -ErrorAction SilentlyContinue | ConvertTo-JeaCapability
					break
				}
				#endregion String
				#region Hashtable
				'System.Collections.Hashtable'
				{
					#region Plain Single-Item hashtable
					if ($inputItem.Name)
					{
						$parameter = @{
							Name = $inputItem.Name
						}
						if ($inputItem.Parameters) { $parameter['Parameter'] = $inputItem.Parameters }
						if ($inputItem.Force) { $parameter['Force'] = $true }
						
						New-JeaCommand @parameter
					}
					#endregion Plain Single-Item hashtable
					
					#region Multiple Command Hashtable
					else
					{
						foreach ($valueItem in $inputItem.Values)
						{
							$parameter = @{
								Name = $valueItem.Name
							}
							if ($valueItem.Parameters) { $parameter['Parameter'] = $valueItem.Parameters }
							if ($inputItem.Force -or $valueItem.Force) { $parameter['Force'] = $true }
							
							New-JeaCommand @parameter
						}
					}
					#endregion Multiple Command Hashtable
					
					break
				}
				#endregion Hashtable
				#region JEAnalyzer: Command Info
				'JEAnalyzer.CommandInfo'
				{
					$inputItem.CommandObject | ConvertTo-JeaCapability
					break
				}
				#endregion JEAnalyzer: Command Info
				default
				{
					Write-PSFMessage -String 'ConvertTo-Capability.CapabilityNotKnown' -StringValues $inputItem -Level Warning
					break
				}
			}
			#endregion Decide based on input type
		}
	}
}