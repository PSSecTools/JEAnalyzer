# JEAnalyzer

## Synopsis

Simplifies the implementation and management of Just Enough Administration.

It provides tools to:

- Scan commands for potential danger when exposed in a JEA endpoint
- Create JEA Endpoints in simple and convenient manner

## Getting Started

To install the module, run:

```powershell
Install-Module JEAnalyzer
```

Then you are ready to create a new JEA module:

```powershell
$module = New-JeaModule -Name ServerOperations -Description 'JEA Module for basic Server Operations' -Author 'Friedrich Weinmann' -Company Contoso -Version 1.0.0
'Restart-Computer', 'Get-ScheduledTask', 'Start-ScheduledTask', 'Stop-ScheduledTask' | Get-Command | New-JeaRole -Name 'ServerSystem' -Identity 'contoso\ServerSystemPermissions' -Module $module
'Send-RDUserMessage', 'Get-RDUserSession', 'Disconnect-RDUser' | New-JeaRole -Name 'RDSHelpDesk' -Identity 'contoso\RDSHelpDeskPermissions' -Module $module
$module | Export-JeaModule -Path '.'
```

This will create a module in the current folder that can be deployed using default package management tools.

When installed on a target machine (under C:\Program Files\WindowsPowerShell\Modules), registering it as an endpoint is straightforward:

```powershell
Register-JeaEndpoint_JEA_ServerOperations
```

> Note: This requires elevation and must be run in the computer it is installed on.

Registering a JEA endpoint will restart the WinRM service on the computer, disconnecting all sessions.
Executing this command via remoting will thus lead to an error, but not affect the results.
