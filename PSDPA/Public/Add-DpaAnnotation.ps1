<#

.SYNOPSIS
Adds a custom annotation to a monitor in DPA.

.DESCRIPTION
Adds a custom annotation to a monitor or monitors in DPA.

.PARAMETER DatabaseId
Database ID of the monitor to get annotations for. This cannot be used in
combination with MonitorName or Monitor.

.PARAMETER MonitorName
Name of the monitor to get annotations for. This cannot be used in combination
with DatabaseId or Monitor.

.PARAMETER Monitor
Monitor object to get annotations for. This cannot be used in combination with
DatabaseId or MonitorName.

.PARAMETER Time
The time the annotation occurred. If not specified the current time will be
used.

.PARAMETER Title
The title of the annotation. This is the "Annotation" field in DPA.

.PARAMETER Description
A longer description of what happened. This is the "Details" field in DPA.

.PARAMETER CreatedBy
Who created the annotation. If not specified the username of the user running
the command will be used.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Add-DpaAnnotation -DatabaseId 1 -Title "Patching" -Description "Latest security patches" -CreatedBy "Andrew"

Adds an annotation "Patching" with a description of "Latest security patches" to
Database ID 1.

.EXAMPLE
Add-DpaAnnotation -MonitorName 'MyMonitoredServer' -Title "Patching" -Description "Latest security patches" -CreatedBy "Andrew"

Adds an annotation "Patching" with a description of "Latest security patches" to
MyMonitoredServer.

.EXAMPLE
Get-DpaMonitor | Add-DpaAnnotation -Title "Patching" -Description "Latest security patches" -CreatedBy "Andrew"

Adds an annotation "Patching" with a description of "Latest security patches" to
all monitors.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Add-DpaAnnotation {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId', Mandatory)]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string[]] $MonitorName,

        [Parameter(ParameterSetName = 'ByMonitor', ValueFromPipeline)]
        [Monitor[]] $Monitor,

        [Parameter()]
        [DateTime] $Time = (Get-Date),

        [Parameter()]
        [string] $Title,

        [Parameter(Mandatory)]
        [string] $Description,

        [Parameter()]
        [string] $CreatedBy = ([Environment]::UserName),

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

            $request = @{
                'title'       = $Title
                'description' = $Description
                'createdBy'   = $CreatedBy
                'time'        = $Time.ToString("yyyy-MM-ddTHH\:mm\:sszzz")
            }

            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Post' -Request $request
            New-Object -TypeName 'Annotation' -ArgumentList $response.data
        }
    }
}