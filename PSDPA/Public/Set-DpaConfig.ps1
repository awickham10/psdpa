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