$script:ModuleRoot = $PSScriptRoot

foreach ($scriptFile in (Get-ChildItem -Path "$($script:ModuleRoot)\internal\scriptsPre\" -Recurse))
{
	. $scriptFile.FullName
}

foreach ($functionFile in (Get-ChildItem -Path "$($script:ModuleRoot)\internal\functions\" -Recurse))
{
	. $functionFile.FullName
}
foreach ($functionFile in (Get-ChildItem -Path "$($script:ModuleRoot)\functions\" -Recurse))
{
	. $functionFile.FullName
}

foreach ($scriptFile in (Get-ChildItem -Path "$($script:ModuleRoot)\internal\scriptsPost\" -Recurse))
{
	. $scriptFile.FullName
}