# Changelog

## 1.3.19 (2025-05-07)

- Upd: New-JeaModule - better service account validation and processing
- Fix: Install-JeaModule - unexpected error when failing to connect to remote computer

## 1.3.17 (2023-06-18)

- New: Get-JeaEndpoint - Retrieve JEA Endpoints and their capabilities from target computers.
- New: Uninstall-JeaModule - Remove JEA Endpoints and - optionally - their backing code.
- Upd: JEA Module - registering a JEA module now creates a scheduled task first to restore the WinRM service in case it fails its restart (as is its wont)
- Upd: Export-JeaModule - able to export as selfcontained ps1 file.
- Upd: New-JeaModule - added ModulesToImport parameter to import modules explicitly, without requiring them as a module dependency.
- Fix: JEA Module - registering a new version fails without manually unregistering the previous JEA endpoint
- Fix: New-JeaModule - using RequiredModules fails

## 1.2.10

- New: Command Install-JeaModule - Installs a JEA module on the target computer
- New: Command Add-JeaModuleScript - Adds a script to a JEA module
- New: Command Test-JeaCommand - Test an individual command for safety to publish in an endpoint.
- Upd: New-JeaModule - Added parameters for PreImport and PostImport scripts
- Upd: New-JeaModule - New parameter `-RequiredModules` enables specifying prerequisites
- Upd: New-JeaCommand - New parameter: `-CommandType` allows picking the type of command for unresolveable commands.
- Upd: JeaModules - all roles will now automatically import the jea module, irrespective of commands used
- Fix: Export-JeaModule - Does not write preimport and postimport scripts
- Fix: New-JeaCommand - Fails for unknown commands
- Fix: Export-JeaModule - New JEA modules will only try to load ps1 files on import.

## 1.1.0 (???)

- Pre-History
