<#

.SYNOPSIS
Gets custom annotations from DPA.

.DESCRIPTION
Gets custom annotations from DPA for a specific monitor within an optionally
specified time period.

.PARAMETER DatabaseId
Database ID of the monitor to get annotations for. This cannot be used in
combination with MonitorName or Monitor.

.PARAMETER MonitorName
Name of the monitor to get annotations for. This cannot be used in combination
with DatabaseId or Monitor.

.PARAMETER Monitor
Monitor object to get annotations for. This cannot be used in combination with
DatabaseId or MonitorName.

.PARAMETER StartTime
The beginning of the time period to get annotations for.

.PARAMETER EndTime
The end of the time period to get annotations for.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Get-DpaAnnotation -DatabaseId 1

Gets annotations for a specific Database ID

.EXAMPLE
Get-DpaAnnotation -MonitorName 'MyMonitoredServer'

Gets annotations for a specific monitor name

.EXAMPLE
Get-DpaMonitor -MonitorName 'MyMonitoredServer' | Get-DpaAnnotation

Gets annotations by piping a monitor

.EXAMPLE
Get-DpaMonitor | Get-DpaAnnotation -StartTime (Get-Date).AddDays(-30)

Get all annotations over the last 30 days for all monitors

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>
function Get-DpaAnnotation {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId')]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName')]
        [string[]] $MonitorName,

        [Parameter(ParameterSetName = 'ByMonitor', ValueFromPipeline)]
        [Monitor[]] $Monitor,

        [Parameter()]
        [DateTime] $StartTime = (Get-Date).AddDays(-30),

        [Parameter()]
        [DateTime] $EndTime = (Get-Date),

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
            $endpoint = "/databases/$($monitorObject.DatabaseId)/annotations"

            $parameters = @{
                'startTime' = $StartTime.ToString("yyyy-MM-ddTHH\:mm\:ss.fffzzz")
                'endTime'   = $EndTime.ToString("yyyy-MM-ddTHH\:mm\:ss.fffzzz")
            }

            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get' -Parameters $parameters
            foreach ($annotation in $response.data) {
                New-Object -TypeName 'Annotation' -ArgumentList $monitorObject, $annotation
            }
        }
    }
}