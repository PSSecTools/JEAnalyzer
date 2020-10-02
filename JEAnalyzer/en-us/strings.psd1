@{
	'Add-JeaModuleRole.AddingRole'			   = 'Adding role {0} to module {1}' # $roleItem.Name, $Module.Name
	'Add-JeaModuleRole.RolePresent'		       = 'Role {0} already exists in {1}! Use -Force to replace the existing role.' # $roleItem.Name, $Module.Name
	
	'ConvertTo-Capability.CapabilityNotKnown'  = 'Could not convert to capability: {0}' # $inputItem
	
	'Export-JeaModule.File.Create'			   = 'Creating File: {0}' # $Path
	'Export-JeaModule.Folder.Content'		   = 'Creating subfolder: {0}' # $folder
	'Export-JeaModule.Folder.ModuleBaseExists' = "The module's base folder already exists: {0}" # $moduleBase.FullName
	'Export-JeaModule.Folder.ModuleBaseNew'    = 'Creating new module folder: {0}' # $moduleBase.FullName
	'Export-JeaModule.Folder.RoleCapailities'  = 'Creating the folder to store Role Capability Files: {0}\RoleCapabilities' # $rootFolder.FullName
	'Export-JeaModule.Folder.VersionRoot'	   = 'Creating version specific module path: {0}\{1}' # $moduleBase.FullName, $moduleObject.Version
	'Export-JeaModule.Role.NewRole'		       = 'Creating new Role: {0} ({1} Published Command Capabilities)' # $role.Name, $role.CommandCapability.Count
	'Export-JeaModule.Role.VisibleCmdlet'	   = '[Role: {0}] Adding visible Cmdlet: {1}{2}' # $role.Name, $commandName, $parameterText
	'Export-JeaModule.Role.VisibleFunction'    = '[Role: {0}] Adding visible Function: {1}{2}' # $role.Name, $commandName, $parameterText
	
	'FileSystem.Directory.Fail'			       = 'Not a directory: {0}' # <user input>, <validation item>
	
	'General.BoundParameters'				   = 'Bound parameters: {0}' # ($PSBoundParameters.Keys -join ", ")
	
	'Import-JeaScriptFile.ParsingError'	       = 'Parsing error for file: {0}' # $file
	'Import-JeaScriptFile.ProcessingInput'	   = 'Processing file for import: {0}' # $file
	'Import-JeaScriptFile.UnknownError'	       = 'Unknown error when processing file: {0}' # $file
	
	'Install-JeaModule.Connecting.Sessions'    = 'Connecting via WinRM to {0}' # ($ComputerName -join ", ")
	'Install-JeaModule.Connections.Failed'	   = 'Failed to connect to {0}' # ($failedServers.TargetObject -join ", ")
	'Install-JeaModule.Connections.NoSessions' = 'No successful sessions established, terminating.' # 
	'Install-JeaModule.Copying.Module'		   = 'Copying JEA module {0} to {1}' # $moduleObject.Name, $session.ComputerName
	'Install-JeaModule.Exporting.Module'	   = 'Exporting JEA module {0}' # $moduleObject.Name
	'Install-JeaModule.Installing.Module'	   = 'Installing JEA module {0}' # $moduleObject.Name
	
	'New-JeaCommand.DangerousCommand'		   = 'Dangerous command detected: {0}. Interrupting, use "-Force" to accept insecure commands.' # $Name
	
	'New-JeaModule.Creating'				   = 'Creating JEA Module object for: {0} (v{1})' # $Name, $Version
	
	'New-JeaRole.Creating'					   = 'Creating Role: {0}' # $Name
}