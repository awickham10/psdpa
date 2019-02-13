<#

.SYNOPSIS
Gets licensing details for a monitored server.

.DESCRIPTION
Gets what licenses are allocated to a server in DPA.

.PARAMETER DatabaseId
The Database IDs of the monitor.

.PARAMETER MonitorName
The name(s) of the monitor.

.PARAMETER Monitor
The monitor object(s).

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Get-DpaMonitor | Get-DpaMonitorLicense

Gets licensing details for all monitored servers.

.EXAMPLE
Get-DpaMonitorLicense -DatabaseId 1

Gets licensing details for Database ID 1

.EXAMPLE
Get-DpaMonitorLicense -MonitorName 'MyMonitoredServer'

Gets licensing details for MyMonitoredServer.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

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
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByDatabaseId') {
            $Monitor = Get-DpaMonitor -DatabaseId $DatabaseId
        }
    }

    process {
        foreach ($monitorObject in $Monitor) {
            $endpoint = "/databases/$($monitorObject.DatabaseId)/licenses"
            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'

            [PSCustomObject] @{
                ServerName                = $response.data.serverName
                OverLicensed              = $response.data.overLicensed
                VmLicenseProduct          = $response.data.vmLicenseProduct
                PerformanceLicenseProduct = $response.data.performanceLicenseProduct
            }
        }
    }

}