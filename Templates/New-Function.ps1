function New-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $RequiredParameter,

        [Parameter()]
        $OptionalParameter
    )
}
