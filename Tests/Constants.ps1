Write-PSFMessage -Level Verbose -Message 'Loading constants from Constants.ps1'

$localConstants = Join-Path -Path (Split-Path -Path $ConstantsFile -Parent) -ChildPath 'Constants.Local.ps1'
if (Test-Path -Path $localConstants) {
    . $localConstants
    return
}

if (-not $ENV:PSDPA_BASEURI) {
    Stop-PSFFunction -Message "Environment variable PSDPA_BASEURI is not set" -EnableException $true
}

if (-not $ENV:PSDPA_TOKEN) {
    Stop-PSFFunction -Message "Environment variable PSDPA_TOKEN is not set" -EnableException $true
}

Set-PSFConfig -Module 'PSDPA' -Name 'baseuri' -Value $ENV:PSDPA_BASEURI
Set-PSFConfig -Module 'PSDPA' -Name 'refreshtoken' -Value $ENV:PSDPA_TOKEN