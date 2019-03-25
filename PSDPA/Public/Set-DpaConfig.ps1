<#

.SYNOPSIS
Sets configuration options for PSDPA.

.PARAMETER BaseUri
The base URI for the DPA API.

.PARAMETER RefreshToken
The refresh token for the DPA API.

.EXAMPLE
Set-DpaConfig -BaseUri 'http://yourserver:8123/iwc/api' -RefreshToken 'yourrefreshtoken'

Sets the Base URI and Refresh Token for the DPA API.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>
function Set-DpaConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        $BaseUri,

        [Parameter()]
        $RefreshToken
    )

    process {
        if ($PSCmdlet.ShouldProcess('Updated Config')) {
            foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
                $name = $parameter.Key.ToLower()

                Set-PSFConfig -Module psdpa -Name $name -Value $parameter.Value
                Register-PSFConfig -FullName psdpa.$name -EnableException -WarningAction SilentlyContinue

                if ($name -eq 'refreshtoken') {
                    Set-Variable -Scope 1 -Name PSDefaultParameterValues -Value @{ 'PSDPA:AccessToken' = $value }
                }
            }

            Get-DpaConfig -Name $name
        }
    }
}