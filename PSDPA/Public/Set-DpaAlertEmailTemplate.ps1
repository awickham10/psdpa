<#

.SYNOPSIS
Updates an alert e-mail template.

.DESCRIPTION
Updates an alert e-mail template with new values based on what parameters are 
supplied. For example, if Description is not provided the Description of the
alert e-mail template will not be updated.

.PARAMETER Template
The template to update.

.PARAMETER TemplateName
The template name to update.. This is the "Name" field in DPA.

.PARAMETER Description
A longer description of the alert e-mail template. This is the "Description" field in DPA.

.PARAMETER TextFormat
The format of the e-mail body (HTML or plain text). This is the "Body message format" field in DPA.

.PARAMETER Subject
The subject of the e-mail. This is the "Subject" field in DPA.

.PARAMETER Body
The body of the e-mail. This is the "Body" field in DPA.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Set-DpaAlertEmailTemplate -TemplateName 'My Custom Template' -Subject 'Oh no!'

Updates the subject on "My Custom Template" to "Oh no!"

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>
function Set-DpaAlertEmailTemplate {
    [CmdletBinding(DefaultParameterSetName = 'ByName', SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        [Parameter(ParameterSetName = 'ByObject', Mandatory)]
        [AlertEmailTemplate[]] $Template,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $TemplateName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Description,

        [Parameter()]
        [ValidateSet('HTML', 'Text')]
        [string] $TextFormat,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Subject,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Body,

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
            if ($PSCmdlet.ShouldProcess($templateObject.TemplateName, 'Update E-mail Template')) {
                $request = @{
                    'id' = $templateObject.AlertEmailTemplateId
                }
                foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
                    if ($parameter.Key -in @('TemplateName', 'Description', 'TextFormat', 'Subject', 'Body')) {
                        $parameterName = switch ($parameter.Key) {
                            'TemplateName' {
                                'name'
                            }
                            'TextFormat' {
                                'emailTextFormat'
                            }
                            default {
                                $parameter.Key.ToLower()
                            }
                        }

                        $request[$parameterName] = $parameter.Value
                    }
                }

                try {
                    $null = Invoke-DpaRequest -Endpoint "/alerts/templates/$($templateObject.AlertEmailTemplateId)" -Method 'PUT' -Request $request
                } catch {
                    Stop-PSFFunction -Message "Could not update template ($templateObject.TemplateName)" -ErrorRecord $_ -EnableException $EnableException
                }
            }
        }
    }
}