function Get-DpaAnnotation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $DatabaseId,

        [Parameter()]
        $StartTime,

        [Parameter()]
        $EndTime
    )
}