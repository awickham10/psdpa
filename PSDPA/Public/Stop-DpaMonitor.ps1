<#

.SYNOPSIS
Stops a DPA monitor

.PARAMETER DatabaseId
Database ID of the monitor to stop. This cannot be used in combination with
MonitorName.

.PARAMETER MonitorName
Name of the monitor to stop. This cannot be used in combination with DatabaseId.

.PARAMETER Monitor
Monitor object to stop. This cannot be used in combination with DatabaseId or
MonitorName.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Stop-DpaMonitor -DatabaseId 1

Stops the monitor for Database ID 1

.EXAMPLE
Stop-DpaMonitor -MonitorName 'MyMonitoredServer'

Stops the monitor for 'MyMonitoredServer'

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Stop-DpaMonitor {
    [CmdletBinding(DefaultParameterSetName = 'ByName', SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId', Mandatory)]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string[]] $MonitorName,

        [Parameter(ParameterSetName = 'ByMonitor', ValueFromPipeline)]
        [Monitor[]] $Monitor,

        [Parameter()]
        [switch] $EnableException
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $Monitor = Get-DpaMonitor -MonitorName $MonitorName
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByDatabaseId') {
            $Monitor = Get-DpaMonitor -DatabaseId $DatabaseId
        }

        $request = @{
            command = 'STOP'
        }
    }

    process {
        foreach ($monitorObject in $Monitor) {
            if ($PSCmdlet.ShouldProcess($monitor.Name, 'Stop Monitor')) {
                try {
                    $response = Invoke-DpaRequest -Endpoint "/databases/$($monitorObject.Dbid)/monitor-status" -Method 'PUT' -Request $request
                } catch {
                    Stop-PSFFunction -Message "Could not stop the monitor" -ErrorRecord $_ -Target $monitorObject.Name
                }
            }
        }
    }
}