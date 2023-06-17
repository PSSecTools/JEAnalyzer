Install-Module Microsoft.PowerShell.PSResourceGet -Force -AllowPrerelease

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