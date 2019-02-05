# Dot source this script in any Pester test script that requires the module to be imported.
if(-not $ENV:BHProjectPath)
{
    Set-BuildEnvironment -Path $PSScriptRoot\..
}
$PSVersion = $PSVersionTable.PSVersion.Major
$ModuleName = $ENV:BHProjectName

Set-PSFConfig -Module 'PSDPA' -Name 'developer' -Value $true

. (Join-Path -Path $PSScriptRoot -ChildPath 'Constants.ps1')

Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
Import-Module (Join-Path $ENV:BHProjectPath $ModuleName) -Force
Import-Module (Join-Path -Path (Join-Path $ENV:BHProjectPath $ModuleName) -ChildPath "$ModuleName.psm1")

function Get-MockJsonResponse {
    param (
        $Tag,
        $Response
    )

    Get-Content -Path "$PSScriptRoot\Responses\$Tag\$Response.json" -Raw | ConvertFrom-Json
}