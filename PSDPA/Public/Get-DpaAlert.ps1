<#

.SYNOPSIS

.DESCRIPTION

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Get-DpaMonitor | Get-DpaAnnotation -StartTime (Get-Date).AddDays(-30)

Get all annotations over the last 30 days for all monitors

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>
function Get-DpaAlert {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByAlertId')]
        [int[]] $AlertId,

        [Parameter(ParameterSetName = 'ByName')]
        [string[]] $AlertName,

        [switch] $EnableException
    )
    
    process {
        $alerts = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByAlertId') {
            foreach ($retrieveAlertId in $AlertId) {
                $endpoint = "/alerts/$retrieveAlertId"

                try {
                    $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'
                    $alerts += New-Object -TypeName 'Alert' -ArgumentList $response.data
                } catch {
                    Stop-PSFFunction -Message "Invalid AlertId" -ErrorRecord $_ -EnableException $EnableException
                }
            }
        } else {
            # get all the alerts
            $endpoint = '/alerts'

            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'
            $filteredResponses = $response.data | Where-Object { $_.name -in $AlertName }
            foreach ($alert in $filteredResponses) {
                $alerts += New-Object -TypeName 'Alert' -ArgumentList $alert
            }

            if ($EnableException -and $alerts.Count -eq 0) {
                Stop-PSFFunction -Message 'No alerts found.' -EnableException $EnableException
            }
        }

        return $alerts
    }
}