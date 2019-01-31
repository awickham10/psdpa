function Add-DpaAnnotation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $DatabaseId,

        [Parameter()]
        $Time,

        [Parameter(Mandatory)]
        $Description,

        [Parameter()]
        $CreatedBy
    )
}