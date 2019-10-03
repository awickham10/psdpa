class AlertGroup {
    [int] $AlertGroupId
    [string] $Name
    [string] $Description
    [Alert[]] $Alerts

    #[Monitor[]] $Monitors
    
    AlertGroup ([PSCustomObject] $Json) {
        $this.AlertGroupId = $Json.id
        $this.Name = $Json.name
        $this.Description = $Json.description
        $this.Alerts = Get-DpaAlert -AlertId $Json.alertIds
    }
}