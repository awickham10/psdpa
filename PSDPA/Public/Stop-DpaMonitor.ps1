function Stop-DpaMonitor {
    [CmdletBinding(DefaultParameterSetName = 'ByName', SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId', Mandatory)]
        $DatabaseId,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        $MonitorName,

        [Parameter()]
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
        command = 'STOP'
    }

    if ($PSCmdlet.ShouldProcess($monitor.Name, 'Stop Monitor')) {
        try {
            $response = Invoke-DpaRequest -Endpoint "/databases/$($monitor.Dbid)/monitor-status" -Method 'PUT' -Request $request
        }
        catch {
            Stop-PSFFunction -Message "Could not stop the monitor" -ErrorRecord $_ -Target $monitor.Name
        }
    }
}