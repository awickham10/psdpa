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

        # get all the alerts
        $endpoint = "/databases/$($Monitor.DatabaseId)/alerts"

        try {
            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'GET'
        } catch {
            Stop-PSFFunction -Message "Could not retrieve alerts for Database ID $($Monitor.DatabaseId)" -ErrorRecord $_ -EnableException $EnableException
        }
        foreach ($alert in $response.data) {
            Write-PSFMessage -Level 'Verbose' -Message "Creating alert for $($alert.id)"
            $alerts += New-Object -TypeName 'Alert' -ArgumentList $alert
        }

        $alerts
    }
}