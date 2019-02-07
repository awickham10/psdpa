function Get-DpaMonitorLicense {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId')]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName')]
        [string[]] $MonitorName,

        [Parameter(ParameterSetName = 'ByMonitor', ValueFromPipeline)]
        [Monitor[]] $Monitor,

        [switch] $EnableException
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $Monitor = Get-DpaMonitor -MonitorName $MonitorName
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByDatabaseId') {
            $Monitor = Get-DpaMonitor -DatabaseId $DatabaseId
        }
    }

    process {
        foreach ($monitorObject in $Monitor) {
            $endpoint = "/databases/$($monitorObject.DatabaseId)/licenses"
            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'

            [PSCustomObject] @{
                ServerName = $response.data.serverName
                OverLicensed = $response.data.overLicensed
                VmLicenseProduct = $response.data.vmLicenseProduct
                PerformanceLicenseProduct = $response.data.performanceLicenseProduct
            }
        }
    }

}