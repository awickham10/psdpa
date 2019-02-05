$localConstants = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Constants.Local.ps1'
if (Test-Path -Path $localConstants) {
    .\$localConstants
    return
}

Set-PSFConfig -Module 'PSDPA' -Name 'baseuri' -Value 'https://myfakedpaserver:8124/iwc/api'
Set-PSFConfig -Module 'PSDPA' -Name 'refreshtoken' -Value 'thisismyrefreshtoken'