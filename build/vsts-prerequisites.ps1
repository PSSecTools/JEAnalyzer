$modules = @(
	'Pester'
	'PSScriptAnalyzer'
	'PSFramework'
	'PSModuleDevelopment'
)

foreach ($module in $modules) {
	Write-Host "Installing $module" -ForegroundColor Cyan
	Install-Module $module -Force -SkipPublisherCheck
}