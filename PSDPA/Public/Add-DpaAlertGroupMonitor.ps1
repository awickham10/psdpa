<#

.SYNOPSIS
Add a monitor to an alert group.

.PARAMETER DatabaseId
Database ID of the monitor to get annotations for. This cannot be used in
combination with MonitorName or Monitor.

.PARAMETER MonitorName
Name of the monitor to get annotations for. This cannot be used in combination
with DatabaseId or Monitor.

.PARAMETER Monitor
Monitor object to get annotations for. This cannot be used in combination with
DatabaseId or MonitorName.

.PARAMETER AlertGroup
Alert group object to add the monitor to.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Add-DpaAlertGroupMonitor -MonitorName 'MyServer' -AlertGroup (Get-DpaAlertGroup -AlertGroupName 'SQL')

Adds "MyServer" to the "SQL" alert group.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Add-DpaAlertGroupMonitor {
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
            Write-PSFMessage -Level Verbose -Message "Adding Database ID $($monitorObject.DatabaseId) to Alert Group ID $($AlertGroup.AlertGroupId)"
            $endpoint = "/alert-groups/$($AlertGroup.AlertGroupId)/databases/$($monitorObject.DatabaseId)"

            try {
                $null = Invoke-DpaRequest -Endpoint $endpoint -Method 'Post'
            } catch {
                Stop-PSFFunction -Level Critical -Message 'Could not associate monitor to alert group' -ErrorRecord $_ -EnableException $EnableException
            }
        }
    }
}