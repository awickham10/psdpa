class Alert {
    [int] $AlertId
    [string] $Name
    [string] $Description
    [string] $Category
    [string[]] $SupportedDbTypes
    [bool] $Enabled
    [Monitor[]] $Monitors
    
    Alert ([PSCustomObject] $Json) {
        $this.AlertId = $Json.id
        $this.Name = $Json.name
        $this.Description = $Json.description
        $this.Category = $Json.category
        $this.SupportedDbTypes = $Json.supportedDatabaseTypes
        $this.Enabled = $Json.enabled

        if ($Json.databaseIds.Count -gt 0) {
            $this.Monitors = Get-DpaMonitor -DatabaseId $Json.databaseIds
        }
    }
}