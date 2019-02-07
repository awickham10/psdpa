class License {
    [string] $Product
    [string] $Category
    [int] $Available
    [int] $Consumed

    License ([PSCustomObject] $Json) {
        $this.Product = $Json.licenseProduct
        $this.Category = $Json.licenseCategory
        $this.Available = $Json.licensesAvailable
        $this.Consumed = $Json.licensesConsumed

        $this | Add-Member -Name Total -MemberType ScriptProperty -Value {
            return ($this.Available + $this.Consumed)
        }
    }
}