Set-PSFScriptblock -Name 'JEAnalyzer.Validate.ServiceAccount' -Scriptblock {
	$_ -match '^[^\\]+\\[^\\]+$'
} -Global