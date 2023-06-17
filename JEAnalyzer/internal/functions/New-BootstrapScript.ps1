function New-BootstrapScript {
	<#
	.SYNOPSIS
		Take all contents of a folder and embed them into a bootstrap scriptfile.
	
	.DESCRIPTION
		Take all contents of a folder and embed them into a bootstrap scriptfile.
		The targeted folder must contain a run.ps1 file for executing the bootstrap logic.

		When executing the resulting file, it will:
		- Create a temp folder
		- Write all contents of the source folder into that temp folder
		- Execute run.ps1 within that temp folder
		- Remove the temp folder
	
	.PARAMETER Path
		The source folder containing the content to wrap up.
		Must contain a file named run.ps1, may contain subfolders.
	
	.PARAMETER OutPath
		The path where to write the bootstrap scriptfile to.
		Can be either a folder or the path to the ps1 file itself.
		If a folder is specified, it will create a "bootstrap.ps1" file in that folder.
	
	.EXAMPLE
		PS C:\> New-BootstrapScript -Path . -OutPath C:\temp
		
		Takes all items in the current folder, wraps them into a bootstrap script and writes that single file to C:\temp\bootstrap.ps1
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PsfValidateScript('PSFramework.Validate.FSPath.Folder', ErrorString = 'PSFramework.Validate.FSPath.Folder')]
		[string]
		$Path,

		[Parameter(Mandatory = $true)]
		[PsfValidateScript('PSFramework.Validate.FSPath.FileOrParent', ErrorString = 'PSFramework.Validate.FSPath.FileOrParent')]
		[string]
		$OutPath
	)
	process {
		$runFile = Join-Path -Path $Path -ChildPath 'run.ps1'
		if (-not (Test-Path -Path $runFile)) {
			Stop-PSFFunction -String 'New-BootstrapScript.Validation.NoRunFile' -StringValues $runFile -Target $Path -EnableException $true -Cmdlet $PSCmdlet -Category InvalidData
		}

		$tempFile = New-PSFTempFile -Name bootstrapzip -Extension zip -ModuleName JEAnalyzer
		Compress-Archive -Path (Join-Path -Path $Path -ChildPath '*') -DestinationPath $tempFile -Force
		$bytes = [System.IO.File]::ReadAllBytes($tempFile)
		$encoded = [convert]::ToBase64String($bytes)
		$bytes = $null

		$bootstrapCode = [System.IO.File]::ReadAllText("$script:ModuleRoot\internal\resources\bootstrap.ps1")
		$bootstrapCode = $bootstrapCode -replace '%data%', $encoded
		$encoded = $null
		Remove-PSFTempItem -Name bootstrapzip -ModuleName JEAnalyzer

		$outFile = Resolve-PSFPath -Path $OutPath -Provider FileSystem -SingleItem -NewChild
		if (Test-Path -Path $OutPath) {
			$item = Get-Item -Path $OutPath
			if ($item.PSIsContainer) {
				$outFile = Join-Path -Path $outFile -ChildPath 'bootstrap.ps1'
			}
		}
		$filename = Split-Path -Path $outFile -Leaf
		$bootstrapCode = $bootstrapCode -replace '%scriptname%', $filename

		$encoding = [System.Text.UTF8Encoding]::new($true)
		[System.IO.File]::WriteAllText($outFile, $bootstrapCode, $encoding)
	}
}