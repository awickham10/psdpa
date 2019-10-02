class AlertGroup {
    [int] $AlertGroupId
    [string] $Name
    [string] $Description
    
    #[Monitor[]] $Monitors
    #[Alert[]] $Alerts

    AlertGroup ([PSCustomObject] $Json) {
        $this.AlertGroupId = $Json.id
        $this.Name = $Json.name
        $this.Description = $Json.description
    }
}