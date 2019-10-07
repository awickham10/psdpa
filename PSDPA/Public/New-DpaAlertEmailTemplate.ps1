<#

.SYNOPSIS
Creates a new alert e-mail template.

.PARAMETER TemplateName
The name of the alert e-mail template. This is the "Name" field in DPA.

.PARAMETER Description
A longer description of the alert e-mail template. This is the "Description" field in DPA.

.PARAMETER TextFormat
The format of the e-mail body (HTML or plain text). This is the "Body message format" field in DPA.

.PARAMETER Subject
The subject of the e-mail. This is the "Subject" field in DPA.

.PARAMETER Body
The body of the e-mail. This is the "Body" field in DPA.

.PARAMETER Default
Makes the alert e-mail template the default for all unassigned alerts.

.PARAMETER Force
When Force is used, if an alert e-mail template with the name provided already
exists it will be overwritten with the new alert e-mail template.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Add-DpaAlertEmailTemplate -TemplateName 'My Custom Template' -TextFormat 'Text' -Subject 'Oh no! [=alert:alertName]' -Body 'Something went wrong with [=database.name]!'

Adds a custom e-mail template named "My Custom Template."

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function New-DpaAlertEmailTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $TemplateName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Description,

        [Parameter(Mandatory)]
        [ValidateSet('HTML', 'Text')]
        [string] $TextFormat,

        [Parameter(Mandatory)]
        [string] $Subject,

        [Parameter(Mandatory)]
        [string] $Body,

        [Parameter()]
        [switch] $Default,

        [Parameter()]
        [switch] $Force,

        [Parameter()]
        [switch] $EnableException
    )

    $endpoint = '/alerts/templates'

    if ($Force) {
        $endpoint += '?override=true'
    }

    $request = @{
        'name'            = $TemplateName
        'description'     = $Description
        'emailTextFormat' = $TextFormat
        'subject'         = $Subject
        'body'            = $Body
    }

    try {
        $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'POST' -Request $request
    } catch {
        Stop-PSFFunction -Message 'Could not add e-mail template' -ErrorRecord $_ -EnableException $EnableException
    }

    try {
        $template = New-Object -TypeName 'AlertEmailTemplate' -ArgumentList $response.data
    } catch {
        Stop-PSFFunction -Message 'Could not create e-mail template from API response' -ErrorRecord $_ -EnableException $EnableException
        return
    }

    if ($Default) {
        $endpoint = "/alerts/templates/$($template.AlertEmailTemplateId)/default"

        try {
            $null = Invoke-DpaRequest -Endpoint $endpoint -Method 'PUT'
        } catch {
            Stop-PSFFunction -Message 'Could not make the e-mail template the default' -ErrorRecord $_ -EnableException $EnableException
        }
    }

    $template
}