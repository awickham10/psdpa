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