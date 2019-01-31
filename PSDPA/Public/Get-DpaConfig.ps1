function Get-DpaConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Name = "*"
    )

    begin {
        $module = "psdpa"
    }

    process {
        $Name = $Name.ToLower()

        $results = [PSFramework.Configuration.ConfigurationHost]::Configurations.Values | Where-Object {
                ($_.Name -like $Name) -and
                ($_.Module -like $Module) -and
                ((-not $_.Hidden) -or ($Force))
            } | Sort-Object Module, Name

        $results | Select-Object Name, Value, Description
    }
}