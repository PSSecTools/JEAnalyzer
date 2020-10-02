$script:ModuleRoot = $PSScriptRoot

foreach ($scriptFile in (Get-ChildItem -Path "$($script:ModuleRoot)\internal\scriptsPre\" -Recurse -Filter *.ps1))
{
	. $scriptFile.FullName
}

foreach ($functionFile in (Get-ChildItem -Path "$($script:ModuleRoot)\internal\functions\" -Recurse -Filter *.ps1))
{
	. $functionFile.FullName
}
foreach ($functionFile in (Get-ChildItem -Path "$($script:ModuleRoot)\functions\" -Recurse -Filter *.ps1))
{
	. $functionFile.FullName
}

foreach ($scriptFile in (Get-ChildItem -Path "$($script:ModuleRoot)\internal\scriptsPost\" -Recurse -Filter *.ps1))
{
	. $scriptFile.FullName
}