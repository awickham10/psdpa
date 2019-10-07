<#

.SYNOPSIS
Remove an e-mail template from an alert.

.DESCRIPTION
Removes a custom e-mail template from an alert.

.PARAMETER Alert
Alert to reset.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Get-DpaAlert -AlertName 'Instance Availability' | Reset-DpaAlertTemplate

Resets the e-mail template for the "Instance Availability" alert back to the default.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Reset-DpaAlertEmailTemplate {
    [CmdletBinding(DefaultParameterSetName = 'ByObject', SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(ParameterSetName = 'ByObject', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alert[]] $Alert,

        [Parameter()]
        [switch] $EnableException
    )

    foreach ($alertObject in $Alert) {
        if ($PSCmdlet.ShouldProcess($alertObject.Name, 'Reset Alert Template')) {
            $endpoint = "/alerts/$($AlertObject.AlertId)/templates/reset"
            try {
                $null = Invoke-DpaRequest -Endpoint $endpoint -Method 'DELETE'
            } catch {
                Stop-PSFFunction -Message 'Could not reset alert template' -EnableException $EnableException -ErrorRecord $_
            }
        }
    }
}