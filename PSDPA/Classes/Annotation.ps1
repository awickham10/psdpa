class Annotation {
    [int] $AnnotationId
    [string] $CreatedBy
    [string] $Type
    [string] $Title
    [string] $Description
    [Datetime] $Time

    Annotation ([PSCustomObject] $Json) {
        $this.AnnotationId = $Json.id
        $this.CreatedBy = $Json.createdBy
        $this.Type = $Json.type
        $this.Title = $Json.title
        $this.Description = $Json.description
        $this.Time = $Json.time
    }
}
