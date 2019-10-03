function Remove-DpaAlertGroupMonitor {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId', Mandatory)]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string[]] $MonitorName,

        [Parameter(ParameterSetName = 'ByMonitor', ValueFromPipeline)]
        [Monitor[]] $Monitor,

        [Parameter(Mandatory)]
        [AlertGroup] $AlertGroup,

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
        foreach ($monitorObject in $Monitor) {
            Write-PSFMessage -Level Verbose -Message "Removing Database ID $($monitorObject.DatabaseId) from Alert Group ID $($AlertGroup.AlertGroupId)"
            $endpoint = "/alert-groups/$($AlertGroup.AlertGroupId)/databases/$($monitorObject.DatabaseId)"

            try {
                $null = Invoke-DpaRequest -Endpoint $endpoint -Method 'DELETE'
            } catch {
                Stop-PSFFunction -Level Critical -Message 'Could not associate monitor to alert group' -ErrorRecord $_ -EnableException $EnableException
            }
        }
    }
}