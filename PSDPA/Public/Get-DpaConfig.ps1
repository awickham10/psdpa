<#

.SYNOPSIS
Gets a configuration option for PSDPA.

.PARAMETER Name
Name of the configuration option. Wildcarding with * is supported.

.EXAMPLE
Get-DpaConfig -Name *

Gets all configuration options for PSDPA

.EXAMPLE
Get-DpaConfig -Name baseuri

Gets the BaseUri configuration option for DPA

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Get-DpaConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Name = "*"
    )

    $module = "psdpa"

    $Name = $Name.ToLower()

    $results = [PSFramework.Configuration.ConfigurationHost]::Configurations.Values | Where-Object {
        ($_.Name -like $Name) -and
        ($_.Module -like $Module) -and
        ((-not $_.Hidden) -or ($Force))
    } | Sort-Object Module, Name

    $results | Select-Object Name, Value, Description
}