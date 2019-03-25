Write-PSFMessage -Level Verbose -Message 'Loading constants from Constants.ps1'

$localConstants = Join-Path -Path (Split-Path -Path $ConstantsFile -Parent) -ChildPath 'Constants.Local.ps1'
if (Test-Path -Path $localConstants) {
    . $localConstants
    return
}

if (-not $ENV:PSDPA_URI) {
    Stop-PSFFunction -Message "Environment variable PSDPA_URI is not set" -EnableException
}

if (-not $ENV:PSDPA_TOKEN) {
    Stop-PSFFunction -Message "Environment variable PSDPA_TOKEN is not set" -EnableException
}

Set-PSFConfig -Module 'PSDPA' -Name 'baseuri' -Value $ENV:PSDPA_URI
Set-PSFConfig -Module 'PSDPA' -Name 'refreshtoken' -Value $ENV:PSDPA_TOKEN