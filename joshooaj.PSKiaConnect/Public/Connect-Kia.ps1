function Connect-Kia {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [pscredential]
        $Credential
    )

    process {
        $irm = @{
            Method  = 'Post'
            Uri     = 'https://owners.kia.com/apps/services/owners/apiGateway'
            Headers = @{
                'Accept'          = 'application/json, text/plain, */*'
                'Accept-Language' = 'en-US,en;q=0.5'
                'Accept-Encoding' = 'gzip, deflate, br'
                'Content-Type'    = 'application/x-www-form-urlencoded'
                'CSRF-Token'      = 'undefined'
                'Origin'          = 'https://owners.kia.com'
                'Connection'      = 'keep-alive'
                'Referer'         = 'https://owners.kia.com/us/en/about-uvo-link.html'
                'Sec-Fetch-Dest'  = 'empty'
                'Sec-Fetch-Mode'  = 'cors'
                'Sec-Fetch-Site'  = 'same-origin'
                'Sec-GPC'         = '1'
            }
            Body    = [ordered]@{
                userId   = $Credential.UserName
                password = $Credential.GetNetworkCredential().Password
                userType = '0'
                action   = 'authenticateUser'
            } | ConvertTo-Json -Compress
            WebSession = $script:kia_session
        }

        $response = HandleKiaRequest $irm

        foreach ($vehicle in $response.Payload.VehicleSummary -as [VehicleSummary[]]) {
            $script:vehicleSummaries.Add($vehicle)
        }
    }
}
