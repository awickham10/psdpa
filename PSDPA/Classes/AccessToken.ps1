class AccessToken {
    [int] $AccessTokenId
    [string] $AccessToken
    [string] $TokenType
    [int] $ExpiresIn
    [string] $UserType
    [string] $Jti
    [DateTime] $Expiration

    AccessToken ([PSCustomObject] $Json) {
        $this.AccessTokenId = $Json.id
        $this.AccessToken = $Json.access_token
        $this.TokenType = $Json.token_type
        $this.ExpiresIn = $Json.expires_in
        $this.UserType = $Json.userType
        $this.Jti = $Json.jti
        $this.Expiration = (Get-Date).AddDays($this.ExpiresIn)
    }

    [string] ToAuthorizationHeader() {
        return "$($this.TokenType) $($this.AccessToken)"
    }

    [bool] IsValid() {
        return `
            (Get-Date) -lt $this.Expiration -and
            $null -ne $this.AccessToken -and
            $null -ne $this.TokenType
    }
}
