class Annotation {
    [int] $AnnotationId
    [int] $DatabaseId
    [string] $CreatedBy
    [string] $Type
    [string] $Title
    [string] $Description
    [Datetime] $Time
    [Monitor] $Monitor

    Annotation ([PSCustomObject] $Json) {
        $this.InitializeFromJson($Json)

        $this.DatabaseId = $Json.dbId
        $this.Monitor = Get-DpaMonitor -DatabaseId $Json.DatabaseId
    }

    Annotation ([Monitor] $Monitor, [PSCustomObject] $Json) {
        $this.InitializeFromJson($Json)

        $this.DatabaseId = $Monitor.DatabaseId
        $this.Monitor = $Monitor
    }

    hidden InitializeFromJson ([PSCustomObject] $Json) {
        $this.AnnotationId = $Json.id
        $this.CreatedBy = $Json.createdBy
        $this.Type = $Json.type
        $this.Title = $Json.title
        $this.Description = $Json.description
        $this.Time = $Json.time
    }
}