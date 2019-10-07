class AlertEmailTemplate {
    [int] $AlertEmailTemplateId
    [string] $Name
    [string] $Description
    [string] $EmailTextFormat
    [string] $Subject
    [string] $Body
    [Alert[]] $Alerts
    
    AlertEmailTemplate ([PSCustomObject] $Json) {
        $this.AlertEmailTemplateId = $Json.id
        $this.Name = $json.name
        $this.Description = $Json.description
        $this.EmailTextFormat = $Json.emailTextFormat
        $this.Subject = $Json.subject
        $this.Body = $Json.body

        if ($Json.alerts.Count -gt 0) {
            $this.Alerts = Get-DpaAlert -AlertId $Json.alerts.alertId
        }
    }
}