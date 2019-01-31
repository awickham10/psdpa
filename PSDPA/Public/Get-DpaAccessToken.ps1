function Get-DpaAccessToken {
    param (
        [switch] $EnableException
    )

    $authTokenUri = (Get-DpaConfig -Name 'baseuri').Value + '/security/oauth/token'
    $refreshToken = (Get-DpaConfig -Name 'refreshtoken').Value

    $request = @{
        grant_type = 'refresh_token'
        refresh_token = $refreshToken
    }

    try {
        $response = Invoke-RestMethod -Uri $authTokenUri -Method 'POST' -Body $request
        $response.data
    }
    catch {
        Stop-PSFFunction -Message "Could not obtain access token" -ErrorRecord $_ -EnableException $EnableException
    }
}