function Get-DpaMonitorAlert {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId', Mandatory)]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string[]] $MonitorName,

        [Parameter(ParameterSetName = 'ByMonitor', ValueFromPipeline)]
        [Monitor[]] $Monitor,

        [Parameter()]
        [int[]] $AlertId,

        [Parameter()]
        [switch] $IncludeAlertGroupAlerts,

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
        $alerts = @()

        if ($IncludeAlertGroupAlerts) {
            $groupEndpoint = "/databases/$($Monitor.DatabaseId)/alert-groups"
            try {
                $groupAlerts = Invoke-DpaRequest -Endpoint $groupEndpoint -Method 'GET'
                foreach ($alertGroup in $groupAlerts.data) {
                    foreach ($groupAlertId in $alertGroup.alertIds) {
                        $alerts += Get-DpaMonitorAlert -Monitor $Monitor -AlertId $groupAlertId
                    }
                }
            } catch {
                Stop-PSFFunction -Message "Could not retrieve alert groups for Database ID $($Monitor.DatabaseId)" -ErrorRecord $_ -EnableException $EnableException
            }
        }

        if (Test-PSFParameterBinding -ParameterName 'AlertId') {
            Write-PSFMessage -Level 'Verbose' -Message 'Getting a single alert'
            $endpoint = "/alerts/$AlertId"
        } else {
            Write-PSFMessage -Level 'Verbose' -Message 'Getting all associated alerts'
            $endpoint = "/databases/$($Monitor.DatabaseId)/alerts"
        }

        try {
            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'GET'
        } catch {
            Stop-PSFFunction -Message "Could not retrieve alerts for Database ID $($Monitor.DatabaseId)" -ErrorRecord $_ -EnableException $EnableException
        }

        foreach ($alert in $response.data) {
            if ($alerts.AlertId -notcontains $alert.id) {
                Write-PSFMessage -Level 'Verbose' -Message "Getting alert status for Database ID $($Monitor.DatabaseId) and Alert ID $($alert.id)"
                $statusEndpoint = "/alerts/$($alert.id)/databases/$($Monitor.DatabaseId)/status"
                try {
                    $statusResponse = Invoke-DpaRequest -Endpoint $statusEndpoint -Method 'GET'
                    $status = $statusResponse.data
                } catch {
                    Stop-PSFFunction -Message 'Could not retrieve alert status' -ErrorRecord $_ -EnableException $EnableException
                }
    
                Write-PSFMessage -Level 'Verbose' -Message "Creating alert for $($alert.id)"
                $alerts += New-Object -TypeName 'MonitorAlert' -ArgumentList $alert, $status
            }
        }

        $alerts
    }
}