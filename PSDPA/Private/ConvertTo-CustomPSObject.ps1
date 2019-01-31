function ConvertTo-CustomPSObject {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [PSCustomObject] $InputObject
    )

    process {
        $properties = $InputObject.PSObject.Properties.Name
        $textInfo = (Get-Culture).TextInfo

        $newObject = @{}

        foreach ($property in $properties) {
            $newName = $textInfo.ToTitleCase($property).Replace('_', '')
            $newObject[$newName] = $InputObject.$property
        }

        [PSCustomObject] $newObject
    }
}