<#

.SYNOPSIS
Removes a monitor from an alert group.

.PARAMETER DatabaseId
Database ID of the monitor (db_id in the URL).

.PARAMETER MonitorName
Name of the monitor.

.PARAMETER Monitor
The monitor object(s).

.PARAMETER AlertGroup
The alert group object.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Remove-DpaAlertGroupMonitor -MonitorName 'MyServer' -AlertGroup (Get-DpaAlertGroup -AlertGroupName 'SQL')

Removes "MyServer" from the Alert Group "SQL."

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Remove-DpaAlertGroupMonitor {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId', Mandatory)]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string[]] $MonitorName,

        [Parameter(ParameterSetName = 'ByMonitor', ValueFromPipeline)]
        [Monitor[]] $Monitor,

        [Parameter(Mandatory)]
        [AlertGroup] $AlertGroup,

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
        foreach ($monitorObject in $Monitor) {
            Write-PSFMessage -Level Verbose -Message "Removing Database ID $($monitorObject.DatabaseId) from Alert Group ID $($AlertGroup.AlertGroupId)"
            $endpoint = "/alert-groups/$($AlertGroup.AlertGroupId)/databases/$($monitorObject.DatabaseId)"

            try {
                $null = Invoke-DpaRequest -Endpoint $endpoint -Method 'DELETE'
            } catch {
                Stop-PSFFunction -Level Critical -Message 'Could not associate monitor to alert group' -ErrorRecord $_ -EnableException $EnableException
            }
        }
    }
}