<#

.SYNOPSIS
Retrieve alert e-mail templates.

.DESCRIPTION
Gets the e-mail templates for alerts.

.PARAMETER TemplateName
Name of the template.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Get-DpaAlertEmailTemplate

Gets all alert e-mail templates

.EXAMPLE
Get-DpaAlertEmailTemplate -TemplateName 'My Custom Template'

Gets the "My Custom Template" alert e-mail template

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>
function Get-DpaAlertEmailTemplate {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string[]] $TemplateName,

        [Parameter()]
        [switch] $EnableException
    )

    $endpoint = '/alerts/templates?require=alert-assignments'

    try {
        $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'GET'
        $templates = $response.data
    } catch {
        Stop-PSFFunction -Message 'Could not retrieve alert e-mail templates' -ErrorRecord $_ -EnableException $EnableException
    }

    if (Test-PSFParameterBinding -ParameterName 'TemplateName') {
        $templates = $templates | Where-Object { $_.name -in $TemplateName }
    }
    
    foreach ($emailTemplate in $templates) {
        $emailTemplate | ogv
        New-Object -TypeName 'AlertEmailTemplate' -ArgumentList $emailTemplate
    }
}