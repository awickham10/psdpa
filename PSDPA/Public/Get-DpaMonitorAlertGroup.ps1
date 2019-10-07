<#

.SYNOPSIS
Gets alert groups assigned to a monitor.

.PARAMETER DatabaseId
Database ID of the monitor (db_id in the URL).

.PARAMETER MonitorName
Name of the monitor.

.PARAMETER Monitor
The monitor object(s).

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Get-DpaMonitorAlertGroup -MonitorName 'My Server'

Gets alert groups "My Server" is part of.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Get-DpaMonitorAlertGroup {
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
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByDatabaseId') {
            $Monitor = Get-DpaMonitor -DatabaseId $DatabaseId
        }
    }

    process {
        $alertGroups = @()

        # get all the alert groups
        $endpoint = "/databases/$($Monitor.DatabaseId)/alert-groups"

        try {
            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'GET'
        } catch {
            Stop-PSFFunction -Message "Could not retrieve alert groups for Database ID $($Monitor.DatabaseId)" -ErrorRecord $_ -EnableException $EnableException
        }
        foreach ($alertGroup in $response.data) {
            Write-PSFMessage -Level 'Verbose' -Message "Creating alert group for $($alertGroup.id)"
            $alertGroups += New-Object -TypeName 'AlertGroup' -ArgumentList $alertGroup
        }

        $alertGroups
    }
}