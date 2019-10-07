<#

.SYNOPSIS
Updates an alert definition.

.PARAMETER Alert
The alert object(s).

.PARAMETER AlertName
Name of the alert.

.PARAMETER TemplateName
The name of the template to use.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Set-DpaAlert -AlertName 'Instance Availability' -TemplateName 'My Custom Alert Template'

Updates the "Instance Availability" alert to use the "My Custom Alert Template" e-mail template.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>
function Set-DpaAlert {
    [CmdletBinding(DefaultParameterSetName = 'ByNameTemplateName', SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        [Parameter(ParameterSetName = 'ByObjectTemplateDefault', Mandatory)]
        [Parameter(ParameterSetName = 'ByObjectTemplateName', Mandatory)]
        [Alert[]] $Alert,

        [Parameter(ParameterSetName = 'ByNameTemplateDefault', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameTemplateName', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $AlertName,

        [Parameter(ParameterSetName = 'ByNameTemplateName', Mandatory)]
        [Parameter(ParameterSetName = 'ByObjectTemplateName', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $AlertEmailTemplateName,

        [Parameter(ParameterSetName = 'ByNameTemplateDefault', Mandatory)]
        [Parameter(ParameterSetName = 'ByObjectTemplateDefault', Mandatory)]
        [switch] $UseDefaultAlertEmailTemplate,

        [Parameter()]
        [switch] $EnableException
    )

    begin {
        if ($PSCmdlet.ParameterSetName -like 'ByName*') {
            $Alert = Get-DpaAlert -AlertName $AlertName -EnableException:$EnableException
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -like '*TemplateName') {
            $template = Get-DpaAlertEmailTemplate -TemplateName $AlertEmailTemplateName -EnableException:$EnableException

            foreach ($alertObject in $Alert) {
                if ($PSCmdlet.ShouldProcess($alertObject.Name, 'Update Alert')) {
                    try {
                        $null = Invoke-DpaRequest -Endpoint "/alerts/$($alertObject.AlertId)/templates/$($template.AlertEmailTemplateId)" -Method 'POST'
                    } catch {
                        Stop-PSFFunction -Message "Could not update alert ($alertObject.Name)" -ErrorRecord $_ -EnableException $EnableException
                    }
                }
            }
        } elseif ($PSCmdlet.ParameterSetName -like '*TemplateDefault') {
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
}