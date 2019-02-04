function Get-DpaAnnotation {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId')]
        $DatabaseId,

        [Parameter(ParameterSetName = 'ByName')]
        $MonitorName,

        [Parameter()]
        [DateTime] $StartTime = (Get-Date).AddDays(-30),

        [Parameter()]
        [DateTime] $EndTime = (Get-Date),

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

    $endpoint = "/databases/$($monitor.DatabaseId)/annotations"

    $parameters = @{
        'startTime' = $StartTime.ToString("yyyy-MM-ddTHH\:mm\:ss.fffzzz")
        'endTime' = $EndTime.ToString("yyyy-MM-ddTHH\:mm\:ss.fffzzz")
    }

    $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get' -Parameters $parameters
    foreach ($annotation in $response.data) {
        New-Object -TypeName 'Annotation' -ArgumentList $annotation
    }
}