<#

.SYNOPSIS
Removes an annotation from DPA.

.DESCRIPTION
Takes an Annotation object and removes it from DPA.

.PARAMETER Annotation
Annotation to remove.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
Get-DpaAnnotation -MonitorName 'MyMonitoredServer' | Where-Object { $_.Title -eq 'Patching' } | Remove-DpaAnnotation

Removes any annotation with a title of "Patching" from MyMonitoredServer.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Remove-DpaAnnotation {
    [CmdletBinding(DefaultParameterSetName = 'ById', SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = 'ByObject', ValueFromPipeline)]
        [Annotation[]] $Annotation,

        [Parameter()]
        [switch] $EnableException
    )

    foreach ($annotationObject in $Annotation) {
        if ($PSCmdlet.ShouldProcess($annotationObject.Title, 'Remove Annotation')) {
            $endpoint = "databases/$($annotationObject.DatabaseId)/annotations/$($annotationObject.AnnotationId)"
            try {
                $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Delete'
            } catch {
                Stop-PSFFunction -Message "Could not remove annotation" -EnableException:$EnableException -ErrorRecord $_
            }
        }
    }
}