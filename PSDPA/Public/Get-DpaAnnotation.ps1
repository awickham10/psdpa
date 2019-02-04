function Get-DpaAnnotation {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId')]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName')]
        [string[]] $MonitorName,

        [Parameter(ParameterSetName = 'ByMonitor', ValueFromPipeline)]
        [Monitor[]] $Monitor,

        [Parameter()]
        [DateTime] $StartTime = (Get-Date).AddDays(-30),

        [Parameter()]
        [DateTime] $EndTime = (Get-Date),

        [switch] $EnableException
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $Monitor = Get-DpaMonitor -MonitorName $MonitorName
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByDatabaseId') {
            $Monitor = Get-DpaMonitor -DatabaseId $DatabaseId
        }
    }

    process {
        foreach ($monitorObject in $Monitor) {
            $endpoint = "/databases/$($monitorObject.DatabaseId)/annotations"

            $parameters = @{
                'startTime' = $StartTime.ToString("yyyy-MM-ddTHH\:mm\:ss.fffzzz")
                'endTime' = $EndTime.ToString("yyyy-MM-ddTHH\:mm\:ss.fffzzz")
            }

            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get' -Parameters $parameters
            foreach ($annotation in $response.data) {
                New-Object -TypeName 'Annotation' -ArgumentList $annotation
            }
        }
    }
}