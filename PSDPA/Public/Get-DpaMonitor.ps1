<#

.SYNOPSIS
Gets a DPA monitor (server)

.DESCRIPTION
Gets a registered server (monitor) from DPA. This can be done by name or ID.

.PARAMETER DatabaseId
Database ID of the monitor (db_id in the URL).

.PARAMETER MonitorName
Name of the monitor.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Get-DpaMonitor -DatabaseId 1

Gets the information for db_id = 1

.EXAMPLE
Get-DpaMonitor -MonitorName 'MyMonitoredServer'

Gets the information for MyMonitoredServer

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Get-DpaMonitor {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId')]
        [ValidateNotNullOrEmpty()]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName')]
        [ValidateNotNullOrEmpty()]
        [string[]] $MonitorName,

        [Parameter(ParameterSetName = 'Pipeline', ValueFromPipeline)]
        [object[]] $InputObject,

        [Parameter()]
        [switch] $EnableException
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Pipeline') {
            foreach ($iObject in $InputObject) {
                switch ($iObject.GetType().Name) {
                    'AlertGroup' {
                        $iObject.Monitors
                    }
                }
            }
        } else {
            if ($PSBoundParameters.ContainsKey('DatabaseId') -and $DatabaseId.Count -eq 1) {
                Write-PSFMessage -Level Verbose -Message 'Getting a single monitor'
                $endpoint = "/databases/$DatabaseId/monitor-information"
            } else {
                Write-PSFMessage -Level Verbose -Message 'Getting all monitors'
                $endpoint = '/databases/monitor-information'
            }
        
            try {
                $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'
                $monitors = $response.data
            } catch {
                if ($_.Exception.Response.StatusCode.value__ -eq 422) {
                    return $null
                }
        
                Stop-PSFFunction -Message 'Could not retrieve monitor information' -ErrorRecord $_ -EnableException:$EnableException
            }
        
            if ($PSBoundParameters.ContainsKey('DatabaseId') -and $DatabaseId -is [array]) {
                $monitors = $monitors | Where-Object { $_.dbid -in $DatabaseId }
            } elseif ($PSCmdlet.ParameterSetName -eq 'ByName') {
                $monitors = $monitors | Where-Object { $_.name -in $MonitorName }
            }
        
            $monitorFactory = New-Object MonitorFactory
            foreach ($monitor in $monitors) {
                $monitorFactory.New($monitor)
            }
        }
    }
}