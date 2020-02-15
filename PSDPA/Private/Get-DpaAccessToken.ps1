function Get-DpaAccessToken {
    param (
        [switch] $EnableException
    )

    $authTokenUri = (Get-DpaConfig -Name 'baseuri').Value + '/security/oauth/token'
    $refreshToken = (Get-DpaConfig -Name 'refreshtoken').Value

    $request = @{
        grant_type    = 'refresh_token'
        refresh_token = $refreshToken
    }

    try {
        Write-PSFMessage -Level 'Verbose' -Message 'Getting an access token'

        $response = Invoke-RestMethod -Uri $authTokenUri -Method 'POST' -Body $request
        $accessToken = New-Object -TypeName 'AccessToken' -ArgumentList $response

        Set-PSFConfig -Module 'psdpa' -Name 'accesstoken' -Value $accessToken
        $PSDefaultParameterValues['Invoke-DpaRequest:AccessToken'] = $accessToken

        $accessToken
    } catch {
        if ($_.ErrorDetails.Message) {
            $errorJson = $_.ErrorDetails.Message | ConvertFrom-Json
            $message = "$($errorJson.messages.reason) ($($errorJson.messages.code))"
        } else {
            $message = 'Could not obtain access token'
        }

        Stop-PSFFunction -Message $message -ErrorRecord $_ -EnableException $EnableException
    }
}