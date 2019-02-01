function Get-DpaMonitor {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId')]
        [ValidateNotNullOrEmpty()]
        $DatabaseId,

        [Parameter(ParameterSetName = 'ByName')]
        [ValidateNotNullOrEmpty()]
        [string[]] $MonitorName,

        [Parameter()]
        [switch] $EnableException
    )

    if ($PSBoundParameters.ContainsKey('DatabaseId') -and -not ($DatabaseId -is [array])) {
        Write-PSFMessage -Level Verbose -Message 'Getting a single monitor'
        $endpoint = "/databases/$DatabaseId/monitor-information"
    }
    else {
        Write-PSFMessage -Level Verbose -Message 'Getting all monitors'
        $endpoint = '/databases/monitor-information'
    }

    try {
        $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'

        if ($PSBoundParameters.ContainsKey('DatabaseId') -and $DatabaseId -is [array]) {
            $response | Where-Object { $_.DbId -in $DatabaseId }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $response | Where-Object { $_.Name -in $MonitorName }
        }
        else {
            $response
        }
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 422) {
            return $null
        }

        Stop-PSFFunction -Message 'Could not retrieve monitor information' -ErrorRecord $_ -EnableException:$EnableException
    }
}
