Set-PSFScriptblock -Name 'JEAnalyzer.ValidateType.Module' -Scriptblock {
	$_.PSObject.Typename -contains 'JEAnalyzer.Module'
}

Set-PSFScriptblock -Name 'JEAnalyzer.ValidateType.Roles' -Scriptblock {
	foreach ($role in $_)
	{
		if ($_.PSObject.Typename -notcontains 'JEAnalyzer.Role') { return $false }
	}
	$true
}