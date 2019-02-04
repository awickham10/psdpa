class AccessToken {
    [int] $AccessTokenId
    [string] $AccessToken
    [string] $TokenType
    [int] $ExpiresIn
    [string] $UserType
    [string] $Jti

    AccessToken ([PSCustomObject] $Json) {
        $this.AccessTokenId = $Json.id
        $this.AccessToken = $Json.access_token
        $this.TokenType = $Json.token_type
        $this.ExpiresIn = $Json.expires_in
        $this.UserType = $Json.userType
        $this.Jti = $Json.jti
    }
}
