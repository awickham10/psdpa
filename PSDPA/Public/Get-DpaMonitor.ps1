function Get-DpaMonitor {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId')]
        [ValidateNotNullOrEmpty()]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName')]
        [ValidateNotNullOrEmpty()]
        [string[]] $MonitorName,

        [Parameter()]
        [switch] $EnableException
    )

    if ($PSBoundParameters.ContainsKey('DatabaseId') -and $DatabaseId.Count -eq 1) {
        Write-PSFMessage -Level Verbose -Message 'Getting a single monitor'
        $endpoint = "/databases/$DatabaseId/monitor-information"
    }
    else {
        Write-PSFMessage -Level Verbose -Message 'Getting all monitors'
        $endpoint = '/databases/monitor-information'
    }

    try {
        $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'
        $monitors = $response.data
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 422) {
            return $null
        }

        Stop-PSFFunction -Message 'Could not retrieve monitor information' -ErrorRecord $_ -EnableException:$EnableException
    }

    if ($PSBoundParameters.ContainsKey('DatabaseId') -and $DatabaseId -is [array]) {
        $monitors = $monitors | Where-Object { $_.dbid -in $DatabaseId }
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'ByName') {
        $monitors = $monitors | Where-Object { $_.name -in $MonitorName }
    }

    $monitorFactory = New-Object MonitorFactory
    foreach ($monitor in $monitors) {
        $monitorFactory.New($monitor)
    }
}
