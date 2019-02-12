<#

.SYNOPSIS
Starts a DPA monitor

.PARAMETER DatabaseId
Database ID of the monitor to start. This cannot be used in combination with
MonitorName.

.PARAMETER MonitorName
Name of the monitor to start. This cannot be used in combination with DatabaseId.

.PARAMETER Monitor
Monitor object to start. This cannot be used in combination with DatabaseId or
MonitorName.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Start-DpaMonitor -DatabaseId 1

Starts the monitor for Database ID 1

.EXAMPLE
Start-DpaMonitor -MonitorName 'MyMonitoredServer'

Starts the monitor for 'MyMonitoredServer'

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Start-DpaMonitor {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
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
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByDatabaseId') {
            $Monitor = Get-DpaMonitor -DatabaseId $DatabaseId
        }

        $request = @{
            command = 'START'
        }
    }

    process {
        foreach ($monitorObject in $monitor) {
            try {
                $response = Invoke-DpaRequest -Endpoint "/databases/$($monitor.Dbid)/monitor-status" -Method 'PUT' -Request $request
            }
            catch {
                Stop-PSFFunction -Message "Could not start the monitor" -EnableException:$EnableException -ErrorRecord $_ -Target $monitor.Name
            }
        }
    }
}