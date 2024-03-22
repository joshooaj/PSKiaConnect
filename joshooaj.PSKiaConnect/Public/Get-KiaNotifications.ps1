function Get-KiaNotifications {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [string[]]
        $VehicleKey
    )

    process {
        if ($VehicleKey.Count -eq 0) {
            $VehicleKey = (Get-KiaVehicleSummary).VehicleKey
        }

        foreach ($vinKey in $VehicleKey) {
            $irm = @{
                WebSession = $script:kia_session
                Method  = 'Post'
                Uri     = 'https://owners.kia.com/apps/services/owners/apigwServlet.html'
                Headers = [ordered]@{
                    'User-Agent'      = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/113.0'
                    'Accept'          = 'application/json, text/plain, */*'
                    'Accept-Language' = 'en-US,en;q=0.5'
                    'Accept-Encoding' = 'gzip, deflate, br'
                    'Content-Type'    = 'application/json'
                    'CSRF-Token'      = 'undefined'
                    'dateStr'         = Get-Date -Format 'r'
                    'offset'          = [datetimeoffset]::Now.Offset.TotalHours
                    'vinkey'          = $VinKey
                    'httpMethod'      = 'POST'
                    'apiURL'          = '/notify/gurn'
                    'serviceType'     = 'postLoginVehicle'
                    'Origin'          = 'https://owners.kia.com'
                    'Connection'      = 'keep-alive'
                    'Referer'         = 'https://owners.kia.com/content/owners/en/dashboard.html/'
                    'Sec-Fetch-Dest'  = 'empty'
                    'Sec-Fetch-Mode'  = 'cors'
                    'Sec-Fetch-Site'  = 'same-origin'
                    'Sec-GPC'         = '1'
                }
                Body    = [ordered]@{
                    status   = ''
                } | ConvertTo-Json -Compress
            }
            $response = HandleKiaRequest $irm
            $response
        }

        # foreach ($vehicle in $response.Payload.VehicleSummary -as [VehicleSummary[]]) {
        #     $script:vehicleSummaries.Add($vehicle)
        # }
    }
}
