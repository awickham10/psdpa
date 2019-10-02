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
function Get-DpaAlertGroup {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(ParameterSetName = 'ByAlertGroupId')]
        [int[]] $AlertGroupId,

        [Parameter(ParameterSetName = 'ByName')]
        [string[]] $AlertGroupName,

        [switch] $EnableException
    )

    process {
        $alertGroups = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByAlertGroupId') {
            foreach ($retrieveAlertGroupId in $AlertGroupId) {
                $endpoint = "/alert-groups/$retrieveAlertGroupId"

                try {
                    $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'
                    $alertGroups += New-Object -TypeName 'AlertGroup' -ArgumentList $response.data
                } catch {
                    Stop-PSFFunction -Message "Invalid AlertGroupId" -ErrorRecord $_ -EnableException $EnableException
                }
            }
        } else {
            # get all the alert groups
            $endpoint = '/alert-groups'

            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Get'
            $filteredResponses = $response.data | Where-Object { $_.name -in $AlertGroupName }
            foreach ($alertGroup in $filteredResponses) {
                $alertGroups = New-Object -TypeName 'AlertGroup' -ArgumentList $alertGroup
            }
        }

        $alertGroups
    }
}