# Load English strings
Import-PSFLocalizedString -Path "$script:ModuleRoot\en-us\strings.psd1" -Module JEAnalyzer -Language en-US

# Obtain strings variable for in-script use
$script:strings = Get-PSFLocalizedString -Module JEAnalyzer