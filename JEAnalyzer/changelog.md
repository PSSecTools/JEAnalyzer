# Changelog

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