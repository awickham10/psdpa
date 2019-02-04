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
        $accessToken = New-Object -TypeName 'AccessToken' -ArgumentList $response

        Set-PSFConfig -Module 'psdpa' -Name 'accesstoken' -Value $accessToken
        $PSDefaultParameterValues['Invoke-DpaRequest:AccessToken'] = $accessToken
        return $accessToken
    }
    catch {
        Stop-PSFFunction -Message "Could not obtain access token" -ErrorRecord $_ -EnableException $EnableException
    }
}