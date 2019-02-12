function Remove-DpaAnnotation {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param (
        [Parameter(ParameterSetName = 'ByObject', ValueFromPipeline)]
        [Annotation[]] $Annotation,

        [Parameter()]
        [switch] $EnableException
    )

    foreach ($annotationObject in $Annotation) {
        $endpoint = "databases/$($annotationObject.DatabaseId)/annotations/$($annotationObject.AnnotationId)"
        try {
            $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'Delete'
        }
        catch {
            Stop-PSFFunction -Message "Could not remove annotation" -EnableException:$EnableException -ErrorRecord $_
        }
    }
}