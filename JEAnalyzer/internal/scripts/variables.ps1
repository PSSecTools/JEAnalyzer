﻿# List of potentially dangerous commands
$script:dangerousCommands = @(
	'%'
	'ForEach'
	'ForEach-Object'
	'?'
	'Where'
	'Where-Object'
	'iex'
    'Add-LocalGroupMember'
	'Add-ADGroupMember'
	'net'
	'net.exe'
	'dsadd'
    'dsadd.exe'
    'Start-Process'
    'New-Service'
	'Invoke-Item'
	'iwmi'
    'Invoke-WmiMethod'
    'Invoke-CimMethod'
    'Invoke-Expression'
    'Invoke-Command'
    'New-ScheduledTask'
	'Register-ScheduledJob'
	'Register-ScheduledTask'
    '*.ps1'
)