# Dot source this script in any Pester test script that requires the module to be imported.
if(-not $ENV:BHProjectPath)
{
    Set-BuildEnvironment -Path $PSScriptRoot\..
}
$PSVersion = $PSVersionTable.PSVersion.Major
$ModuleName = $ENV:BHProjectName

Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
Import-Module (Join-Path $ENV:BHProjectPath $ModuleName) -Force

function Initialize-TestDrive {
    param (
        $Tag
    )

    Copy-Item "$PSScriptRoot\Responses\$Tag\*" "TestDrive:\"
}

function Get-JsonResponse {
    param (
        $Tag,
        $Response
    )

    Get-Content -Path "TestDrive:\$Tag\$Response.json" -Raw | ConvertFrom-Json
}