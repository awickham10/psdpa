function Add-DpaAnnotation {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId', Mandatory)]
        [int] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string] $MonitorName,

        [Parameter()]
        [DateTime] $Time = (Get-Date),

        [Parameter()]
        [string] $Title,

        [Parameter(Mandatory)]
        [string] $Description,

        [Parameter()]
        [string] $CreatedBy = ([Environment]::UserName),

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

    $endpoint = "/databases/$($monitor.DbId)/annotations"

    $request = @{
        'title' = $Title
        'description' = $Description
        'createdBy' = $CreatedBy
        'time' = $Time.ToString("yyyy-MM-ddTHH\:mm\:sszzz")
    }

    Invoke-DpaRequest -Endpoint $endpoint -Method 'Post' -Request $request
}