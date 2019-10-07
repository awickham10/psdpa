class MonitorAlert : Alert {
    [string] $Status

    MonitorAlert ([PSCustomObject] $AlertJson, $Status) : base ($AlertJson) {
        $this.Status = $Status
    }
}
