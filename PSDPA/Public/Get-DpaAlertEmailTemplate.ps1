<#

.SYNOPSIS
Retrieve alert e-mail templates.

.DESCRIPTION
Gets the e-mail templates for alerts.

.PARAMETER TemplateId
ID of the template.

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
        [Parameter(ParameterSetName = 'ById', Mandatory)]
        [int[]] $TemplateId,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $TemplateName,

        [Parameter()]
        [switch] $EnableException
    )

    process {
        $templates = @()

        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            foreach ($retrieveTemplateId in $TemplateId) {
                $endpoint = "/alerts/templates/$($retrieveTemplateId)?require=alert-assignments"

                try {
                    $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'GET'
                    $templates += New-Object -TypeName 'AlertEmailTemplate' -ArgumentList $response.data
                } catch {
                    Stop-PSFFunction -Message 'Invalid TemplateId' -ErrorRecord $_ -EnableException $EnableException
                }
            }
        } else {
            $endpoint = '/alerts/templates?require=alert-assignments'

            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'GET'

            # filter by name if applicable
            if (Test-PSFParameterBinding -ParameterName 'TemplateName') {
                $response = $response.data | Where-Object { $_.name -in $TemplateName }
            } else {
                $response = $response.data
            }

            foreach ($emailTemplate in $response) {
                New-Object -TypeName 'AlertEmailTemplate' -ArgumentList $emailTemplate
            }
        }

        $templates
    }
}