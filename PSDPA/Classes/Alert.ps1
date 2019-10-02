class Alert {
    [int] $AlertId
    [string] $Name
    [string] $Description
    [string] $Category
    [string[]] $SupportedDbTypes
    [bool] $Enabled
    
    Alert ([PSCustomObject] $Json) {
        $this.AlertId = $Json.id
        $this.Name = $Json.name
        $this.Description = $Json.description
        $this.Category = $Json.category
        $this.SupportedDbTypes = $Json.supportedDatabaseTypes
        $this.Enabled = $Json.enabled
    }
}