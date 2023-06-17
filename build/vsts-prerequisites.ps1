Install-Module Microsoft.PowerShell.PSResourceGet -Force

$modules = @(
	'Pester'
	'PSScriptAnalyzer'
	'PSFramework'
	'PSModuleDevelopment'
)

foreach ($module in $Modules) {
	Write-Host "Installing $module" -ForegroundColor Cyan
	Install-PSResource $module
}