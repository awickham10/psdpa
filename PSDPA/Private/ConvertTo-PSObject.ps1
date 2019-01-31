function ConvertTo-PSObject {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    begin {
        $properties = $json.PSObject.Properties.Name
        $textInfo = (Get-Culture).TextInfo
    }

    process {
        $newObject = @{}

        foreach ($property in $properties) {
            $newName = $textInfo.ToTitleCase($property).Replace('_', '')
            $newObject[$newName] = $InputObject.$property
        }

        [PSCustomObject] $newObject
    }
}