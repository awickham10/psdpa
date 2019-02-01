function Start-DpaMonitor {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId', Mandatory)]
        $DatabaseId,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        $MonitorName,

        [switch] $EnableException
    )

    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        $monitor = Get-DpaMonitor -MonitorName $MonitorName
    }
    else {
        $monitor = Get-DpaMonitor -DatabaseId $DatabaseId
    }

    if (-not $monitor) {
        Stop-PSFFunction -Message "Monitor does not exist" -EnableException:$EnableException
        return
    }

    $request = @{
        command = 'START'
    }

    try {
        $response = Invoke-DpaRequest -Endpoint "/databases/$($monitor.Dbid)/monitor-status" -Method 'PUT' -Request $request
    }
    catch {
        Stop-PSFFunction -Message "Could not start the monitor" -ErrorRecord $_ -Target $monitor.Name
    }
}