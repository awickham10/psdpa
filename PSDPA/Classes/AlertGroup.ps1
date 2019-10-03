class AlertGroup {
    [int] $AlertGroupId
    [string] $Name
    [string] $Description
    [Alert[]] $Alerts
    [Monitor[]] $Monitors
    
    AlertGroup ([PSCustomObject] $Json) {
        $this.AlertGroupId = $Json.id
        $this.Name = $Json.name
        $this.Description = $Json.description

        if ($Json.alertIds.Count -gt 0) {
            $this.Alerts = Get-DpaAlert -AlertId $Json.alertIds
        }
        
        if ($Json.databaseIds.Count -gt 0) {
            $this.Monitors = Get-DpaMonitor -DatabaseId $Json.databaseIds
        }
    }
}