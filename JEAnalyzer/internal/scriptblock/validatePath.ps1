Set-PSFScriptblock -Name 'JEAnalyzer.ValidatePath.Directory' -Scriptblock {
	Param ($Path)
	if (-not (Test-Path $Path)) { return $false }
	try { $null = Resolve-PSFPath -Path $Path -Provider FileSystem -SingleItem }
	catch { return $false }
	(Get-Item -Path $Path).PSIsContainer
}