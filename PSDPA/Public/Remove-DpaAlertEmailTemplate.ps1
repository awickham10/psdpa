<#

.SYNOPSIS
Removes an alert e-mail template from DPA.

.PARAMETER Template
The template to update.

.PARAMETER TemplateName
The template name to update.. This is the "Name" field in DPA.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Remove-DpaAlertEmailTemplate -TemplateName 'My Custom Template'

Removes the "My Custom Template" alert e-mail template.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Remove-DpaAlertEmailTemplate {
    [CmdletBinding(DefaultParameterSetName = 'ByName', SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(ParameterSetName = 'ByObject', ValueFromPipeline)]
        [AlertEmailTemplate[]] $Template,

        [Parameter(ParameterSetName = 'ByName')]
        [string[]] $TemplateName,

        [Parameter()]
        [switch] $EnableException
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $Template = Get-DpaAlertEmailTemplate -TemplateName $TemplateName -EnableException:$EnableException
        }
    }

    process {
        foreach ($templateObject in $Template) {
            if ($PSCmdlet.ShouldProcess($templateObject.Name, 'Remove Alert E-mail Template')) {
                if ($Template.Alerts.Count -gt 0) {
                    Write-PSFMessage -Level 'Verbose' -Message 'Resetting alerts that use the template'
                    Reset-DpaAlertEmailTemplate -Alert $Template.Alerts
                }

                $endpoint = "alerts/templates/$($templateObject.AlertEmailTemplateId)"
                try {
                    $null = Invoke-DpaRequest -Endpoint $endpoint -Method 'DELETE'
                } catch {
                    Stop-PSFFunction -Message 'Could not remove alert e-mail template' -EnableException $EnableException -ErrorRecord $_
                }
            }
        }
    }
}